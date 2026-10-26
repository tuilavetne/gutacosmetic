import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../session/session_controller.dart';
import '../../../shared/models/models.dart';
import '../../data/manager_repository.dart';
import 'stock_dialogs.dart';
import 'stock_health.dart';

/// Danh sách sản phẩm của chi nhánh để chọn trong hộp thoại (rỗng khi chưa tải).
List<StockRow> _stockRows(WidgetRef ref) => stockRowsFor(
  ref.watch(managerStockProvider).value ?? const [],
  ref.watch(activeStoreProvider)?.id ?? '',
);

/// Phiếu nhập kho (nhập trực tiếp, theo đề xuất Sales, hàng chuyển đến).
class ReceiptsTab extends ConsumerWidget {
  const ReceiptsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = _stockRows(ref);
    return _LogList<InventoryReceipt>(
      value: ref.watch(managerReceiptsProvider),
      onRefresh: () => ref.refresh(managerReceiptsProvider.future),
      actionLabel: 'Tạo phiếu nhập',
      onAction: () => ReceiptDialog.show(context, rows: rows),
      emptyMessage: 'Chưa có phiếu nhập nào',
      itemBuilder: (receipt) => _LogCard(
        icon: Icons.move_to_inbox_outlined,
        color: AppColors.success,
        title: receipt.productId?.data?.name ?? 'Sản phẩm',
        amount: '+${receipt.quantity}',
        tag: receipt.source.label,
        lines: [
          if (receipt.expiryDate != null)
            'HSD lô: ${formatDate(receipt.expiryDate)}',
          if ((receipt.note ?? '').isNotEmpty) receipt.note!,
          [
            formatDateTime(receipt.createdAt),
            ?receipt.receivedBy?.data?.displayName,
          ].join(' • '),
        ],
      ),
    );
  }
}

/// Phiếu ghi giảm kho (hỏng / lỗi / mất / hết hạn).
class AdjustmentsTab extends ConsumerWidget {
  const AdjustmentsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = _stockRows(ref);
    return _LogList<InventoryAdjustment>(
      value: ref.watch(managerAdjustmentsProvider),
      onRefresh: () => ref.refresh(managerAdjustmentsProvider.future),
      actionLabel: 'Ghi giảm kho',
      onAction: () => AdjustmentDialog.show(context, rows: rows),
      emptyMessage: 'Chưa có phiếu ghi giảm nào',
      itemBuilder: (adjustment) => _LogCard(
        icon: Icons.remove_circle_outline,
        color: AppColors.accent,
        title: adjustment.productId?.data?.name ?? 'Sản phẩm',
        amount: '-${adjustment.quantity}',
        tag: adjustment.type.label,
        lines: [
          if ((adjustment.note ?? '').isNotEmpty) adjustment.note!,
          [
            formatDateTime(adjustment.createdAt),
            ?adjustment.createdBy?.data?.displayName,
          ].join(' • '),
        ],
      ),
    );
  }
}

class _LogList<T> extends StatelessWidget {
  const _LogList({
    required this.value,
    required this.onRefresh,
    required this.actionLabel,
    required this.onAction,
    required this.emptyMessage,
    required this.itemBuilder,
  });

  final AsyncValue<List<T>> value;
  final Future<void> Function() onRefresh;
  final String actionLabel;
  final VoidCallback onAction;
  final String emptyMessage;
  final Widget Function(T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
              onPressed: onAction,
            ),
          ),
        ),
        Expanded(
          child: AsyncValueView<List<T>>(
            value: value,
            onRetry: onRefresh,
            data: (items) => RefreshIndicator(
              onRefresh: onRefresh,
              child: items.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 60),
                        EmptyState(
                          icon: Icons.receipt_long_outlined,
                          message: emptyMessage,
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, index) => itemBuilder(items[index]),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.amount,
    required this.tag,
    required this.lines,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String amount;
  final String tag;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  StatusChip(label: tag, color: color),
                  for (final line in lines)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        line,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
