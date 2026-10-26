import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../customer/orders/order_display.dart';
import '../../../shared/models/models.dart';

/// Nhãn và bước xử lý đơn online dưới góc nhìn cửa hàng.
extension ManagerOnlineOrderDisplay on Order {
  String get managerStatusLabel => switch (status) {
    OrderStatus.pending => 'Chờ xử lý',
    OrderStatus.preparing => 'Đang chuẩn bị',
    OrderStatus.readyForPickup => 'Chờ khách nhận',
    OrderStatus.completed => isDelivery ? 'Đã giao' : 'Khách đã nhận',
    OrderStatus.cancelled => 'Đã hủy',
    _ => status.label,
  };

  Color get managerStatusColor => switch (status) {
    OrderStatus.pending => AppColors.warning,
    OrderStatus.preparing => AppColors.info,
    OrderStatus.readyForPickup => AppColors.primary,
    OrderStatus.completed => AppColors.success,
    _ => AppColors.muted,
  };

  /// Chuyển khoản nhưng khách chưa trả: khi hoàn tất phải thu tiền mặt.
  bool get unpaidTransfer =>
      isBankTransfer && paymentStatus == PaymentStatus.unpaid;

  /// Bước kế tiếp Manager được chuyển:
  /// giao hàng PENDING → PREPARING → COMPLETED;
  /// nhận tại CH PENDING → PREPARING → READY_FOR_PICKUP → COMPLETED.
  ({OrderStatus next, String label, IconData icon})? get nextStep =>
      switch (status) {
        OrderStatus.pending => (
          next: OrderStatus.preparing,
          label: 'Bắt đầu chuẩn bị hàng',
          icon: Icons.inventory_outlined,
        ),
        OrderStatus.preparing when isDelivery => (
          next: OrderStatus.completed,
          label: 'Đã giao xong – Hoàn tất',
          icon: Icons.local_shipping_outlined,
        ),
        OrderStatus.preparing => (
          next: OrderStatus.readyForPickup,
          label: 'Hàng đã sẵn sàng cho khách nhận',
          icon: Icons.storefront_outlined,
        ),
        OrderStatus.readyForPickup => (
          next: OrderStatus.completed,
          label: 'Khách đã nhận – Hoàn tất',
          icon: Icons.check_circle_outline,
        ),
        _ => null,
      };

  bool get managerCanCancel => const {
    OrderStatus.pending,
    OrderStatus.preparing,
    OrderStatus.readyForPickup,
  }.contains(status);
}
