import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_messenger.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/state_views.dart';
import '../../customer/presentation/widgets/order_widgets.dart';
import '../../shared/models/models.dart';
import '../data/sales_repository.dart';

class SalesOrderDetailScreen extends ConsumerStatefulWidget {
  const SalesOrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<SalesOrderDetailScreen> createState() =>
      _SalesOrderDetailScreenState();
}

class _SalesOrderDetailScreenState
    extends ConsumerState<SalesOrderDetailScreen> {
  Order? _order;
  bool _loading = true;
  Object? _error;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final order = await ref
          .read(salesRepositoryProvider)
          .fetchOrderDetail(widget.orderId);
      if (mounted) {
        setState(() {
          _order = order;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  Future<void> _approve() async {
    if (_order == null || _actionLoading) return;
    setState(() => _actionLoading = true);
    try {
      final updated = await ref
          .read(salesRepositoryProvider)
          .approveOfflineOrder(_order!.id);
      if (mounted) {
        setState(() {
          _order = updated;
          _actionLoading = false;
        });
        showAppSnackBar('Đã duyệt đơn và giữ hàng thành công! Đã gửi sang thu ngân.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _actionLoading = false);
        showAppSnackBar('Lỗi khi duyệt đơn: ${errorMessageOf(e)}', isError: true);
      }
    }
  }

  /// Khách đổi ý: hủy giỏ tạm, hoặc rút đơn đã gửi thu ngân (trả hàng về kho).
  Future<void> _cancel() async {
    if (_order == null || _actionLoading) return;
    final reserved = _order!.status == OrderStatus.pendingPayment;

    final reason = await showReasonDialog(
      context,
      title: 'Hủy đơn ${_order!.orderCode}?',
      message: reserved
          ? 'Đơn đang chờ thu ngân. Hủy đơn sẽ trả lại hàng đang giữ về kho.'
          : 'Giỏ tạm sẽ bị hủy và không gửi sang thu ngân.',
      confirmLabel: 'Hủy đơn',
      hint: 'Lý do (không bắt buộc), ví dụ: khách đổi ý',
      maxLength: 255,
    );
    if (reason == null) return;

    setState(() => _actionLoading = true);
    try {
      final updated = await ref
          .read(salesRepositoryProvider)
          .cancelOfflineOrder(_order!.id, reason: reason);
      if (mounted) {
        setState(() {
          _order = updated;
          _actionLoading = false;
        });
        showAppSnackBar(
          reserved
              ? 'Đã hủy đơn và trả hàng về kho.'
              : 'Đã hủy giỏ tạm.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _actionLoading = false);
        showAppSnackBar('Lỗi khi hủy đơn: ${errorMessageOf(e)}', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết đơn hàng POS')),
        body: const LoadingView(),
      );
    }

    if (_error != null || _order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết đơn hàng POS')),
        body: ErrorState(
          error: _error ?? 'Không tìm thấy đơn hàng',
          onRetry: _load,
        ),
      );
    }

    final order = _order!;
    final isMember = (order.customerId?.id ?? '').isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              order.orderCode,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.copy, size: 16, color: AppColors.muted),
              tooltip: 'Sao chép mã đơn',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: order.orderCode));
                showAppSnackBar('Đã sao chép mã đơn: ${order.orderCode}');
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: _load,
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // 1. Order Status Header Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.storefront,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'ĐƠN TẠI QUẦY (OFFLINE)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SalesOrderStatusBadge(order: order),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 14, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Text(
                            'Thời gian tạo: ${formatDateTime(order.createdAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                          if (order.paidAt != null) ...[
                            const SizedBox(width: 12),
                            const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text(
                              'Thanh toán: ${formatDateTime(order.paidAt)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Customer Profile Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isMember
                            ? const Color(0xFFFEF3C7)
                            : AppColors.background,
                        child: Icon(
                          isMember ? Icons.star_rounded : Icons.person_outline,
                          color: isMember
                              ? const Color(0xFFD97706)
                              : AppColors.muted,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  (order.customerName ?? '').isNotEmpty
                                      ? order.customerName!
                                      : 'Khách vãng lai tại quầy',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                if (isMember) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFFDE68A),
                                      ),
                                    ),
                                    child: const Text(
                                      'THÀNH VIÊN',
                                      style: TextStyle(
                                        color: Color(0xFFB45309),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (order.customerPhone ?? '').isNotEmpty
                                  ? 'SĐT: ${order.customerPhone!}'
                                  : 'Không lưu số điện thoại',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Products List Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sản phẩm trong đơn (${order.itemCount})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${order.items.length} mặt hàng',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      for (final item in order.items) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  color: AppColors.background,
                                  child: Image.network(
                                    item.image ?? '',
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.spa_outlined,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'SKU: ${item.sku.isNotEmpty ? item.sku : "SP-${item.productId.id.substring(0, 6)}"}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${formatVnd(item.unitPrice)} × ${item.quantity}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                formatVnd(item.lineTotal),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item != order.items.last)
                          const Divider(height: 16),
                      ],
                      const Divider(height: 24),
                      // Summary Breakdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tiền hàng:',
                              style: TextStyle(color: AppColors.muted)),
                          Text(formatVnd(order.subtotal),
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      if (order.discountAmount > 0) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Giảm giá:',
                                style: TextStyle(color: AppColors.accent)),
                            Text('- ${formatVnd(order.discountAmount)}',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tổng thanh toán:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            formatVnd(order.totalPrice),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 4. Order Status Timeline Card
              if (order.statusHistory.isNotEmpty)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.timeline, size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Tiến trình xử lý đơn hàng',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        for (var i = 0; i < order.statusHistory.length; i++)
                          _buildTimelineItem(
                            order.statusHistory[i],
                            i == order.statusHistory.length - 1,
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildActionBar(order),
    );
  }

  /// Thanh thao tác của Sales. Sales không thu tiền: đơn đã gửi thu ngân chỉ
  /// còn nút hủy (khách đổi ý); đơn đã hủy thì không hiện thanh nào.
  Widget? _buildActionBar(Order order) {
    final actions = switch (order.status) {
      OrderStatus.pendingApproval => [
        _cancelButton('Hủy giỏ'),
        const SizedBox(width: 12),
        Expanded(
          child: AppButton(
            label: 'Duyệt giỏ gửi sang thu ngân (Giữ kho)',
            icon: Icons.check_circle_outline,
            loading: _actionLoading,
            onPressed: _approve,
          ),
        ),
      ],
      OrderStatus.pendingPayment => [
        const Icon(Icons.hourglass_top, color: Color(0xFF2563EB)),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Đã gửi sang thu ngân, chờ Quản lý thu tiền.',
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _cancelButton('Hủy đơn'),
      ],
      OrderStatus.completed => [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                SizedBox(width: 8),
                Text(
                  'Đơn hàng đã thanh toán & hoàn tất thành công',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      _ => null,
    };
    if (actions == null) return null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        // heightFactor: 1 — thiếu nó Align giãn hết chiều cao Scaffold dành
        // cho bottomNavigationBar và đè mất nội dung đơn.
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Row(children: actions),
          ),
        ),
      ),
    );
  }

  Widget _cancelButton(String label) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accent,
        side: const BorderSide(color: AppColors.accent),
        minimumSize: const Size(0, 48),
      ),
      onPressed: _actionLoading ? null : _cancel,
      child: Text(label),
    );
  }

  Widget _buildTimelineItem(StatusHistoryEntry step, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLast ? AppColors.primary : AppColors.border,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    step.status.label,
                    style: TextStyle(
                      fontWeight: isLast ? FontWeight.bold : FontWeight.w600,
                      fontSize: 13,
                      color: isLast ? AppColors.primary : AppColors.ink,
                    ),
                  ),
                  Text(
                    formatDateTime(step.changedAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              if ((step.note ?? '').isNotEmpty) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    step.note!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}
