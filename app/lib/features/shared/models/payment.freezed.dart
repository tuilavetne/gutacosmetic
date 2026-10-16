// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PayosPayment {

 String? get checkoutUrl;@FlexibleDateTimeConverter() DateTime? get expiredAt; String? get paymentLinkId;/// Data URL: `data:image/png;base64,...`.
 String? get qrImage;/// Chuỗi VietQR thô.
 String? get qrCode;
/// Create a copy of PayosPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayosPaymentCopyWith<PayosPayment> get copyWith => _$PayosPaymentCopyWithImpl<PayosPayment>(this as PayosPayment, _$identity);

  /// Serializes this PayosPayment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PayosPayment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayosPayment&&(identical(other.checkoutUrl, _this.checkoutUrl) || other.checkoutUrl == _this.checkoutUrl)&&(identical(other.expiredAt, _this.expiredAt) || other.expiredAt == _this.expiredAt)&&(identical(other.paymentLinkId, _this.paymentLinkId) || other.paymentLinkId == _this.paymentLinkId)&&(identical(other.qrImage, _this.qrImage) || other.qrImage == _this.qrImage)&&(identical(other.qrCode, _this.qrCode) || other.qrCode == _this.qrCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PayosPayment;
  return Object.hash(runtimeType,_this.checkoutUrl,_this.expiredAt,_this.paymentLinkId,_this.qrImage,_this.qrCode);
}

@override
String toString() {
  final _this = this as PayosPayment;
  return 'PayosPayment(checkoutUrl: ${_this.checkoutUrl}, expiredAt: ${_this.expiredAt}, paymentLinkId: ${_this.paymentLinkId}, qrImage: ${_this.qrImage}, qrCode: ${_this.qrCode})';
}


}

/// @nodoc
abstract mixin class $PayosPaymentCopyWith<$Res>  {
  factory $PayosPaymentCopyWith(PayosPayment value, $Res Function(PayosPayment) _then) = _$PayosPaymentCopyWithImpl;
@useResult
$Res call({
 String? checkoutUrl,@FlexibleDateTimeConverter() DateTime? expiredAt, String? paymentLinkId, String? qrImage, String? qrCode
});




}
/// @nodoc
class _$PayosPaymentCopyWithImpl<$Res>
    implements $PayosPaymentCopyWith<$Res> {
  _$PayosPaymentCopyWithImpl(this._self, this._then);

  final PayosPayment _self;
  final $Res Function(PayosPayment) _then;

/// Create a copy of PayosPayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? checkoutUrl = freezed,Object? expiredAt = freezed,Object? paymentLinkId = freezed,Object? qrImage = freezed,Object? qrCode = freezed,}) {
  return _then(PayosPayment(
checkoutUrl: freezed == checkoutUrl ? _self.checkoutUrl : checkoutUrl // ignore: cast_nullable_to_non_nullable
as String?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentLinkId: freezed == paymentLinkId ? _self.paymentLinkId : paymentLinkId // ignore: cast_nullable_to_non_nullable
as String?,qrImage: freezed == qrImage ? _self.qrImage : qrImage // ignore: cast_nullable_to_non_nullable
as String?,qrCode: freezed == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PayosPayment].
extension PayosPaymentPatterns on PayosPayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayosPayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayosPayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayosPayment value)  $default,){
final _that = this;
switch (_that) {
case _PayosPayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayosPayment value)?  $default,){
final _that = this;
switch (_that) {
case _PayosPayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? checkoutUrl, @FlexibleDateTimeConverter()  DateTime? expiredAt,  String? paymentLinkId,  String? qrImage,  String? qrCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayosPayment() when $default != null:
return $default(_that.checkoutUrl,_that.expiredAt,_that.paymentLinkId,_that.qrImage,_that.qrCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? checkoutUrl, @FlexibleDateTimeConverter()  DateTime? expiredAt,  String? paymentLinkId,  String? qrImage,  String? qrCode)  $default,) {final _that = this;
switch (_that) {
case _PayosPayment():
return $default(_that.checkoutUrl,_that.expiredAt,_that.paymentLinkId,_that.qrImage,_that.qrCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? checkoutUrl, @FlexibleDateTimeConverter()  DateTime? expiredAt,  String? paymentLinkId,  String? qrImage,  String? qrCode)?  $default,) {final _that = this;
switch (_that) {
case _PayosPayment() when $default != null:
return $default(_that.checkoutUrl,_that.expiredAt,_that.paymentLinkId,_that.qrImage,_that.qrCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PayosPayment extends PayosPayment {
  const _PayosPayment({this.checkoutUrl, @FlexibleDateTimeConverter() this.expiredAt, this.paymentLinkId, this.qrImage, this.qrCode}): super._();
  factory _PayosPayment.fromJson(Map<String, dynamic> json) => _$PayosPaymentFromJson(json);

@override final  String? checkoutUrl;
@override@FlexibleDateTimeConverter() final  DateTime? expiredAt;
@override final  String? paymentLinkId;
/// Data URL: `data:image/png;base64,...`.
@override final  String? qrImage;
/// Chuỗi VietQR thô.
@override final  String? qrCode;

/// Create a copy of PayosPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayosPaymentCopyWith<_PayosPayment> get copyWith => __$PayosPaymentCopyWithImpl<_PayosPayment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayosPaymentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayosPayment&&(identical(other.checkoutUrl, checkoutUrl) || other.checkoutUrl == checkoutUrl)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.paymentLinkId, paymentLinkId) || other.paymentLinkId == paymentLinkId)&&(identical(other.qrImage, qrImage) || other.qrImage == qrImage)&&(identical(other.qrCode, qrCode) || other.qrCode == qrCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,checkoutUrl,expiredAt,paymentLinkId,qrImage,qrCode);
}

@override
String toString() {
    return 'PayosPayment(checkoutUrl: $checkoutUrl, expiredAt: $expiredAt, paymentLinkId: $paymentLinkId, qrImage: $qrImage, qrCode: $qrCode)';
}


}

/// @nodoc
abstract mixin class _$PayosPaymentCopyWith<$Res> implements $PayosPaymentCopyWith<$Res> {
  factory _$PayosPaymentCopyWith(_PayosPayment value, $Res Function(_PayosPayment) _then) = __$PayosPaymentCopyWithImpl;
@override @useResult
$Res call({
 String? checkoutUrl,@FlexibleDateTimeConverter() DateTime? expiredAt, String? paymentLinkId, String? qrImage, String? qrCode
});




}
/// @nodoc
class __$PayosPaymentCopyWithImpl<$Res>
    implements _$PayosPaymentCopyWith<$Res> {
  __$PayosPaymentCopyWithImpl(this._self, this._then);

  final _PayosPayment _self;
  final $Res Function(_PayosPayment) _then;

/// Create a copy of PayosPayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? checkoutUrl = freezed,Object? expiredAt = freezed,Object? paymentLinkId = freezed,Object? qrImage = freezed,Object? qrCode = freezed,}) {
  return _then(_PayosPayment(
checkoutUrl: freezed == checkoutUrl ? _self.checkoutUrl : checkoutUrl // ignore: cast_nullable_to_non_nullable
as String?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentLinkId: freezed == paymentLinkId ? _self.paymentLinkId : paymentLinkId // ignore: cast_nullable_to_non_nullable
as String?,qrImage: freezed == qrImage ? _self.qrImage : qrImage // ignore: cast_nullable_to_non_nullable
as String?,qrCode: freezed == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PayosSyncResult {

 Order get order; String? get payosStatus;
/// Create a copy of PayosSyncResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayosSyncResultCopyWith<PayosSyncResult> get copyWith => _$PayosSyncResultCopyWithImpl<PayosSyncResult>(this as PayosSyncResult, _$identity);

  /// Serializes this PayosSyncResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PayosSyncResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayosSyncResult&&(identical(other.order, _this.order) || other.order == _this.order)&&(identical(other.payosStatus, _this.payosStatus) || other.payosStatus == _this.payosStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PayosSyncResult;
  return Object.hash(runtimeType,_this.order,_this.payosStatus);
}

@override
String toString() {
  final _this = this as PayosSyncResult;
  return 'PayosSyncResult(order: ${_this.order}, payosStatus: ${_this.payosStatus})';
}


}

/// @nodoc
abstract mixin class $PayosSyncResultCopyWith<$Res>  {
  factory $PayosSyncResultCopyWith(PayosSyncResult value, $Res Function(PayosSyncResult) _then) = _$PayosSyncResultCopyWithImpl;
@useResult
$Res call({
 Order order, String? payosStatus
});


$OrderCopyWith<$Res> get order;

}
/// @nodoc
class _$PayosSyncResultCopyWithImpl<$Res>
    implements $PayosSyncResultCopyWith<$Res> {
  _$PayosSyncResultCopyWithImpl(this._self, this._then);

  final PayosSyncResult _self;
  final $Res Function(PayosSyncResult) _then;

/// Create a copy of PayosSyncResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? order = null,Object? payosStatus = freezed,}) {
  return _then(PayosSyncResult(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as Order,payosStatus: freezed == payosStatus ? _self.payosStatus : payosStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PayosSyncResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderCopyWith<$Res> get order {
  
  return $OrderCopyWith<$Res>(_self.order, (value) {
    return _then(_self.copyWith(order: value));
  });
}
}


/// Adds pattern-matching-related methods to [PayosSyncResult].
extension PayosSyncResultPatterns on PayosSyncResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayosSyncResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayosSyncResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayosSyncResult value)  $default,){
final _that = this;
switch (_that) {
case _PayosSyncResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayosSyncResult value)?  $default,){
final _that = this;
switch (_that) {
case _PayosSyncResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Order order,  String? payosStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayosSyncResult() when $default != null:
return $default(_that.order,_that.payosStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Order order,  String? payosStatus)  $default,) {final _that = this;
switch (_that) {
case _PayosSyncResult():
return $default(_that.order,_that.payosStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Order order,  String? payosStatus)?  $default,) {final _that = this;
switch (_that) {
case _PayosSyncResult() when $default != null:
return $default(_that.order,_that.payosStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PayosSyncResult implements PayosSyncResult {
  const _PayosSyncResult({required this.order, this.payosStatus});
  factory _PayosSyncResult.fromJson(Map<String, dynamic> json) => _$PayosSyncResultFromJson(json);

@override final  Order order;
@override final  String? payosStatus;

/// Create a copy of PayosSyncResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayosSyncResultCopyWith<_PayosSyncResult> get copyWith => __$PayosSyncResultCopyWithImpl<_PayosSyncResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayosSyncResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayosSyncResult&&(identical(other.order, order) || other.order == order)&&(identical(other.payosStatus, payosStatus) || other.payosStatus == payosStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,order,payosStatus);
}

@override
String toString() {
    return 'PayosSyncResult(order: $order, payosStatus: $payosStatus)';
}


}

/// @nodoc
abstract mixin class _$PayosSyncResultCopyWith<$Res> implements $PayosSyncResultCopyWith<$Res> {
  factory _$PayosSyncResultCopyWith(_PayosSyncResult value, $Res Function(_PayosSyncResult) _then) = __$PayosSyncResultCopyWithImpl;
@override @useResult
$Res call({
 Order order, String? payosStatus
});


@override $OrderCopyWith<$Res> get order;

}
/// @nodoc
class __$PayosSyncResultCopyWithImpl<$Res>
    implements _$PayosSyncResultCopyWith<$Res> {
  __$PayosSyncResultCopyWithImpl(this._self, this._then);

  final _PayosSyncResult _self;
  final $Res Function(_PayosSyncResult) _then;

/// Create a copy of PayosSyncResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? order = null,Object? payosStatus = freezed,}) {
  return _then(_PayosSyncResult(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as Order,payosStatus: freezed == payosStatus ? _self.payosStatus : payosStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PayosSyncResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderCopyWith<$Res> get order {
  
  return $OrderCopyWith<$Res>(_self.order, (value) {
    return _then(_self.copyWith(order: value));
  });
}
}


/// @nodoc
mixin _$PlacedOrder {

 Order get order; PayosPayment? get payment;
/// Create a copy of PlacedOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlacedOrderCopyWith<PlacedOrder> get copyWith => _$PlacedOrderCopyWithImpl<PlacedOrder>(this as PlacedOrder, _$identity);

  /// Serializes this PlacedOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlacedOrder;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlacedOrder&&(identical(other.order, _this.order) || other.order == _this.order)&&(identical(other.payment, _this.payment) || other.payment == _this.payment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlacedOrder;
  return Object.hash(runtimeType,_this.order,_this.payment);
}

@override
String toString() {
  final _this = this as PlacedOrder;
  return 'PlacedOrder(order: ${_this.order}, payment: ${_this.payment})';
}


}

/// @nodoc
abstract mixin class $PlacedOrderCopyWith<$Res>  {
  factory $PlacedOrderCopyWith(PlacedOrder value, $Res Function(PlacedOrder) _then) = _$PlacedOrderCopyWithImpl;
@useResult
$Res call({
 Order order, PayosPayment? payment
});


$OrderCopyWith<$Res> get order;$PayosPaymentCopyWith<$Res>? get payment;

}
/// @nodoc
class _$PlacedOrderCopyWithImpl<$Res>
    implements $PlacedOrderCopyWith<$Res> {
  _$PlacedOrderCopyWithImpl(this._self, this._then);

  final PlacedOrder _self;
  final $Res Function(PlacedOrder) _then;

/// Create a copy of PlacedOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? order = null,Object? payment = freezed,}) {
  return _then(PlacedOrder(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as Order,payment: freezed == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as PayosPayment?,
  ));
}
/// Create a copy of PlacedOrder
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderCopyWith<$Res> get order {
  
  return $OrderCopyWith<$Res>(_self.order, (value) {
    return _then(_self.copyWith(order: value));
  });
}/// Create a copy of PlacedOrder
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PayosPaymentCopyWith<$Res>? get payment {
    if (_self.payment == null) {
    return null;
  }

  return $PayosPaymentCopyWith<$Res>(_self.payment!, (value) {
    return _then(_self.copyWith(payment: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlacedOrder].
extension PlacedOrderPatterns on PlacedOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlacedOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlacedOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlacedOrder value)  $default,){
final _that = this;
switch (_that) {
case _PlacedOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlacedOrder value)?  $default,){
final _that = this;
switch (_that) {
case _PlacedOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Order order,  PayosPayment? payment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlacedOrder() when $default != null:
return $default(_that.order,_that.payment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Order order,  PayosPayment? payment)  $default,) {final _that = this;
switch (_that) {
case _PlacedOrder():
return $default(_that.order,_that.payment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Order order,  PayosPayment? payment)?  $default,) {final _that = this;
switch (_that) {
case _PlacedOrder() when $default != null:
return $default(_that.order,_that.payment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlacedOrder implements PlacedOrder {
  const _PlacedOrder({required this.order, this.payment});
  factory _PlacedOrder.fromJson(Map<String, dynamic> json) => _$PlacedOrderFromJson(json);

@override final  Order order;
@override final  PayosPayment? payment;

/// Create a copy of PlacedOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlacedOrderCopyWith<_PlacedOrder> get copyWith => __$PlacedOrderCopyWithImpl<_PlacedOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlacedOrderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlacedOrder&&(identical(other.order, order) || other.order == order)&&(identical(other.payment, payment) || other.payment == payment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,order,payment);
}

@override
String toString() {
    return 'PlacedOrder(order: $order, payment: $payment)';
}


}

/// @nodoc
abstract mixin class _$PlacedOrderCopyWith<$Res> implements $PlacedOrderCopyWith<$Res> {
  factory _$PlacedOrderCopyWith(_PlacedOrder value, $Res Function(_PlacedOrder) _then) = __$PlacedOrderCopyWithImpl;
@override @useResult
$Res call({
 Order order, PayosPayment? payment
});


@override $OrderCopyWith<$Res> get order;@override $PayosPaymentCopyWith<$Res>? get payment;

}
/// @nodoc
class __$PlacedOrderCopyWithImpl<$Res>
    implements _$PlacedOrderCopyWith<$Res> {
  __$PlacedOrderCopyWithImpl(this._self, this._then);

  final _PlacedOrder _self;
  final $Res Function(_PlacedOrder) _then;

/// Create a copy of PlacedOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? order = null,Object? payment = freezed,}) {
  return _then(_PlacedOrder(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as Order,payment: freezed == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as PayosPayment?,
  ));
}

/// Create a copy of PlacedOrder
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderCopyWith<$Res> get order {
  
  return $OrderCopyWith<$Res>(_self.order, (value) {
    return _then(_self.copyWith(order: value));
  });
}/// Create a copy of PlacedOrder
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PayosPaymentCopyWith<$Res>? get payment {
    if (_self.payment == null) {
    return null;
  }

  return $PayosPaymentCopyWith<$Res>(_self.payment!, (value) {
    return _then(_self.copyWith(payment: value));
  });
}
}

// dart format on
