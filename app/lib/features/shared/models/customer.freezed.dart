// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomerSearchResult {

@JsonKey(name: '_id') String get id; String get fullName; String? get email; String? get phone; int get points; bool get isGuest; int? get orderCount;
/// Create a copy of CustomerSearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerSearchResultCopyWith<CustomerSearchResult> get copyWith => _$CustomerSearchResultCopyWithImpl<CustomerSearchResult>(this as CustomerSearchResult, _$identity);

  /// Serializes this CustomerSearchResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CustomerSearchResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerSearchResult&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.points, _this.points) || other.points == _this.points)&&(identical(other.isGuest, _this.isGuest) || other.isGuest == _this.isGuest)&&(identical(other.orderCount, _this.orderCount) || other.orderCount == _this.orderCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CustomerSearchResult;
  return Object.hash(runtimeType,_this.id,_this.fullName,_this.email,_this.phone,_this.points,_this.isGuest,_this.orderCount);
}

@override
String toString() {
  final _this = this as CustomerSearchResult;
  return 'CustomerSearchResult(id: ${_this.id}, fullName: ${_this.fullName}, email: ${_this.email}, phone: ${_this.phone}, points: ${_this.points}, isGuest: ${_this.isGuest}, orderCount: ${_this.orderCount})';
}


}

/// @nodoc
abstract mixin class $CustomerSearchResultCopyWith<$Res>  {
  factory $CustomerSearchResultCopyWith(CustomerSearchResult value, $Res Function(CustomerSearchResult) _then) = _$CustomerSearchResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String fullName, String? email, String? phone, int points, bool isGuest, int? orderCount
});




}
/// @nodoc
class _$CustomerSearchResultCopyWithImpl<$Res>
    implements $CustomerSearchResultCopyWith<$Res> {
  _$CustomerSearchResultCopyWithImpl(this._self, this._then);

  final CustomerSearchResult _self;
  final $Res Function(CustomerSearchResult) _then;

/// Create a copy of CustomerSearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? email = freezed,Object? phone = freezed,Object? points = null,Object? isGuest = null,Object? orderCount = freezed,}) {
  return _then(CustomerSearchResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,orderCount: freezed == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerSearchResult].
extension CustomerSearchResultPatterns on CustomerSearchResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerSearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerSearchResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerSearchResult value)  $default,){
final _that = this;
switch (_that) {
case _CustomerSearchResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerSearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerSearchResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String fullName,  String? email,  String? phone,  int points,  bool isGuest,  int? orderCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerSearchResult() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.phone,_that.points,_that.isGuest,_that.orderCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String fullName,  String? email,  String? phone,  int points,  bool isGuest,  int? orderCount)  $default,) {final _that = this;
switch (_that) {
case _CustomerSearchResult():
return $default(_that.id,_that.fullName,_that.email,_that.phone,_that.points,_that.isGuest,_that.orderCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String fullName,  String? email,  String? phone,  int points,  bool isGuest,  int? orderCount)?  $default,) {final _that = this;
switch (_that) {
case _CustomerSearchResult() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.phone,_that.points,_that.isGuest,_that.orderCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerSearchResult extends CustomerSearchResult {
  const _CustomerSearchResult({@JsonKey(name: '_id') required this.id, this.fullName = '', this.email, this.phone, this.points = 0, this.isGuest = false, this.orderCount}): super._();
  factory _CustomerSearchResult.fromJson(Map<String, dynamic> json) => _$CustomerSearchResultFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override@JsonKey() final  String fullName;
@override final  String? email;
@override final  String? phone;
@override@JsonKey() final  int points;
@override@JsonKey() final  bool isGuest;
@override final  int? orderCount;

/// Create a copy of CustomerSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerSearchResultCopyWith<_CustomerSearchResult> get copyWith => __$CustomerSearchResultCopyWithImpl<_CustomerSearchResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerSearchResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerSearchResult&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.points, points) || other.points == points)&&(identical(other.isGuest, isGuest) || other.isGuest == isGuest)&&(identical(other.orderCount, orderCount) || other.orderCount == orderCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,fullName,email,phone,points,isGuest,orderCount);
}

@override
String toString() {
    return 'CustomerSearchResult(id: $id, fullName: $fullName, email: $email, phone: $phone, points: $points, isGuest: $isGuest, orderCount: $orderCount)';
}


}

/// @nodoc
abstract mixin class _$CustomerSearchResultCopyWith<$Res> implements $CustomerSearchResultCopyWith<$Res> {
  factory _$CustomerSearchResultCopyWith(_CustomerSearchResult value, $Res Function(_CustomerSearchResult) _then) = __$CustomerSearchResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String fullName, String? email, String? phone, int points, bool isGuest, int? orderCount
});




}
/// @nodoc
class __$CustomerSearchResultCopyWithImpl<$Res>
    implements _$CustomerSearchResultCopyWith<$Res> {
  __$CustomerSearchResultCopyWithImpl(this._self, this._then);

  final _CustomerSearchResult _self;
  final $Res Function(_CustomerSearchResult) _then;

/// Create a copy of CustomerSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? email = freezed,Object? phone = freezed,Object? points = null,Object? isGuest = null,Object? orderCount = freezed,}) {
  return _then(_CustomerSearchResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,orderCount: freezed == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$RewardRedemption {

@JsonKey(name: '_id') String get id;@UserRefConverter() EntityRef<AppUser>? get customerId;@StoreRefConverter() EntityRef<Store>? get storeId;@UserRefConverter() EntityRef<AppUser>? get redeemedBy; String get rewardName; int get pointsUsed; String? get note; DateTime? get createdAt;
/// Create a copy of RewardRedemption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RewardRedemptionCopyWith<RewardRedemption> get copyWith => _$RewardRedemptionCopyWithImpl<RewardRedemption>(this as RewardRedemption, _$identity);

  /// Serializes this RewardRedemption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RewardRedemption;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RewardRedemption&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.storeId, _this.storeId) || other.storeId == _this.storeId)&&(identical(other.redeemedBy, _this.redeemedBy) || other.redeemedBy == _this.redeemedBy)&&(identical(other.rewardName, _this.rewardName) || other.rewardName == _this.rewardName)&&(identical(other.pointsUsed, _this.pointsUsed) || other.pointsUsed == _this.pointsUsed)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RewardRedemption;
  return Object.hash(runtimeType,_this.id,_this.customerId,_this.storeId,_this.redeemedBy,_this.rewardName,_this.pointsUsed,_this.note,_this.createdAt);
}

@override
String toString() {
  final _this = this as RewardRedemption;
  return 'RewardRedemption(id: ${_this.id}, customerId: ${_this.customerId}, storeId: ${_this.storeId}, redeemedBy: ${_this.redeemedBy}, rewardName: ${_this.rewardName}, pointsUsed: ${_this.pointsUsed}, note: ${_this.note}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $RewardRedemptionCopyWith<$Res>  {
  factory $RewardRedemptionCopyWith(RewardRedemption value, $Res Function(RewardRedemption) _then) = _$RewardRedemptionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id,@UserRefConverter() EntityRef<AppUser>? customerId,@StoreRefConverter() EntityRef<Store>? storeId,@UserRefConverter() EntityRef<AppUser>? redeemedBy, String rewardName, int pointsUsed, String? note, DateTime? createdAt
});




}
/// @nodoc
class _$RewardRedemptionCopyWithImpl<$Res>
    implements $RewardRedemptionCopyWith<$Res> {
  _$RewardRedemptionCopyWithImpl(this._self, this._then);

  final RewardRedemption _self;
  final $Res Function(RewardRedemption) _then;

/// Create a copy of RewardRedemption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerId = freezed,Object? storeId = freezed,Object? redeemedBy = freezed,Object? rewardName = null,Object? pointsUsed = null,Object? note = freezed,Object? createdAt = freezed,}) {
  return _then(RewardRedemption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,redeemedBy: freezed == redeemedBy ? _self.redeemedBy : redeemedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,rewardName: null == rewardName ? _self.rewardName : rewardName // ignore: cast_nullable_to_non_nullable
as String,pointsUsed: null == pointsUsed ? _self.pointsUsed : pointsUsed // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RewardRedemption].
extension RewardRedemptionPatterns on RewardRedemption {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RewardRedemption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RewardRedemption() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RewardRedemption value)  $default,){
final _that = this;
switch (_that) {
case _RewardRedemption():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RewardRedemption value)?  $default,){
final _that = this;
switch (_that) {
case _RewardRedemption() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id, @UserRefConverter()  EntityRef<AppUser>? customerId, @StoreRefConverter()  EntityRef<Store>? storeId, @UserRefConverter()  EntityRef<AppUser>? redeemedBy,  String rewardName,  int pointsUsed,  String? note,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RewardRedemption() when $default != null:
return $default(_that.id,_that.customerId,_that.storeId,_that.redeemedBy,_that.rewardName,_that.pointsUsed,_that.note,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id, @UserRefConverter()  EntityRef<AppUser>? customerId, @StoreRefConverter()  EntityRef<Store>? storeId, @UserRefConverter()  EntityRef<AppUser>? redeemedBy,  String rewardName,  int pointsUsed,  String? note,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _RewardRedemption():
return $default(_that.id,_that.customerId,_that.storeId,_that.redeemedBy,_that.rewardName,_that.pointsUsed,_that.note,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id, @UserRefConverter()  EntityRef<AppUser>? customerId, @StoreRefConverter()  EntityRef<Store>? storeId, @UserRefConverter()  EntityRef<AppUser>? redeemedBy,  String rewardName,  int pointsUsed,  String? note,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RewardRedemption() when $default != null:
return $default(_that.id,_that.customerId,_that.storeId,_that.redeemedBy,_that.rewardName,_that.pointsUsed,_that.note,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RewardRedemption implements RewardRedemption {
  const _RewardRedemption({@JsonKey(name: '_id') required this.id, @UserRefConverter() this.customerId, @StoreRefConverter() this.storeId, @UserRefConverter() this.redeemedBy, this.rewardName = '', this.pointsUsed = 0, this.note, this.createdAt});
  factory _RewardRedemption.fromJson(Map<String, dynamic> json) => _$RewardRedemptionFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override@UserRefConverter() final  EntityRef<AppUser>? customerId;
@override@StoreRefConverter() final  EntityRef<Store>? storeId;
@override@UserRefConverter() final  EntityRef<AppUser>? redeemedBy;
@override@JsonKey() final  String rewardName;
@override@JsonKey() final  int pointsUsed;
@override final  String? note;
@override final  DateTime? createdAt;

/// Create a copy of RewardRedemption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RewardRedemptionCopyWith<_RewardRedemption> get copyWith => __$RewardRedemptionCopyWithImpl<_RewardRedemption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RewardRedemptionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RewardRedemption&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.redeemedBy, redeemedBy) || other.redeemedBy == redeemedBy)&&(identical(other.rewardName, rewardName) || other.rewardName == rewardName)&&(identical(other.pointsUsed, pointsUsed) || other.pointsUsed == pointsUsed)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,customerId,storeId,redeemedBy,rewardName,pointsUsed,note,createdAt);
}

@override
String toString() {
    return 'RewardRedemption(id: $id, customerId: $customerId, storeId: $storeId, redeemedBy: $redeemedBy, rewardName: $rewardName, pointsUsed: $pointsUsed, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RewardRedemptionCopyWith<$Res> implements $RewardRedemptionCopyWith<$Res> {
  factory _$RewardRedemptionCopyWith(_RewardRedemption value, $Res Function(_RewardRedemption) _then) = __$RewardRedemptionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id,@UserRefConverter() EntityRef<AppUser>? customerId,@StoreRefConverter() EntityRef<Store>? storeId,@UserRefConverter() EntityRef<AppUser>? redeemedBy, String rewardName, int pointsUsed, String? note, DateTime? createdAt
});




}
/// @nodoc
class __$RewardRedemptionCopyWithImpl<$Res>
    implements _$RewardRedemptionCopyWith<$Res> {
  __$RewardRedemptionCopyWithImpl(this._self, this._then);

  final _RewardRedemption _self;
  final $Res Function(_RewardRedemption) _then;

/// Create a copy of RewardRedemption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerId = freezed,Object? storeId = freezed,Object? redeemedBy = freezed,Object? rewardName = null,Object? pointsUsed = null,Object? note = freezed,Object? createdAt = freezed,}) {
  return _then(_RewardRedemption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,redeemedBy: freezed == redeemedBy ? _self.redeemedBy : redeemedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,rewardName: null == rewardName ? _self.rewardName : rewardName // ignore: cast_nullable_to_non_nullable
as String,pointsUsed: null == pointsUsed ? _self.pointsUsed : pointsUsed // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$RedeemResult {

 CustomerSearchResult get customer; RewardRedemption? get redemption;
/// Create a copy of RedeemResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RedeemResultCopyWith<RedeemResult> get copyWith => _$RedeemResultCopyWithImpl<RedeemResult>(this as RedeemResult, _$identity);

  /// Serializes this RedeemResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RedeemResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RedeemResult&&(identical(other.customer, _this.customer) || other.customer == _this.customer)&&(identical(other.redemption, _this.redemption) || other.redemption == _this.redemption));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RedeemResult;
  return Object.hash(runtimeType,_this.customer,_this.redemption);
}

@override
String toString() {
  final _this = this as RedeemResult;
  return 'RedeemResult(customer: ${_this.customer}, redemption: ${_this.redemption})';
}


}

/// @nodoc
abstract mixin class $RedeemResultCopyWith<$Res>  {
  factory $RedeemResultCopyWith(RedeemResult value, $Res Function(RedeemResult) _then) = _$RedeemResultCopyWithImpl;
@useResult
$Res call({
 CustomerSearchResult customer, RewardRedemption? redemption
});


$CustomerSearchResultCopyWith<$Res> get customer;$RewardRedemptionCopyWith<$Res>? get redemption;

}
/// @nodoc
class _$RedeemResultCopyWithImpl<$Res>
    implements $RedeemResultCopyWith<$Res> {
  _$RedeemResultCopyWithImpl(this._self, this._then);

  final RedeemResult _self;
  final $Res Function(RedeemResult) _then;

/// Create a copy of RedeemResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customer = null,Object? redemption = freezed,}) {
  return _then(RedeemResult(
customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as CustomerSearchResult,redemption: freezed == redemption ? _self.redemption : redemption // ignore: cast_nullable_to_non_nullable
as RewardRedemption?,
  ));
}
/// Create a copy of RedeemResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerSearchResultCopyWith<$Res> get customer {
  
  return $CustomerSearchResultCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}/// Create a copy of RedeemResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RewardRedemptionCopyWith<$Res>? get redemption {
    if (_self.redemption == null) {
    return null;
  }

  return $RewardRedemptionCopyWith<$Res>(_self.redemption!, (value) {
    return _then(_self.copyWith(redemption: value));
  });
}
}


/// Adds pattern-matching-related methods to [RedeemResult].
extension RedeemResultPatterns on RedeemResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RedeemResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RedeemResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RedeemResult value)  $default,){
final _that = this;
switch (_that) {
case _RedeemResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RedeemResult value)?  $default,){
final _that = this;
switch (_that) {
case _RedeemResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CustomerSearchResult customer,  RewardRedemption? redemption)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RedeemResult() when $default != null:
return $default(_that.customer,_that.redemption);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CustomerSearchResult customer,  RewardRedemption? redemption)  $default,) {final _that = this;
switch (_that) {
case _RedeemResult():
return $default(_that.customer,_that.redemption);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CustomerSearchResult customer,  RewardRedemption? redemption)?  $default,) {final _that = this;
switch (_that) {
case _RedeemResult() when $default != null:
return $default(_that.customer,_that.redemption);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RedeemResult implements RedeemResult {
  const _RedeemResult({required this.customer, this.redemption});
  factory _RedeemResult.fromJson(Map<String, dynamic> json) => _$RedeemResultFromJson(json);

@override final  CustomerSearchResult customer;
@override final  RewardRedemption? redemption;

/// Create a copy of RedeemResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RedeemResultCopyWith<_RedeemResult> get copyWith => __$RedeemResultCopyWithImpl<_RedeemResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RedeemResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RedeemResult&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.redemption, redemption) || other.redemption == redemption));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,customer,redemption);
}

@override
String toString() {
    return 'RedeemResult(customer: $customer, redemption: $redemption)';
}


}

/// @nodoc
abstract mixin class _$RedeemResultCopyWith<$Res> implements $RedeemResultCopyWith<$Res> {
  factory _$RedeemResultCopyWith(_RedeemResult value, $Res Function(_RedeemResult) _then) = __$RedeemResultCopyWithImpl;
@override @useResult
$Res call({
 CustomerSearchResult customer, RewardRedemption? redemption
});


@override $CustomerSearchResultCopyWith<$Res> get customer;@override $RewardRedemptionCopyWith<$Res>? get redemption;

}
/// @nodoc
class __$RedeemResultCopyWithImpl<$Res>
    implements _$RedeemResultCopyWith<$Res> {
  __$RedeemResultCopyWithImpl(this._self, this._then);

  final _RedeemResult _self;
  final $Res Function(_RedeemResult) _then;

/// Create a copy of RedeemResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customer = null,Object? redemption = freezed,}) {
  return _then(_RedeemResult(
customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as CustomerSearchResult,redemption: freezed == redemption ? _self.redemption : redemption // ignore: cast_nullable_to_non_nullable
as RewardRedemption?,
  ));
}

/// Create a copy of RedeemResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerSearchResultCopyWith<$Res> get customer {
  
  return $CustomerSearchResultCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}/// Create a copy of RedeemResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RewardRedemptionCopyWith<$Res>? get redemption {
    if (_self.redemption == null) {
    return null;
  }

  return $RewardRedemptionCopyWith<$Res>(_self.redemption!, (value) {
    return _then(_self.copyWith(redemption: value));
  });
}
}

// dart format on
