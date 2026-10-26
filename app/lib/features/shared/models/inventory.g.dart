// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoreStock _$StoreStockFromJson(Map<String, dynamic> json) => _StoreStock(
  store: Store.fromJson(json['store'] as Map<String, dynamic>),
  totalStock: (json['totalStock'] as num?)?.toInt() ?? 0,
  reservedStock: (json['reservedStock'] as num?)?.toInt() ?? 0,
  availableStock: (json['availableStock'] as num?)?.toInt() ?? 0,
  expiryDate: json['expiryDate'] == null
      ? null
      : DateTime.parse(json['expiryDate'] as String),
  expiryDateLabel: json['expiryDateLabel'] as String?,
  daysUntilExpiry: (json['daysUntilExpiry'] as num?)?.toInt(),
  lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 5,
);

Map<String, dynamic> _$StoreStockToJson(_StoreStock instance) =>
    <String, dynamic>{
      'store': instance.store.toJson(),
      'totalStock': instance.totalStock,
      'reservedStock': instance.reservedStock,
      'availableStock': instance.availableStock,
      'expiryDate': ?instance.expiryDate?.toIso8601String(),
      'expiryDateLabel': ?instance.expiryDateLabel,
      'daysUntilExpiry': ?instance.daysUntilExpiry,
      'lowStockThreshold': instance.lowStockThreshold,
    };

_ProductInventory _$ProductInventoryFromJson(Map<String, dynamic> json) =>
    _ProductInventory(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      inventories:
          (json['inventories'] as List<dynamic>?)
              ?.map((e) => StoreStock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <StoreStock>[],
    );

Map<String, dynamic> _$ProductInventoryToJson(_ProductInventory instance) =>
    <String, dynamic>{
      'product': instance.product.toJson(),
      'inventories': instance.inventories.map((e) => e.toJson()).toList(),
    };

_InventoryAlert _$InventoryAlertFromJson(Map<String, dynamic> json) =>
    _InventoryAlert(
      type:
          $enumDecodeNullable(
            _$InventoryAlertTypeEnumMap,
            json['type'],
            unknownValue: InventoryAlertType.unknown,
          ) ??
          InventoryAlertType.unknown,
      severity: json['severity'] as String?,
      message: json['message'] as String? ?? '',
      inventoryId: json['inventoryId'] as String?,
      store: _$JsonConverterFromJson<Object, EntityRef<Store>>(
        json['store'],
        const StoreRefConverter().fromJson,
      ),
      product: _$JsonConverterFromJson<Object, EntityRef<Product>>(
        json['product'],
        const ProductRefConverter().fromJson,
      ),
      totalStock: (json['totalStock'] as num?)?.toInt() ?? 0,
      reservedStock: (json['reservedStock'] as num?)?.toInt() ?? 0,
      availableStock: (json['availableStock'] as num?)?.toInt() ?? 0,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 5,
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      daysUntilExpiry: (json['daysUntilExpiry'] as num?)?.toInt(),
      expiryDateLabel: json['expiryDateLabel'] as String?,
    );

Map<String, dynamic> _$InventoryAlertToJson(_InventoryAlert instance) =>
    <String, dynamic>{
      'type': _$InventoryAlertTypeEnumMap[instance.type]!,
      'severity': ?instance.severity,
      'message': instance.message,
      'inventoryId': ?instance.inventoryId,
      'store': ?_$JsonConverterToJson<Object, EntityRef<Store>>(
        instance.store,
        const StoreRefConverter().toJson,
      ),
      'product': ?_$JsonConverterToJson<Object, EntityRef<Product>>(
        instance.product,
        const ProductRefConverter().toJson,
      ),
      'totalStock': instance.totalStock,
      'reservedStock': instance.reservedStock,
      'availableStock': instance.availableStock,
      'lowStockThreshold': instance.lowStockThreshold,
      'expiryDate': ?instance.expiryDate?.toIso8601String(),
      'daysUntilExpiry': ?instance.daysUntilExpiry,
      'expiryDateLabel': ?instance.expiryDateLabel,
    };

const _$InventoryAlertTypeEnumMap = {
  InventoryAlertType.lowStock: 'LOW_STOCK',
  InventoryAlertType.expiringSoon: 'EXPIRING_SOON',
  InventoryAlertType.expired: 'EXPIRED',
  InventoryAlertType.unknown: 'UNKNOWN',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_RestockRequest _$RestockRequestFromJson(Map<String, dynamic> json) =>
    _RestockRequest(
      id: json['_id'] as String,
      storeId: _$JsonConverterFromJson<Object, EntityRef<Store>>(
        _readStore(json, 'storeId'),
        const StoreRefConverter().fromJson,
      ),
      productId: _$JsonConverterFromJson<Object, EntityRef<Product>>(
        _readProduct(json, 'productId'),
        const ProductRefConverter().fromJson,
      ),
      requestedBy: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
        json['requestedBy'],
        const UserRefConverter().fromJson,
      ),
      handledBy: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
        json['handledBy'],
        const UserRefConverter().fromJson,
      ),
      acknowledgedBy: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
        json['acknowledgedBy'],
        const UserRefConverter().fromJson,
      ),
      currentAvailableStock:
          (json['currentAvailableStock'] as num?)?.toInt() ?? 0,
      requestedQuantity: (json['requestedQuantity'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String?,
      status:
          $enumDecodeNullable(_$RestockStatusEnumMap, json['status']) ??
          RestockStatus.open,
      managerNote: json['managerNote'] as String?,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      acknowledgedAt: json['acknowledgedAt'] == null
          ? null
          : DateTime.parse(json['acknowledgedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$RestockRequestToJson(_RestockRequest instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'storeId': ?_$JsonConverterToJson<Object, EntityRef<Store>>(
        instance.storeId,
        const StoreRefConverter().toJson,
      ),
      'productId': ?_$JsonConverterToJson<Object, EntityRef<Product>>(
        instance.productId,
        const ProductRefConverter().toJson,
      ),
      'requestedBy': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
        instance.requestedBy,
        const UserRefConverter().toJson,
      ),
      'handledBy': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
        instance.handledBy,
        const UserRefConverter().toJson,
      ),
      'acknowledgedBy': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
        instance.acknowledgedBy,
        const UserRefConverter().toJson,
      ),
      'currentAvailableStock': instance.currentAvailableStock,
      'requestedQuantity': instance.requestedQuantity,
      'reason': ?instance.reason,
      'status': _$RestockStatusEnumMap[instance.status]!,
      'managerNote': ?instance.managerNote,
      'resolvedAt': ?instance.resolvedAt?.toIso8601String(),
      'acknowledgedAt': ?instance.acknowledgedAt?.toIso8601String(),
      'createdAt': ?instance.createdAt?.toIso8601String(),
      'updatedAt': ?instance.updatedAt?.toIso8601String(),
    };

const _$RestockStatusEnumMap = {
  RestockStatus.open: 'OPEN',
  RestockStatus.resolved: 'RESOLVED',
  RestockStatus.cancelled: 'CANCELLED',
};

_InventoryReceipt _$InventoryReceiptFromJson(Map<String, dynamic> json) =>
    _InventoryReceipt(
      id: json['_id'] as String,
      storeId: _$JsonConverterFromJson<Object, EntityRef<Store>>(
        _readStore(json, 'storeId'),
        const StoreRefConverter().fromJson,
      ),
      productId: _$JsonConverterFromJson<Object, EntityRef<Product>>(
        _readProduct(json, 'productId'),
        const ProductRefConverter().fromJson,
      ),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      source:
          $enumDecodeNullable(_$ReceiptSourceEnumMap, json['source']) ??
          ReceiptSource.direct,
      note: json['note'] as String?,
      referenceId: json['referenceId'] as String?,
      receivedBy: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
        json['receivedBy'],
        const UserRefConverter().fromJson,
      ),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$InventoryReceiptToJson(_InventoryReceipt instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'storeId': ?_$JsonConverterToJson<Object, EntityRef<Store>>(
        instance.storeId,
        const StoreRefConverter().toJson,
      ),
      'productId': ?_$JsonConverterToJson<Object, EntityRef<Product>>(
        instance.productId,
        const ProductRefConverter().toJson,
      ),
      'quantity': instance.quantity,
      'expiryDate': ?instance.expiryDate?.toIso8601String(),
      'source': _$ReceiptSourceEnumMap[instance.source]!,
      'note': ?instance.note,
      'referenceId': ?instance.referenceId,
      'receivedBy': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
        instance.receivedBy,
        const UserRefConverter().toJson,
      ),
      'createdAt': ?instance.createdAt?.toIso8601String(),
    };

const _$ReceiptSourceEnumMap = {
  ReceiptSource.direct: 'DIRECT',
  ReceiptSource.salesRequest: 'SALES_REQUEST',
  ReceiptSource.transfer: 'TRANSFER',
  ReceiptSource.returnRejected: 'RETURN_REJECTED',
};

_InventoryAdjustment _$InventoryAdjustmentFromJson(Map<String, dynamic> json) =>
    _InventoryAdjustment(
      id: json['_id'] as String,
      storeId: _$JsonConverterFromJson<Object, EntityRef<Store>>(
        _readStore(json, 'storeId'),
        const StoreRefConverter().fromJson,
      ),
      productId: _$JsonConverterFromJson<Object, EntityRef<Product>>(
        _readProduct(json, 'productId'),
        const ProductRefConverter().fromJson,
      ),
      type:
          $enumDecodeNullable(_$AdjustmentTypeEnumMap, json['type']) ??
          AdjustmentType.other,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      note: json['note'] as String?,
      createdBy: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
        json['createdBy'],
        const UserRefConverter().fromJson,
      ),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$InventoryAdjustmentToJson(
  _InventoryAdjustment instance,
) => <String, dynamic>{
  '_id': instance.id,
  'storeId': ?_$JsonConverterToJson<Object, EntityRef<Store>>(
    instance.storeId,
    const StoreRefConverter().toJson,
  ),
  'productId': ?_$JsonConverterToJson<Object, EntityRef<Product>>(
    instance.productId,
    const ProductRefConverter().toJson,
  ),
  'type': _$AdjustmentTypeEnumMap[instance.type]!,
  'quantity': instance.quantity,
  'note': ?instance.note,
  'createdBy': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
    instance.createdBy,
    const UserRefConverter().toJson,
  ),
  'createdAt': ?instance.createdAt?.toIso8601String(),
};

const _$AdjustmentTypeEnumMap = {
  AdjustmentType.damaged: 'DAMAGED',
  AdjustmentType.defective: 'DEFECTIVE',
  AdjustmentType.lost: 'LOST',
  AdjustmentType.expired: 'EXPIRED',
  AdjustmentType.other: 'OTHER',
};

_InventoryReturnRequest _$InventoryReturnRequestFromJson(
  Map<String, dynamic> json,
) => _InventoryReturnRequest(
  id: json['_id'] as String,
  storeId: _$JsonConverterFromJson<Object, EntityRef<Store>>(
    _readStore(json, 'storeId'),
    const StoreRefConverter().fromJson,
  ),
  productId: _$JsonConverterFromJson<Object, EntityRef<Product>>(
    _readProduct(json, 'productId'),
    const ProductRefConverter().fromJson,
  ),
  quantity: (json['quantity'] as num?)?.toInt() ?? 0,
  currentAvailableStock: (json['currentAvailableStock'] as num?)?.toInt() ?? 0,
  reasonType:
      $enumDecodeNullable(_$ReturnReasonTypeEnumMap, json['reasonType']) ??
      ReturnReasonType.other,
  managerNote: json['managerNote'] as String?,
  reviewNote: json['reviewNote'] as String?,
  status:
      $enumDecodeNullable(_$ReturnRequestStatusEnumMap, json['status']) ??
      ReturnRequestStatus.pending,
  requestedBy: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
    json['requestedBy'],
    const UserRefConverter().fromJson,
  ),
  reviewedBy: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
    json['reviewedBy'],
    const UserRefConverter().fromJson,
  ),
  reviewedAt: json['reviewedAt'] == null
      ? null
      : DateTime.parse(json['reviewedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$InventoryReturnRequestToJson(
  _InventoryReturnRequest instance,
) => <String, dynamic>{
  '_id': instance.id,
  'storeId': ?_$JsonConverterToJson<Object, EntityRef<Store>>(
    instance.storeId,
    const StoreRefConverter().toJson,
  ),
  'productId': ?_$JsonConverterToJson<Object, EntityRef<Product>>(
    instance.productId,
    const ProductRefConverter().toJson,
  ),
  'quantity': instance.quantity,
  'currentAvailableStock': instance.currentAvailableStock,
  'reasonType': _$ReturnReasonTypeEnumMap[instance.reasonType]!,
  'managerNote': ?instance.managerNote,
  'reviewNote': ?instance.reviewNote,
  'status': _$ReturnRequestStatusEnumMap[instance.status]!,
  'requestedBy': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
    instance.requestedBy,
    const UserRefConverter().toJson,
  ),
  'reviewedBy': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
    instance.reviewedBy,
    const UserRefConverter().toJson,
  ),
  'reviewedAt': ?instance.reviewedAt?.toIso8601String(),
  'createdAt': ?instance.createdAt?.toIso8601String(),
};

const _$ReturnReasonTypeEnumMap = {
  ReturnReasonType.damaged: 'DAMAGED',
  ReturnReasonType.defective: 'DEFECTIVE',
  ReturnReasonType.expired: 'EXPIRED',
  ReturnReasonType.other: 'OTHER',
};

const _$ReturnRequestStatusEnumMap = {
  ReturnRequestStatus.pending: 'PENDING',
  ReturnRequestStatus.approved: 'APPROVED',
  ReturnRequestStatus.rejected: 'REJECTED',
};

_TransferItem _$TransferItemFromJson(Map<String, dynamic> json) =>
    _TransferItem(
      productId: const ProductRefConverter().fromJson(
        _readProduct(json, 'productId') as Object,
      ),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TransferItemToJson(_TransferItem instance) =>
    <String, dynamic>{
      'productId': const ProductRefConverter().toJson(instance.productId),
      'quantity': instance.quantity,
    };

_StockTransfer _$StockTransferFromJson(Map<String, dynamic> json) =>
    _StockTransfer(
      id: json['_id'] as String,
      fromStoreId: _$JsonConverterFromJson<Object, EntityRef<Store>>(
        json['fromStoreId'],
        const StoreRefConverter().fromJson,
      ),
      toStoreId: _$JsonConverterFromJson<Object, EntityRef<Store>>(
        json['toStoreId'],
        const StoreRefConverter().fromJson,
      ),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => TransferItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TransferItem>[],
      status:
          $enumDecodeNullable(_$TransferStatusEnumMap, json['status']) ??
          TransferStatus.pending,
      createdBy: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
        json['createdBy'],
        const UserRefConverter().fromJson,
      ),
      confirmedBy: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
        json['confirmedBy'],
        const UserRefConverter().fromJson,
      ),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$StockTransferToJson(_StockTransfer instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'fromStoreId': ?_$JsonConverterToJson<Object, EntityRef<Store>>(
        instance.fromStoreId,
        const StoreRefConverter().toJson,
      ),
      'toStoreId': ?_$JsonConverterToJson<Object, EntityRef<Store>>(
        instance.toStoreId,
        const StoreRefConverter().toJson,
      ),
      'items': instance.items.map((e) => e.toJson()).toList(),
      'status': _$TransferStatusEnumMap[instance.status]!,
      'createdBy': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
        instance.createdBy,
        const UserRefConverter().toJson,
      ),
      'confirmedBy': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
        instance.confirmedBy,
        const UserRefConverter().toJson,
      ),
      'createdAt': ?instance.createdAt?.toIso8601String(),
      'updatedAt': ?instance.updatedAt?.toIso8601String(),
    };

const _$TransferStatusEnumMap = {
  TransferStatus.pending: 'PENDING',
  TransferStatus.confirmed: 'CONFIRMED',
  TransferStatus.cancelled: 'CANCELLED',
};
