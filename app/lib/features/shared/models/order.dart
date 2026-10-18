import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'json_converters.dart';
import 'product.dart';
import 'store.dart';
import 'user.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
abstract class ShippingAddress with _$ShippingAddress {
  const factory ShippingAddress({
    @Default('') String recipientName,
    @Default('') String phone,
    @Default('') String addressLine,
  }) = _ShippingAddress;

  factory ShippingAddress.fromJson(Map<String, dynamic> json) =>
      _$ShippingAddressFromJson(json);
}

/// Snapshot sản phẩm tại thời điểm đặt.
@freezed
abstract class OrderItem with _$OrderItem {
  const factory OrderItem({
    @ProductRefConverter() required EntityRef<Product> productId,
    @Default('') String sku,
    @Default('') String name,
    String? image,
    @Default(1) int quantity,
    @Default(0) int unitPrice,
    @Default(0) int lineTotal,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}

@freezed
abstract class StatusHistoryEntry with _$StatusHistoryEntry {
  const factory StatusHistoryEntry({
    @JsonKey(readValue: readEnumValue) required OrderStatus status,
    @UserRefConverter() EntityRef<AppUser>? changedBy,
    String? note,
    DateTime? changedAt,
  }) = _StatusHistoryEntry;

  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$StatusHistoryEntryFromJson(json);
}

@freezed
abstract class Order with _$Order {
  const Order._();

  const factory Order({
    @JsonKey(name: '_id') required String id,
    @Default('') String orderCode,
    @JsonKey(readValue: readEnumValue)
    @Default(OrderChannel.online)
    OrderChannel channel,
    @JsonKey(readValue: readEnumValue) FulfillmentType? fulfillmentType,

    // Khách hàng — `customerId` null với khách vãng lai.
    @UserRefConverter() EntityRef<AppUser>? customerId,
    String? customerName,
    String? customerPhone,
    ShippingAddress? shippingAddress,

    // Hàng hóa
    @StoreRefConverter() EntityRef<Store>? storeId,
    @Default(<OrderItem>[]) List<OrderItem> items,

    // Tiền
    @Default(0) int subtotal,
    @Default(0) int discountAmount,
    @Default(0) int shippingFee,
    @Default(0) int totalPrice,
    @Default(0) int pointsUsed,
    @Default(0) int pointsEarned,

    // Trạng thái và thanh toán
    @JsonKey(readValue: readEnumValue) required OrderStatus status,
    @JsonKey(readValue: readEnumValue)
    @Default(PaymentStatus.unpaid)
    PaymentStatus paymentStatus,
    @JsonKey(readValue: readEnumValue, unknownEnumValue: RefundStatus.none)
    @Default(RefundStatus.none)
    RefundStatus refundStatus,
    @JsonKey(readValue: readEnumValue) PaymentMethod? paymentMethod,

    // PayOS
    String? paymentProvider,
    @StringishConverter() String? paymentOrderCode,
    String? paymentLinkId,
    String? checkoutUrl,
    String? qrCode,
    String? paymentReference,
    @FlexibleDateTimeConverter() DateTime? paymentExpiresAt,

    // Theo dõi xử lý
    @Default(false) bool inventoryReserved,
    @UserRefConverter() EntityRef<AppUser>? createdBySalesId,
    @UserRefConverter() EntityRef<AppUser>? approvedBySalesId,
    @UserRefConverter() EntityRef<AppUser>? paidByManagerId,
    @UserRefConverter() EntityRef<AppUser>? cancelledBy,
    String? cancellationReason,
    @Default(<StatusHistoryEntry>[]) List<StatusHistoryEntry> statusHistory,
    DateTime? paidAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    @Default(false) bool isReviewed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  int get itemCount => items.fold(0, (sum, e) => sum + e.quantity);

  String get storeName => storeId?.data?.name ?? '';

  /// Khách thành viên (có tài khoản) — được cộng điểm, đổi quà.
  bool get hasMemberCustomer =>
      customerId != null && !customerId!.id.startsWith('guest:');

  String get customerDisplayName {
    final populated = customerId?.data?.fullName;
    if (populated != null && populated.isNotEmpty) return populated;
    if (customerName != null && customerName!.isNotEmpty) return customerName!;
    return shippingAddress?.recipientName ?? 'Khách lẻ';
  }

  String? get customerDisplayPhone =>
      customerId?.data?.phone ?? customerPhone ?? shippingAddress?.phone;

  bool get isBankTransfer => paymentMethod == PaymentMethod.bankTransfer;
  bool get isPaid => paymentStatus == PaymentStatus.paid;
  bool get awaitsRefund => refundStatus == RefundStatus.pendingRefund;

  /// Đơn chuyển khoản chưa trả, còn có thể thanh toán.
  bool get awaitsBankTransfer =>
      isBankTransfer &&
      paymentStatus == PaymentStatus.unpaid &&
      status == OrderStatus.pending;
}
