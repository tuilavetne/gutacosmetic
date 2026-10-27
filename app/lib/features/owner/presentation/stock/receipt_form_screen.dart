import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../shared/models/models.dart';
import '../../data/owner_repository.dart';

class _Line {
  _Line(this.product, {int quantity = 1})
    : quantity = TextEditingController(text: '$quantity');

  final Product product;
  final TextEditingController quantity;
  DateTime? expiry;

  int? get qty {
    final v = int.tryParse(quantity.text.trim());
    return v == null || v < 1 || v > AppConstants.maxReceiveQuantity ? null : v;
  }
}

/// Owner nhập hàng từ nhà cung cấp vào kho tổng (nhiều sản phẩm, mỗi dòng
/// một phiếu nhập kèm HSD lô). [product] / [quantity] điền sẵn khi mở từ hộp
/// duyệt đề xuất nhập lúc kho tổng thiếu hàng. Trả về `true` nếu đã nhập.
class ReceiptFormScreen extends ConsumerStatefulWidget {
  const ReceiptFormScreen({super.key, this.product, this.quantity});

  final Product? product;
  final int? quantity;

  @override
  ConsumerState<ReceiptFormScreen> createState() => _ReceiptFormScreenState();
}

class _ReceiptFormScreenState extends ConsumerState<ReceiptFormScreen> {
  late final _lines = <_Line>[
    if (widget.product case final product?)
      _Line(product, quantity: widget.quantity ?? 1),
  ];
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    for (final line in _lines) {
      line.quantity.dispose();
    }
    _note.dispose();
    super.dispose();
  }

  Future<void> _addProduct(List<Product> products, Store central) async {
    final taken = {for (final line in _lines) line.product.id};
    final picked = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProductPicker(
        candidates: products
            .where((p) => p.isActive && !taken.contains(p.id))
            .toList(),
        central: central,
      ),
    );
    if (picked == null) return;
    setState(() => _lines.add(_Line(picked)));
  }

  void _removeLine(_Line line) {
    setState(() => _lines.remove(line));
    line.quantity.dispose();
  }

  Future<void> _pickExpiry(_Line line) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: line.expiry ?? today.add(const Duration(days: 365)),
      firstDate: today,
      lastDate: DateTime(today.year + 10),
      helpText: 'Chọn hạn sử dụng của lô',
    );
    if (picked != null) setState(() => line.expiry = picked);
  }

  /// Mỗi sản phẩm là một phiếu nhập. Lỗi giữa chừng thì bỏ các dòng đã nhập
  /// khỏi form để Owner sửa dòng lỗi rồi bấm lại, không bị nhập trùng.
  Future<void> _save(Store central) async {
    setState(() => _saving = true);
    final repo = ref.read(ownerRepositoryProvider);
    var done = 0;
    try {
      for (final line in List.of(_lines)) {
        await repo.createReceipt(
          storeId: central.id,
          productId: line.product.id,
          quantity: line.qty!,
          expiryDate: line.expiry,
          note: _note.text,
        );
        done++;
        _lines.remove(line);
        line.quantity.dispose();
      }
      _invalidate();
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showAppSnackBar('Đã nhập $done sản phẩm vào ${central.name}.');
    } catch (e) {
      if (done > 0) _invalidate();
      if (!mounted) return;
      setState(() => _saving = false);
      final failed = _lines.firstOrNull?.product.name ?? 'sản phẩm';
      showAppSnackBar(
        '${done > 0 ? 'Đã nhập $done sản phẩm. ' : ''}'
        'Không nhập được $failed: ${errorMessageOf(e)}',
        isError: true,
      );
    }
  }

  void _invalidate() => ref
    ..invalidate(ownerStockProvider)
    ..invalidate(ownerReceiptsProvider)
    ..invalidate(ownerDashboardProvider);

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(ownerStoresProvider);
    final products = ref.watch(ownerProductsProvider).value ?? const [];
    final stock = ref.watch(ownerStockProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Nhập hàng về kho tổng')),
      body: AsyncValueView<List<Store>>(
        value: storesAsync,
        onRetry: () => ref.invalidate(ownerStoresProvider),
        data: (stores) {
          final central = stores
              .where((s) => s.isCentral && s.isActive)
              .firstOrNull;
          if (central == null) {
            return const EmptyState(
              icon: Icons.warehouse_outlined,
              message: 'Chưa có kho tổng đang hoạt động',
              hint: 'Tạo kho tổng ở tab Quản trị trước khi nhập hàng.',
            );
          }
          int availableOf(Product product) {
            for (final item in stock) {
              if (item.product.id == product.id) {
                return item.availableAt(central.id);
              }
            }
            return 0;
          }

          final valid =
              _lines.isNotEmpty && _lines.every((line) => line.qty != null);
          final total = _lines.fold<int>(0, (s, l) => s + (l.qty ?? 0));

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Hàng từ nhà cung cấp nhập vào ${central.name}: bấm Nhập kho '
                    'là kho tổng được cộng ngay, không cần chờ duyệt. Chi nhánh '
                    'nhận hàng qua phiếu chuyển.',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Sản phẩm nhập',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm sản phẩm'),
                        onPressed: _saving
                            ? null
                            : () => _addProduct(products, central),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_lines.isEmpty)
                    const Text(
                      'Chưa có sản phẩm nào.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  for (final line in _lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(line.product.name),
                                Text(
                                  'SKU ${line.product.sku} • kho tổng đang có ${availableOf(line.product)}'
                                  '${line.qty == null ? '' : ' → sau khi nhập ${availableOf(line.product) + line.qty!}'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                  ),
                                ),
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  icon: const Icon(Icons.event, size: 16),
                                  label: Text(
                                    line.expiry == null
                                        ? 'Chọn HSD lô (không bắt buộc)'
                                        : 'HSD: ${formatDate(line.expiry)}',
                                  ),
                                  onPressed: _saving
                                      ? null
                                      : () => _pickExpiry(line),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 130,
                            child: TextField(
                              key: ValueKey('receipt-qty-${line.product.id}'),
                              controller: line.quantity,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: 'Số lượng',
                                isDense: true,
                                border: const OutlineInputBorder(),
                                errorText: line.qty == null
                                    ? 'Từ 1 đến ${AppConstants.maxReceiveQuantity}'
                                    : null,
                                errorMaxLines: 2,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Bỏ sản phẩm',
                            icon: const Icon(Icons.close),
                            onPressed: _saving ? null : () => _removeLine(line),
                          ),
                        ],
                      ),
                    ),
                  TextField(
                    controller: _note,
                    maxLength: 300,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú (nhà cung cấp, số hóa đơn...)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    key: const ValueKey('receipt-save'),
                    icon: const Icon(Icons.move_to_inbox_outlined),
                    label: Text(
                      _lines.isEmpty ? 'Nhập kho' : 'Nhập kho ($total sp)',
                    ),
                    onPressed: valid && !_saving ? () => _save(central) : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductPicker extends ConsumerStatefulWidget {
  const _ProductPicker({required this.candidates, required this.central});

  final List<Product> candidates;
  final Store central;

  @override
  ConsumerState<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends ConsumerState<_ProductPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final stock = ref.watch(ownerStockProvider).value ?? const [];
    final available = {
      for (final item in stock)
        item.product.id: item.availableAt(widget.central.id),
    };
    final q = _query.trim().toLowerCase();
    final items = widget.candidates
        .where(
          (p) =>
              q.isEmpty ||
              p.name.toLowerCase().contains(q) ||
              p.sku.toLowerCase().contains(q),
        )
        .toList();
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
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
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const EmptyState(
                      icon: Icons.inventory_2_outlined,
                      message: 'Không tìm thấy sản phẩm',
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final p = items[index];
                        return ListTile(
                          title: Text(p.name),
                          subtitle: Text('SKU ${p.sku}'),
                          trailing: Text('Kho tổng: ${available[p.id] ?? 0}'),
                          onTap: () => Navigator.of(context).pop(p),
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
