import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../shared/models/models.dart';
import '../../../shared/presentation/restock_request_details.dart';
import '../../data/owner_repository.dart';
import 'receipt_form_screen.dart';
import 'transfer_form_screen.dart';

enum OwnerStockSection { restock, returns, transfers, receipts }

/// Phần đang mở trong tab Kho & duyệt (trang chủ chuyển thẳng tới đây).
final ownerStockSectionProvider =
    NotifierProvider<OwnerStockSectionController, OwnerStockSection>(
      OwnerStockSectionController.new,
    );

class OwnerStockSectionController extends Notifier<OwnerStockSection> {
  @override
  OwnerStockSection build() => OwnerStockSection.restock;

  void show(OwnerStockSection section) => state = section;
}

/// Làm mới dữ liệu duyệt kho / chuyển hàng / trang chủ sau một thao tác.
void invalidateOwnerStock(WidgetRef ref) => ref
  ..invalidate(ownerRestockRequestsProvider)
  ..invalidate(ownerReturnRequestsProvider)
  ..invalidate(ownerTransfersProvider)
  ..invalidate(ownerStockProvider)
  ..invalidate(ownerReceiptsProvider)
  ..invalidate(ownerDashboardProvider);

/// Tab Kho & duyệt của Owner: duyệt đề xuất nhập, duyệt trả hàng lỗi, chuyển
/// hàng giữa các cửa hàng, nhập hàng nhà cung cấp về kho tổng.
class OwnerStockScreen extends ConsumerStatefulWidget {
  const OwnerStockScreen({super.key});

  @override
  ConsumerState<OwnerStockScreen> createState() => _OwnerStockScreenState();
}

class _OwnerStockScreenState extends ConsumerState<OwnerStockScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: OwnerStockSection.values.length,
    vsync: this,
    initialIndex: ref.read(ownerStockSectionProvider).index,
  );

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      ownerStockSectionProvider,
      (_, next) => _tabs.animateTo(next.index),
    );
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          ColoredBox(
            color: Colors.white,
            child: TabBar(
              controller: _tabs,
              labelColor: AppColors.primary,
              indicatorColor: AppColors.primary,
              unselectedLabelColor: AppColors.muted,
              // 4 tab không vừa màn hình điện thoại — cho cuộn ngang.
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              onTap: (index) => ref
                  .read(ownerStockSectionProvider.notifier)
                  .show(OwnerStockSection.values[index]),
              tabs: const [
                Tab(text: 'Duyệt đề xuất nhập'),
                Tab(text: 'Trả hàng lỗi'),
                Tab(text: 'Chuyển hàng'),
                Tab(text: 'Nhập hàng'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: TabBarView(
                  controller: _tabs,
                  children: const [
                    _RestockTab(),
                    _ReturnsTab(),
                    _TransfersTab(),
                    _ReceiptsTab(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Filter<T> extends StatelessWidget {
  const _Filter({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.trailing,
  });

  final List<T?> values;
  final T? selected;
  final String Function(T? value) labelOf;
  final ValueChanged<T?> onSelected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final value in values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(labelOf(value)),
                        selected: value == selected,
                        onSelected: (_) => onSelected(value),
                      ),
                    ),
                ],
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

Widget _list<T>({
  required WidgetRef ref,
  required AsyncValue<List<T>> value,
  required VoidCallback onRetry,
  required Future<void> Function() onRefresh,
  required String empty,
  required Widget Function(T item) itemBuilder,
}) {
  return AsyncValueView<List<T>>(
    value: value,
    onRetry: onRetry,
    data: (items) => RefreshIndicator(
      onRefresh: onRefresh,
      child: items.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 60),
                EmptyState(icon: Icons.inbox_outlined, message: empty),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, index) => itemBuilder(items[index]),
            ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Duyệt đề xuất nhập
// ---------------------------------------------------------------------------

class _RestockTab extends ConsumerStatefulWidget {
  const _RestockTab();

  @override
  ConsumerState<_RestockTab> createState() => _RestockTabState();
}

class _RestockTabState extends ConsumerState<_RestockTab> {
  RestockStatus? _status = RestockStatus.forwarded;

  @override
  Widget build(BuildContext context) {
    final provider = ownerRestockRequestsProvider(_status);
    return Column(
      children: [
        _Filter<RestockStatus>(
          values: const [
            RestockStatus.forwarded,
            RestockStatus.inTransit,
            RestockStatus.resolved,
            RestockStatus.cancelled,
            null,
          ],
          selected: _status,
          labelOf: (s) => s?.label ?? 'Tất cả',
          onSelected: (s) => setState(() => _status = s),
        ),
        Expanded(
          child: _list<RestockRequest>(
            ref: ref,
            value: ref.watch(provider),
            onRetry: () => ref.invalidate(provider),
            onRefresh: () => ref.refresh(provider.future),
            empty: 'Không có đề xuất nhập nào',
            itemBuilder: (request) => _RestockItem(request: request),
          ),
        ),
      ],
    );
  }
}

class _RestockItem extends ConsumerStatefulWidget {
  const _RestockItem({required this.request});

  final RestockRequest request;

  @override
  ConsumerState<_RestockItem> createState() => _RestockItemState();
}

class _RestockItemState extends ConsumerState<_RestockItem> {
  bool _busy = false;

  Future<void> _reject() async {
    final note = await showReasonDialog(
      context,
      title: 'Từ chối đề xuất nhập?',
      message: 'Lý do sẽ hiển thị cho Manager và Sales.',
      confirmLabel: 'Từ chối',
      hint: 'Ví dụ: kho tổng đang hết hàng',
      minLength: 3,
      maxLength: 300,
    );
    if (note == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(ownerRepositoryProvider)
          .rejectRestock(widget.request.id, note);
      invalidateOwnerStock(ref);
      showAppSnackBar('Đã từ chối đề xuất.');
    } catch (e) {
      showAppSnackBar(errorMessageOf(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    return RestockRequestCard(
      request: request,
      showStore: true,
      actions: [
        if (request.status == RestockStatus.forwarded) ...[
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            onPressed: _busy ? null : _reject,
            child: const Text('Từ chối'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.local_shipping_outlined, size: 18),
            label: const Text('Duyệt & chuyển hàng'),
            onPressed: _busy
                ? null
                : () => _ApproveRestockDialog.show(context, request),
          ),
        ],
      ],
    );
  }
}

/// Duyệt = tạo phiếu chuyển hàng từ kho gửi (mặc định kho tổng) tới chi nhánh.
class _ApproveRestockDialog extends ConsumerStatefulWidget {
  const _ApproveRestockDialog({required this.request});

  final RestockRequest request;

  static Future<void> show(BuildContext context, RestockRequest request) =>
      showDialog<void>(
        context: context,
        builder: (_) => _ApproveRestockDialog(request: request),
      );

  @override
  ConsumerState<_ApproveRestockDialog> createState() =>
      _ApproveRestockDialogState();
}

class _ApproveRestockDialogState extends ConsumerState<_ApproveRestockDialog> {
  String? _fromStoreId;
  late final _quantity = TextEditingController(
    text:
        '${widget.request.forwardedQuantity ?? widget.request.requestedQuantity}',
  );
  final _note = TextEditingController();
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

  Future<void> _save(String fromStoreId) async {
    final qty = _qty;
    if (qty == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(ownerRepositoryProvider)
          .approveRestock(
            widget.request.id,
            fromStoreId: fromStoreId,
            quantity: qty,
            note: _note.text,
          );
      invalidateOwnerStock(ref);
      if (!mounted) return;
      Navigator.of(context).pop();
      showAppSnackBar('Đã duyệt và tạo phiếu chuyển $qty sp.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar('Không duyệt được: ${errorMessageOf(e)}', isError: true);
    }
  }

  /// Kho tổng thiếu hàng: mở form nhập hàng nhà cung cấp, điền sẵn sản phẩm
  /// và số còn thiếu. Nhập xong, tồn kho tải lại và hộp duyệt tự cập nhật.
  Future<void> _receiveIntoCentral(int shortfall) async {
    final product =
        widget.request.productId?.data ??
        Product(id: widget.request.productId?.id ?? '', name: 'Sản phẩm');
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReceiptFormScreen(
          product: product,
          quantity: shortfall.clamp(1, AppConstants.maxReceiveQuantity),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final toStoreId = request.storeId?.id;
    final stores = (ref.watch(ownerStoresProvider).value ?? const <Store>[])
        .where((s) => s.isActive && s.id != toStoreId)
        .toList();
    final stockAsync = ref.watch(ownerStockProvider);
    final stock = stockAsync.value;
    final central = stores.where((s) => s.isCentral).firstOrNull;
    final fromStoreId = _fromStoreId ?? central?.id ?? stores.firstOrNull?.id;
    final fromStore = stores.where((s) => s.id == fromStoreId).firstOrNull;
    // Chưa tải xong tồn kho thì chưa biết (null); không có dòng tồn = 0.
    int? availableAt(String storeId) {
      if (stock == null) return null;
      for (final item in stock) {
        if (item.product.id == request.productId?.id) {
          return item.availableAt(storeId);
        }
      }
      return 0;
    }

    final available = fromStoreId == null ? null : availableAt(fromStoreId);
    final qty = _qty;
    final notEnough = qty != null && available != null && qty > available;
    final canReceive =
        fromStore != null &&
        fromStore.isCentral &&
        available != null &&
        (notEnough || available == 0);

    return AlertDialog(
      title: const Text('Duyệt đề xuất nhập'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${request.productId?.data?.name ?? 'Sản phẩm'} → '
              '${request.storeId?.data?.name ?? 'chi nhánh'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Tồn khả dụng ở mọi cửa hàng — chạm để chọn làm kho gửi.
            const Text(
              'Tồn khả dụng các cửa hàng',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final store in stores)
                  ChoiceChip(
                    key: ValueKey('source-${store.id}'),
                    label: Text(
                      '${store.isCentral ? 'Kho tổng' : store.name}: '
                      '${availableAt(store.id) ?? '…'}',
                    ),
                    selected: store.id == fromStoreId,
                    onSelected: (_) => setState(() => _fromStoreId = store.id),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              // Đổi key để ô chọn theo kịp khi chọn kho bằng chip ở trên.
              key: ValueKey('approve-from-$fromStoreId'),
              initialValue: fromStoreId,
              decoration: const InputDecoration(
                labelText: 'Kho gửi',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final store in stores)
                  DropdownMenuItem(
                    value: store.id,
                    child: Text(
                      '${store.name}${store.isCentral ? ' (kho tổng)' : ''}',
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _fromStoreId = v),
            ),
            if (available != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Kho gửi còn $available sp khả dụng',
                  style: TextStyle(
                    fontSize: 12,
                    color: notEnough ? AppColors.accent : AppColors.muted,
                  ),
                ),
              ),
            if (canReceive)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const ValueKey('receive-into-central'),
                  icon: const Icon(Icons.move_to_inbox_outlined, size: 18),
                  label: Text(
                    'Nhập hàng về kho tổng'
                    '${qty != null && qty > available ? ' (thiếu ${qty - available})' : ''}',
                  ),
                  onPressed: _saving
                      ? null
                      : () => _receiveIntoCentral(
                          qty != null && qty > available
                              ? qty - available
                              : qty ?? 1,
                        ),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('approve-quantity'),
              controller: _quantity,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Số lượng chuyển',
                border: const OutlineInputBorder(),
                errorText: qty == null
                    ? 'Từ 1 đến ${AppConstants.maxReceiveQuantity}'
                    : notEnough
                    ? 'Kho gửi không đủ hàng'
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (không bắt buộc)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
        FilledButton(
          onPressed: fromStoreId == null || qty == null || notEnough || _saving
              ? null
              : () => _save(fromStoreId),
          child: const Text('Duyệt & tạo phiếu chuyển'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Trả hàng lỗi
// ---------------------------------------------------------------------------

class _ReturnsTab extends ConsumerStatefulWidget {
  const _ReturnsTab();

  @override
  ConsumerState<_ReturnsTab> createState() => _ReturnsTabState();
}

class _ReturnsTabState extends ConsumerState<_ReturnsTab> {
  ReturnRequestStatus? _status = ReturnRequestStatus.pending;

  @override
  Widget build(BuildContext context) {
    final provider = ownerReturnRequestsProvider(_status);
    return Column(
      children: [
        _Filter<ReturnRequestStatus>(
          values: const [...ReturnRequestStatus.values, null],
          selected: _status,
          labelOf: (s) => s?.label ?? 'Tất cả',
          onSelected: (s) => setState(() => _status = s),
        ),
        Expanded(
          child: _list<InventoryReturnRequest>(
            ref: ref,
            value: ref.watch(provider),
            onRetry: () => ref.invalidate(provider),
            onRefresh: () => ref.refresh(provider.future),
            empty: 'Không có yêu cầu trả hàng nào',
            itemBuilder: (request) => _ReturnItem(request: request),
          ),
        ),
      ],
    );
  }
}

class _ReturnItem extends ConsumerStatefulWidget {
  const _ReturnItem({required this.request});

  final InventoryReturnRequest request;

  @override
  ConsumerState<_ReturnItem> createState() => _ReturnItemState();
}

class _ReturnItemState extends ConsumerState<_ReturnItem> {
  bool _busy = false;

  Future<void> _review({required bool approve}) async {
    final note = await showReasonDialog(
      context,
      title: approve ? 'Duyệt trả hàng?' : 'Từ chối trả hàng?',
      message: approve
          ? 'Số hàng đang khóa sẽ bị trừ hẳn khỏi kho chi nhánh.'
          : 'Số hàng đang khóa sẽ trở lại hàng bán được.',
      confirmLabel: approve ? 'Duyệt' : 'Từ chối',
      hint: approve ? 'Ghi chú (không bắt buộc)' : 'Lý do từ chối',
      minLength: approve ? 0 : 3,
      maxLength: 300,
      destructive: !approve,
    );
    if (note == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(ownerRepositoryProvider)
          .reviewReturn(widget.request.id, approve: approve, note: note);
      invalidateOwnerStock(ref);
      showAppSnackBar(approve ? 'Đã duyệt trả hàng.' : 'Đã từ chối trả hàng.');
    } catch (e) {
      showAppSnackBar(errorMessageOf(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final color = switch (r.status) {
      ReturnRequestStatus.pending => AppColors.warning,
      ReturnRequestStatus.approved => AppColors.success,
      ReturnRequestStatus.rejected => AppColors.muted,
    };
    final note = r.managerNote?.trim() ?? '';
    final review = r.reviewNote?.trim() ?? '';
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    r.productId?.data?.name ?? 'Sản phẩm',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                StatusChip(label: r.status.label, color: color),
              ],
            ),
            Text(
              '${r.storeId?.data?.name ?? 'Chi nhánh'} • trả ${r.quantity} sp • ${r.reasonType.label}',
            ),
            if (note.isNotEmpty)
              Text('Mô tả: $note', style: const TextStyle(fontSize: 12)),
            Text(
              [
                ?r.requestedBy?.data?.displayName,
                formatDateTime(r.createdAt),
              ].join(' • '),
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            if (review.isNotEmpty)
              Text(
                'Owner: $review',
                style: TextStyle(fontSize: 12, color: color),
              ),
            if (r.status == ReturnRequestStatus.pending) ...[
              const Divider(height: 20),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                    ),
                    onPressed: _busy ? null : () => _review(approve: false),
                    child: const Text('Từ chối'),
                  ),
                  FilledButton(
                    onPressed: _busy ? null : () => _review(approve: true),
                    child: const Text('Duyệt trả hàng'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chuyển hàng
// ---------------------------------------------------------------------------

class _TransfersTab extends ConsumerStatefulWidget {
  const _TransfersTab();

  @override
  ConsumerState<_TransfersTab> createState() => _TransfersTabState();
}

class _TransfersTabState extends ConsumerState<_TransfersTab> {
  TransferStatus? _status = TransferStatus.pending;

  @override
  Widget build(BuildContext context) {
    final provider = ownerTransfersProvider(_status);
    return Column(
      children: [
        _Filter<TransferStatus>(
          values: const [...TransferStatus.values, null],
          selected: _status,
          labelOf: (s) => s?.label ?? 'Tất cả',
          onSelected: (s) => setState(() => _status = s),
          trailing: FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Tạo phiếu'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const TransferFormScreen(),
              ),
            ),
          ),
        ),
        Expanded(
          child: _list<StockTransfer>(
            ref: ref,
            value: ref.watch(provider),
            onRetry: () => ref.invalidate(provider),
            onRefresh: () => ref.refresh(provider.future),
            empty: 'Không có phiếu chuyển hàng nào',
            itemBuilder: (transfer) => _TransferItem(transfer: transfer),
          ),
        ),
      ],
    );
  }
}

class _TransferItem extends ConsumerStatefulWidget {
  const _TransferItem({required this.transfer});

  final StockTransfer transfer;

  @override
  ConsumerState<_TransferItem> createState() => _TransferItemState();
}

class _TransferItemState extends ConsumerState<_TransferItem> {
  bool _busy = false;

  Future<void> _cancel() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hủy phiếu chuyển hàng?',
      message:
          'Hàng sẽ được hoàn về ${widget.transfer.fromStoreId?.data?.name ?? 'kho gửi'}'
          '${widget.transfer.restockRequestId != null ? '. Đề xuất nhập liên quan quay về chờ duyệt.' : '.'}',
      confirmLabel: 'Hủy phiếu',
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(ownerRepositoryProvider)
          .cancelTransfer(widget.transfer.id);
      invalidateOwnerStock(ref);
      showAppSnackBar('Đã hủy phiếu và hoàn hàng về kho gửi.');
    } catch (e) {
      showAppSnackBar(errorMessageOf(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.transfer;
    final color = switch (t.status) {
      TransferStatus.pending => AppColors.warning,
      TransferStatus.confirmed => AppColors.success,
      TransferStatus.cancelled => AppColors.muted,
    };
    final note = t.note?.trim() ?? '';
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${t.fromStoreId?.data?.name ?? 'Kho gửi'} → ${t.toStoreId?.data?.name ?? 'Nơi nhận'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                StatusChip(label: t.status.label, color: color),
              ],
            ),
            const SizedBox(height: 4),
            for (final item in t.items)
              Text(
                '• ${item.productId.data?.name ?? 'Sản phẩm'} × ${item.quantity}',
              ),
            if (note.isNotEmpty)
              Text('Ghi chú: $note', style: const TextStyle(fontSize: 12)),
            Text(
              [
                '${t.totalQuantity} sp',
                formatDateTime(t.createdAt),
                if (t.restockRequestId != null) 'theo đề xuất nhập',
                if (t.confirmedBy?.data != null)
                  'nhận bởi ${t.confirmedBy!.data!.displayName}',
              ].join(' • '),
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            if (t.status == TransferStatus.pending) ...[
              const Divider(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                  ),
                  onPressed: _busy ? null : _cancel,
                  child: const Text('Hủy phiếu'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nhập hàng nhà cung cấp về kho tổng
// ---------------------------------------------------------------------------

class _ReceiptsTab extends ConsumerWidget {
  const _ReceiptsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(ownerStoresProvider);
    return AsyncValueView<List<Store>>(
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
        final provider = ownerReceiptsProvider(central.id);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Phiếu nhập hàng nhà cung cấp vào ${central.name}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Nhập hàng'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<bool>(
                        builder: (_) => const ReceiptFormScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _list<InventoryReceipt>(
                ref: ref,
                value: ref.watch(provider),
                onRetry: () => ref.invalidate(provider),
                onRefresh: () => ref.refresh(provider.future),
                empty: 'Chưa có phiếu nhập nào',
                itemBuilder: (r) => Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: ListTile(
                    title: Text(r.productId?.data?.name ?? 'Sản phẩm'),
                    subtitle: Text(
                      [
                        r.source.label,
                        if (r.expiryDate != null)
                          'HSD ${formatDate(r.expiryDate)}',
                        ?r.receivedBy?.data?.displayName,
                        formatDateTime(r.createdAt),
                        if ((r.note ?? '').trim().isNotEmpty) r.note!.trim(),
                      ].join(' • '),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Text(
                      '+${r.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
