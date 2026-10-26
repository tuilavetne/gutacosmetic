import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../session/session_controller.dart';
import '../../../shared/models/models.dart';
import '../../data/manager_repository.dart';
import 'stock_dialogs.dart';
import 'stock_health.dart';

class _StatusFilter<T> extends StatelessWidget {
  const _StatusFilter({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<T?> values;
  final T? selected;
  final String Function(T? value) labelOf;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          for (final value in values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(labelOf(value)),
                selected: value == selected,
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: value == selected ? Colors.white : AppColors.ink,
                ),
                onSelected: (_) => onSelected(value),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _emptyList(IconData icon, String message) => ListView(
  children: [
    const SizedBox(height: 60),
    EmptyState(icon: icon, message: message),
  ],
);

ShapeBorder _cardShape([Color? border]) => RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(14),
  side: BorderSide(color: border ?? AppColors.border),
);

// ---------------------------------------------------------------------------
// Trả hàng lỗi
// ---------------------------------------------------------------------------

/// Yêu cầu trả hàng lỗi gửi Owner duyệt; hàng bị khóa trong lúc chờ.
class ReturnRequestsTab extends ConsumerStatefulWidget {
  const ReturnRequestsTab({super.key});

  @override
  ConsumerState<ReturnRequestsTab> createState() => _ReturnRequestsTabState();
}

class _ReturnRequestsTabState extends ConsumerState<ReturnRequestsTab> {
  ReturnRequestStatus? _status = ReturnRequestStatus.pending;

  @override
  Widget build(BuildContext context) {
    final rows = stockRowsFor(
      ref.watch(managerStockProvider).value ?? const [],
      ref.watch(activeStoreProvider)?.id ?? '',
    );
    final requestsAsync = ref.watch(managerReturnRequestsProvider(_status));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _StatusFilter<ReturnRequestStatus>(
                values: const [...ReturnRequestStatus.values, null],
                selected: _status,
                labelOf: (s) => s?.label ?? 'Tất cả',
                onSelected: (s) => setState(() => _status = s),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 8),
              child: FilledButton.icon(
                icon: const Icon(Icons.assignment_return_outlined),
                label: const Text('Trả hàng'),
                onPressed: () => ReturnRequestDialog.show(context, rows: rows),
              ),
            ),
          ],
        ),
        Expanded(
          child: AsyncValueView<List<InventoryReturnRequest>>(
            value: requestsAsync,
            onRetry: () =>
                ref.invalidate(managerReturnRequestsProvider(_status)),
            data: (requests) => RefreshIndicator(
              onRefresh: () =>
                  ref.refresh(managerReturnRequestsProvider(_status).future),
              child: requests.isEmpty
                  ? _emptyList(
                      Icons.assignment_return_outlined,
                      'Không có yêu cầu trả hàng nào',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, index) =>
                          _ReturnCard(request: requests[index]),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReturnCard extends StatelessWidget {
  const _ReturnCard({required this.request});

  final InventoryReturnRequest request;

  @override
  Widget build(BuildContext context) {
    final color = switch (request.status) {
      ReturnRequestStatus.pending => AppColors.warning,
      ReturnRequestStatus.approved => AppColors.success,
      ReturnRequestStatus.rejected => AppColors.muted,
    };
    final note = request.managerNote?.trim() ?? '';
    final review = request.reviewNote?.trim() ?? '';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: _cardShape(),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.productId?.data?.name ?? 'Sản phẩm',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                StatusChip(label: request.status.label, color: color),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Trả ${request.quantity} sp • ${request.reasonType.label}'
              '${request.status == ReturnRequestStatus.pending ? ' • đang khóa trong kho' : ''}',
            ),
            if (note.isNotEmpty)
              Text(
                'Mô tả: $note',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            Text(
              [
                ?request.requestedBy?.data?.displayName,
                formatDateTime(request.createdAt),
              ].join(' • '),
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            if (request.status != ReturnRequestStatus.pending) ...[
              const SizedBox(height: 6),
              Text(
                'Owner ${request.status == ReturnRequestStatus.approved ? 'duyệt' : 'từ chối'}'
                '${request.reviewedAt != null ? ' lúc ${formatDateTime(request.reviewedAt)}' : ''}'
                '${review.isNotEmpty ? ': $review' : ''}',
                style: TextStyle(fontSize: 12, color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hàng chuyển đến
// ---------------------------------------------------------------------------

/// Phiếu Owner chuyển hàng từ kho tổng tới chi nhánh; Manager xác nhận nhận.
class IncomingTransfersTab extends ConsumerStatefulWidget {
  const IncomingTransfersTab({super.key});

  @override
  ConsumerState<IncomingTransfersTab> createState() =>
      _IncomingTransfersTabState();
}

class _IncomingTransfersTabState extends ConsumerState<IncomingTransfersTab> {
  TransferStatus? _status = TransferStatus.pending;

  @override
  Widget build(BuildContext context) {
    final transfersAsync = ref.watch(managerIncomingTransfersProvider(_status));

    return Column(
      children: [
        _StatusFilter<TransferStatus>(
          values: const [...TransferStatus.values, null],
          selected: _status,
          labelOf: (s) => s?.label ?? 'Tất cả',
          onSelected: (s) => setState(() => _status = s),
        ),
        Expanded(
          child: AsyncValueView<List<StockTransfer>>(
            value: transfersAsync,
            onRetry: () =>
                ref.invalidate(managerIncomingTransfersProvider(_status)),
            data: (transfers) => RefreshIndicator(
              onRefresh: () =>
                  ref.refresh(managerIncomingTransfersProvider(_status).future),
              child: transfers.isEmpty
                  ? _emptyList(
                      Icons.local_shipping_outlined,
                      'Không có hàng chuyển đến',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: transfers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, index) =>
                          _TransferCard(transfer: transfers[index]),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TransferCard extends ConsumerStatefulWidget {
  const _TransferCard({required this.transfer});

  final StockTransfer transfer;

  @override
  ConsumerState<_TransferCard> createState() => _TransferCardState();
}

class _TransferCardState extends ConsumerState<_TransferCard> {
  bool _busy = false;

  Future<void> _confirm() async {
    final transfer = widget.transfer;
    final ok = await showConfirmDialog(
      context,
      title: 'Xác nhận đã nhận hàng?',
      message:
          'Đã kiểm đủ ${transfer.totalQuantity} sản phẩm từ '
          '${transfer.fromStoreId?.data?.name ?? 'kho tổng'}. Hàng sẽ được '
          'cộng vào kho chi nhánh.',
      confirmLabel: 'Đã nhận đủ',
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(managerRepositoryProvider).confirmTransfer(transfer.id);
      invalidateStock(ref);
      showAppSnackBar('Đã nhận hàng và cộng vào kho.');
    } catch (e) {
      showAppSnackBar(
        'Không xác nhận được: ${errorMessageOf(e)}',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transfer = widget.transfer;
    final color = switch (transfer.status) {
      TransferStatus.pending => AppColors.warning,
      TransferStatus.confirmed => AppColors.success,
      TransferStatus.cancelled => AppColors.muted,
    };

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: _cardShape(),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Từ ${transfer.fromStoreId?.data?.name ?? 'kho tổng'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                StatusChip(label: transfer.status.label, color: color),
              ],
            ),
            const SizedBox(height: 6),
            for (final item in transfer.items)
              Text(
                '• ${item.productId.data?.name ?? 'Sản phẩm'} × ${item.quantity}',
              ),
            const SizedBox(height: 4),
            Text(
              [
                '${transfer.totalQuantity} sp',
                formatDateTime(transfer.createdAt),
                if (transfer.confirmedBy?.data != null)
                  'nhận bởi ${transfer.confirmedBy!.data!.displayName}',
              ].join(' • '),
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            if (transfer.status == TransferStatus.pending) ...[
              const Divider(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  icon: const Icon(Icons.inventory_outlined, size: 18),
                  label: const Text('Xác nhận đã nhận hàng'),
                  onPressed: _busy ? null : _confirm,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
