import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_messenger.dart';
import '../../../core/widgets/state_views.dart';
import '../../shared/models/models.dart';
import '../data/order_repository.dart';
import '../data/review_repository.dart';
import '../orders/order_actions.dart';
import '../orders/order_display.dart';
import 'widgets/order_widgets.dart';
import 'widgets/product_reviews_section.dart' show ReviewCard;

/// Chi tiết đơn: trạng thái + tiến trình, nhận hàng, sản phẩm, thanh toán,
/// lịch sử. Hủy đơn / thanh toán QR / mua lại ở thanh dưới.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(customerOrderProvider(orderId));
    final order = orderAsync.value;
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
      body: AsyncValueView<Order>(
        value: orderAsync,
        onRetry: () => ref.invalidate(customerOrderProvider(orderId)),
        data: (order) => RefreshIndicator(
          onRefresh: () => ref.refresh(customerOrderProvider(orderId).future),
          child: OrderContentWidth(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _StatusCard(order: order),
                _ReceiveCard(order: order),
                TitledCard(
                  title: 'Sản phẩm (${order.itemCount})',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      for (final item in order.items)
                        OrderLineTile(
                          name: item.name,
                          image: item.image,
                          quantity: item.quantity,
                          unitPrice: item.unitPrice,
                          onTap: item.productId.id.isEmpty
                              ? null
                              : () => context.push(
                                  AppRoutes.customerProduct(item.productId.id),
                                ),
                        ),
                    ],
                  ),
                ),
                if (order.status == OrderStatus.completed)
                  _ReviewSection(order: order),
                _PaymentCard(order: order),
                _HistoryCard(order: order),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: order == null ? null : _ActionBar(order: order),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.order});

  final Order order;

  String get _message {
    final store = order.storeName.isEmpty ? 'cửa hàng' : order.storeName;
    return switch (order.status) {
      OrderStatus.pending when order.awaitsBankTransfer =>
        'Vui lòng chuyển khoản trước '
            '${formatDateTime(order.paymentExpiresAt)} để giữ đơn. Quá hạn '
            'đơn sẽ tự động hủy.',
      OrderStatus.pending when order.isPaid =>
        'Đã nhận thanh toán. Cửa hàng sẽ sớm xác nhận đơn của bạn.',
      OrderStatus.pending => 'Cửa hàng sẽ sớm xác nhận đơn của bạn.',
      OrderStatus.preparing =>
        order.isDelivery
            ? 'Đơn đang được chuẩn bị và giao đến bạn.'
            : '$store đang chuẩn bị hàng cho bạn.',
      OrderStatus.readyForPickup =>
        'Hàng đã sẵn sàng tại $store. Đọc mã đơn tại quầy để nhận hàng.',
      OrderStatus.completed =>
        'Đơn hoàn tất lúc ${formatFullDateTime(order.completedAt ?? order.updatedAt)}.',
      OrderStatus.cancelled =>
        'Đơn đã hủy lúc ${formatFullDateTime(order.cancelledAt ?? order.updatedAt)}.'
            '${order.cancellationReasonLabel == null ? '' : '\nLý do: ${order.cancellationReasonLabel}'}',
      _ => 'Đơn hàng đang được xử lý.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = order.customerStatusColor;
    final steps = order.progressSteps;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Sao chép mã đơn',
                  visualDensity: VisualDensity.compact,
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: order.orderCode),
                    );
                    showAppSnackBar('Đã sao chép mã đơn.');
                  },
                  icon: const Icon(Icons.copy, size: 18),
                ),
              ],
            ),
            Text(
              'Đặt lúc ${formatFullDateTime(order.createdAt)}',
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.customerStatusLabel,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_message, style: const TextStyle(height: 1.4)),
                ],
              ),
            ),
            if (steps.isNotEmpty) ...[
              const SizedBox(height: 16),
              _ProgressSteps(steps: steps, current: order.currentStepIndex),
            ],
          ],
        ),
      ),
    );
  }
}

/// Thanh tiến trình ngang: chấm tròn + nhãn + giờ.
class _ProgressSteps extends StatelessWidget {
  const _ProgressSteps({required this.steps, required this.current});

  final List<OrderStep> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: i == 0
                          ? const SizedBox()
                          : Container(
                              height: 2,
                              color: i <= current
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                    ),
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: i <= current
                          ? AppColors.primary
                          : AppColors.border,
                      child: i <= current
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : Text(
                              '${i + 1}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                    ),
                    Expanded(
                      child: i == steps.length - 1
                          ? const SizedBox()
                          : Container(
                              height: 2,
                              color: i < current
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  steps[i].label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: i == current
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: i <= current ? AppColors.ink : AppColors.muted,
                  ),
                ),
                if (i <= current && steps[i].at != null)
                  Text(
                    formatDateTime(steps[i].at),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ReceiveCard extends StatelessWidget {
  const _ReceiveCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final store = order.storeId?.data;
    final address = order.shippingAddress;
    return TitledCard(
      title: order.isDelivery ? 'Địa chỉ nhận hàng' : 'Cửa hàng nhận hàng',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (order.isDelivery && address != null) ...[
            _IconLine(
              icon: Icons.person_outline,
              text: '${address.recipientName} · ${formatPhone(address.phone)}',
              bold: true,
            ),
            _IconLine(
              icon: Icons.location_on_outlined,
              text: address.addressLine,
            ),
            if (store != null)
              _IconLine(
                icon: Icons.storefront_outlined,
                text: 'Giao từ ${store.name}',
                muted: true,
              ),
          ] else if (store != null) ...[
            _IconLine(
              icon: Icons.storefront_outlined,
              text: store.name,
              bold: true,
            ),
            if (store.address.isNotEmpty)
              _IconLine(icon: Icons.location_on_outlined, text: store.address),
            if (store.phone.isNotEmpty)
              InkWell(
                onTap: () => launchUrl(Uri(scheme: 'tel', path: store.phone)),
                child: _IconLine(
                  icon: Icons.phone_outlined,
                  text: formatPhone(store.phone),
                  color: AppColors.primary,
                ),
              ),
          ] else
            const Text(
              'Không có thông tin nhận hàng.',
              style: TextStyle(color: AppColors.muted),
            ),
        ],
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({
    required this.icon,
    required this.text,
    this.bold = false,
    this.muted = false,
    this.color,
  });

  final IconData icon;
  final String text;
  final bool bold;
  final bool muted;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color ?? AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                color: color ?? (muted ? AppColors.muted : AppColors.ink),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final statusColor = order.isPaid
        ? AppColors.success
        : order.paymentStatus == PaymentStatus.failed
        ? AppColors.accent
        : AppColors.warning;
    return TitledCard(
      title: 'Thanh toán',
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                order.isBankTransfer
                    ? Icons.qr_code_2
                    : Icons.payments_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  order.paymentMethodLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                order.paymentStatusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          MoneyRow(label: 'Tạm tính', value: formatVnd(order.subtotal)),
          MoneyRow(
            label: 'Phí vận chuyển',
            value: order.shippingFee == 0
                ? 'Miễn phí'
                : formatVnd(order.shippingFee),
          ),
          if (order.discountAmount > 0)
            MoneyRow(
              label: 'Giảm giá',
              value: '-${formatVnd(order.discountAmount)}',
              valueColor: AppColors.success,
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1),
          ),
          MoneyRow(
            label: 'Tổng cộng',
            value: formatVnd(order.totalPrice),
            emphasize: true,
          ),
          if (order.status != OrderStatus.cancelled && order.expectedPoints > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.stars_outlined,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.status == OrderStatus.completed
                          ? 'Đã nhận ${order.expectedPoints} điểm thành viên'
                          : 'Nhận ${order.expectedPoints} điểm khi đơn hoàn tất',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.order});

  final Order order;

  String _label(OrderStatus status) => switch (status) {
    OrderStatus.pending => 'Đặt hàng thành công',
    OrderStatus.preparing =>
      order.isDelivery
          ? 'Cửa hàng xác nhận, đang giao'
          : 'Cửa hàng đang chuẩn bị',
    OrderStatus.readyForPickup => 'Sẵn sàng nhận hàng',
    OrderStatus.completed =>
      order.isDelivery ? 'Giao hàng thành công' : 'Hoàn tất',
    OrderStatus.cancelled => 'Đơn đã hủy',
    _ => status.label,
  };

  @override
  Widget build(BuildContext context) {
    final events = <({String label, DateTime at})>[
      for (final e in order.statusHistory)
        if (e.changedAt != null) (label: _label(e.status), at: e.changedAt!),
      if (order.paidAt != null)
        (label: 'Đã nhận thanh toán', at: order.paidAt!),
    ]..sort((a, b) => b.at.compareTo(a.at));
    if (events.isEmpty) return const SizedBox.shrink();

    return TitledCard(
      title: 'Lịch sử đơn hàng',
      child: Column(
        children: [
          for (var i = 0; i < events.length; i++)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: i == 0 ? AppColors.primary : AppColors.border,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (i < events.length - 1)
                      Container(width: 2, height: 30, color: AppColors.border),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    events[i].label,
                    style: TextStyle(
                      fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  formatFullDateTime(events[i].at),
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Đơn hoàn tất: mời đánh giá, hoặc hiện đánh giá đã viết kèm Sửa / Xóa.
class _ReviewSection extends ConsumerWidget {
  const _ReviewSection({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = OrderActions(context, ref, order);
    if (!order.isReviewed) {
      return TitledCard(
        title: 'Đánh giá của bạn',
        child: Row(
          children: [
            const Icon(Icons.rate_review_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Bạn thấy sản phẩm thế nào? Chia sẻ cảm nhận để giúp những '
                'khách hàng khác nhé.',
                style: TextStyle(height: 1.4),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: actions.review,
              child: const Text('Viết đánh giá'),
            ),
          ],
        ),
      );
    }

    final reviewAsync = ref.watch(orderReviewProvider(order.id));
    final review = reviewAsync.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Đánh giá của bạn',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (review != null) ...[
                TextButton.icon(
                  onPressed: actions.review,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Sửa'),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                  ),
                  onPressed: () => _delete(actions, review),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Xóa'),
                ),
              ],
            ],
          ),
        ),
        if (review != null)
          ReviewCard(review: review)
        else if (reviewAsync.hasError)
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: InlineError(
                message: 'Không tải được đánh giá.',
                onRetry: () => ref.invalidate(orderReviewProvider(order.id)),
              ),
            ),
          )
        else if (reviewAsync.isLoading)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Không tìm thấy đánh giá của đơn này.',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _delete(OrderActions actions, Review review) async {
    try {
      await actions.deleteReview(review);
    } catch (e) {
      showAppSnackBar(errorMessageOf(e), isError: true);
    }
  }
}

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = OrderActions(context, ref, order);
    final buttons = <Widget>[
      if (order.customerCanCancel)
        Expanded(
          child: AppButton(
            label: 'Hủy đơn',
            variant: AppButtonVariant.outlined,
            onPressed: actions.cancel,
          ),
        ),
      if (order.awaitsBankTransfer)
        Expanded(
          child: AppButton(
            label: 'Thanh toán ngay',
            icon: Icons.qr_code_2,
            onPressed: actions.pay,
          ),
        ),
      if (actions.canReorder)
        Expanded(
          child: AppButton(
            label: 'Mua lại',
            icon: Icons.replay,
            variant: order.canReview
                ? AppButtonVariant.outlined
                : AppButtonVariant.filled,
            onPressed: () async => actions.reorder(),
          ),
        ),
      if (order.canReview)
        Expanded(
          child: AppButton(
            label: 'Đánh giá',
            icon: Icons.star_outline_rounded,
            onPressed: actions.review,
          ),
        ),
    ];
    if (buttons.isEmpty) return const SizedBox.shrink();
    return BottomActionBar(
      child: Row(
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            buttons[i],
          ],
        ],
      ),
    );
  }
}
