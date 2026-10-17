import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../shared/models/models.dart';
import '../catalog/catalog_filter.dart';
import '../data/order_repository.dart';
import '../orders/order_actions.dart';
import '../orders/order_display.dart';
import 'widgets/cart_icon_button.dart';
import 'widgets/order_widgets.dart';

/// Tab Đơn hàng: toàn bộ đơn của khách, lọc theo trạng thái.
class CustomerOrdersScreen extends ConsumerWidget {
  const CustomerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(customerOrdersProvider);
    final orders = ordersAsync.value ?? const <Order>[];

    return DefaultTabController(
      length: OrderTab.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn hàng của tôi'),
          actions: const [CartIconButton(), SizedBox(width: 4)],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final tab in OrderTab.values)
                Tab(text: _tabLabel(tab, orders.where(tab.matches).length)),
            ],
          ),
        ),
        body: AsyncValueView<List<Order>>(
          value: ordersAsync,
          onRetry: () => ref.invalidate(customerOrdersProvider),
          data: (orders) => TabBarView(
            children: [
              for (final tab in OrderTab.values)
                _OrderList(
                  tab: tab,
                  orders: orders.where(tab.matches).toList(),
                  onRefresh: () => ref.refresh(customerOrdersProvider.future),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kèm số đơn, trừ tab "Tất cả" và tab rỗng.
String _tabLabel(OrderTab tab, int count) =>
    tab == OrderTab.all || count == 0 ? tab.label : '${tab.label} ($count)';

class _OrderList extends StatelessWidget {
  const _OrderList({
    required this.tab,
    required this.orders,
    required this.onRefresh,
  });

  final OrderTab tab;
  final List<Order> orders;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return RefreshableFill(
        onRefresh: onRefresh,
        child: _EmptyOrders(tab: tab),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: OrderContentWidth(
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: orders.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) => OrderCard(order: orders[index]),
        ),
      ),
    );
  }
}

class _EmptyOrders extends ConsumerWidget {
  const _EmptyOrders({required this.tab});

  final OrderTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      message: tab == OrderTab.all
          ? 'Bạn chưa có đơn hàng nào'
          : 'Không có đơn "${tab.label}"',
      hint: tab == OrderTab.all ? 'Đơn hàng bạn đặt sẽ hiển thị ở đây.' : null,
      action: tab == OrderTab.all
          ? FilledButton(
              onPressed: () {
                ref.read(catalogFilterProvider.notifier).browse();
                context.go(AppRoutes.customerCategory);
              },
              child: const Text('Mua sắm ngay'),
            )
          : null,
    );
  }
}

/// Thẻ tóm tắt một đơn: mã, ngày, sản phẩm đầu tiên, tổng tiền, hành động.
class OrderCard extends ConsumerWidget {
  const OrderCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final first = order.items.isEmpty ? null : order.items.first;
    final more = order.items.length - 1;
    final actions = OrderActions(context, ref, order);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => context.push(AppRoutes.customerOrder(order.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    order.isDelivery
                        ? Icons.local_shipping_outlined
                        : Icons.storefront_outlined,
                    size: 18,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.orderCode,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  OrderStatusBadge(order: order),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${formatFullDateTime(order.createdAt)} · '
                '${order.fulfillmentType?.label ?? order.channel.label}',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              if (first != null) ...[
                const Divider(height: 20),
                Row(
                  children: [
                    ItemThumbnail(url: first.image),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            first.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            more > 0
                                ? 'x${first.quantity} · và $more sản phẩm khác'
                                : 'x${first.quantity}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Tổng (${order.itemCount} sp): ',
                        style: const TextStyle(color: AppColors.muted),
                        children: [
                          TextSpan(
                            text: formatVnd(order.totalPrice),
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...actions.compactButtons(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
