import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../customer/presentation/widgets/order_widgets.dart';
import '../../../manager/presentation/stock/stock_health.dart';
import '../../../shared/models/models.dart';
import '../../data/owner_repository.dart';

const _activeStatuses = {
  OrderStatus.pendingApproval,
  OrderStatus.pendingPayment,
  OrderStatus.pending,
  OrderStatus.preparing,
  OrderStatus.readyForPickup,
};

enum _OrderFilter {
  active('Đang xử lý'),
  completed('Hoàn tất'),
  cancelled('Đã hủy'),
  all('Tất cả');

  const _OrderFilter(this.label);
  final String label;

  bool matches(Order order) => switch (this) {
    active => _activeStatuses.contains(order.status),
    completed => order.status == OrderStatus.completed,
    cancelled => order.status == OrderStatus.cancelled,
    all => true,
  };
}

/// Owner xem (chỉ đọc) đơn hàng và tồn kho của một chi nhánh.
class StoreOverviewScreen extends StatelessWidget {
  const StoreOverviewScreen({super.key, required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(store.name),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Đơn hàng'),
              Tab(text: 'Tồn kho'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _StoreOrders(store: store),
            _StoreStock(store: store),
          ],
        ),
      ),
    );
  }
}

class _StoreOrders extends ConsumerStatefulWidget {
  const _StoreOrders({required this.store});

  final Store store;

  @override
  ConsumerState<_StoreOrders> createState() => _StoreOrdersState();
}

class _StoreOrdersState extends ConsumerState<_StoreOrders> {
  _OrderFilter _filter = _OrderFilter.active;

  @override
  Widget build(BuildContext context) {
    final provider = ownerStoreOrdersProvider(widget.store.id);
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              for (final filter in _OrderFilter.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter.label),
                    selected: filter == _filter,
                    onSelected: (_) => setState(() => _filter = filter),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: AsyncValueView<List<Order>>(
            value: ref.watch(provider),
            onRetry: () => ref.invalidate(provider),
            data: (orders) {
              final visible = orders.where(_filter.matches).toList();
              return RefreshIndicator(
                onRefresh: () => ref.refresh(provider.future),
                child: visible.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 60),
                          EmptyState(
                            icon: Icons.receipt_long_outlined,
                            message: 'Không có đơn phù hợp',
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final order = visible[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(order.orderCode),
                            subtitle: Text(
                              '${order.channel == OrderChannel.online ? 'Online' : 'Tại quầy'}'
                              ' • ${order.customerName ?? 'Khách'} • ${order.itemCount} sp'
                              '\n${formatDateTime(order.createdAt)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatVnd(order.totalPrice),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SalesOrderStatusBadge(order: order),
                              ],
                            ),
                          );
                        },
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StoreStock extends ConsumerWidget {
  const _StoreStock({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueView<List<ProductInventory>>(
      value: ref.watch(ownerStockProvider),
      onRetry: () => ref.invalidate(ownerStockProvider),
      data: (items) {
        final now = DateTime.now();
        final rows = stockRowsFor(items, store.id)
          ..sort(
            (a, b) => a.stock.availableStock.compareTo(b.stock.availableStock),
          );
        return RefreshIndicator(
          onRefresh: () => ref.refresh(ownerStockProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final row = rows[index];
              final stock = row.stock;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(row.product.name),
                subtitle: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Tổng ${stock.totalStock} • Giữ ${stock.reservedStock} • '
                      'Khả dụng ${stock.availableStock}'
                      '${stock.expiryDate != null ? ' • HSD ${formatDate(stock.expiryDate)}' : ''}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    for (final flag in stock.flags(now))
                      StatusChip(label: flag.label, color: flag.color),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
