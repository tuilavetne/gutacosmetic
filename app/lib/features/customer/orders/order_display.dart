import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../core/utils/constants.dart';
import '../../shared/models/models.dart';
import '../cart/cart_item.dart';

/// Tab lọc ở màn Đơn hàng (lọc phía client trên toàn bộ đơn của khách).
enum OrderTab {
  all('Tất cả'),
  pending('Chờ xác nhận'),
  processing('Đang xử lý'),
  completed('Hoàn tất'),
  cancelled('Đã hủy');

  const OrderTab(this.label);

  final String label;

  bool matches(Order order) => switch (this) {
    all => true,
    pending => order.status == OrderStatus.pending,
    completed => order.status == OrderStatus.completed,
    cancelled => order.status == OrderStatus.cancelled,
    processing => order.status != OrderStatus.pending && !order.status.isFinal,
  };
}

/// Một bước trên thanh tiến trình của đơn online.
typedef OrderStep = ({String label, DateTime? at});

/// Cách hiển thị đơn hàng cho khách (nhãn trong enum dành cho nhân viên).
extension CustomerOrderDisplay on Order {
  bool get isDelivery => fulfillmentType == FulfillmentType.delivery;
  bool get isPickup => fulfillmentType == FulfillmentType.storePickup;

  String get customerStatusLabel => switch (status) {
    OrderStatus.pending =>
      awaitsBankTransfer ? 'Chờ thanh toán' : 'Chờ xác nhận',
    OrderStatus.preparing => isDelivery ? 'Đang giao hàng' : 'Đang chuẩn bị',
    OrderStatus.readyForPickup => 'Sẵn sàng nhận hàng',
    OrderStatus.completed =>
      isDelivery
          ? 'Đã giao'
          : isPickup
          ? 'Đã nhận hàng'
          : 'Hoàn tất',
    OrderStatus.cancelled => 'Đã hủy',
    OrderStatus.paid => 'Đã thanh toán',
    OrderStatus.draft ||
    OrderStatus.pendingApproval ||
    OrderStatus.pendingPayment => 'Đang xử lý',
  };

  Color get customerStatusColor => switch (status) {
    OrderStatus.pending =>
      awaitsBankTransfer ? AppColors.accent : AppColors.warning,
    OrderStatus.completed => AppColors.success,
    OrderStatus.cancelled => AppColors.muted,
    OrderStatus.readyForPickup => AppColors.primary,
    _ => AppColors.info,
  };

  /// Khách được hủy đơn online đang chờ xác nhận và chưa thanh toán (đơn đã
  /// trả tiền cần cửa hàng hoàn tiền).
  bool get customerCanCancel =>
      channel == OrderChannel.online &&
      status == OrderStatus.pending &&
      !isPaid;

  String get paymentMethodLabel => switch (paymentMethod) {
    PaymentMethod.cod =>
      isPickup
          ? 'Thanh toán khi nhận tại cửa hàng'
          : 'Thanh toán khi nhận hàng (COD)',
    PaymentMethod.bankTransfer => 'Chuyển khoản QR PayOS',
    PaymentMethod.cash => 'Tiền mặt',
    PaymentMethod.card => 'Thẻ',
    PaymentMethod.onlinePayment => 'Thanh toán online',
    PaymentMethod.payAtStore => 'Thanh toán tại cửa hàng',
    null => 'Chưa chọn',
  };

  String get paymentStatusLabel {
    if (isPaid) return 'Đã thanh toán';
    if (paymentStatus == PaymentStatus.failed) return 'Thanh toán thất bại';
    if (paymentStatus == PaymentStatus.refunded) return 'Đã hoàn tiền';
    if (status == OrderStatus.cancelled) return 'Chưa thanh toán';
    return paymentMethod == PaymentMethod.cod
        ? (isPickup ? 'Trả khi nhận tại cửa hàng' : 'Trả khi nhận hàng')
        : 'Chưa thanh toán';
  }

  /// Lý do hủy đã dịch (lý do tự động của backend là tiếng Anh).
  String? get cancellationReasonLabel {
    final reason = cancellationReason?.trim() ?? '';
    if (reason.isEmpty) return null;
    if (reason.toLowerCase().contains('payos') &&
        reason.toLowerCase().contains('expired')) {
      return 'Mã QR thanh toán đã hết hạn trước khi nhận được tiền.';
    }
    return reason;
  }

  /// Điểm sẽ được cộng khi đơn hoàn tất (1 điểm / 10.000đ).
  int get expectedPoints =>
      pointsEarned > 0 ? pointsEarned : totalPrice ~/ AppConstants.vndPerPoint;

  /// Các bước của đơn online; rỗng với đơn tại quầy hoặc đơn đã hủy.
  List<OrderStep> get progressSteps {
    if (channel != OrderChannel.online || status == OrderStatus.cancelled) {
      return const [];
    }
    DateTime? at(OrderStatus s) {
      for (final e in statusHistory.reversed) {
        if (e.status == s) return e.changedAt;
      }
      return null;
    }

    final placed = (
      label: 'Đặt hàng',
      at: createdAt ?? at(OrderStatus.pending),
    );
    if (isDelivery) {
      return [
        placed,
        (label: 'Đang giao', at: at(OrderStatus.preparing)),
        (label: 'Đã giao', at: completedAt ?? at(OrderStatus.completed)),
      ];
    }
    return [
      placed,
      (label: 'Chuẩn bị', at: at(OrderStatus.preparing)),
      (label: 'Sẵn sàng', at: at(OrderStatus.readyForPickup)),
      (label: 'Đã nhận', at: completedAt ?? at(OrderStatus.completed)),
    ];
  }

  /// Chỉ số bước hiện tại trong [progressSteps].
  int get currentStepIndex {
    if (isDelivery) {
      return switch (status) {
        OrderStatus.completed => 2,
        OrderStatus.preparing => 1,
        _ => 0,
      };
    }
    return switch (status) {
      OrderStatus.completed => 3,
      OrderStatus.readyForPickup => 2,
      OrderStatus.preparing => 1,
      _ => 0,
    };
  }

  /// Dòng giỏ hàng để "Mua lại" (giá được cập nhật lại khi thanh toán).
  List<CartItem> get reorderLines => [
    for (final item in items)
      if (item.productId.id.isNotEmpty)
        CartItem(
          productId: item.productId.id,
          sku: item.sku,
          name: item.name,
          brand: item.productId.data?.brand ?? '',
          image: item.image,
          unitPrice: item.unitPrice,
          quantity: item.quantity,
        ),
  ];
}
