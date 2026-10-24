import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_messenger.dart';
import '../../../core/widgets/state_views.dart';
import '../../customer/presentation/widgets/order_widgets.dart';
import '../../shared/models/models.dart';
import '../data/sales_repository.dart';
import 'sales_order_detail_screen.dart';

const _statusFilters = [
  (label: 'Tất cả', status: null, icon: Icons.all_inbox_outlined),
  (label: 'Chờ duyệt', status: 'PENDING_APPROVAL', icon: Icons.pending_actions_outlined),
  (label: 'Chờ thu ngân', status: 'PENDING_PAYMENT', icon: Icons.point_of_sale_outlined),
  (label: 'Hoàn thành', status: 'COMPLETED', icon: Icons.check_circle_outline),
  (label: 'Đã hủy', status: 'CANCELLED', icon: Icons.cancel_outlined),
];

class SalesOrdersScreen extends ConsumerStatefulWidget {
  const SalesOrdersScreen({super.key});

  @override
  ConsumerState<SalesOrdersScreen> createState() => _SalesOrdersScreenState();
}

class _SalesOrdersScreenState extends ConsumerState<SalesOrdersScreen> {
  int _selectedFilterIndex = 0;

  String? get _currentStatus => _statusFilters[_selectedFilterIndex].status;

  Future<void> _approveOrder(String orderId, String orderCode) async {
    try {
      await ref.read(salesRepositoryProvider).approveOfflineOrder(orderId);
      showAppSnackBar(
        'Đã duyệt đơn $orderCode gửi sang thu ngân! Đã giữ tồn kho.',
      );
      ref.invalidate(salesOrdersProvider(_currentStatus));
    } catch (e) {
      showAppSnackBar('Lỗi khi duyệt đơn: ${errorMessageOf(e)}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(salesOrdersProvider(_currentStatus));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < _statusFilters.length; i++) ...[
                        ChoiceChip(
                          avatar: Icon(
                            _statusFilters[i].icon,
                            size: 16,
                            color: _selectedFilterIndex == i
                                ? Colors.white
                                : AppColors.muted,
                          ),
                          label: Text(_statusFilters[i].label),
                          selected: _selectedFilterIndex == i,
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: _selectedFilterIndex == i
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: _selectedFilterIndex == i
                                ? Colors.white
                                : AppColors.ink,
                            fontWeight: _selectedFilterIndex == i
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedFilterIndex = i);
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1),

          // Orders List
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: AsyncValueView<List<Order>>(
                  value: ordersAsync,
                  onRetry: () =>
                      ref.invalidate(salesOrdersProvider(_currentStatus)),
                  data: (orders) {
                    if (orders.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () => ref
                            .refresh(salesOrdersProvider(_currentStatus).future),
                        child: ListView(
                          children: const [
                            SizedBox(height: 80),
                            EmptyState(
                              icon: Icons.receipt_long_outlined,
                              message: 'Chưa có đơn hàng tại quầy nào',
                              hint: 'Tạo đơn mới từ màn hình Bán hàng (POS).',
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => ref
                          .refresh(salesOrdersProvider(_currentStatus).future),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        itemCount: orders.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final isPendingApproval =
                              order.status == OrderStatus.pendingApproval;
                          final isMember =
                              (order.customerId?.id ?? '').isNotEmpty;

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SalesOrderDetailScreen(
                                      orderId: order.id,
                                    ),
                                  ),
                                ).then((_) {
                                  ref.invalidate(
                                    salesOrdersProvider(_currentStatus),
                                  );
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header: OrderCode + Badge
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.receipt_outlined,
                                                size: 16,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              order.orderCode,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SalesOrderStatusBadge(order: order),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Customer Row
                                    Row(
                                      children: [
                                        Icon(
                                          isMember
                                              ? Icons.star_rounded
                                              : Icons.person_outline,
                                          size: 18,
                                          color: isMember
                                              ? const Color(0xFFD97706)
                                              : AppColors.muted,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          (order.customerName ?? '').isNotEmpty
                                              ? order.customerName!
                                              : 'Khách vãng lai tại quầy',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isMember
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isMember
                                                ? AppColors.ink
                                                : Colors.black87,
                                          ),
                                        ),
                                        if ((order.customerPhone ?? '')
                                            .isNotEmpty) ...[
                                          const Text(
                                            ' • ',
                                            style: TextStyle(
                                              color: AppColors.muted,
                                            ),
                                          ),
                                          Text(
                                            order.customerPhone!,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.muted,
                                            ),
                                          ),
                                        ],
                                        if (isMember) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEF3C7),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Thành viên',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFB45309),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),

                                    // Date
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.schedule,
                                          size: 14,
                                          color: AppColors.muted,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          formatDateTime(order.createdAt),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20),

                                    // Footer: Item Count, Total Price, Quick Action
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${order.itemCount} sản phẩm',
                                            style: const TextStyle(
                                              color: AppColors.muted,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          formatVnd(order.totalPrice),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        if (isPendingApproval) ...[
                                          FilledButton.tonalIcon(
                                            style: FilledButton.styleFrom(
                                              backgroundColor: AppColors.primary
                                                  .withValues(alpha: 0.12),
                                              foregroundColor:
                                                  AppColors.primary,
                                              visualDensity:
                                                  VisualDensity.compact,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            icon: const Icon(
                                              Icons.check_circle_outline,
                                              size: 16,
                                            ),
                                            label: const Text(
                                              'Duyệt giỏ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            onPressed: () => _approveOrder(
                                              order.id,
                                              order.orderCode,
                                            ),
                                          ),
                                        ] else ...[
                                          const Icon(
                                            Icons.chevron_right,
                                            color: AppColors.muted,
                                            size: 20,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
