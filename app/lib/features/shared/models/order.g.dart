// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShippingAddress _$ShippingAddressFromJson(Map<String, dynamic> json) =>
    _ShippingAddress(
      recipientName: json['recipientName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      addressLine: json['addressLine'] as String? ?? '',
    );

Map<String, dynamic> _$ShippingAddressToJson(_ShippingAddress instance) =>
    <String, dynamic>{
      'recipientName': instance.recipientName,
      'phone': instance.phone,
      'addressLine': instance.addressLine,
    };

_OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => _OrderItem(
  productId: const ProductRefConverter().fromJson(json['productId'] as Object),
  sku: json['sku'] as String? ?? '',
  name: json['name'] as String? ?? '',
  image: json['image'] as String?,
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  unitPrice: (json['unitPrice'] as num?)?.toInt() ?? 0,
  lineTotal: (json['lineTotal'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OrderItemToJson(_OrderItem instance) =>
    <String, dynamic>{
      'productId': const ProductRefConverter().toJson(instance.productId),
      'sku': instance.sku,
      'name': instance.name,
      'image': ?instance.image,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'lineTotal': instance.lineTotal,
    };

_StatusHistoryEntry _$StatusHistoryEntryFromJson(Map<String, dynamic> json) =>
    _StatusHistoryEntry(
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      changedBy: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
        json['changedBy'],
        const UserRefConverter().fromJson,
      ),
      note: json['note'] as String?,
      changedAt: json['changedAt'] == null
          ? null
          : DateTime.parse(json['changedAt'] as String),
    );

Map<String, dynamic> _$StatusHistoryEntryToJson(_StatusHistoryEntry instance) =>
    <String, dynamic>{
      'status': _$OrderStatusEnumMap[instance.status]!,
      'changedBy': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
        instance.changedBy,
        const UserRefConverter().toJson,
      ),
      'note': ?instance.note,
      'changedAt': ?instance.changedAt?.toIso8601String(),
    };

const _$OrderStatusEnumMap = {
  OrderStatus.draft: 'DRAFT',
  OrderStatus.pendingApproval: 'PENDING_APPROVAL',
  OrderStatus.pendingPayment: 'PENDING_PAYMENT',
  OrderStatus.pending: 'PENDING',
  OrderStatus.paid: 'PAID',
  OrderStatus.preparing: 'PREPARING',
  OrderStatus.readyForPickup: 'READY_FOR_PICKUP',
  OrderStatus.completed: 'COMPLETED',
  OrderStatus.cancelled: 'CANCELLED',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: json['_id'] as String,
  orderCode: json['orderCode'] as String? ?? '',
  channel:
      $enumDecodeNullable(_$OrderChannelEnumMap, json['channel']) ??
      OrderChannel.online,
  fulfillmentType: $enumDecodeNullable(
    _$FulfillmentTypeEnumMap,
    json['fulfillmentType'],
  ),
  customerId: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
    json['customerId'],
    const UserRefConverter().fromJson,
  ),
  customerName: json['customerName'] as String?,
  customerPhone: json['customerPhone'] as String?,
  shippingAddress: json['shippingAddress'] == null
      ? null
      : ShippingAddress.fromJson(
          json['shippingAddress'] as Map<String, dynamic>,
        ),
  storeId: _$JsonConverterFromJson<Object, EntityRef<Store>>(
    json['storeId'],
    const StoreRefConverter().fromJson,
  ),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OrderItem>[],
  subtotal: (json['subtotal'] as num?)?.toInt() ?? 0,
  discountAmount: (json['discountAmount'] as num?)?.toInt() ?? 0,
  shippingFee: (json['shippingFee'] as num?)?.toInt() ?? 0,
  totalPrice: (json['totalPrice'] as num?)?.toInt() ?? 0,
  pointsUsed: (json['pointsUsed'] as num?)?.toInt() ?? 0,
  pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  paymentStatus:
      $enumDecodeNullable(_$PaymentStatusEnumMap, json['paymentStatus']) ??
      PaymentStatus.unpaid,
  paymentMethod: $enumDecodeNullable(
    _$PaymentMethodEnumMap,
    json['paymentMethod'],
  ),
  paymentProvider: json['paymentProvider'] as String?,
  paymentOrderCode: _$JsonConverterFromJson<Object, String>(
    json['paymentOrderCode'],
    const StringishConverter().fromJson,
  ),
  paymentLinkId: json['paymentLinkId'] as String?,
  checkoutUrl: json['checkoutUrl'] as String?,
  qrCode: json['qrCode'] as String?,
  paymentReference: json['paymentReference'] as String?,
  paymentExpiresAt: _$JsonConverterFromJson<Object, DateTime>(
    json['paymentExpiresAt'],
    const FlexibleDateTimeConverter().fromJson,
  ),
  inventoryReserved: json['inventoryReserved'] as bool? ?? false,
  createdBySalesId: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
    json['createdBySalesId'],
    const UserRefConverter().fromJson,
  ),
  approvedBySalesId: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
    json['approvedBySalesId'],
    const UserRefConverter().fromJson,
  ),
  paidByManagerId: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
    json['paidByManagerId'],
    const UserRefConverter().fromJson,
  ),
  cancelledBy: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
    json['cancelledBy'],
    const UserRefConverter().fromJson,
  ),
  cancellationReason: json['cancellationReason'] as String?,
  statusHistory:
      (json['statusHistory'] as List<dynamic>?)
          ?.map((e) => StatusHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <StatusHistoryEntry>[],
  paidAt: json['paidAt'] == null
      ? null
      : DateTime.parse(json['paidAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  cancelledAt: json['cancelledAt'] == null
      ? null
      : DateTime.parse(json['cancelledAt'] as String),
  isReviewed: json['isReviewed'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  '_id': instance.id,
  'orderCode': instance.orderCode,
  'channel': _$OrderChannelEnumMap[instance.channel]!,
  'fulfillmentType': ?_$FulfillmentTypeEnumMap[instance.fulfillmentType],
  'customerId': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
    instance.customerId,
    const UserRefConverter().toJson,
  ),
  'customerName': ?instance.customerName,
  'customerPhone': ?instance.customerPhone,
  'shippingAddress': ?instance.shippingAddress?.toJson(),
  'storeId': ?_$JsonConverterToJson<Object, EntityRef<Store>>(
    instance.storeId,
    const StoreRefConverter().toJson,
  ),
  'items': instance.items.map((e) => e.toJson()).toList(),
  'subtotal': instance.subtotal,
  'discountAmount': instance.discountAmount,
  'shippingFee': instance.shippingFee,
  'totalPrice': instance.totalPrice,
  'pointsUsed': instance.pointsUsed,
  'pointsEarned': instance.pointsEarned,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus]!,
  'paymentMethod': ?_$PaymentMethodEnumMap[instance.paymentMethod],
  'paymentProvider': ?instance.paymentProvider,
  'paymentOrderCode': ?_$JsonConverterToJson<Object, String>(
    instance.paymentOrderCode,
    const StringishConverter().toJson,
  ),
  'paymentLinkId': ?instance.paymentLinkId,
  'checkoutUrl': ?instance.checkoutUrl,
  'qrCode': ?instance.qrCode,
  'paymentReference': ?instance.paymentReference,
  'paymentExpiresAt': ?_$JsonConverterToJson<Object, DateTime>(
    instance.paymentExpiresAt,
    const FlexibleDateTimeConverter().toJson,
  ),
  'inventoryReserved': instance.inventoryReserved,
  'createdBySalesId': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
    instance.createdBySalesId,
    const UserRefConverter().toJson,
  ),
  'approvedBySalesId': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
    instance.approvedBySalesId,
    const UserRefConverter().toJson,
  ),
  'paidByManagerId': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
    instance.paidByManagerId,
    const UserRefConverter().toJson,
  ),
  'cancelledBy': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
    instance.cancelledBy,
    const UserRefConverter().toJson,
  ),
  'cancellationReason': ?instance.cancellationReason,
  'statusHistory': instance.statusHistory.map((e) => e.toJson()).toList(),
  'paidAt': ?instance.paidAt?.toIso8601String(),
  'completedAt': ?instance.completedAt?.toIso8601String(),
  'cancelledAt': ?instance.cancelledAt?.toIso8601String(),
  'isReviewed': instance.isReviewed,
  'createdAt': ?instance.createdAt?.toIso8601String(),
  'updatedAt': ?instance.updatedAt?.toIso8601String(),
};

const _$OrderChannelEnumMap = {
  OrderChannel.online: 'ONLINE',
  OrderChannel.offline: 'OFFLINE',
};

const _$FulfillmentTypeEnumMap = {
  FulfillmentType.delivery: 'DELIVERY',
  FulfillmentType.storePickup: 'STORE_PICKUP',
  FulfillmentType.inStore: 'IN_STORE',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.unpaid: 'UNPAID',
  PaymentStatus.paid: 'PAID',
  PaymentStatus.refunded: 'REFUNDED',
  PaymentStatus.failed: 'FAILED',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'CASH',
  PaymentMethod.card: 'CARD',
  PaymentMethod.bankTransfer: 'BANK_TRANSFER',
  PaymentMethod.cod: 'COD',
  PaymentMethod.onlinePayment: 'ONLINE_PAYMENT',
  PaymentMethod.payAtStore: 'PAY_AT_STORE',
};
