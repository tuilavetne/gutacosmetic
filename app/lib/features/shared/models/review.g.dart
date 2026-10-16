// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Review _$ReviewFromJson(Map<String, dynamic> json) => _Review(
  id: json['_id'] as String,
  productId: _$JsonConverterFromJson<Object, EntityRef<Product>>(
    json['productId'],
    const ProductRefConverter().fromJson,
  ),
  orderId: _$JsonConverterFromJson<Object, String>(
    json['orderId'],
    const StringishConverter().fromJson,
  ),
  customerId: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
    json['customerId'],
    const UserRefConverter().fromJson,
  ),
  customerName: json['customerName'] as String? ?? '',
  rating: (json['rating'] as num?)?.toInt() ?? 5,
  comment: json['comment'] as String? ?? '',
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ReviewToJson(_Review instance) => <String, dynamic>{
  '_id': instance.id,
  'productId': ?_$JsonConverterToJson<Object, EntityRef<Product>>(
    instance.productId,
    const ProductRefConverter().toJson,
  ),
  'orderId': ?_$JsonConverterToJson<Object, String>(
    instance.orderId,
    const StringishConverter().toJson,
  ),
  'customerId': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
    instance.customerId,
    const UserRefConverter().toJson,
  ),
  'customerName': instance.customerName,
  'rating': instance.rating,
  'comment': instance.comment,
  'images': instance.images,
  'createdAt': ?instance.createdAt?.toIso8601String(),
  'updatedAt': ?instance.updatedAt?.toIso8601String(),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
