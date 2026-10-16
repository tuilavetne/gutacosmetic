// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthResult {

 AppUser get user; String get token;
/// Create a copy of AuthResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthResultCopyWith<AuthResult> get copyWith => _$AuthResultCopyWithImpl<AuthResult>(this as AuthResult, _$identity);

  /// Serializes this AuthResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuthResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthResult&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.token, _this.token) || other.token == _this.token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuthResult;
  return Object.hash(runtimeType,_this.user,_this.token);
}

@override
String toString() {
  final _this = this as AuthResult;
  return 'AuthResult(user: ${_this.user}, token: ${_this.token})';
}


}

/// @nodoc
abstract mixin class $AuthResultCopyWith<$Res>  {
  factory $AuthResultCopyWith(AuthResult value, $Res Function(AuthResult) _then) = _$AuthResultCopyWithImpl;
@useResult
$Res call({
 AppUser user, String token
});


$AppUserCopyWith<$Res> get user;

}
/// @nodoc
class _$AuthResultCopyWithImpl<$Res>
    implements $AuthResultCopyWith<$Res> {
  _$AuthResultCopyWithImpl(this._self, this._then);

  final AuthResult _self;
  final $Res Function(AuthResult) _then;

/// Create a copy of AuthResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? token = null,}) {
  return _then(AuthResult(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AppUser,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of AuthResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUserCopyWith<$Res> get user {
  
  return $AppUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthResult].
extension AuthResultPatterns on AuthResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthResult value)  $default,){
final _that = this;
switch (_that) {
case _AuthResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthResult value)?  $default,){
final _that = this;
switch (_that) {
case _AuthResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppUser user,  String token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthResult() when $default != null:
return $default(_that.user,_that.token);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppUser user,  String token)  $default,) {final _that = this;
switch (_that) {
case _AuthResult():
return $default(_that.user,_that.token);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppUser user,  String token)?  $default,) {final _that = this;
switch (_that) {
case _AuthResult() when $default != null:
return $default(_that.user,_that.token);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthResult implements AuthResult {
  const _AuthResult({required this.user, required this.token});
  factory _AuthResult.fromJson(Map<String, dynamic> json) => _$AuthResultFromJson(json);

@override final  AppUser user;
@override final  String token;

/// Create a copy of AuthResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthResultCopyWith<_AuthResult> get copyWith => __$AuthResultCopyWithImpl<_AuthResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthResult&&(identical(other.user, user) || other.user == user)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,user,token);
}

@override
String toString() {
    return 'AuthResult(user: $user, token: $token)';
}


}

/// @nodoc
abstract mixin class _$AuthResultCopyWith<$Res> implements $AuthResultCopyWith<$Res> {
  factory _$AuthResultCopyWith(_AuthResult value, $Res Function(_AuthResult) _then) = __$AuthResultCopyWithImpl;
@override @useResult
$Res call({
 AppUser user, String token
});


@override $AppUserCopyWith<$Res> get user;

}
/// @nodoc
class __$AuthResultCopyWithImpl<$Res>
    implements _$AuthResultCopyWith<$Res> {
  __$AuthResultCopyWithImpl(this._self, this._then);

  final _AuthResult _self;
  final $Res Function(_AuthResult) _then;

/// Create a copy of AuthResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? token = null,}) {
  return _then(_AuthResult(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AppUser,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of AuthResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUserCopyWith<$Res> get user {
  
  return $AppUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$OtpChallenge {

 String get challengeId; String get channel;/// Email đã che bớt, ví dụ `ng***@gmail.com`.
 String get deliveryTarget;/// Số giây OTP còn hiệu lực.
 int get expiresIn;/// Chỉ có khi backend chạy `OTP_MODE=development`.
 String? get developmentOtp;
/// Create a copy of OtpChallenge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpChallengeCopyWith<OtpChallenge> get copyWith => _$OtpChallengeCopyWithImpl<OtpChallenge>(this as OtpChallenge, _$identity);

  /// Serializes this OtpChallenge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OtpChallenge;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpChallenge&&(identical(other.challengeId, _this.challengeId) || other.challengeId == _this.challengeId)&&(identical(other.channel, _this.channel) || other.channel == _this.channel)&&(identical(other.deliveryTarget, _this.deliveryTarget) || other.deliveryTarget == _this.deliveryTarget)&&(identical(other.expiresIn, _this.expiresIn) || other.expiresIn == _this.expiresIn)&&(identical(other.developmentOtp, _this.developmentOtp) || other.developmentOtp == _this.developmentOtp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OtpChallenge;
  return Object.hash(runtimeType,_this.challengeId,_this.channel,_this.deliveryTarget,_this.expiresIn,_this.developmentOtp);
}

@override
String toString() {
  final _this = this as OtpChallenge;
  return 'OtpChallenge(challengeId: ${_this.challengeId}, channel: ${_this.channel}, deliveryTarget: ${_this.deliveryTarget}, expiresIn: ${_this.expiresIn}, developmentOtp: ${_this.developmentOtp})';
}


}

/// @nodoc
abstract mixin class $OtpChallengeCopyWith<$Res>  {
  factory $OtpChallengeCopyWith(OtpChallenge value, $Res Function(OtpChallenge) _then) = _$OtpChallengeCopyWithImpl;
@useResult
$Res call({
 String challengeId, String channel, String deliveryTarget, int expiresIn, String? developmentOtp
});




}
/// @nodoc
class _$OtpChallengeCopyWithImpl<$Res>
    implements $OtpChallengeCopyWith<$Res> {
  _$OtpChallengeCopyWithImpl(this._self, this._then);

  final OtpChallenge _self;
  final $Res Function(OtpChallenge) _then;

/// Create a copy of OtpChallenge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? challengeId = null,Object? channel = null,Object? deliveryTarget = null,Object? expiresIn = null,Object? developmentOtp = freezed,}) {
  return _then(OtpChallenge(
challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,deliveryTarget: null == deliveryTarget ? _self.deliveryTarget : deliveryTarget // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,developmentOtp: freezed == developmentOtp ? _self.developmentOtp : developmentOtp // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OtpChallenge].
extension OtpChallengePatterns on OtpChallenge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtpChallenge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtpChallenge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtpChallenge value)  $default,){
final _that = this;
switch (_that) {
case _OtpChallenge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtpChallenge value)?  $default,){
final _that = this;
switch (_that) {
case _OtpChallenge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String challengeId,  String channel,  String deliveryTarget,  int expiresIn,  String? developmentOtp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtpChallenge() when $default != null:
return $default(_that.challengeId,_that.channel,_that.deliveryTarget,_that.expiresIn,_that.developmentOtp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String challengeId,  String channel,  String deliveryTarget,  int expiresIn,  String? developmentOtp)  $default,) {final _that = this;
switch (_that) {
case _OtpChallenge():
return $default(_that.challengeId,_that.channel,_that.deliveryTarget,_that.expiresIn,_that.developmentOtp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String challengeId,  String channel,  String deliveryTarget,  int expiresIn,  String? developmentOtp)?  $default,) {final _that = this;
switch (_that) {
case _OtpChallenge() when $default != null:
return $default(_that.challengeId,_that.channel,_that.deliveryTarget,_that.expiresIn,_that.developmentOtp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OtpChallenge implements OtpChallenge {
  const _OtpChallenge({required this.challengeId, this.channel = 'EMAIL', this.deliveryTarget = '', this.expiresIn = 300, this.developmentOtp});
  factory _OtpChallenge.fromJson(Map<String, dynamic> json) => _$OtpChallengeFromJson(json);

@override final  String challengeId;
@override@JsonKey() final  String channel;
/// Email đã che bớt, ví dụ `ng***@gmail.com`.
@override@JsonKey() final  String deliveryTarget;
/// Số giây OTP còn hiệu lực.
@override@JsonKey() final  int expiresIn;
/// Chỉ có khi backend chạy `OTP_MODE=development`.
@override final  String? developmentOtp;

/// Create a copy of OtpChallenge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpChallengeCopyWith<_OtpChallenge> get copyWith => __$OtpChallengeCopyWithImpl<_OtpChallenge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OtpChallengeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpChallenge&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.deliveryTarget, deliveryTarget) || other.deliveryTarget == deliveryTarget)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.developmentOtp, developmentOtp) || other.developmentOtp == developmentOtp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,challengeId,channel,deliveryTarget,expiresIn,developmentOtp);
}

@override
String toString() {
    return 'OtpChallenge(challengeId: $challengeId, channel: $channel, deliveryTarget: $deliveryTarget, expiresIn: $expiresIn, developmentOtp: $developmentOtp)';
}


}

/// @nodoc
abstract mixin class _$OtpChallengeCopyWith<$Res> implements $OtpChallengeCopyWith<$Res> {
  factory _$OtpChallengeCopyWith(_OtpChallenge value, $Res Function(_OtpChallenge) _then) = __$OtpChallengeCopyWithImpl;
@override @useResult
$Res call({
 String challengeId, String channel, String deliveryTarget, int expiresIn, String? developmentOtp
});




}
/// @nodoc
class __$OtpChallengeCopyWithImpl<$Res>
    implements _$OtpChallengeCopyWith<$Res> {
  __$OtpChallengeCopyWithImpl(this._self, this._then);

  final _OtpChallenge _self;
  final $Res Function(_OtpChallenge) _then;

/// Create a copy of OtpChallenge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? challengeId = null,Object? channel = null,Object? deliveryTarget = null,Object? expiresIn = null,Object? developmentOtp = freezed,}) {
  return _then(_OtpChallenge(
challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,deliveryTarget: null == deliveryTarget ? _self.deliveryTarget : deliveryTarget // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,developmentOtp: freezed == developmentOtp ? _self.developmentOtp : developmentOtp // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PasswordResetToken {

 String get resetToken; int get expiresIn;
/// Create a copy of PasswordResetToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetTokenCopyWith<PasswordResetToken> get copyWith => _$PasswordResetTokenCopyWithImpl<PasswordResetToken>(this as PasswordResetToken, _$identity);

  /// Serializes this PasswordResetToken to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PasswordResetToken;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetToken&&(identical(other.resetToken, _this.resetToken) || other.resetToken == _this.resetToken)&&(identical(other.expiresIn, _this.expiresIn) || other.expiresIn == _this.expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PasswordResetToken;
  return Object.hash(runtimeType,_this.resetToken,_this.expiresIn);
}

@override
String toString() {
  final _this = this as PasswordResetToken;
  return 'PasswordResetToken(resetToken: ${_this.resetToken}, expiresIn: ${_this.expiresIn})';
}


}

/// @nodoc
abstract mixin class $PasswordResetTokenCopyWith<$Res>  {
  factory $PasswordResetTokenCopyWith(PasswordResetToken value, $Res Function(PasswordResetToken) _then) = _$PasswordResetTokenCopyWithImpl;
@useResult
$Res call({
 String resetToken, int expiresIn
});




}
/// @nodoc
class _$PasswordResetTokenCopyWithImpl<$Res>
    implements $PasswordResetTokenCopyWith<$Res> {
  _$PasswordResetTokenCopyWithImpl(this._self, this._then);

  final PasswordResetToken _self;
  final $Res Function(PasswordResetToken) _then;

/// Create a copy of PasswordResetToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? resetToken = null,Object? expiresIn = null,}) {
  return _then(PasswordResetToken(
resetToken: null == resetToken ? _self.resetToken : resetToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordResetToken].
extension PasswordResetTokenPatterns on PasswordResetToken {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordResetToken value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordResetToken() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordResetToken value)  $default,){
final _that = this;
switch (_that) {
case _PasswordResetToken():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordResetToken value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordResetToken() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String resetToken,  int expiresIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordResetToken() when $default != null:
return $default(_that.resetToken,_that.expiresIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String resetToken,  int expiresIn)  $default,) {final _that = this;
switch (_that) {
case _PasswordResetToken():
return $default(_that.resetToken,_that.expiresIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String resetToken,  int expiresIn)?  $default,) {final _that = this;
switch (_that) {
case _PasswordResetToken() when $default != null:
return $default(_that.resetToken,_that.expiresIn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PasswordResetToken implements PasswordResetToken {
  const _PasswordResetToken({required this.resetToken, this.expiresIn = 600});
  factory _PasswordResetToken.fromJson(Map<String, dynamic> json) => _$PasswordResetTokenFromJson(json);

@override final  String resetToken;
@override@JsonKey() final  int expiresIn;

/// Create a copy of PasswordResetToken
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordResetTokenCopyWith<_PasswordResetToken> get copyWith => __$PasswordResetTokenCopyWithImpl<_PasswordResetToken>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PasswordResetTokenToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordResetToken&&(identical(other.resetToken, resetToken) || other.resetToken == resetToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,resetToken,expiresIn);
}

@override
String toString() {
    return 'PasswordResetToken(resetToken: $resetToken, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class _$PasswordResetTokenCopyWith<$Res> implements $PasswordResetTokenCopyWith<$Res> {
  factory _$PasswordResetTokenCopyWith(_PasswordResetToken value, $Res Function(_PasswordResetToken) _then) = __$PasswordResetTokenCopyWithImpl;
@override @useResult
$Res call({
 String resetToken, int expiresIn
});




}
/// @nodoc
class __$PasswordResetTokenCopyWithImpl<$Res>
    implements _$PasswordResetTokenCopyWith<$Res> {
  __$PasswordResetTokenCopyWithImpl(this._self, this._then);

  final _PasswordResetToken _self;
  final $Res Function(_PasswordResetToken) _then;

/// Create a copy of PasswordResetToken
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? resetToken = null,Object? expiresIn = null,}) {
  return _then(_PasswordResetToken(
resetToken: null == resetToken ? _self.resetToken : resetToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
