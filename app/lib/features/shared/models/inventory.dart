import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'json_converters.dart';
import 'product.dart';
import 'store.dart';
import 'user.dart';

part 'inventory.freezed.dart';
part 'inventory.g.dart';

/// Tồn kho của một sản phẩm tại một cửa hàng (`GET /inventory/products`).
@freezed
abstract class StoreStock with _$StoreStock {
  const StoreStock._();

  const factory StoreStock({
    required Store store,
    @Default(0) int totalStock,
    @Default(0) int reservedStock,
    @Default(0) int availableStock,
    DateTime? expiryDate,
    String? expiryDateLabel,
    int? daysUntilExpiry,
    @Default(5) int lowStockThreshold,
  }) = _StoreStock;

  factory StoreStock.fromJson(Map<String, dynamic> json) =>
      _$StoreStockFromJson(json);

  bool get isOutOfStock => availableStock <= 0;

  /// Còn hàng nhưng không quá ngưỡng cảnh báo của cửa hàng.
  bool get isLowStock => !isOutOfStock && availableStock <= lowStockThreshold;
}

@freezed
abstract class ProductInventory with _$ProductInventory {
  const ProductInventory._();

  const factory ProductInventory({
    required Product product,
    @Default(<StoreStock>[]) List<StoreStock> inventories,
  }) = _ProductInventory;

  factory ProductInventory.fromJson(Map<String, dynamic> json) =>
      _$ProductInventoryFromJson(json);

  StoreStock? stockAt(String storeId) {
    for (final item in inventories) {
      if (item.store.id == storeId) return item;
    }
    return null;
  }

  int availableAt(String storeId) => stockAt(storeId)?.availableStock ?? 0;

  int get totalAvailable =>
      inventories.fold(0, (sum, e) => sum + e.availableStock);
}

/// Cảnh báo kho (`GET /inventory/alerts`).
@freezed
abstract class InventoryAlert with _$InventoryAlert {
  const InventoryAlert._();

  const factory InventoryAlert({
    @JsonKey(unknownEnumValue: InventoryAlertType.unknown)
    @Default(InventoryAlertType.unknown)
    InventoryAlertType type,

    /// Ví dụ `CRITICAL` khi tồn bằng 0.
    String? severity,
    @Default('') String message,
    String? inventoryId,
    @StoreRefConverter() EntityRef<Store>? store,
    @ProductRefConverter() EntityRef<Product>? product,
    @Default(0) int totalStock,
    @Default(0) int reservedStock,
    @Default(0) int availableStock,
    @Default(5) int lowStockThreshold,
    DateTime? expiryDate,
    int? daysUntilExpiry,
    String? expiryDateLabel,
  }) = _InventoryAlert;

  factory InventoryAlert.fromJson(Map<String, dynamic> json) =>
      _$InventoryAlertFromJson(json);

  bool get isCritical => severity?.toUpperCase() == 'CRITICAL';

  /// Khóa ổn định để ẩn từng cảnh báo ở client.
  String get key =>
      '${type.name}:${inventoryId ?? '${store?.id}:${product?.id}'}';
}

Object? _readStore(Map<dynamic, dynamic> json, String key) =>
    json['storeId'] ?? json['store'];
Object? _readProduct(Map<dynamic, dynamic> json, String key) =>
    json['productId'] ?? json['product'];

/// Yêu cầu bổ sung hàng của Sales/Manager.
@freezed
abstract class RestockRequest with _$RestockRequest {
  const factory RestockRequest({
    @JsonKey(name: '_id') required String id,
    @JsonKey(readValue: _readStore)
    @StoreRefConverter()
    EntityRef<Store>? storeId,
    @JsonKey(readValue: _readProduct)
    @ProductRefConverter()
    EntityRef<Product>? productId,
    @UserRefConverter() EntityRef<AppUser>? requestedBy,
    @UserRefConverter() EntityRef<AppUser>? handledBy,
    @UserRefConverter() EntityRef<AppUser>? acknowledgedBy,
    @Default(0) int currentAvailableStock,
    @Default(0) int requestedQuantity,
    String? reason,
    @Default(RestockStatus.open) RestockStatus status,
    String? managerNote,
    DateTime? resolvedAt,
    DateTime? acknowledgedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RestockRequest;

  factory RestockRequest.fromJson(Map<String, dynamic> json) =>
      _$RestockRequestFromJson(json);
}

/// Nhật ký nhập kho (`GET /inventory/receipts`).
@freezed
abstract class InventoryReceipt with _$InventoryReceipt {
  const factory InventoryReceipt({
    @JsonKey(name: '_id') required String id,
    @JsonKey(readValue: _readStore)
    @StoreRefConverter()
    EntityRef<Store>? storeId,
    @JsonKey(readValue: _readProduct)
    @ProductRefConverter()
    EntityRef<Product>? productId,
    @Default(0) int quantity,
    DateTime? expiryDate,
    @Default(ReceiptSource.direct) ReceiptSource source,
    String? note,
    String? referenceId,
    @UserRefConverter() EntityRef<AppUser>? receivedBy,
    DateTime? createdAt,
  }) = _InventoryReceipt;

  factory InventoryReceipt.fromJson(Map<String, dynamic> json) =>
      _$InventoryReceiptFromJson(json);
}

/// Nhật ký trừ kho (`GET /inventory/adjustments`).
@freezed
abstract class InventoryAdjustment with _$InventoryAdjustment {
  const factory InventoryAdjustment({
    @JsonKey(name: '_id') required String id,
    @JsonKey(readValue: _readStore)
    @StoreRefConverter()
    EntityRef<Store>? storeId,
    @JsonKey(readValue: _readProduct)
    @ProductRefConverter()
    EntityRef<Product>? productId,
    @Default(AdjustmentType.other) AdjustmentType type,
    @Default(0) int quantity,
    String? note,
    @UserRefConverter() EntityRef<AppUser>? createdBy,
    DateTime? createdAt,
  }) = _InventoryAdjustment;

  factory InventoryAdjustment.fromJson(Map<String, dynamic> json) =>
      _$InventoryAdjustmentFromJson(json);
}

/// Yêu cầu trả hàng lỗi của Manager (`GET /inventory/return-requests`). Số
/// hàng bị khóa (đang giữ) tới khi Owner duyệt hoặc từ chối.
@freezed
abstract class InventoryReturnRequest with _$InventoryReturnRequest {
  const factory InventoryReturnRequest({
    @JsonKey(name: '_id') required String id,
    @JsonKey(readValue: _readStore)
    @StoreRefConverter()
    EntityRef<Store>? storeId,
    @JsonKey(readValue: _readProduct)
    @ProductRefConverter()
    EntityRef<Product>? productId,
    @Default(0) int quantity,
    @Default(0) int currentAvailableStock,
    @Default(ReturnReasonType.other) ReturnReasonType reasonType,
    String? managerNote,
    String? reviewNote,
    @Default(ReturnRequestStatus.pending) ReturnRequestStatus status,
    @UserRefConverter() EntityRef<AppUser>? requestedBy,
    @UserRefConverter() EntityRef<AppUser>? reviewedBy,
    DateTime? reviewedAt,
    DateTime? createdAt,
  }) = _InventoryReturnRequest;

  factory InventoryReturnRequest.fromJson(Map<String, dynamic> json) =>
      _$InventoryReturnRequestFromJson(json);
}

@freezed
abstract class TransferItem with _$TransferItem {
  const factory TransferItem({
    @JsonKey(readValue: _readProduct)
    @ProductRefConverter()
    required EntityRef<Product> productId,
    @Default(0) int quantity,
  }) = _TransferItem;

  factory TransferItem.fromJson(Map<String, dynamic> json) =>
      _$TransferItemFromJson(json);
}

/// Phiếu điều chuyển CENTRAL → BRANCH.
@freezed
abstract class StockTransfer with _$StockTransfer {
  const StockTransfer._();

  const factory StockTransfer({
    @JsonKey(name: '_id') required String id,
    @StoreRefConverter() EntityRef<Store>? fromStoreId,
    @StoreRefConverter() EntityRef<Store>? toStoreId,
    @Default(<TransferItem>[]) List<TransferItem> items,
    @Default(TransferStatus.pending) TransferStatus status,
    @UserRefConverter() EntityRef<AppUser>? createdBy,
    @UserRefConverter() EntityRef<AppUser>? confirmedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _StockTransfer;

  factory StockTransfer.fromJson(Map<String, dynamic> json) =>
      _$StockTransferFromJson(json);

  int get totalQuantity => items.fold(0, (sum, e) => sum + e.quantity);
}
