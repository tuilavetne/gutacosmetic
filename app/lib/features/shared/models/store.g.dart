// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Store _$StoreFromJson(Map<String, dynamic> json) => _Store(
  id: json['_id'] as String,
  name: json['name'] as String? ?? '',
  type:
      $enumDecodeNullable(_$StoreTypeEnumMap, json['type']) ?? StoreType.branch,
  address: json['address'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$StoreToJson(_Store instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'type': _$StoreTypeEnumMap[instance.type]!,
  'address': instance.address,
  'phone': instance.phone,
  'isActive': instance.isActive,
  'createdAt': ?instance.createdAt?.toIso8601String(),
  'updatedAt': ?instance.updatedAt?.toIso8601String(),
};

const _$StoreTypeEnumMap = {
  StoreType.central: 'CENTRAL',
  StoreType.branch: 'BRANCH',
};
