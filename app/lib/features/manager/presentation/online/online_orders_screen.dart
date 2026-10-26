import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../customer/orders/order_display.dart';
import '../../../shared/models/models.dart';
import '../../data/manager_repository.dart';
import 'online_order_display.dart';
import 'online_order_screen.dart';

const _filters = <({String label, OrderStatus? status})>[
  (label: 'Chờ xử lý', status: OrderStatus.pending),
  (label: 'Đang chuẩn bị', status: OrderStatus.preparing),
  (label: 'Chờ khách nhận', status: OrderStatus.readyForPickup),
  (label: 'Hoàn tất', status: OrderStatus.completed),
  (label: 'Đã hủy', status: OrderStatus.cancelled),
  (label: 'Tất cả', status: null),
];

/// Tab Đơn online: đơn giao tận nơi và nhận tại cửa hàng của chi nhánh.
class OnlineOrdersScreen extends ConsumerStatefulWidget {
  const OnlineOrdersScreen({super.key});

  static const refreshInterval = Duration(seconds: 30);

  @override
  ConsumerState<OnlineOrdersScreen> createState() => _OnlineOrdersScreenState();
}

class _OnlineOrdersScreenState extends ConsumerState<OnlineOrdersScreen> {
  int _filterIndex = 0;
  Timer? _refreshTimer;

  OrderStatus? get _status => _filters[_filterIndex].status;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(
      OnlineOrdersScreen.refreshInterval,
      (_) => ref.invalidate(managerOnlineOrdersProvider(_status)),
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
        builder: (_) => OnlineOrderScreen(orderId: order.id),
      ),
    );
    ref.invalidate(managerOnlineOrdersProvider);
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(managerOnlineOrdersProvider(_status));

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                for (var i = 0; i < _filters.length; i++) ...[
                  ChoiceChip(
                    label: Text(_filters[i].label),
                    selected: i == _filterIndex,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: i == _filterIndex ? Colors.white : AppColors.ink,
                      fontWeight: i == _filterIndex
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                    onSelected: (_) => setState(() => _filterIndex = i),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: AsyncValueView<List<Order>>(
                  value: ordersAsync,
                  onRetry: () =>
                      ref.invalidate(managerOnlineOrdersProvider(_status)),
                  data: (orders) => RefreshIndicator(
                    onRefresh: () => ref.refresh(
                      managerOnlineOrdersProvider(_status).future,
                    ),
                    child: orders.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 80),
                              EmptyState(
                                icon: Icons.local_shipping_outlined,
                                message: 'Không có đơn online nào',
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: orders.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) => _OnlineOrderCard(
                              order: orders[index],
                              onTap: () => _open(orders[index]),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineOrderCard extends StatelessWidget {
  const _OnlineOrderCard({required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    order.isDelivery
                        ? Icons.local_shipping_outlined
                        : Icons.storefront_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.orderCode,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  StatusChip(
                    label: order.managerStatusLabel,
                    color: order.managerStatusColor,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                [
                  order.fulfillmentType?.label ?? 'Online',
                  order.customerName ?? 'Khách hàng',
                  '${order.itemCount} sp',
                ].join(' • '),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.unpaidTransfer
                          ? 'Chuyển khoản • CHƯA TRẢ'
                          : '${order.paymentMethodLabel} • ${order.paymentStatusLabel}',
                      style: TextStyle(
                        fontSize: 12,
                        color: order.unpaidTransfer
                            ? AppColors.accent
                            : AppColors.muted,
                        fontWeight: order.unpaidTransfer
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    formatVnd(order.totalPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Text(
                formatDateTime(order.createdAt),
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
