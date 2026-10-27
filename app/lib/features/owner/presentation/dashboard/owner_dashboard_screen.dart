import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../data/owner_models.dart';
import '../../data/owner_repository.dart';
import '../owner_shell.dart';
import '../stock/owner_stock_screen.dart';
import 'store_overview_screen.dart';

/// Trang chủ Owner: doanh thu hôm nay / tháng này, việc chờ duyệt, cảnh báo
/// kho và tóm tắt từng chi nhánh của toàn chuỗi.
class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  void _openStock(WidgetRef ref, OwnerStockSection section) {
    ref.read(ownerStockSectionProvider.notifier).show(section);
    ref.read(ownerTabProvider.notifier).show(OwnerTab.stock);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: AppColors.background,
      child: AsyncValueView<OwnerDashboard>(
        value: ref.watch(ownerDashboardProvider),
        onRetry: () => ref.invalidate(ownerDashboardProvider),
        data: (d) => RefreshIndicator(
          onRefresh: () => ref.refresh(ownerDashboardProvider.future),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _StatTile(
                        label: 'Doanh thu hôm nay',
                        value: formatVnd(d.today.revenue),
                        hint: '${d.today.orders} đơn hoàn tất',
                      ),
                      _StatTile(
                        label: 'Doanh thu tháng này',
                        value: formatVnd(d.month.revenue),
                        hint: '${d.month.orders} đơn hoàn tất',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _SectionTitle('Việc cần xử lý'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PendingChip(
                        icon: Icons.move_to_inbox_outlined,
                        label: 'Đề xuất nhập chờ duyệt',
                        count: d.pendingRestock,
                        onTap: () => _openStock(ref, OwnerStockSection.restock),
                      ),
                      _PendingChip(
                        icon: Icons.assignment_return_outlined,
                        label: 'Trả hàng lỗi chờ duyệt',
                        count: d.pendingReturns,
                        onTap: () => _openStock(ref, OwnerStockSection.returns),
                      ),
                      _PendingChip(
                        icon: Icons.local_shipping_outlined,
                        label: 'Phiếu chuyển chưa nhận',
                        count: d.transfersInTransit,
                        onTap: () =>
                            _openStock(ref, OwnerStockSection.transfers),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _SectionTitle('Cảnh báo tồn kho toàn chuỗi'),
                  Text(
                    'Hết hàng ${d.alerts.outOfStock} • Sắp hết ${d.alerts.lowStock}'
                    ' • Sắp hết hạn ${d.alerts.expiringSoon} • Đã hết hạn ${d.alerts.expired}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 20),
                  const _SectionTitle('Chi nhánh'),
                  for (final entry in d.stores)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _StoreCard(entry: entry),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    ),
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.hint});

  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          if (hint != null)
            Text(
              hint!,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class _PendingChip extends StatelessWidget {
  const _PendingChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(
        icon,
        size: 18,
        color: count > 0 ? AppColors.accent : AppColors.muted,
      ),
      label: Text(
        '$label: $count',
        style: TextStyle(
          fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onPressed: onTap,
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.entry});

  final DashboardStore entry;

  @override
  Widget build(BuildContext context) {
    final store = entry.store;
    final alerts = entry.alerts;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => StoreOverviewScreen(store: store),
          ),
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
                      store.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  StatusChip(
                    label: store.type.label,
                    color: store.isCentral ? AppColors.primary : AppColors.info,
                  ),
                  if (!store.isActive) ...[
                    const SizedBox(width: 6),
                    const StatusChip(
                      label: 'Ngừng hoạt động',
                      color: AppColors.muted,
                    ),
                  ],
                  const Icon(Icons.chevron_right, color: AppColors.muted),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Hôm nay ${formatVnd(entry.today.revenue)} • '
                'Tháng này ${formatVnd(entry.month.revenue)}',
              ),
              Text(
                '${entry.ordersInProgress} đơn đang xử lý • '
                '${entry.activeStaff} nhân viên • '
                '${alerts.total} cảnh báo kho'
                '${alerts.outOfStock > 0 ? ' (${alerts.outOfStock} hết hàng)' : ''}',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
