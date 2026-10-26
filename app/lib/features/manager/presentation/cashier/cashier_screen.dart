import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../shared/models/models.dart';
import '../../data/manager_repository.dart';
import 'cashier_order_screen.dart';

/// Tab Thu ngân: các đơn tại quầy Sales đã gửi sang, chờ thu tiền.
class CashierScreen extends ConsumerStatefulWidget {
  const CashierScreen({super.key});

  /// Sales gửi đơn liên tục nên danh sách tự làm mới định kỳ.
  static const refreshInterval = Duration(seconds: 15);

  @override
  ConsumerState<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends ConsumerState<CashierScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(
      CashierScreen.refreshInterval,
      (_) => ref.invalidate(cashierOrdersProvider),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _open(Order order) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CashierOrderScreen(orderId: order.id),
      ),
    );
    ref.invalidate(cashierOrdersProvider);
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(cashierOrdersProvider);

    return ColoredBox(
      color: AppColors.background,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: AsyncValueView<List<Order>>(
            value: ordersAsync,
            onRetry: () => ref.invalidate(cashierOrdersProvider),
            data: (orders) => RefreshIndicator(
              onRefresh: () => ref.refresh(cashierOrdersProvider.future),
              child: orders.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 80),
                        EmptyState(
                          icon: Icons.point_of_sale_outlined,
                          message: 'Chưa có đơn nào chờ thu ngân',
                          hint: 'Đơn Sales gửi sang sẽ tự hiện ở đây.',
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Text(
                            '${orders.length} đơn chờ thu • tổng '
                            '${formatVnd(orders.fold<int>(0, (sum, o) => sum + o.totalPrice))}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }
                        final order = orders[index - 1];
                        return _CashierOrderCard(
                          order: order,
                          onTap: () => _open(order),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CashierOrderCard extends StatelessWidget {
  const _CashierOrderCard({required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isMember = order.customerId != null;
    final waited = order.updatedAt == null
        ? null
        : DateTime.now().difference(order.updatedAt!);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.receipt_long, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderCode,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        (order.customerName ?? '').isNotEmpty
                            ? order.customerName!
                            : 'Khách vãng lai',
                        if (isMember) 'Thành viên',
                        '${order.itemCount} sp',
                      ].join(' • '),
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (waited != null)
                      Text(
                        waited.inMinutes < 1
                            ? 'Vừa gửi sang'
                            : 'Chờ ${waited.inMinutes} phút',
                        style: TextStyle(
                          fontSize: 11,
                          color: waited.inMinutes >= 10
                              ? AppColors.warning
                              : AppColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatVnd(order.totalPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
