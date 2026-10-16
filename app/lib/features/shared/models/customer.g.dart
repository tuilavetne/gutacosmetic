// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomerSearchResult _$CustomerSearchResultFromJson(
  Map<String, dynamic> json,
) => _CustomerSearchResult(
  id: json['_id'] as String,
  fullName: json['fullName'] as String? ?? '',
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  points: (json['points'] as num?)?.toInt() ?? 0,
  isGuest: json['isGuest'] as bool? ?? false,
  orderCount: (json['orderCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$CustomerSearchResultToJson(
  _CustomerSearchResult instance,
) => <String, dynamic>{
  '_id': instance.id,
  'fullName': instance.fullName,
  'email': ?instance.email,
  'phone': ?instance.phone,
  'points': instance.points,
  'isGuest': instance.isGuest,
  'orderCount': ?instance.orderCount,
};

_RewardRedemption _$RewardRedemptionFromJson(Map<String, dynamic> json) =>
    _RewardRedemption(
      id: json['_id'] as String,
      customerId: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
        json['customerId'],
        const UserRefConverter().fromJson,
      ),
      storeId: _$JsonConverterFromJson<Object, EntityRef<Store>>(
        json['storeId'],
        const StoreRefConverter().fromJson,
      ),
      redeemedBy: _$JsonConverterFromJson<Object, EntityRef<AppUser>>(
        json['redeemedBy'],
        const UserRefConverter().fromJson,
      ),
      rewardName: json['rewardName'] as String? ?? '',
      pointsUsed: (json['pointsUsed'] as num?)?.toInt() ?? 0,
      note: json['note'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RewardRedemptionToJson(_RewardRedemption instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'customerId': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
        instance.customerId,
        const UserRefConverter().toJson,
      ),
      'storeId': ?_$JsonConverterToJson<Object, EntityRef<Store>>(
        instance.storeId,
        const StoreRefConverter().toJson,
      ),
      'redeemedBy': ?_$JsonConverterToJson<Object, EntityRef<AppUser>>(
        instance.redeemedBy,
        const UserRefConverter().toJson,
      ),
      'rewardName': instance.rewardName,
      'pointsUsed': instance.pointsUsed,
      'note': ?instance.note,
      'createdAt': ?instance.createdAt?.toIso8601String(),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_RedeemResult _$RedeemResultFromJson(Map<String, dynamic> json) =>
    _RedeemResult(
      customer: CustomerSearchResult.fromJson(
        json['customer'] as Map<String, dynamic>,
      ),
      redemption: json['redemption'] == null
          ? null
          : RewardRedemption.fromJson(
              json['redemption'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$RedeemResultToJson(_RedeemResult instance) =>
    <String, dynamic>{
      'customer': instance.customer.toJson(),
      'redemption': ?instance.redemption?.toJson(),
    };
