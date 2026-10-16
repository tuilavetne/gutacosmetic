// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PayosPayment _$PayosPaymentFromJson(Map<String, dynamic> json) =>
    _PayosPayment(
      checkoutUrl: json['checkoutUrl'] as String?,
      expiredAt: _$JsonConverterFromJson<Object, DateTime>(
        json['expiredAt'],
        const FlexibleDateTimeConverter().fromJson,
      ),
      paymentLinkId: json['paymentLinkId'] as String?,
      qrImage: json['qrImage'] as String?,
      qrCode: json['qrCode'] as String?,
    );

Map<String, dynamic> _$PayosPaymentToJson(_PayosPayment instance) =>
    <String, dynamic>{
      'checkoutUrl': ?instance.checkoutUrl,
      'expiredAt': ?_$JsonConverterToJson<Object, DateTime>(
        instance.expiredAt,
        const FlexibleDateTimeConverter().toJson,
      ),
      'paymentLinkId': ?instance.paymentLinkId,
      'qrImage': ?instance.qrImage,
      'qrCode': ?instance.qrCode,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_PayosSyncResult _$PayosSyncResultFromJson(Map<String, dynamic> json) =>
    _PayosSyncResult(
      order: Order.fromJson(json['order'] as Map<String, dynamic>),
      payosStatus: json['payosStatus'] as String?,
    );

Map<String, dynamic> _$PayosSyncResultToJson(_PayosSyncResult instance) =>
    <String, dynamic>{
      'order': instance.order.toJson(),
      'payosStatus': ?instance.payosStatus,
    };

_PlacedOrder _$PlacedOrderFromJson(Map<String, dynamic> json) => _PlacedOrder(
  order: Order.fromJson(json['order'] as Map<String, dynamic>),
  payment: json['payment'] == null
      ? null
      : PayosPayment.fromJson(json['payment'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PlacedOrderToJson(_PlacedOrder instance) =>
    <String, dynamic>{
      'order': instance.order.toJson(),
      'payment': ?instance.payment?.toJson(),
    };
