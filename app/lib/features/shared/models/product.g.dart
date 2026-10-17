// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Ingredient _$IngredientFromJson(Map<String, dynamic> json) => _Ingredient(
  icon: json['icon'] as String?,
  title: json['title'] as String? ?? '',
  subtitle: json['subtitle'] as String? ?? '',
);

Map<String, dynamic> _$IngredientToJson(_Ingredient instance) =>
    <String, dynamic>{
      'icon': ?instance.icon,
      'title': instance.title,
      'subtitle': instance.subtitle,
    };

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['_id'] as String,
  sku: json['sku'] as String? ?? '',
  name: json['name'] as String? ?? '',
  brand: json['brand'] as String? ?? '',
  price: (json['price'] as num?)?.toInt() ?? 0,
  costPrice: (json['costPrice'] as num?)?.toInt(),
  originalPrice: (json['originalPrice'] as num?)?.toInt(),
  description: json['description'] as String?,
  image: json['image'] as String?,
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  category: json['category'] as String?,
  skinTypes:
      (json['skinTypes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  volume: json['volume'] as String?,
  origin: json['origin'] as String?,
  expiryDate: json['expiryDate'] as String?,
  ingredients:
      (json['ingredients'] as List<dynamic>?)
          ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Ingredient>[],
  isActive: json['isActive'] as bool? ?? true,
  rating: (json['rating'] as num?)?.toDouble(),
  reviewCount: (json['reviewCount'] as num?)?.toInt(),
  ratingBreakdown:
      (json['ratingBreakdown'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  '_id': instance.id,
  'sku': instance.sku,
  'name': instance.name,
  'brand': instance.brand,
  'price': instance.price,
  'costPrice': ?instance.costPrice,
  'originalPrice': ?instance.originalPrice,
  'description': ?instance.description,
  'image': ?instance.image,
  'images': instance.images,
  'category': ?instance.category,
  'skinTypes': instance.skinTypes,
  'volume': ?instance.volume,
  'origin': ?instance.origin,
  'expiryDate': ?instance.expiryDate,
  'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
  'isActive': instance.isActive,
  'rating': ?instance.rating,
  'reviewCount': ?instance.reviewCount,
  'ratingBreakdown': instance.ratingBreakdown,
  'createdAt': ?instance.createdAt?.toIso8601String(),
  'updatedAt': ?instance.updatedAt?.toIso8601String(),
};
