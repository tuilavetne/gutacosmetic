import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../shared/models/models.dart';
import '../../data/manager_repository.dart';
import 'stock_health.dart';

/// Làm mới mọi dữ liệu kho sau một thao tác nhập/ghi giảm/sửa HSD.
void invalidateStock(WidgetRef ref) => ref
  ..invalidate(managerStockProvider)
  ..invalidate(managerReceiptsProvider)
  ..invalidate(managerAdjustmentsProvider)
  ..invalidate(managerRestockRequestsProvider)
  ..invalidate(managerReturnRequestsProvider)
  ..invalidate(managerIncomingTransfersProvider);

/// Chọn một sản phẩm trong kho chi nhánh (tìm theo tên/SKU).
Future<StockRow?> pickStockRow(BuildContext context, List<StockRow> rows) {
  return showModalBottomSheet<StockRow>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ProductPicker(rows: rows),
  );
}

class _ProductPicker extends StatefulWidget {
  const _ProductPicker({required this.rows});

  final List<StockRow> rows;

  @override
  State<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends State<_ProductPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final rows = widget.rows
        .where(
          (r) =>
              q.isEmpty ||
              r.product.name.toLowerCase().contains(q) ||
              r.product.sku.toLowerCase().contains(q),
        )
        .toList();

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Tìm theo tên hoặc SKU',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final row = rows[index];
                  return ListTile(
                    title: Text(row.product.name),
                    subtitle: Text(
                      'SKU ${row.product.sku} • khả dụng ${row.stock.availableStock}',
                    ),
                    onTap: () => Navigator.of(context).pop(row),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ô chọn sản phẩm dùng trong các hộp thoại kho.
class _ProductField extends StatelessWidget {
  const _ProductField({
    required this.row,
    required this.rows,
    required this.onChanged,
    required this.locked,
  });

  final StockRow? row;
  final List<StockRow> rows;
  final ValueChanged<StockRow> onChanged;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final current = row;
    return InkWell(
      onTap: locked
          ? null
          : () async {
              final picked = await pickStockRow(context, rows);
              if (picked != null) onChanged(picked);
            },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Sản phẩm',
          border: const OutlineInputBorder(),
          suffixIcon: locked ? null : const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          current == null
              ? 'Chọn sản phẩm'
              : '${current.product.name}\nKhả dụng ${current.stock.availableStock} • '
                    'tổng ${current.stock.totalStock}',
          style: TextStyle(color: current == null ? AppColors.muted : null),
        ),
      ),
    );
  }
}

class _QuantityField extends StatelessWidget {
  const _QuantityField({
    required this.controller,
    required this.max,
    required this.onChanged,
    this.fieldKey,
  });

  final TextEditingController controller;
  final int max;
  final VoidCallback onChanged;
  final Key? fieldKey;

  int? get value {
    final v = int.tryParse(controller.text.trim());
    return v == null || v < 1 || v > max ? null : v;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: fieldKey,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        labelText: 'Số lượng',
        helperText: 'Từ 1 đến $max',
        errorText: controller.text.isNotEmpty && value == null
            ? 'Số lượng phải từ 1 đến $max'
            : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

Future<DateTime?> _pickDate(
  BuildContext context, {
  DateTime? initial,
  bool allowPast = false,
}) {
  final today = DateUtils.dateOnly(DateTime.now());
  final first = allowPast ? DateTime(today.year - 5) : today;
  final init = initial ?? today.add(const Duration(days: 365));
  return showDatePicker(
    context: context,
    initialDate: init.isBefore(first) ? first : init,
    firstDate: first,
    lastDate: DateTime(today.year + 10),
    helpText: 'Chọn hạn sử dụng',
  );
}

// ---------------------------------------------------------------------------
// Phiếu nhập trực tiếp
// ---------------------------------------------------------------------------

class ReceiptDialog extends ConsumerStatefulWidget {
  const ReceiptDialog({super.key, required this.rows, this.initial});

  final List<StockRow> rows;
  final StockRow? initial;

  /// `true` khi đã tạo phiếu.
  static Future<bool> show(
    BuildContext context, {
    required List<StockRow> rows,
    StockRow? initial,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => ReceiptDialog(rows: rows, initial: initial),
      ) ??
      false;

  @override
  ConsumerState<ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends ConsumerState<ReceiptDialog> {
  late StockRow? _row = widget.initial;
  final _quantity = TextEditingController();
  final _note = TextEditingController();
  DateTime? _expiry;
  bool _saving = false;

  @override
  void dispose() {
    _quantity.dispose();
    _note.dispose();
    super.dispose();
  }

  int? get _qty {
    final v = int.tryParse(_quantity.text.trim());
    return v == null || v < 1 || v > AppConstants.maxReceiveQuantity ? null : v;
  }

  Future<void> _save() async {
    final row = _row;
    final qty = _qty;
    if (row == null || qty == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(managerRepositoryProvider)
          .createReceipt(
            productId: row.product.id,
            quantity: qty,
            expiryDate: _expiry,
            note: _note.text,
          );
      invalidateStock(ref);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showAppSnackBar('Đã nhập $qty ${row.product.name} vào kho.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar(
        'Không tạo được phiếu nhập: ${errorMessageOf(e)}',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Phiếu nhập kho'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProductField(
              row: _row,
              rows: widget.rows,
              locked: widget.initial != null,
              onChanged: (r) => setState(() => _row = r),
            ),
            const SizedBox(height: 12),
            _QuantityField(
              fieldKey: const ValueKey('receipt-quantity'),
              controller: _quantity,
              max: AppConstants.maxReceiveQuantity,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.event_outlined),
              label: Text(
                _expiry == null
                    ? 'Hạn sử dụng (không bắt buộc)'
                    : 'HSD: ${formatDate(_expiry)}',
              ),
              onPressed: _saving
                  ? null
                  : () async {
                      final picked = await _pickDate(context, initial: _expiry);
                      if (picked != null) setState(() => _expiry = picked);
                    },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (không bắt buộc)',
                hintText: 'Ví dụ: nhà cung cấp, số hóa đơn',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Đóng'),
        ),
        FilledButton(
          onPressed: _row == null || _qty == null || _saving ? null : _save,
          child: const Text('Nhập kho'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Ghi giảm kho
// ---------------------------------------------------------------------------

class AdjustmentDialog extends ConsumerStatefulWidget {
  const AdjustmentDialog({super.key, required this.rows, this.initial});

  final List<StockRow> rows;
  final StockRow? initial;

  static Future<bool> show(
    BuildContext context, {
    required List<StockRow> rows,
    StockRow? initial,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => AdjustmentDialog(rows: rows, initial: initial),
      ) ??
      false;

  @override
  ConsumerState<AdjustmentDialog> createState() => _AdjustmentDialogState();
}

class _AdjustmentDialogState extends ConsumerState<AdjustmentDialog> {
  late StockRow? _row = widget.initial;
  AdjustmentType _type = AdjustmentType.damaged;
  final _quantity = TextEditingController();
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _quantity.dispose();
    _note.dispose();
    super.dispose();
  }

  int get _max => _row?.stock.availableStock ?? 0;

  int? get _qty {
    final v = int.tryParse(_quantity.text.trim());
    return v == null || v < 1 || v > _max ? null : v;
  }

  Future<void> _save() async {
    final row = _row;
    final qty = _qty;
    if (row == null || qty == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(managerRepositoryProvider)
          .createAdjustment(
            productId: row.product.id,
            type: _type,
            quantity: qty,
            note: _note.text,
          );
      invalidateStock(ref);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showAppSnackBar('Đã ghi giảm $qty ${row.product.name} (${_type.label}).');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar(
        'Không ghi giảm được: ${errorMessageOf(e)}',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ghi giảm kho'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProductField(
              row: _row,
              rows: widget.rows,
              locked: widget.initial != null,
              onChanged: (r) => setState(() => _row = r),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final type in AdjustmentType.values)
                  ChoiceChip(
                    label: Text(type.label),
                    selected: type == _type,
                    onSelected: (_) => setState(() => _type = type),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_row != null && _max <= 0)
              const Text(
                'Không còn hàng khả dụng để ghi giảm (hàng đang giữ cho đơn '
                'không được ghi giảm).',
                style: TextStyle(color: AppColors.accent),
              )
            else
              _QuantityField(
                fieldKey: const ValueKey('adjustment-quantity'),
                controller: _quantity,
                max: _max < 1 ? 1 : _max,
                onChanged: () => setState(() {}),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                hintText: 'Ví dụ: vỡ chai khi vận chuyển',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Đóng'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
          onPressed: _row == null || _qty == null || _saving ? null : _save,
          child: const Text('Ghi giảm'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sửa HSD
// ---------------------------------------------------------------------------

class ExpiryDialog extends ConsumerStatefulWidget {
  const ExpiryDialog({super.key, required this.row});

  final StockRow row;

  static Future<bool> show(BuildContext context, StockRow row) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => ExpiryDialog(row: row),
      ) ??
      false;

  @override
  ConsumerState<ExpiryDialog> createState() => _ExpiryDialogState();
}

class _ExpiryDialogState extends ConsumerState<ExpiryDialog> {
  late DateTime? _expiry = widget.row.stock.expiryDate;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(managerRepositoryProvider)
          .updateExpiry(widget.row.product.id, _expiry);
      invalidateStock(ref);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showAppSnackBar(
        _expiry == null
            ? 'Đã bỏ theo dõi HSD của ${widget.row.product.name}.'
            : 'Đã cập nhật HSD ${formatDate(_expiry)}.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar(
        'Không cập nhật được HSD: ${errorMessageOf(e)}',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hạn sử dụng'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.row.product.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Kho lưu HSD gần nhất của các lô đang còn. Khi lô cũ đã bán hết, '
            'cập nhật sang HSD của lô còn lại.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.event_outlined),
            label: Text(
              _expiry == null
                  ? 'Chưa theo dõi HSD'
                  : 'HSD: ${formatDate(_expiry)}',
            ),
            onPressed: _saving
                ? null
                : () async {
                    final picked = await _pickDate(
                      context,
                      initial: _expiry,
                      allowPast: true,
                    );
                    if (picked != null) setState(() => _expiry = picked);
                  },
          ),
          if (_expiry != null)
            TextButton(
              onPressed: _saving ? null : () => setState(() => _expiry = null),
              child: const Text('Bỏ theo dõi HSD'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Đóng'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Chuyển đề xuất của Sales lên Owner
// ---------------------------------------------------------------------------

class RestockForwardDialog extends ConsumerStatefulWidget {
  const RestockForwardDialog({super.key, required this.request});

  final RestockRequest request;

  static Future<bool> show(
    BuildContext context,
    RestockRequest request,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => RestockForwardDialog(request: request),
      ) ??
      false;

  @override
  ConsumerState<RestockForwardDialog> createState() =>
      _RestockForwardDialogState();
}

class _RestockForwardDialogState extends ConsumerState<RestockForwardDialog> {
  late final _quantity = TextEditingController(
    text: '${widget.request.requestedQuantity}',
  );
  final _note = TextEditingController();
  bool _saving = false;

  static const _max = AppConstants.maxReceiveQuantity;

  int? get _qty {
    final v = int.tryParse(_quantity.text.trim());
    return v == null || v < 1 || v > _max ? null : v;
  }

  @override
  void dispose() {
    _quantity.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final qty = _qty;
    if (qty == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(managerRepositoryProvider)
          .forwardRestock(widget.request.id, quantity: qty, note: _note.text);
      invalidateStock(ref);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showAppSnackBar('Đã chuyển đề xuất $qty sp lên Owner duyệt.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar('Không chuyển được: ${errorMessageOf(e)}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    return AlertDialog(
      title: const Text('Chuyển đề xuất lên Owner'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              request.productId?.data?.name ?? 'Sản phẩm',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Sales đề xuất ${request.requestedQuantity} sp. Owner duyệt sẽ '
              'tạo phiếu chuyển hàng tới chi nhánh.',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            _QuantityField(
              fieldKey: const ValueKey('restock-forward-quantity'),
              controller: _quantity,
              max: _max,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'Ghi chú cho Owner (không bắt buộc)',
                hintText: 'Ví dụ: sản phẩm bán chạy, cần trước cuối tuần',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Đóng'),
        ),
        FilledButton(
          onPressed: _qty == null || _saving ? null : _save,
          child: const Text('Chuyển lên Owner'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Yêu cầu trả hàng lỗi
// ---------------------------------------------------------------------------

class ReturnRequestDialog extends ConsumerStatefulWidget {
  const ReturnRequestDialog({super.key, required this.rows});

  final List<StockRow> rows;

  static Future<bool> show(
    BuildContext context, {
    required List<StockRow> rows,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => ReturnRequestDialog(rows: rows),
      ) ??
      false;

  @override
  ConsumerState<ReturnRequestDialog> createState() =>
      _ReturnRequestDialogState();
}

class _ReturnRequestDialogState extends ConsumerState<ReturnRequestDialog> {
  StockRow? _row;
  ReturnReasonType _reason = ReturnReasonType.defective;
  final _quantity = TextEditingController();
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _quantity.dispose();
    _note.dispose();
    super.dispose();
  }

  int get _max => _row?.stock.availableStock ?? 0;

  int? get _qty {
    final v = int.tryParse(_quantity.text.trim());
    return v == null || v < 1 || v > _max ? null : v;
  }

  Future<void> _save() async {
    final row = _row;
    final qty = _qty;
    if (row == null || qty == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(managerRepositoryProvider)
          .createReturnRequest(
            productId: row.product.id,
            quantity: qty,
            reason: _reason,
            note: _note.text,
          );
      invalidateStock(ref);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showAppSnackBar(
        'Đã gửi yêu cầu trả $qty ${row.product.name}. Hàng được khóa tới khi '
        'Owner duyệt.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar(
        'Không gửi được yêu cầu: ${errorMessageOf(e)}',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yêu cầu trả hàng lỗi'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProductField(
              row: _row,
              rows: widget.rows,
              locked: false,
              onChanged: (r) => setState(() => _row = r),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final reason in ReturnReasonType.values)
                  ChoiceChip(
                    label: Text(reason.label),
                    selected: reason == _reason,
                    onSelected: (_) => setState(() => _reason = reason),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _QuantityField(
              fieldKey: const ValueKey('return-quantity'),
              controller: _quantity,
              max: _max < 1 ? 1 : _max,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 4),
            const Text(
              'Số hàng này sẽ bị khóa (không bán được) tới khi Owner duyệt. '
              'Owner từ chối thì hàng trở lại bán được.',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'Mô tả lỗi',
                hintText: 'Ví dụ: vòi xịt bị hỏng cả lô',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Đóng'),
        ),
        FilledButton(
          onPressed: _row == null || _qty == null || _saving ? null : _save,
          child: const Text('Gửi yêu cầu'),
        ),
      ],
    );
  }
}
