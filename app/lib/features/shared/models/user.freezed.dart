// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {

@JsonKey(name: '_id') String get id; String get fullName; String get email; UserRole get role; String? get phone; String? get address; bool get emailVerified;@JsonKey(unknownEnumValue: AuthProvider.local) AuthProvider get authProvider; String? get avatarUrl;@StoreRefConverter() EntityRef<Store>? get storeId; int get points; bool get isActive; DateTime? get disabledAt; String? get disabledReason;@IdListConverter() List<String> get wishlist; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppUser;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.emailVerified, _this.emailVerified) || other.emailVerified == _this.emailVerified)&&(identical(other.authProvider, _this.authProvider) || other.authProvider == _this.authProvider)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl)&&(identical(other.storeId, _this.storeId) || other.storeId == _this.storeId)&&(identical(other.points, _this.points) || other.points == _this.points)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.disabledAt, _this.disabledAt) || other.disabledAt == _this.disabledAt)&&(identical(other.disabledReason, _this.disabledReason) || other.disabledReason == _this.disabledReason)&&const DeepCollectionEquality().equals(other.wishlist, _this.wishlist)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppUser;
  return Object.hash(runtimeType,_this.id,_this.fullName,_this.email,_this.role,_this.phone,_this.address,_this.emailVerified,_this.authProvider,_this.avatarUrl,_this.storeId,_this.points,_this.isActive,_this.disabledAt,_this.disabledReason,const DeepCollectionEquality().hash(_this.wishlist),_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as AppUser;
  return 'AppUser(id: ${_this.id}, fullName: ${_this.fullName}, email: ${_this.email}, role: ${_this.role}, phone: ${_this.phone}, address: ${_this.address}, emailVerified: ${_this.emailVerified}, authProvider: ${_this.authProvider}, avatarUrl: ${_this.avatarUrl}, storeId: ${_this.storeId}, points: ${_this.points}, isActive: ${_this.isActive}, disabledAt: ${_this.disabledAt}, disabledReason: ${_this.disabledReason}, wishlist: ${_this.wishlist}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String fullName, String email, UserRole role, String? phone, String? address, bool emailVerified,@JsonKey(unknownEnumValue: AuthProvider.local) AuthProvider authProvider, String? avatarUrl,@StoreRefConverter() EntityRef<Store>? storeId, int points, bool isActive, DateTime? disabledAt, String? disabledReason,@IdListConverter() List<String> wishlist, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? role = null,Object? phone = freezed,Object? address = freezed,Object? emailVerified = null,Object? authProvider = null,Object? avatarUrl = freezed,Object? storeId = freezed,Object? points = null,Object? isActive = null,Object? disabledAt = freezed,Object? disabledReason = freezed,Object? wishlist = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(AppUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,authProvider: null == authProvider ? _self.authProvider : authProvider // ignore: cast_nullable_to_non_nullable
as AuthProvider,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,disabledAt: freezed == disabledAt ? _self.disabledAt : disabledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,disabledReason: freezed == disabledReason ? _self.disabledReason : disabledReason // ignore: cast_nullable_to_non_nullable
as String?,wishlist: null == wishlist ? _self.wishlist : wishlist // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String fullName,  String email,  UserRole role,  String? phone,  String? address,  bool emailVerified, @JsonKey(unknownEnumValue: AuthProvider.local)  AuthProvider authProvider,  String? avatarUrl, @StoreRefConverter()  EntityRef<Store>? storeId,  int points,  bool isActive,  DateTime? disabledAt,  String? disabledReason, @IdListConverter()  List<String> wishlist,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.role,_that.phone,_that.address,_that.emailVerified,_that.authProvider,_that.avatarUrl,_that.storeId,_that.points,_that.isActive,_that.disabledAt,_that.disabledReason,_that.wishlist,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String fullName,  String email,  UserRole role,  String? phone,  String? address,  bool emailVerified, @JsonKey(unknownEnumValue: AuthProvider.local)  AuthProvider authProvider,  String? avatarUrl, @StoreRefConverter()  EntityRef<Store>? storeId,  int points,  bool isActive,  DateTime? disabledAt,  String? disabledReason, @IdListConverter()  List<String> wishlist,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.id,_that.fullName,_that.email,_that.role,_that.phone,_that.address,_that.emailVerified,_that.authProvider,_that.avatarUrl,_that.storeId,_that.points,_that.isActive,_that.disabledAt,_that.disabledReason,_that.wishlist,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String fullName,  String email,  UserRole role,  String? phone,  String? address,  bool emailVerified, @JsonKey(unknownEnumValue: AuthProvider.local)  AuthProvider authProvider,  String? avatarUrl, @StoreRefConverter()  EntityRef<Store>? storeId,  int points,  bool isActive,  DateTime? disabledAt,  String? disabledReason, @IdListConverter()  List<String> wishlist,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.role,_that.phone,_that.address,_that.emailVerified,_that.authProvider,_that.avatarUrl,_that.storeId,_that.points,_that.isActive,_that.disabledAt,_that.disabledReason,_that.wishlist,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser extends AppUser {
  const _AppUser({@JsonKey(name: '_id') required this.id, this.fullName = '', this.email = '', required this.role, this.phone, this.address, this.emailVerified = false, @JsonKey(unknownEnumValue: AuthProvider.local) this.authProvider = AuthProvider.local, this.avatarUrl, @StoreRefConverter() this.storeId, this.points = 0, this.isActive = true, this.disabledAt, this.disabledReason, @IdListConverter()  List<String> wishlist = const <String>[], this.createdAt, this.updatedAt}): _wishlist = wishlist,super._();
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override@JsonKey() final  String fullName;
@override@JsonKey() final  String email;
@override final  UserRole role;
@override final  String? phone;
@override final  String? address;
@override@JsonKey() final  bool emailVerified;
@override@JsonKey(unknownEnumValue: AuthProvider.local) final  AuthProvider authProvider;
@override final  String? avatarUrl;
@override@StoreRefConverter() final  EntityRef<Store>? storeId;
@override@JsonKey() final  int points;
@override@JsonKey() final  bool isActive;
@override final  DateTime? disabledAt;
@override final  String? disabledReason;
 final  List<String> _wishlist;
@override@JsonKey()@IdListConverter() List<String> get wishlist {
  if (_wishlist is EqualUnmodifiableListView) return _wishlist;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_wishlist);
}

@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.authProvider, authProvider) || other.authProvider == authProvider)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.points, points) || other.points == points)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.disabledAt, disabledAt) || other.disabledAt == disabledAt)&&(identical(other.disabledReason, disabledReason) || other.disabledReason == disabledReason)&&const DeepCollectionEquality().equals(other.wishlist, _wishlist)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,fullName,email,role,phone,address,emailVerified,authProvider,avatarUrl,storeId,points,isActive,disabledAt,disabledReason,const DeepCollectionEquality().hash(_wishlist),createdAt,updatedAt);
}

@override
String toString() {
    return 'AppUser(id: $id, fullName: $fullName, email: $email, role: $role, phone: $phone, address: $address, emailVerified: $emailVerified, authProvider: $authProvider, avatarUrl: $avatarUrl, storeId: $storeId, points: $points, isActive: $isActive, disabledAt: $disabledAt, disabledReason: $disabledReason, wishlist: $wishlist, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String fullName, String email, UserRole role, String? phone, String? address, bool emailVerified,@JsonKey(unknownEnumValue: AuthProvider.local) AuthProvider authProvider, String? avatarUrl,@StoreRefConverter() EntityRef<Store>? storeId, int points, bool isActive, DateTime? disabledAt, String? disabledReason,@IdListConverter() List<String> wishlist, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? role = null,Object? phone = freezed,Object? address = freezed,Object? emailVerified = null,Object? authProvider = null,Object? avatarUrl = freezed,Object? storeId = freezed,Object? points = null,Object? isActive = null,Object? disabledAt = freezed,Object? disabledReason = freezed,Object? wishlist = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_AppUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,authProvider: null == authProvider ? _self.authProvider : authProvider // ignore: cast_nullable_to_non_nullable
as AuthProvider,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,disabledAt: freezed == disabledAt ? _self.disabledAt : disabledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,disabledReason: freezed == disabledReason ? _self.disabledReason : disabledReason // ignore: cast_nullable_to_non_nullable
as String?,wishlist: null == wishlist ? _self._wishlist : wishlist // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
