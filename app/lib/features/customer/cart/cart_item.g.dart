// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartItem _$CartItemFromJson(Map<String, dynamic> json) => _CartItem(
  productId: json['productId'] as String,
  sku: json['sku'] as String? ?? '',
  name: json['name'] as String? ?? '',
  brand: json['brand'] as String? ?? '',
  image: json['image'] as String?,
  unitPrice: (json['unitPrice'] as num?)?.toInt() ?? 0,
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$CartItemToJson(_CartItem instance) => <String, dynamic>{
  'productId': instance.productId,
  'sku': instance.sku,
  'name': instance.name,
  'brand': instance.brand,
  'image': ?instance.image,
  'unitPrice': instance.unitPrice,
  'quantity': instance.quantity,
};
