import 'package:json_annotation/json_annotation.dart';

// Giá trị JSON của backend là SCREAMING_SNAKE_CASE (ví dụ `PENDING_APPROVAL`),
// map 1-1 với tên enum lowerCamelCase.

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum UserRole {
  owner,
  manager,
  sales,
  customer;

  bool get isStaff => this == manager || this == sales;

  String get label => switch (this) {
    owner => 'Chủ chuỗi',
    manager => 'Quản lý',
    sales => 'Tư vấn viên',
    customer => 'Khách hàng',
  };
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum AuthProvider { local, google }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum StoreType {
  central,
  branch;

  String get label => switch (this) {
    central => 'Kho tổng',
    branch => 'Chi nhánh',
  };
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum OrderChannel {
  online,
  offline;

  String get label => switch (this) {
    online => 'Online',
    offline => 'Tại quầy',
  };
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum FulfillmentType {
  delivery,
  storePickup,
  inStore;

  String get label => switch (this) {
    delivery => 'Giao hàng tận nơi',
    storePickup => 'Nhận tại cửa hàng',
    inStore => 'Mua tại quầy',
  };
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum OrderStatus {
  draft,
  pendingApproval,
  pendingPayment,
  pending,
  paid,
  preparing,
  readyForPickup,
  completed,
  cancelled;

  String get label => switch (this) {
    draft => 'Nháp',
    pendingApproval => 'Chờ Sales gửi',
    pendingPayment => 'Chờ thu ngân',
    pending => 'Chờ xác nhận',
    paid => 'Đã thanh toán',
    preparing => 'Đang xử lý',
    readyForPickup => 'Sẵn sàng nhận',
    completed => 'Hoàn tất',
    cancelled => 'Đã hủy',
  };

  bool get isFinal => this == completed || this == cancelled;
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum PaymentStatus {
  unpaid,
  paid,
  refunded,
  failed;

  String get label => switch (this) {
    unpaid => 'Chưa thanh toán',
    paid => 'Đã thanh toán',
    refunded => 'Đã hoàn tiền',
    failed => 'Thất bại',
  };
}

/// Đơn hủy sau khi đã nhận tiền chờ cửa hàng hoàn tiền.
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum RefundStatus {
  none,
  pendingRefund,
  refunded;

  String get label => switch (this) {
    none => 'Không hoàn tiền',
    pendingRefund => 'Chờ hoàn tiền',
    refunded => 'Đã hoàn tiền',
  };
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum PaymentMethod {
  cash,
  card,
  bankTransfer,
  cod,
  onlinePayment,
  payAtStore;

  String get label => switch (this) {
    cash => 'Tiền mặt',
    card => 'Thẻ',
    bankTransfer => 'Chuyển khoản QR',
    cod => 'COD',
    onlinePayment => 'Thanh toán online',
    payAtStore => 'Trả tại cửa hàng',
  };
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum AdjustmentType {
  damaged,
  defective,
  lost,
  expired,
  other;

  String get label => switch (this) {
    damaged => 'Hàng hỏng',
    defective => 'Hàng lỗi',
    lost => 'Mất mát',
    expired => 'Hết hạn',
    other => 'Khác',
  };
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ReceiptSource {
  direct,
  salesRequest,
  transfer,
  returnRejected;

  String get label => switch (this) {
    direct => 'Nhập trực tiếp',
    salesRequest => 'Theo đề xuất Sales',
    transfer => 'Hàng chuyển đến',
    returnRejected => 'Trả hàng bị từ chối',
  };
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
/// Sales đề xuất (open) → Manager chuyển lên (forwarded) → Owner duyệt, tạo
/// phiếu chuyển (inTransit) → Manager nhận hàng (resolved). Hủy/từ chối:
/// cancelled.
enum RestockStatus {
  open,
  forwarded,
  inTransit,
  resolved,
  cancelled;

  String get label => switch (this) {
    open => 'Chờ Manager',
    forwarded => 'Chờ Owner duyệt',
    inTransit => 'Đang chuyển hàng',
    resolved => 'Đã nhận hàng',
    cancelled => 'Đã hủy',
  };

  /// Còn đang xử lý (chưa nhận hàng, chưa hủy).
  bool get isActive => this == open || this == forwarded || this == inTransit;
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ReturnRequestStatus {
  pending,
  approved,
  rejected;

  String get label => switch (this) {
    pending => 'Chờ Owner duyệt',
    approved => 'Đã duyệt trả',
    rejected => 'Bị từ chối',
  };
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ReturnReasonType {
  damaged,
  defective,
  expired,
  other;

  String get label => switch (this) {
    damaged => 'Hàng hỏng',
    defective => 'Hàng lỗi',
    expired => 'Hết hạn',
    other => 'Khác',
  };
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum TransferStatus {
  pending,
  confirmed,
  cancelled;

  String get label => switch (this) {
    pending => 'Đang chờ nhận',
    confirmed => 'Đã nhận',
    cancelled => 'Đã hủy',
  };
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum InventoryAlertType {
  lowStock,
  expiringSoon,
  expired,
  unknown;

  String get label => switch (this) {
    lowStock => 'Tồn thấp',
    expiringSoon => 'Sắp hết hạn',
    expired => 'Đã hết hạn',
    unknown => 'Cảnh báo',
  };

  bool get isExpiry => this == expiringSoon || this == expired;
}

/// Giá trị JSON của mọi enum: `pendingApproval.apiValue` → `PENDING_APPROVAL`.
extension ApiEnumValue on Enum {
  String get apiValue => toScreamingSnake(name);
}

/// `pendingApproval` → `PENDING_APPROVAL`.
String toScreamingSnake(String camel) => camel
    .replaceAllMapped(RegExp('([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
    .toUpperCase();
