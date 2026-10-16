// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShippingAddress {

 String get recipientName; String get phone; String get addressLine;
/// Create a copy of ShippingAddress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShippingAddressCopyWith<ShippingAddress> get copyWith => _$ShippingAddressCopyWithImpl<ShippingAddress>(this as ShippingAddress, _$identity);

  /// Serializes this ShippingAddress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ShippingAddress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShippingAddress&&(identical(other.recipientName, _this.recipientName) || other.recipientName == _this.recipientName)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.addressLine, _this.addressLine) || other.addressLine == _this.addressLine));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ShippingAddress;
  return Object.hash(runtimeType,_this.recipientName,_this.phone,_this.addressLine);
}

@override
String toString() {
  final _this = this as ShippingAddress;
  return 'ShippingAddress(recipientName: ${_this.recipientName}, phone: ${_this.phone}, addressLine: ${_this.addressLine})';
}


}

/// @nodoc
abstract mixin class $ShippingAddressCopyWith<$Res>  {
  factory $ShippingAddressCopyWith(ShippingAddress value, $Res Function(ShippingAddress) _then) = _$ShippingAddressCopyWithImpl;
@useResult
$Res call({
 String recipientName, String phone, String addressLine
});




}
/// @nodoc
class _$ShippingAddressCopyWithImpl<$Res>
    implements $ShippingAddressCopyWith<$Res> {
  _$ShippingAddressCopyWithImpl(this._self, this._then);

  final ShippingAddress _self;
  final $Res Function(ShippingAddress) _then;

/// Create a copy of ShippingAddress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recipientName = null,Object? phone = null,Object? addressLine = null,}) {
  return _then(ShippingAddress(
recipientName: null == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,addressLine: null == addressLine ? _self.addressLine : addressLine // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ShippingAddress].
extension ShippingAddressPatterns on ShippingAddress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShippingAddress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShippingAddress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShippingAddress value)  $default,){
final _that = this;
switch (_that) {
case _ShippingAddress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShippingAddress value)?  $default,){
final _that = this;
switch (_that) {
case _ShippingAddress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String recipientName,  String phone,  String addressLine)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShippingAddress() when $default != null:
return $default(_that.recipientName,_that.phone,_that.addressLine);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String recipientName,  String phone,  String addressLine)  $default,) {final _that = this;
switch (_that) {
case _ShippingAddress():
return $default(_that.recipientName,_that.phone,_that.addressLine);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String recipientName,  String phone,  String addressLine)?  $default,) {final _that = this;
switch (_that) {
case _ShippingAddress() when $default != null:
return $default(_that.recipientName,_that.phone,_that.addressLine);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShippingAddress implements ShippingAddress {
  const _ShippingAddress({this.recipientName = '', this.phone = '', this.addressLine = ''});
  factory _ShippingAddress.fromJson(Map<String, dynamic> json) => _$ShippingAddressFromJson(json);

@override@JsonKey() final  String recipientName;
@override@JsonKey() final  String phone;
@override@JsonKey() final  String addressLine;

/// Create a copy of ShippingAddress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShippingAddressCopyWith<_ShippingAddress> get copyWith => __$ShippingAddressCopyWithImpl<_ShippingAddress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShippingAddressToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShippingAddress&&(identical(other.recipientName, recipientName) || other.recipientName == recipientName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.addressLine, addressLine) || other.addressLine == addressLine));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,recipientName,phone,addressLine);
}

@override
String toString() {
    return 'ShippingAddress(recipientName: $recipientName, phone: $phone, addressLine: $addressLine)';
}


}

/// @nodoc
abstract mixin class _$ShippingAddressCopyWith<$Res> implements $ShippingAddressCopyWith<$Res> {
  factory _$ShippingAddressCopyWith(_ShippingAddress value, $Res Function(_ShippingAddress) _then) = __$ShippingAddressCopyWithImpl;
@override @useResult
$Res call({
 String recipientName, String phone, String addressLine
});




}
/// @nodoc
class __$ShippingAddressCopyWithImpl<$Res>
    implements _$ShippingAddressCopyWith<$Res> {
  __$ShippingAddressCopyWithImpl(this._self, this._then);

  final _ShippingAddress _self;
  final $Res Function(_ShippingAddress) _then;

/// Create a copy of ShippingAddress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recipientName = null,Object? phone = null,Object? addressLine = null,}) {
  return _then(_ShippingAddress(
recipientName: null == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,addressLine: null == addressLine ? _self.addressLine : addressLine // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$OrderItem {

@ProductRefConverter() EntityRef<Product> get productId; String get sku; String get name; String? get image; int get quantity; int get unitPrice; int get lineTotal;
/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemCopyWith<OrderItem> get copyWith => _$OrderItemCopyWithImpl<OrderItem>(this as OrderItem, _$identity);

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrderItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItem&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.sku, _this.sku) || other.sku == _this.sku)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.image, _this.image) || other.image == _this.image)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.lineTotal, _this.lineTotal) || other.lineTotal == _this.lineTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrderItem;
  return Object.hash(runtimeType,_this.productId,_this.sku,_this.name,_this.image,_this.quantity,_this.unitPrice,_this.lineTotal);
}

@override
String toString() {
  final _this = this as OrderItem;
  return 'OrderItem(productId: ${_this.productId}, sku: ${_this.sku}, name: ${_this.name}, image: ${_this.image}, quantity: ${_this.quantity}, unitPrice: ${_this.unitPrice}, lineTotal: ${_this.lineTotal})';
}


}

/// @nodoc
abstract mixin class $OrderItemCopyWith<$Res>  {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) _then) = _$OrderItemCopyWithImpl;
@useResult
$Res call({
@ProductRefConverter() EntityRef<Product> productId, String sku, String name, String? image, int quantity, int unitPrice, int lineTotal
});




}
/// @nodoc
class _$OrderItemCopyWithImpl<$Res>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._self, this._then);

  final OrderItem _self;
  final $Res Function(OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? sku = null,Object? name = null,Object? image = freezed,Object? quantity = null,Object? unitPrice = null,Object? lineTotal = null,}) {
  return _then(OrderItem(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as EntityRef<Product>,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderItem].
extension OrderItemPatterns on OrderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItem value)  $default,){
final _that = this;
switch (_that) {
case _OrderItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@ProductRefConverter()  EntityRef<Product> productId,  String sku,  String name,  String? image,  int quantity,  int unitPrice,  int lineTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.productId,_that.sku,_that.name,_that.image,_that.quantity,_that.unitPrice,_that.lineTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@ProductRefConverter()  EntityRef<Product> productId,  String sku,  String name,  String? image,  int quantity,  int unitPrice,  int lineTotal)  $default,) {final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that.productId,_that.sku,_that.name,_that.image,_that.quantity,_that.unitPrice,_that.lineTotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@ProductRefConverter()  EntityRef<Product> productId,  String sku,  String name,  String? image,  int quantity,  int unitPrice,  int lineTotal)?  $default,) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.productId,_that.sku,_that.name,_that.image,_that.quantity,_that.unitPrice,_that.lineTotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderItem implements OrderItem {
  const _OrderItem({@ProductRefConverter() required this.productId, this.sku = '', this.name = '', this.image, this.quantity = 1, this.unitPrice = 0, this.lineTotal = 0});
  factory _OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);

@override@ProductRefConverter() final  EntityRef<Product> productId;
@override@JsonKey() final  String sku;
@override@JsonKey() final  String name;
@override final  String? image;
@override@JsonKey() final  int quantity;
@override@JsonKey() final  int unitPrice;
@override@JsonKey() final  int lineTotal;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemCopyWith<_OrderItem> get copyWith => __$OrderItemCopyWithImpl<_OrderItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItem&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.name, name) || other.name == name)&&(identical(other.image, image) || other.image == image)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.lineTotal, lineTotal) || other.lineTotal == lineTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,sku,name,image,quantity,unitPrice,lineTotal);
}

@override
String toString() {
    return 'OrderItem(productId: $productId, sku: $sku, name: $name, image: $image, quantity: $quantity, unitPrice: $unitPrice, lineTotal: $lineTotal)';
}


}

/// @nodoc
abstract mixin class _$OrderItemCopyWith<$Res> implements $OrderItemCopyWith<$Res> {
  factory _$OrderItemCopyWith(_OrderItem value, $Res Function(_OrderItem) _then) = __$OrderItemCopyWithImpl;
@override @useResult
$Res call({
@ProductRefConverter() EntityRef<Product> productId, String sku, String name, String? image, int quantity, int unitPrice, int lineTotal
});




}
/// @nodoc
class __$OrderItemCopyWithImpl<$Res>
    implements _$OrderItemCopyWith<$Res> {
  __$OrderItemCopyWithImpl(this._self, this._then);

  final _OrderItem _self;
  final $Res Function(_OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? sku = null,Object? name = null,Object? image = freezed,Object? quantity = null,Object? unitPrice = null,Object? lineTotal = null,}) {
  return _then(_OrderItem(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as EntityRef<Product>,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$StatusHistoryEntry {

 OrderStatus get status;@UserRefConverter() EntityRef<AppUser>? get changedBy; String? get note; DateTime? get changedAt;
/// Create a copy of StatusHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusHistoryEntryCopyWith<StatusHistoryEntry> get copyWith => _$StatusHistoryEntryCopyWithImpl<StatusHistoryEntry>(this as StatusHistoryEntry, _$identity);

  /// Serializes this StatusHistoryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StatusHistoryEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusHistoryEntry&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.changedBy, _this.changedBy) || other.changedBy == _this.changedBy)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.changedAt, _this.changedAt) || other.changedAt == _this.changedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StatusHistoryEntry;
  return Object.hash(runtimeType,_this.status,_this.changedBy,_this.note,_this.changedAt);
}

@override
String toString() {
  final _this = this as StatusHistoryEntry;
  return 'StatusHistoryEntry(status: ${_this.status}, changedBy: ${_this.changedBy}, note: ${_this.note}, changedAt: ${_this.changedAt})';
}


}

/// @nodoc
abstract mixin class $StatusHistoryEntryCopyWith<$Res>  {
  factory $StatusHistoryEntryCopyWith(StatusHistoryEntry value, $Res Function(StatusHistoryEntry) _then) = _$StatusHistoryEntryCopyWithImpl;
@useResult
$Res call({
 OrderStatus status,@UserRefConverter() EntityRef<AppUser>? changedBy, String? note, DateTime? changedAt
});




}
/// @nodoc
class _$StatusHistoryEntryCopyWithImpl<$Res>
    implements $StatusHistoryEntryCopyWith<$Res> {
  _$StatusHistoryEntryCopyWithImpl(this._self, this._then);

  final StatusHistoryEntry _self;
  final $Res Function(StatusHistoryEntry) _then;

/// Create a copy of StatusHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? changedBy = freezed,Object? note = freezed,Object? changedAt = freezed,}) {
  return _then(StatusHistoryEntry(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,changedBy: freezed == changedBy ? _self.changedBy : changedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,changedAt: freezed == changedAt ? _self.changedAt : changedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StatusHistoryEntry].
extension StatusHistoryEntryPatterns on StatusHistoryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatusHistoryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatusHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatusHistoryEntry value)  $default,){
final _that = this;
switch (_that) {
case _StatusHistoryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatusHistoryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _StatusHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OrderStatus status, @UserRefConverter()  EntityRef<AppUser>? changedBy,  String? note,  DateTime? changedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatusHistoryEntry() when $default != null:
return $default(_that.status,_that.changedBy,_that.note,_that.changedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OrderStatus status, @UserRefConverter()  EntityRef<AppUser>? changedBy,  String? note,  DateTime? changedAt)  $default,) {final _that = this;
switch (_that) {
case _StatusHistoryEntry():
return $default(_that.status,_that.changedBy,_that.note,_that.changedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OrderStatus status, @UserRefConverter()  EntityRef<AppUser>? changedBy,  String? note,  DateTime? changedAt)?  $default,) {final _that = this;
switch (_that) {
case _StatusHistoryEntry() when $default != null:
return $default(_that.status,_that.changedBy,_that.note,_that.changedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatusHistoryEntry implements StatusHistoryEntry {
  const _StatusHistoryEntry({required this.status, @UserRefConverter() this.changedBy, this.note, this.changedAt});
  factory _StatusHistoryEntry.fromJson(Map<String, dynamic> json) => _$StatusHistoryEntryFromJson(json);

@override final  OrderStatus status;
@override@UserRefConverter() final  EntityRef<AppUser>? changedBy;
@override final  String? note;
@override final  DateTime? changedAt;

/// Create a copy of StatusHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusHistoryEntryCopyWith<_StatusHistoryEntry> get copyWith => __$StatusHistoryEntryCopyWithImpl<_StatusHistoryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatusHistoryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusHistoryEntry&&(identical(other.status, status) || other.status == status)&&(identical(other.changedBy, changedBy) || other.changedBy == changedBy)&&(identical(other.note, note) || other.note == note)&&(identical(other.changedAt, changedAt) || other.changedAt == changedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,changedBy,note,changedAt);
}

@override
String toString() {
    return 'StatusHistoryEntry(status: $status, changedBy: $changedBy, note: $note, changedAt: $changedAt)';
}


}

/// @nodoc
abstract mixin class _$StatusHistoryEntryCopyWith<$Res> implements $StatusHistoryEntryCopyWith<$Res> {
  factory _$StatusHistoryEntryCopyWith(_StatusHistoryEntry value, $Res Function(_StatusHistoryEntry) _then) = __$StatusHistoryEntryCopyWithImpl;
@override @useResult
$Res call({
 OrderStatus status,@UserRefConverter() EntityRef<AppUser>? changedBy, String? note, DateTime? changedAt
});




}
/// @nodoc
class __$StatusHistoryEntryCopyWithImpl<$Res>
    implements _$StatusHistoryEntryCopyWith<$Res> {
  __$StatusHistoryEntryCopyWithImpl(this._self, this._then);

  final _StatusHistoryEntry _self;
  final $Res Function(_StatusHistoryEntry) _then;

/// Create a copy of StatusHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? changedBy = freezed,Object? note = freezed,Object? changedAt = freezed,}) {
  return _then(_StatusHistoryEntry(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,changedBy: freezed == changedBy ? _self.changedBy : changedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,changedAt: freezed == changedAt ? _self.changedAt : changedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Order {

@JsonKey(name: '_id') String get id; String get orderCode; OrderChannel get channel; FulfillmentType? get fulfillmentType;@UserRefConverter() EntityRef<AppUser>? get customerId; String? get customerName; String? get customerPhone; ShippingAddress? get shippingAddress;@StoreRefConverter() EntityRef<Store>? get storeId; List<OrderItem> get items; int get subtotal; int get discountAmount; int get shippingFee; int get totalPrice; int get pointsUsed; int get pointsEarned; OrderStatus get status; PaymentStatus get paymentStatus; PaymentMethod? get paymentMethod; String? get paymentProvider;@StringishConverter() String? get paymentOrderCode; String? get paymentLinkId; String? get checkoutUrl; String? get qrCode; String? get paymentReference;@FlexibleDateTimeConverter() DateTime? get paymentExpiresAt; bool get inventoryReserved;@UserRefConverter() EntityRef<AppUser>? get createdBySalesId;@UserRefConverter() EntityRef<AppUser>? get approvedBySalesId;@UserRefConverter() EntityRef<AppUser>? get paidByManagerId;@UserRefConverter() EntityRef<AppUser>? get cancelledBy; String? get cancellationReason; List<StatusHistoryEntry> get statusHistory; DateTime? get paidAt; DateTime? get completedAt; DateTime? get cancelledAt; bool get isReviewed; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Order;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.orderCode, _this.orderCode) || other.orderCode == _this.orderCode)&&(identical(other.channel, _this.channel) || other.channel == _this.channel)&&(identical(other.fulfillmentType, _this.fulfillmentType) || other.fulfillmentType == _this.fulfillmentType)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.customerPhone, _this.customerPhone) || other.customerPhone == _this.customerPhone)&&(identical(other.shippingAddress, _this.shippingAddress) || other.shippingAddress == _this.shippingAddress)&&(identical(other.storeId, _this.storeId) || other.storeId == _this.storeId)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.subtotal, _this.subtotal) || other.subtotal == _this.subtotal)&&(identical(other.discountAmount, _this.discountAmount) || other.discountAmount == _this.discountAmount)&&(identical(other.shippingFee, _this.shippingFee) || other.shippingFee == _this.shippingFee)&&(identical(other.totalPrice, _this.totalPrice) || other.totalPrice == _this.totalPrice)&&(identical(other.pointsUsed, _this.pointsUsed) || other.pointsUsed == _this.pointsUsed)&&(identical(other.pointsEarned, _this.pointsEarned) || other.pointsEarned == _this.pointsEarned)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.paymentStatus, _this.paymentStatus) || other.paymentStatus == _this.paymentStatus)&&(identical(other.paymentMethod, _this.paymentMethod) || other.paymentMethod == _this.paymentMethod)&&(identical(other.paymentProvider, _this.paymentProvider) || other.paymentProvider == _this.paymentProvider)&&(identical(other.paymentOrderCode, _this.paymentOrderCode) || other.paymentOrderCode == _this.paymentOrderCode)&&(identical(other.paymentLinkId, _this.paymentLinkId) || other.paymentLinkId == _this.paymentLinkId)&&(identical(other.checkoutUrl, _this.checkoutUrl) || other.checkoutUrl == _this.checkoutUrl)&&(identical(other.qrCode, _this.qrCode) || other.qrCode == _this.qrCode)&&(identical(other.paymentReference, _this.paymentReference) || other.paymentReference == _this.paymentReference)&&(identical(other.paymentExpiresAt, _this.paymentExpiresAt) || other.paymentExpiresAt == _this.paymentExpiresAt)&&(identical(other.inventoryReserved, _this.inventoryReserved) || other.inventoryReserved == _this.inventoryReserved)&&(identical(other.createdBySalesId, _this.createdBySalesId) || other.createdBySalesId == _this.createdBySalesId)&&(identical(other.approvedBySalesId, _this.approvedBySalesId) || other.approvedBySalesId == _this.approvedBySalesId)&&(identical(other.paidByManagerId, _this.paidByManagerId) || other.paidByManagerId == _this.paidByManagerId)&&(identical(other.cancelledBy, _this.cancelledBy) || other.cancelledBy == _this.cancelledBy)&&(identical(other.cancellationReason, _this.cancellationReason) || other.cancellationReason == _this.cancellationReason)&&const DeepCollectionEquality().equals(other.statusHistory, _this.statusHistory)&&(identical(other.paidAt, _this.paidAt) || other.paidAt == _this.paidAt)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt)&&(identical(other.cancelledAt, _this.cancelledAt) || other.cancelledAt == _this.cancelledAt)&&(identical(other.isReviewed, _this.isReviewed) || other.isReviewed == _this.isReviewed)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Order;
  return Object.hashAll([runtimeType,_this.id,_this.orderCode,_this.channel,_this.fulfillmentType,_this.customerId,_this.customerName,_this.customerPhone,_this.shippingAddress,_this.storeId,const DeepCollectionEquality().hash(_this.items),_this.subtotal,_this.discountAmount,_this.shippingFee,_this.totalPrice,_this.pointsUsed,_this.pointsEarned,_this.status,_this.paymentStatus,_this.paymentMethod,_this.paymentProvider,_this.paymentOrderCode,_this.paymentLinkId,_this.checkoutUrl,_this.qrCode,_this.paymentReference,_this.paymentExpiresAt,_this.inventoryReserved,_this.createdBySalesId,_this.approvedBySalesId,_this.paidByManagerId,_this.cancelledBy,_this.cancellationReason,const DeepCollectionEquality().hash(_this.statusHistory),_this.paidAt,_this.completedAt,_this.cancelledAt,_this.isReviewed,_this.createdAt,_this.updatedAt]);
}

@override
String toString() {
  final _this = this as Order;
  return 'Order(id: ${_this.id}, orderCode: ${_this.orderCode}, channel: ${_this.channel}, fulfillmentType: ${_this.fulfillmentType}, customerId: ${_this.customerId}, customerName: ${_this.customerName}, customerPhone: ${_this.customerPhone}, shippingAddress: ${_this.shippingAddress}, storeId: ${_this.storeId}, items: ${_this.items}, subtotal: ${_this.subtotal}, discountAmount: ${_this.discountAmount}, shippingFee: ${_this.shippingFee}, totalPrice: ${_this.totalPrice}, pointsUsed: ${_this.pointsUsed}, pointsEarned: ${_this.pointsEarned}, status: ${_this.status}, paymentStatus: ${_this.paymentStatus}, paymentMethod: ${_this.paymentMethod}, paymentProvider: ${_this.paymentProvider}, paymentOrderCode: ${_this.paymentOrderCode}, paymentLinkId: ${_this.paymentLinkId}, checkoutUrl: ${_this.checkoutUrl}, qrCode: ${_this.qrCode}, paymentReference: ${_this.paymentReference}, paymentExpiresAt: ${_this.paymentExpiresAt}, inventoryReserved: ${_this.inventoryReserved}, createdBySalesId: ${_this.createdBySalesId}, approvedBySalesId: ${_this.approvedBySalesId}, paidByManagerId: ${_this.paidByManagerId}, cancelledBy: ${_this.cancelledBy}, cancellationReason: ${_this.cancellationReason}, statusHistory: ${_this.statusHistory}, paidAt: ${_this.paidAt}, completedAt: ${_this.completedAt}, cancelledAt: ${_this.cancelledAt}, isReviewed: ${_this.isReviewed}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String orderCode, OrderChannel channel, FulfillmentType? fulfillmentType,@UserRefConverter() EntityRef<AppUser>? customerId, String? customerName, String? customerPhone, ShippingAddress? shippingAddress,@StoreRefConverter() EntityRef<Store>? storeId, List<OrderItem> items, int subtotal, int discountAmount, int shippingFee, int totalPrice, int pointsUsed, int pointsEarned, OrderStatus status, PaymentStatus paymentStatus, PaymentMethod? paymentMethod, String? paymentProvider,@StringishConverter() String? paymentOrderCode, String? paymentLinkId, String? checkoutUrl, String? qrCode, String? paymentReference,@FlexibleDateTimeConverter() DateTime? paymentExpiresAt, bool inventoryReserved,@UserRefConverter() EntityRef<AppUser>? createdBySalesId,@UserRefConverter() EntityRef<AppUser>? approvedBySalesId,@UserRefConverter() EntityRef<AppUser>? paidByManagerId,@UserRefConverter() EntityRef<AppUser>? cancelledBy, String? cancellationReason, List<StatusHistoryEntry> statusHistory, DateTime? paidAt, DateTime? completedAt, DateTime? cancelledAt, bool isReviewed, DateTime? createdAt, DateTime? updatedAt
});


$ShippingAddressCopyWith<$Res>? get shippingAddress;

}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderCode = null,Object? channel = null,Object? fulfillmentType = freezed,Object? customerId = freezed,Object? customerName = freezed,Object? customerPhone = freezed,Object? shippingAddress = freezed,Object? storeId = freezed,Object? items = null,Object? subtotal = null,Object? discountAmount = null,Object? shippingFee = null,Object? totalPrice = null,Object? pointsUsed = null,Object? pointsEarned = null,Object? status = null,Object? paymentStatus = null,Object? paymentMethod = freezed,Object? paymentProvider = freezed,Object? paymentOrderCode = freezed,Object? paymentLinkId = freezed,Object? checkoutUrl = freezed,Object? qrCode = freezed,Object? paymentReference = freezed,Object? paymentExpiresAt = freezed,Object? inventoryReserved = null,Object? createdBySalesId = freezed,Object? approvedBySalesId = freezed,Object? paidByManagerId = freezed,Object? cancelledBy = freezed,Object? cancellationReason = freezed,Object? statusHistory = null,Object? paidAt = freezed,Object? completedAt = freezed,Object? cancelledAt = freezed,Object? isReviewed = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderCode: null == orderCode ? _self.orderCode : orderCode // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as OrderChannel,fulfillmentType: freezed == fulfillmentType ? _self.fulfillmentType : fulfillmentType // ignore: cast_nullable_to_non_nullable
as FulfillmentType?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,shippingAddress: freezed == shippingAddress ? _self.shippingAddress : shippingAddress // ignore: cast_nullable_to_non_nullable
as ShippingAddress?,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as int,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as int,shippingFee: null == shippingFee ? _self.shippingFee : shippingFee // ignore: cast_nullable_to_non_nullable
as int,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as int,pointsUsed: null == pointsUsed ? _self.pointsUsed : pointsUsed // ignore: cast_nullable_to_non_nullable
as int,pointsEarned: null == pointsEarned ? _self.pointsEarned : pointsEarned // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod?,paymentProvider: freezed == paymentProvider ? _self.paymentProvider : paymentProvider // ignore: cast_nullable_to_non_nullable
as String?,paymentOrderCode: freezed == paymentOrderCode ? _self.paymentOrderCode : paymentOrderCode // ignore: cast_nullable_to_non_nullable
as String?,paymentLinkId: freezed == paymentLinkId ? _self.paymentLinkId : paymentLinkId // ignore: cast_nullable_to_non_nullable
as String?,checkoutUrl: freezed == checkoutUrl ? _self.checkoutUrl : checkoutUrl // ignore: cast_nullable_to_non_nullable
as String?,qrCode: freezed == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String?,paymentReference: freezed == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String?,paymentExpiresAt: freezed == paymentExpiresAt ? _self.paymentExpiresAt : paymentExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,inventoryReserved: null == inventoryReserved ? _self.inventoryReserved : inventoryReserved // ignore: cast_nullable_to_non_nullable
as bool,createdBySalesId: freezed == createdBySalesId ? _self.createdBySalesId : createdBySalesId // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,approvedBySalesId: freezed == approvedBySalesId ? _self.approvedBySalesId : approvedBySalesId // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,paidByManagerId: freezed == paidByManagerId ? _self.paidByManagerId : paidByManagerId // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,cancelledBy: freezed == cancelledBy ? _self.cancelledBy : cancelledBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,statusHistory: null == statusHistory ? _self.statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<StatusHistoryEntry>,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isReviewed: null == isReviewed ? _self.isReviewed : isReviewed // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShippingAddressCopyWith<$Res>? get shippingAddress {
    if (_self.shippingAddress == null) {
    return null;
  }

  return $ShippingAddressCopyWith<$Res>(_self.shippingAddress!, (value) {
    return _then(_self.copyWith(shippingAddress: value));
  });
}
}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String orderCode,  OrderChannel channel,  FulfillmentType? fulfillmentType, @UserRefConverter()  EntityRef<AppUser>? customerId,  String? customerName,  String? customerPhone,  ShippingAddress? shippingAddress, @StoreRefConverter()  EntityRef<Store>? storeId,  List<OrderItem> items,  int subtotal,  int discountAmount,  int shippingFee,  int totalPrice,  int pointsUsed,  int pointsEarned,  OrderStatus status,  PaymentStatus paymentStatus,  PaymentMethod? paymentMethod,  String? paymentProvider, @StringishConverter()  String? paymentOrderCode,  String? paymentLinkId,  String? checkoutUrl,  String? qrCode,  String? paymentReference, @FlexibleDateTimeConverter()  DateTime? paymentExpiresAt,  bool inventoryReserved, @UserRefConverter()  EntityRef<AppUser>? createdBySalesId, @UserRefConverter()  EntityRef<AppUser>? approvedBySalesId, @UserRefConverter()  EntityRef<AppUser>? paidByManagerId, @UserRefConverter()  EntityRef<AppUser>? cancelledBy,  String? cancellationReason,  List<StatusHistoryEntry> statusHistory,  DateTime? paidAt,  DateTime? completedAt,  DateTime? cancelledAt,  bool isReviewed,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.orderCode,_that.channel,_that.fulfillmentType,_that.customerId,_that.customerName,_that.customerPhone,_that.shippingAddress,_that.storeId,_that.items,_that.subtotal,_that.discountAmount,_that.shippingFee,_that.totalPrice,_that.pointsUsed,_that.pointsEarned,_that.status,_that.paymentStatus,_that.paymentMethod,_that.paymentProvider,_that.paymentOrderCode,_that.paymentLinkId,_that.checkoutUrl,_that.qrCode,_that.paymentReference,_that.paymentExpiresAt,_that.inventoryReserved,_that.createdBySalesId,_that.approvedBySalesId,_that.paidByManagerId,_that.cancelledBy,_that.cancellationReason,_that.statusHistory,_that.paidAt,_that.completedAt,_that.cancelledAt,_that.isReviewed,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String orderCode,  OrderChannel channel,  FulfillmentType? fulfillmentType, @UserRefConverter()  EntityRef<AppUser>? customerId,  String? customerName,  String? customerPhone,  ShippingAddress? shippingAddress, @StoreRefConverter()  EntityRef<Store>? storeId,  List<OrderItem> items,  int subtotal,  int discountAmount,  int shippingFee,  int totalPrice,  int pointsUsed,  int pointsEarned,  OrderStatus status,  PaymentStatus paymentStatus,  PaymentMethod? paymentMethod,  String? paymentProvider, @StringishConverter()  String? paymentOrderCode,  String? paymentLinkId,  String? checkoutUrl,  String? qrCode,  String? paymentReference, @FlexibleDateTimeConverter()  DateTime? paymentExpiresAt,  bool inventoryReserved, @UserRefConverter()  EntityRef<AppUser>? createdBySalesId, @UserRefConverter()  EntityRef<AppUser>? approvedBySalesId, @UserRefConverter()  EntityRef<AppUser>? paidByManagerId, @UserRefConverter()  EntityRef<AppUser>? cancelledBy,  String? cancellationReason,  List<StatusHistoryEntry> statusHistory,  DateTime? paidAt,  DateTime? completedAt,  DateTime? cancelledAt,  bool isReviewed,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.orderCode,_that.channel,_that.fulfillmentType,_that.customerId,_that.customerName,_that.customerPhone,_that.shippingAddress,_that.storeId,_that.items,_that.subtotal,_that.discountAmount,_that.shippingFee,_that.totalPrice,_that.pointsUsed,_that.pointsEarned,_that.status,_that.paymentStatus,_that.paymentMethod,_that.paymentProvider,_that.paymentOrderCode,_that.paymentLinkId,_that.checkoutUrl,_that.qrCode,_that.paymentReference,_that.paymentExpiresAt,_that.inventoryReserved,_that.createdBySalesId,_that.approvedBySalesId,_that.paidByManagerId,_that.cancelledBy,_that.cancellationReason,_that.statusHistory,_that.paidAt,_that.completedAt,_that.cancelledAt,_that.isReviewed,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String orderCode,  OrderChannel channel,  FulfillmentType? fulfillmentType, @UserRefConverter()  EntityRef<AppUser>? customerId,  String? customerName,  String? customerPhone,  ShippingAddress? shippingAddress, @StoreRefConverter()  EntityRef<Store>? storeId,  List<OrderItem> items,  int subtotal,  int discountAmount,  int shippingFee,  int totalPrice,  int pointsUsed,  int pointsEarned,  OrderStatus status,  PaymentStatus paymentStatus,  PaymentMethod? paymentMethod,  String? paymentProvider, @StringishConverter()  String? paymentOrderCode,  String? paymentLinkId,  String? checkoutUrl,  String? qrCode,  String? paymentReference, @FlexibleDateTimeConverter()  DateTime? paymentExpiresAt,  bool inventoryReserved, @UserRefConverter()  EntityRef<AppUser>? createdBySalesId, @UserRefConverter()  EntityRef<AppUser>? approvedBySalesId, @UserRefConverter()  EntityRef<AppUser>? paidByManagerId, @UserRefConverter()  EntityRef<AppUser>? cancelledBy,  String? cancellationReason,  List<StatusHistoryEntry> statusHistory,  DateTime? paidAt,  DateTime? completedAt,  DateTime? cancelledAt,  bool isReviewed,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.orderCode,_that.channel,_that.fulfillmentType,_that.customerId,_that.customerName,_that.customerPhone,_that.shippingAddress,_that.storeId,_that.items,_that.subtotal,_that.discountAmount,_that.shippingFee,_that.totalPrice,_that.pointsUsed,_that.pointsEarned,_that.status,_that.paymentStatus,_that.paymentMethod,_that.paymentProvider,_that.paymentOrderCode,_that.paymentLinkId,_that.checkoutUrl,_that.qrCode,_that.paymentReference,_that.paymentExpiresAt,_that.inventoryReserved,_that.createdBySalesId,_that.approvedBySalesId,_that.paidByManagerId,_that.cancelledBy,_that.cancellationReason,_that.statusHistory,_that.paidAt,_that.completedAt,_that.cancelledAt,_that.isReviewed,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order extends Order {
  const _Order({@JsonKey(name: '_id') required this.id, this.orderCode = '', this.channel = OrderChannel.online, this.fulfillmentType, @UserRefConverter() this.customerId, this.customerName, this.customerPhone, this.shippingAddress, @StoreRefConverter() this.storeId,  List<OrderItem> items = const <OrderItem>[], this.subtotal = 0, this.discountAmount = 0, this.shippingFee = 0, this.totalPrice = 0, this.pointsUsed = 0, this.pointsEarned = 0, required this.status, this.paymentStatus = PaymentStatus.unpaid, this.paymentMethod, this.paymentProvider, @StringishConverter() this.paymentOrderCode, this.paymentLinkId, this.checkoutUrl, this.qrCode, this.paymentReference, @FlexibleDateTimeConverter() this.paymentExpiresAt, this.inventoryReserved = false, @UserRefConverter() this.createdBySalesId, @UserRefConverter() this.approvedBySalesId, @UserRefConverter() this.paidByManagerId, @UserRefConverter() this.cancelledBy, this.cancellationReason,  List<StatusHistoryEntry> statusHistory = const <StatusHistoryEntry>[], this.paidAt, this.completedAt, this.cancelledAt, this.isReviewed = false, this.createdAt, this.updatedAt}): _items = items,_statusHistory = statusHistory,super._();
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override@JsonKey() final  String orderCode;
@override@JsonKey() final  OrderChannel channel;
@override final  FulfillmentType? fulfillmentType;
@override@UserRefConverter() final  EntityRef<AppUser>? customerId;
@override final  String? customerName;
@override final  String? customerPhone;
@override final  ShippingAddress? shippingAddress;
@override@StoreRefConverter() final  EntityRef<Store>? storeId;
 final  List<OrderItem> _items;
@override@JsonKey() List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int subtotal;
@override@JsonKey() final  int discountAmount;
@override@JsonKey() final  int shippingFee;
@override@JsonKey() final  int totalPrice;
@override@JsonKey() final  int pointsUsed;
@override@JsonKey() final  int pointsEarned;
@override final  OrderStatus status;
@override@JsonKey() final  PaymentStatus paymentStatus;
@override final  PaymentMethod? paymentMethod;
@override final  String? paymentProvider;
@override@StringishConverter() final  String? paymentOrderCode;
@override final  String? paymentLinkId;
@override final  String? checkoutUrl;
@override final  String? qrCode;
@override final  String? paymentReference;
@override@FlexibleDateTimeConverter() final  DateTime? paymentExpiresAt;
@override@JsonKey() final  bool inventoryReserved;
@override@UserRefConverter() final  EntityRef<AppUser>? createdBySalesId;
@override@UserRefConverter() final  EntityRef<AppUser>? approvedBySalesId;
@override@UserRefConverter() final  EntityRef<AppUser>? paidByManagerId;
@override@UserRefConverter() final  EntityRef<AppUser>? cancelledBy;
@override final  String? cancellationReason;
 final  List<StatusHistoryEntry> _statusHistory;
@override@JsonKey() List<StatusHistoryEntry> get statusHistory {
  if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statusHistory);
}

@override final  DateTime? paidAt;
@override final  DateTime? completedAt;
@override final  DateTime? cancelledAt;
@override@JsonKey() final  bool isReviewed;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.orderCode, orderCode) || other.orderCode == orderCode)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.fulfillmentType, fulfillmentType) || other.fulfillmentType == fulfillmentType)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.shippingAddress, shippingAddress) || other.shippingAddress == shippingAddress)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.shippingFee, shippingFee) || other.shippingFee == shippingFee)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.pointsUsed, pointsUsed) || other.pointsUsed == pointsUsed)&&(identical(other.pointsEarned, pointsEarned) || other.pointsEarned == pointsEarned)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentProvider, paymentProvider) || other.paymentProvider == paymentProvider)&&(identical(other.paymentOrderCode, paymentOrderCode) || other.paymentOrderCode == paymentOrderCode)&&(identical(other.paymentLinkId, paymentLinkId) || other.paymentLinkId == paymentLinkId)&&(identical(other.checkoutUrl, checkoutUrl) || other.checkoutUrl == checkoutUrl)&&(identical(other.qrCode, qrCode) || other.qrCode == qrCode)&&(identical(other.paymentReference, paymentReference) || other.paymentReference == paymentReference)&&(identical(other.paymentExpiresAt, paymentExpiresAt) || other.paymentExpiresAt == paymentExpiresAt)&&(identical(other.inventoryReserved, inventoryReserved) || other.inventoryReserved == inventoryReserved)&&(identical(other.createdBySalesId, createdBySalesId) || other.createdBySalesId == createdBySalesId)&&(identical(other.approvedBySalesId, approvedBySalesId) || other.approvedBySalesId == approvedBySalesId)&&(identical(other.paidByManagerId, paidByManagerId) || other.paidByManagerId == paidByManagerId)&&(identical(other.cancelledBy, cancelledBy) || other.cancelledBy == cancelledBy)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&const DeepCollectionEquality().equals(other.statusHistory, _statusHistory)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.isReviewed, isReviewed) || other.isReviewed == isReviewed)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,orderCode,channel,fulfillmentType,customerId,customerName,customerPhone,shippingAddress,storeId,const DeepCollectionEquality().hash(_items),subtotal,discountAmount,shippingFee,totalPrice,pointsUsed,pointsEarned,status,paymentStatus,paymentMethod,paymentProvider,paymentOrderCode,paymentLinkId,checkoutUrl,qrCode,paymentReference,paymentExpiresAt,inventoryReserved,createdBySalesId,approvedBySalesId,paidByManagerId,cancelledBy,cancellationReason,const DeepCollectionEquality().hash(_statusHistory),paidAt,completedAt,cancelledAt,isReviewed,createdAt,updatedAt]);
}

@override
String toString() {
    return 'Order(id: $id, orderCode: $orderCode, channel: $channel, fulfillmentType: $fulfillmentType, customerId: $customerId, customerName: $customerName, customerPhone: $customerPhone, shippingAddress: $shippingAddress, storeId: $storeId, items: $items, subtotal: $subtotal, discountAmount: $discountAmount, shippingFee: $shippingFee, totalPrice: $totalPrice, pointsUsed: $pointsUsed, pointsEarned: $pointsEarned, status: $status, paymentStatus: $paymentStatus, paymentMethod: $paymentMethod, paymentProvider: $paymentProvider, paymentOrderCode: $paymentOrderCode, paymentLinkId: $paymentLinkId, checkoutUrl: $checkoutUrl, qrCode: $qrCode, paymentReference: $paymentReference, paymentExpiresAt: $paymentExpiresAt, inventoryReserved: $inventoryReserved, createdBySalesId: $createdBySalesId, approvedBySalesId: $approvedBySalesId, paidByManagerId: $paidByManagerId, cancelledBy: $cancelledBy, cancellationReason: $cancellationReason, statusHistory: $statusHistory, paidAt: $paidAt, completedAt: $completedAt, cancelledAt: $cancelledAt, isReviewed: $isReviewed, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String orderCode, OrderChannel channel, FulfillmentType? fulfillmentType,@UserRefConverter() EntityRef<AppUser>? customerId, String? customerName, String? customerPhone, ShippingAddress? shippingAddress,@StoreRefConverter() EntityRef<Store>? storeId, List<OrderItem> items, int subtotal, int discountAmount, int shippingFee, int totalPrice, int pointsUsed, int pointsEarned, OrderStatus status, PaymentStatus paymentStatus, PaymentMethod? paymentMethod, String? paymentProvider,@StringishConverter() String? paymentOrderCode, String? paymentLinkId, String? checkoutUrl, String? qrCode, String? paymentReference,@FlexibleDateTimeConverter() DateTime? paymentExpiresAt, bool inventoryReserved,@UserRefConverter() EntityRef<AppUser>? createdBySalesId,@UserRefConverter() EntityRef<AppUser>? approvedBySalesId,@UserRefConverter() EntityRef<AppUser>? paidByManagerId,@UserRefConverter() EntityRef<AppUser>? cancelledBy, String? cancellationReason, List<StatusHistoryEntry> statusHistory, DateTime? paidAt, DateTime? completedAt, DateTime? cancelledAt, bool isReviewed, DateTime? createdAt, DateTime? updatedAt
});


@override $ShippingAddressCopyWith<$Res>? get shippingAddress;

}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderCode = null,Object? channel = null,Object? fulfillmentType = freezed,Object? customerId = freezed,Object? customerName = freezed,Object? customerPhone = freezed,Object? shippingAddress = freezed,Object? storeId = freezed,Object? items = null,Object? subtotal = null,Object? discountAmount = null,Object? shippingFee = null,Object? totalPrice = null,Object? pointsUsed = null,Object? pointsEarned = null,Object? status = null,Object? paymentStatus = null,Object? paymentMethod = freezed,Object? paymentProvider = freezed,Object? paymentOrderCode = freezed,Object? paymentLinkId = freezed,Object? checkoutUrl = freezed,Object? qrCode = freezed,Object? paymentReference = freezed,Object? paymentExpiresAt = freezed,Object? inventoryReserved = null,Object? createdBySalesId = freezed,Object? approvedBySalesId = freezed,Object? paidByManagerId = freezed,Object? cancelledBy = freezed,Object? cancellationReason = freezed,Object? statusHistory = null,Object? paidAt = freezed,Object? completedAt = freezed,Object? cancelledAt = freezed,Object? isReviewed = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderCode: null == orderCode ? _self.orderCode : orderCode // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as OrderChannel,fulfillmentType: freezed == fulfillmentType ? _self.fulfillmentType : fulfillmentType // ignore: cast_nullable_to_non_nullable
as FulfillmentType?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,shippingAddress: freezed == shippingAddress ? _self.shippingAddress : shippingAddress // ignore: cast_nullable_to_non_nullable
as ShippingAddress?,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as int,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as int,shippingFee: null == shippingFee ? _self.shippingFee : shippingFee // ignore: cast_nullable_to_non_nullable
as int,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as int,pointsUsed: null == pointsUsed ? _self.pointsUsed : pointsUsed // ignore: cast_nullable_to_non_nullable
as int,pointsEarned: null == pointsEarned ? _self.pointsEarned : pointsEarned // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod?,paymentProvider: freezed == paymentProvider ? _self.paymentProvider : paymentProvider // ignore: cast_nullable_to_non_nullable
as String?,paymentOrderCode: freezed == paymentOrderCode ? _self.paymentOrderCode : paymentOrderCode // ignore: cast_nullable_to_non_nullable
as String?,paymentLinkId: freezed == paymentLinkId ? _self.paymentLinkId : paymentLinkId // ignore: cast_nullable_to_non_nullable
as String?,checkoutUrl: freezed == checkoutUrl ? _self.checkoutUrl : checkoutUrl // ignore: cast_nullable_to_non_nullable
as String?,qrCode: freezed == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String?,paymentReference: freezed == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String?,paymentExpiresAt: freezed == paymentExpiresAt ? _self.paymentExpiresAt : paymentExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,inventoryReserved: null == inventoryReserved ? _self.inventoryReserved : inventoryReserved // ignore: cast_nullable_to_non_nullable
as bool,createdBySalesId: freezed == createdBySalesId ? _self.createdBySalesId : createdBySalesId // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,approvedBySalesId: freezed == approvedBySalesId ? _self.approvedBySalesId : approvedBySalesId // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,paidByManagerId: freezed == paidByManagerId ? _self.paidByManagerId : paidByManagerId // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,cancelledBy: freezed == cancelledBy ? _self.cancelledBy : cancelledBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,statusHistory: null == statusHistory ? _self._statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<StatusHistoryEntry>,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isReviewed: null == isReviewed ? _self.isReviewed : isReviewed // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShippingAddressCopyWith<$Res>? get shippingAddress {
    if (_self.shippingAddress == null) {
    return null;
  }

  return $ShippingAddressCopyWith<$Res>(_self.shippingAddress!, (value) {
    return _then(_self.copyWith(shippingAddress: value));
  });
}
}

// dart format on
