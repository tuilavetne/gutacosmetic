import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_messenger.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../shared/models/models.dart';
import '../cart/cart_controller.dart';
import '../catalog/product_reviews_controller.dart';
import '../data/order_repository.dart';
import '../data/product_repository.dart';
import '../data/review_repository.dart';
import 'order_display.dart';

/// Hành động của khách trên một đơn (dùng chung cho thẻ đơn và màn chi tiết).
class OrderActions {
  OrderActions(this.context, this.ref, this.order);

  final BuildContext context;
  final WidgetRef ref;
  final Order order;

  void _refreshOrders() => ref
    ..invalidate(customerOrdersProvider)
    ..invalidate(customerOrderProvider(order.id));

  /// Mở màn quét QR; quay lại thì tải lại đơn.
  Future<void> pay() async {
    await context.push(AppRoutes.customerOrderPayment(order.id));
    if (context.mounted) _refreshOrders();
  }

  Future<void> cancel() async {
    final reason = await showReasonDialog(
      context,
      title: 'Hủy đơn hàng',
      message:
          'Hủy đơn ${order.orderCode}? Sản phẩm sẽ được trả lại kho và '
          'không thể khôi phục đơn này.',
      confirmLabel: 'Hủy đơn',
    );
    if (reason == null) return;
    await ref
        .read(orderRepositoryProvider)
        .cancelOrder(
          order.id,
          reason: reason.isEmpty ? 'Khách hàng hủy đơn' : reason,
        );
    if (context.mounted) _refreshOrders();
    showAppSnackBar('Đã hủy đơn ${order.orderCode}.');
  }

  /// Thêm lại các sản phẩm của đơn vào giỏ rồi mở giỏ hàng.
  void reorder() {
    final added = ref
        .read(cartControllerProvider.notifier)
        .addItems(order.reorderLines);
    if (added == 0) {
      showAppSnackBar('Giỏ hàng đã có đủ các sản phẩm này.');
    } else {
      showAppSnackBar('Đã thêm $added sản phẩm vào giỏ hàng.');
    }
    context.push(AppRoutes.customerCart);
  }

  bool get canReorder => order.status.isFinal && order.reorderLines.isNotEmpty;

  /// Mở màn viết (hoặc sửa, nếu đã có) đánh giá của đơn.
  Future<void> review() async {
    await context.push(AppRoutes.customerOrderReview(order.id));
  }

  Future<void> deleteReview(Review review) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Xóa đánh giá',
      message:
          'Xóa đánh giá của đơn ${order.orderCode}? Bạn có thể viết lại '
          'đánh giá sau.',
      confirmLabel: 'Xóa',
      destructive: true,
    );
    if (!ok) return;
    await ref.read(reviewRepositoryProvider).deleteReview(review.id);
    if (context.mounted) invalidateReviewCaches(ref, order, review);
    showAppSnackBar('Đã xóa đánh giá.');
  }

  /// Nút chính trên thẻ đơn (tối đa một nút).
  List<Widget> compactButtons() => [
    if (order.awaitsBankTransfer)
      AppButton(expand: false, label: 'Thanh toán', onPressed: pay)
    else if (order.customerCanCancel)
      AppButton(
        expand: false,
        label: 'Hủy đơn',
        variant: AppButtonVariant.outlined,
        onPressed: cancel,
      )
    else if (order.canReview)
      AppButton(expand: false, label: 'Đánh giá', onPressed: review)
    else if (canReorder)
      AppButton(
        expand: false,
        label: 'Mua lại',
        variant: AppButtonVariant.outlined,
        onPressed: () async => reorder(),
      ),
  ];
}

/// Tải lại mọi nơi hiển thị đánh giá của [order] sau khi tạo/sửa/xóa: danh
/// sách đơn, chi tiết đơn, đánh giá của đơn và trang sản phẩm được đánh giá
/// (điểm trung bình đổi theo).
void invalidateReviewCaches(WidgetRef ref, Order order, [Review? review]) {
  ref
    ..invalidate(customerOrdersProvider)
    ..invalidate(customerOrderProvider(order.id))
    ..invalidate(orderReviewProvider(order.id));
  final productId = review?.productId?.id ?? order.reviewedProductId;
  if (productId != null && productId.isNotEmpty) {
    ref
      ..invalidate(productReviewsProvider(productId))
      ..invalidate(productDetailProvider(productId));
  }
}
