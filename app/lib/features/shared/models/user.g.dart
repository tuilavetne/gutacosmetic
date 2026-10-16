// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  id: json['_id'] as String,
  fullName: json['fullName'] as String? ?? '',
  email: json['email'] as String? ?? '',
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  phone: json['phone'] as String?,
  address: json['address'] as String?,
  emailVerified: json['emailVerified'] as bool? ?? false,
  authProvider:
      $enumDecodeNullable(
        _$AuthProviderEnumMap,
        json['authProvider'],
        unknownValue: AuthProvider.local,
      ) ??
      AuthProvider.local,
  avatarUrl: json['avatarUrl'] as String?,
  storeId: _$JsonConverterFromJson<Object, EntityRef<Store>>(
    json['storeId'],
    const StoreRefConverter().fromJson,
  ),
  points: (json['points'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
  disabledAt: json['disabledAt'] == null
      ? null
      : DateTime.parse(json['disabledAt'] as String),
  disabledReason: json['disabledReason'] as String?,
  wishlist: json['wishlist'] == null
      ? const <String>[]
      : const IdListConverter().fromJson(json['wishlist'] as Object),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  '_id': instance.id,
  'fullName': instance.fullName,
  'email': instance.email,
  'role': _$UserRoleEnumMap[instance.role]!,
  'phone': ?instance.phone,
  'address': ?instance.address,
  'emailVerified': instance.emailVerified,
  'authProvider': _$AuthProviderEnumMap[instance.authProvider]!,
  'avatarUrl': ?instance.avatarUrl,
  'storeId': ?_$JsonConverterToJson<Object, EntityRef<Store>>(
    instance.storeId,
    const StoreRefConverter().toJson,
  ),
  'points': instance.points,
  'isActive': instance.isActive,
  'disabledAt': ?instance.disabledAt?.toIso8601String(),
  'disabledReason': ?instance.disabledReason,
  'wishlist': const IdListConverter().toJson(instance.wishlist),
  'createdAt': ?instance.createdAt?.toIso8601String(),
  'updatedAt': ?instance.updatedAt?.toIso8601String(),
};

const _$UserRoleEnumMap = {
  UserRole.owner: 'OWNER',
  UserRole.manager: 'MANAGER',
  UserRole.sales: 'SALES',
  UserRole.customer: 'CUSTOMER',
};

const _$AuthProviderEnumMap = {
  AuthProvider.local: 'LOCAL',
  AuthProvider.google: 'GOOGLE',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
