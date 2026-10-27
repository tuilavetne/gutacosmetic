// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StoreStock {

 Store get store; int get totalStock; int get reservedStock; int get availableStock; DateTime? get expiryDate; String? get expiryDateLabel; int? get daysUntilExpiry; int get lowStockThreshold;
/// Create a copy of StoreStock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreStockCopyWith<StoreStock> get copyWith => _$StoreStockCopyWithImpl<StoreStock>(this as StoreStock, _$identity);

  /// Serializes this StoreStock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StoreStock;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreStock&&(identical(other.store, _this.store) || other.store == _this.store)&&(identical(other.totalStock, _this.totalStock) || other.totalStock == _this.totalStock)&&(identical(other.reservedStock, _this.reservedStock) || other.reservedStock == _this.reservedStock)&&(identical(other.availableStock, _this.availableStock) || other.availableStock == _this.availableStock)&&(identical(other.expiryDate, _this.expiryDate) || other.expiryDate == _this.expiryDate)&&(identical(other.expiryDateLabel, _this.expiryDateLabel) || other.expiryDateLabel == _this.expiryDateLabel)&&(identical(other.daysUntilExpiry, _this.daysUntilExpiry) || other.daysUntilExpiry == _this.daysUntilExpiry)&&(identical(other.lowStockThreshold, _this.lowStockThreshold) || other.lowStockThreshold == _this.lowStockThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StoreStock;
  return Object.hash(runtimeType,_this.store,_this.totalStock,_this.reservedStock,_this.availableStock,_this.expiryDate,_this.expiryDateLabel,_this.daysUntilExpiry,_this.lowStockThreshold);
}

@override
String toString() {
  final _this = this as StoreStock;
  return 'StoreStock(store: ${_this.store}, totalStock: ${_this.totalStock}, reservedStock: ${_this.reservedStock}, availableStock: ${_this.availableStock}, expiryDate: ${_this.expiryDate}, expiryDateLabel: ${_this.expiryDateLabel}, daysUntilExpiry: ${_this.daysUntilExpiry}, lowStockThreshold: ${_this.lowStockThreshold})';
}


}

/// @nodoc
abstract mixin class $StoreStockCopyWith<$Res>  {
  factory $StoreStockCopyWith(StoreStock value, $Res Function(StoreStock) _then) = _$StoreStockCopyWithImpl;
@useResult
$Res call({
 Store store, int totalStock, int reservedStock, int availableStock, DateTime? expiryDate, String? expiryDateLabel, int? daysUntilExpiry, int lowStockThreshold
});


$StoreCopyWith<$Res> get store;

}
/// @nodoc
class _$StoreStockCopyWithImpl<$Res>
    implements $StoreStockCopyWith<$Res> {
  _$StoreStockCopyWithImpl(this._self, this._then);

  final StoreStock _self;
  final $Res Function(StoreStock) _then;

/// Create a copy of StoreStock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? store = null,Object? totalStock = null,Object? reservedStock = null,Object? availableStock = null,Object? expiryDate = freezed,Object? expiryDateLabel = freezed,Object? daysUntilExpiry = freezed,Object? lowStockThreshold = null,}) {
  return _then(StoreStock(
store: null == store ? _self.store : store // ignore: cast_nullable_to_non_nullable
as Store,totalStock: null == totalStock ? _self.totalStock : totalStock // ignore: cast_nullable_to_non_nullable
as int,reservedStock: null == reservedStock ? _self.reservedStock : reservedStock // ignore: cast_nullable_to_non_nullable
as int,availableStock: null == availableStock ? _self.availableStock : availableStock // ignore: cast_nullable_to_non_nullable
as int,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryDateLabel: freezed == expiryDateLabel ? _self.expiryDateLabel : expiryDateLabel // ignore: cast_nullable_to_non_nullable
as String?,daysUntilExpiry: freezed == daysUntilExpiry ? _self.daysUntilExpiry : daysUntilExpiry // ignore: cast_nullable_to_non_nullable
as int?,lowStockThreshold: null == lowStockThreshold ? _self.lowStockThreshold : lowStockThreshold // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of StoreStock
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StoreCopyWith<$Res> get store {
  
  return $StoreCopyWith<$Res>(_self.store, (value) {
    return _then(_self.copyWith(store: value));
  });
}
}


/// Adds pattern-matching-related methods to [StoreStock].
extension StoreStockPatterns on StoreStock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreStock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreStock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreStock value)  $default,){
final _that = this;
switch (_that) {
case _StoreStock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreStock value)?  $default,){
final _that = this;
switch (_that) {
case _StoreStock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Store store,  int totalStock,  int reservedStock,  int availableStock,  DateTime? expiryDate,  String? expiryDateLabel,  int? daysUntilExpiry,  int lowStockThreshold)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreStock() when $default != null:
return $default(_that.store,_that.totalStock,_that.reservedStock,_that.availableStock,_that.expiryDate,_that.expiryDateLabel,_that.daysUntilExpiry,_that.lowStockThreshold);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Store store,  int totalStock,  int reservedStock,  int availableStock,  DateTime? expiryDate,  String? expiryDateLabel,  int? daysUntilExpiry,  int lowStockThreshold)  $default,) {final _that = this;
switch (_that) {
case _StoreStock():
return $default(_that.store,_that.totalStock,_that.reservedStock,_that.availableStock,_that.expiryDate,_that.expiryDateLabel,_that.daysUntilExpiry,_that.lowStockThreshold);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Store store,  int totalStock,  int reservedStock,  int availableStock,  DateTime? expiryDate,  String? expiryDateLabel,  int? daysUntilExpiry,  int lowStockThreshold)?  $default,) {final _that = this;
switch (_that) {
case _StoreStock() when $default != null:
return $default(_that.store,_that.totalStock,_that.reservedStock,_that.availableStock,_that.expiryDate,_that.expiryDateLabel,_that.daysUntilExpiry,_that.lowStockThreshold);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoreStock extends StoreStock {
  const _StoreStock({required this.store, this.totalStock = 0, this.reservedStock = 0, this.availableStock = 0, this.expiryDate, this.expiryDateLabel, this.daysUntilExpiry, this.lowStockThreshold = 5}): super._();
  factory _StoreStock.fromJson(Map<String, dynamic> json) => _$StoreStockFromJson(json);

@override final  Store store;
@override@JsonKey() final  int totalStock;
@override@JsonKey() final  int reservedStock;
@override@JsonKey() final  int availableStock;
@override final  DateTime? expiryDate;
@override final  String? expiryDateLabel;
@override final  int? daysUntilExpiry;
@override@JsonKey() final  int lowStockThreshold;

/// Create a copy of StoreStock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreStockCopyWith<_StoreStock> get copyWith => __$StoreStockCopyWithImpl<_StoreStock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreStockToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreStock&&(identical(other.store, store) || other.store == store)&&(identical(other.totalStock, totalStock) || other.totalStock == totalStock)&&(identical(other.reservedStock, reservedStock) || other.reservedStock == reservedStock)&&(identical(other.availableStock, availableStock) || other.availableStock == availableStock)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.expiryDateLabel, expiryDateLabel) || other.expiryDateLabel == expiryDateLabel)&&(identical(other.daysUntilExpiry, daysUntilExpiry) || other.daysUntilExpiry == daysUntilExpiry)&&(identical(other.lowStockThreshold, lowStockThreshold) || other.lowStockThreshold == lowStockThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,store,totalStock,reservedStock,availableStock,expiryDate,expiryDateLabel,daysUntilExpiry,lowStockThreshold);
}

@override
String toString() {
    return 'StoreStock(store: $store, totalStock: $totalStock, reservedStock: $reservedStock, availableStock: $availableStock, expiryDate: $expiryDate, expiryDateLabel: $expiryDateLabel, daysUntilExpiry: $daysUntilExpiry, lowStockThreshold: $lowStockThreshold)';
}


}

/// @nodoc
abstract mixin class _$StoreStockCopyWith<$Res> implements $StoreStockCopyWith<$Res> {
  factory _$StoreStockCopyWith(_StoreStock value, $Res Function(_StoreStock) _then) = __$StoreStockCopyWithImpl;
@override @useResult
$Res call({
 Store store, int totalStock, int reservedStock, int availableStock, DateTime? expiryDate, String? expiryDateLabel, int? daysUntilExpiry, int lowStockThreshold
});


@override $StoreCopyWith<$Res> get store;

}
/// @nodoc
class __$StoreStockCopyWithImpl<$Res>
    implements _$StoreStockCopyWith<$Res> {
  __$StoreStockCopyWithImpl(this._self, this._then);

  final _StoreStock _self;
  final $Res Function(_StoreStock) _then;

/// Create a copy of StoreStock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? store = null,Object? totalStock = null,Object? reservedStock = null,Object? availableStock = null,Object? expiryDate = freezed,Object? expiryDateLabel = freezed,Object? daysUntilExpiry = freezed,Object? lowStockThreshold = null,}) {
  return _then(_StoreStock(
store: null == store ? _self.store : store // ignore: cast_nullable_to_non_nullable
as Store,totalStock: null == totalStock ? _self.totalStock : totalStock // ignore: cast_nullable_to_non_nullable
as int,reservedStock: null == reservedStock ? _self.reservedStock : reservedStock // ignore: cast_nullable_to_non_nullable
as int,availableStock: null == availableStock ? _self.availableStock : availableStock // ignore: cast_nullable_to_non_nullable
as int,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryDateLabel: freezed == expiryDateLabel ? _self.expiryDateLabel : expiryDateLabel // ignore: cast_nullable_to_non_nullable
as String?,daysUntilExpiry: freezed == daysUntilExpiry ? _self.daysUntilExpiry : daysUntilExpiry // ignore: cast_nullable_to_non_nullable
as int?,lowStockThreshold: null == lowStockThreshold ? _self.lowStockThreshold : lowStockThreshold // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of StoreStock
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StoreCopyWith<$Res> get store {
  
  return $StoreCopyWith<$Res>(_self.store, (value) {
    return _then(_self.copyWith(store: value));
  });
}
}


/// @nodoc
mixin _$ProductInventory {

 Product get product; List<StoreStock> get inventories;
/// Create a copy of ProductInventory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductInventoryCopyWith<ProductInventory> get copyWith => _$ProductInventoryCopyWithImpl<ProductInventory>(this as ProductInventory, _$identity);

  /// Serializes this ProductInventory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductInventory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductInventory&&(identical(other.product, _this.product) || other.product == _this.product)&&const DeepCollectionEquality().equals(other.inventories, _this.inventories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductInventory;
  return Object.hash(runtimeType,_this.product,const DeepCollectionEquality().hash(_this.inventories));
}

@override
String toString() {
  final _this = this as ProductInventory;
  return 'ProductInventory(product: ${_this.product}, inventories: ${_this.inventories})';
}


}

/// @nodoc
abstract mixin class $ProductInventoryCopyWith<$Res>  {
  factory $ProductInventoryCopyWith(ProductInventory value, $Res Function(ProductInventory) _then) = _$ProductInventoryCopyWithImpl;
@useResult
$Res call({
 Product product, List<StoreStock> inventories
});


$ProductCopyWith<$Res> get product;

}
/// @nodoc
class _$ProductInventoryCopyWithImpl<$Res>
    implements $ProductInventoryCopyWith<$Res> {
  _$ProductInventoryCopyWithImpl(this._self, this._then);

  final ProductInventory _self;
  final $Res Function(ProductInventory) _then;

/// Create a copy of ProductInventory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? product = null,Object? inventories = null,}) {
  return _then(ProductInventory(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,inventories: null == inventories ? _self.inventories : inventories // ignore: cast_nullable_to_non_nullable
as List<StoreStock>,
  ));
}
/// Create a copy of ProductInventory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProductInventory].
extension ProductInventoryPatterns on ProductInventory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductInventory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductInventory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductInventory value)  $default,){
final _that = this;
switch (_that) {
case _ProductInventory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductInventory value)?  $default,){
final _that = this;
switch (_that) {
case _ProductInventory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Product product,  List<StoreStock> inventories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductInventory() when $default != null:
return $default(_that.product,_that.inventories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Product product,  List<StoreStock> inventories)  $default,) {final _that = this;
switch (_that) {
case _ProductInventory():
return $default(_that.product,_that.inventories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Product product,  List<StoreStock> inventories)?  $default,) {final _that = this;
switch (_that) {
case _ProductInventory() when $default != null:
return $default(_that.product,_that.inventories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductInventory extends ProductInventory {
  const _ProductInventory({required this.product,  List<StoreStock> inventories = const <StoreStock>[]}): _inventories = inventories,super._();
  factory _ProductInventory.fromJson(Map<String, dynamic> json) => _$ProductInventoryFromJson(json);

@override final  Product product;
 final  List<StoreStock> _inventories;
@override@JsonKey() List<StoreStock> get inventories {
  if (_inventories is EqualUnmodifiableListView) return _inventories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_inventories);
}


/// Create a copy of ProductInventory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductInventoryCopyWith<_ProductInventory> get copyWith => __$ProductInventoryCopyWithImpl<_ProductInventory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductInventoryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductInventory&&(identical(other.product, product) || other.product == product)&&const DeepCollectionEquality().equals(other.inventories, _inventories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,product,const DeepCollectionEquality().hash(_inventories));
}

@override
String toString() {
    return 'ProductInventory(product: $product, inventories: $inventories)';
}


}

/// @nodoc
abstract mixin class _$ProductInventoryCopyWith<$Res> implements $ProductInventoryCopyWith<$Res> {
  factory _$ProductInventoryCopyWith(_ProductInventory value, $Res Function(_ProductInventory) _then) = __$ProductInventoryCopyWithImpl;
@override @useResult
$Res call({
 Product product, List<StoreStock> inventories
});


@override $ProductCopyWith<$Res> get product;

}
/// @nodoc
class __$ProductInventoryCopyWithImpl<$Res>
    implements _$ProductInventoryCopyWith<$Res> {
  __$ProductInventoryCopyWithImpl(this._self, this._then);

  final _ProductInventory _self;
  final $Res Function(_ProductInventory) _then;

/// Create a copy of ProductInventory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? product = null,Object? inventories = null,}) {
  return _then(_ProductInventory(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,inventories: null == inventories ? _self._inventories : inventories // ignore: cast_nullable_to_non_nullable
as List<StoreStock>,
  ));
}

/// Create a copy of ProductInventory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// @nodoc
mixin _$InventoryAlert {

@JsonKey(unknownEnumValue: InventoryAlertType.unknown) InventoryAlertType get type;/// Ví dụ `CRITICAL` khi tồn bằng 0.
 String? get severity; String get message; String? get inventoryId;@StoreRefConverter() EntityRef<Store>? get store;@ProductRefConverter() EntityRef<Product>? get product; int get totalStock; int get reservedStock; int get availableStock; int get lowStockThreshold; DateTime? get expiryDate; int? get daysUntilExpiry; String? get expiryDateLabel;
/// Create a copy of InventoryAlert
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryAlertCopyWith<InventoryAlert> get copyWith => _$InventoryAlertCopyWithImpl<InventoryAlert>(this as InventoryAlert, _$identity);

  /// Serializes this InventoryAlert to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InventoryAlert;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryAlert&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.severity, _this.severity) || other.severity == _this.severity)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.inventoryId, _this.inventoryId) || other.inventoryId == _this.inventoryId)&&(identical(other.store, _this.store) || other.store == _this.store)&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.totalStock, _this.totalStock) || other.totalStock == _this.totalStock)&&(identical(other.reservedStock, _this.reservedStock) || other.reservedStock == _this.reservedStock)&&(identical(other.availableStock, _this.availableStock) || other.availableStock == _this.availableStock)&&(identical(other.lowStockThreshold, _this.lowStockThreshold) || other.lowStockThreshold == _this.lowStockThreshold)&&(identical(other.expiryDate, _this.expiryDate) || other.expiryDate == _this.expiryDate)&&(identical(other.daysUntilExpiry, _this.daysUntilExpiry) || other.daysUntilExpiry == _this.daysUntilExpiry)&&(identical(other.expiryDateLabel, _this.expiryDateLabel) || other.expiryDateLabel == _this.expiryDateLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InventoryAlert;
  return Object.hash(runtimeType,_this.type,_this.severity,_this.message,_this.inventoryId,_this.store,_this.product,_this.totalStock,_this.reservedStock,_this.availableStock,_this.lowStockThreshold,_this.expiryDate,_this.daysUntilExpiry,_this.expiryDateLabel);
}

@override
String toString() {
  final _this = this as InventoryAlert;
  return 'InventoryAlert(type: ${_this.type}, severity: ${_this.severity}, message: ${_this.message}, inventoryId: ${_this.inventoryId}, store: ${_this.store}, product: ${_this.product}, totalStock: ${_this.totalStock}, reservedStock: ${_this.reservedStock}, availableStock: ${_this.availableStock}, lowStockThreshold: ${_this.lowStockThreshold}, expiryDate: ${_this.expiryDate}, daysUntilExpiry: ${_this.daysUntilExpiry}, expiryDateLabel: ${_this.expiryDateLabel})';
}


}

/// @nodoc
abstract mixin class $InventoryAlertCopyWith<$Res>  {
  factory $InventoryAlertCopyWith(InventoryAlert value, $Res Function(InventoryAlert) _then) = _$InventoryAlertCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: InventoryAlertType.unknown) InventoryAlertType type, String? severity, String message, String? inventoryId,@StoreRefConverter() EntityRef<Store>? store,@ProductRefConverter() EntityRef<Product>? product, int totalStock, int reservedStock, int availableStock, int lowStockThreshold, DateTime? expiryDate, int? daysUntilExpiry, String? expiryDateLabel
});




}
/// @nodoc
class _$InventoryAlertCopyWithImpl<$Res>
    implements $InventoryAlertCopyWith<$Res> {
  _$InventoryAlertCopyWithImpl(this._self, this._then);

  final InventoryAlert _self;
  final $Res Function(InventoryAlert) _then;

/// Create a copy of InventoryAlert
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? severity = freezed,Object? message = null,Object? inventoryId = freezed,Object? store = freezed,Object? product = freezed,Object? totalStock = null,Object? reservedStock = null,Object? availableStock = null,Object? lowStockThreshold = null,Object? expiryDate = freezed,Object? daysUntilExpiry = freezed,Object? expiryDateLabel = freezed,}) {
  return _then(InventoryAlert(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InventoryAlertType,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,inventoryId: freezed == inventoryId ? _self.inventoryId : inventoryId // ignore: cast_nullable_to_non_nullable
as String?,store: freezed == store ? _self.store : store // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as EntityRef<Product>?,totalStock: null == totalStock ? _self.totalStock : totalStock // ignore: cast_nullable_to_non_nullable
as int,reservedStock: null == reservedStock ? _self.reservedStock : reservedStock // ignore: cast_nullable_to_non_nullable
as int,availableStock: null == availableStock ? _self.availableStock : availableStock // ignore: cast_nullable_to_non_nullable
as int,lowStockThreshold: null == lowStockThreshold ? _self.lowStockThreshold : lowStockThreshold // ignore: cast_nullable_to_non_nullable
as int,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,daysUntilExpiry: freezed == daysUntilExpiry ? _self.daysUntilExpiry : daysUntilExpiry // ignore: cast_nullable_to_non_nullable
as int?,expiryDateLabel: freezed == expiryDateLabel ? _self.expiryDateLabel : expiryDateLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryAlert].
extension InventoryAlertPatterns on InventoryAlert {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryAlert value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryAlert() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryAlert value)  $default,){
final _that = this;
switch (_that) {
case _InventoryAlert():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryAlert value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryAlert() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: InventoryAlertType.unknown)  InventoryAlertType type,  String? severity,  String message,  String? inventoryId, @StoreRefConverter()  EntityRef<Store>? store, @ProductRefConverter()  EntityRef<Product>? product,  int totalStock,  int reservedStock,  int availableStock,  int lowStockThreshold,  DateTime? expiryDate,  int? daysUntilExpiry,  String? expiryDateLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryAlert() when $default != null:
return $default(_that.type,_that.severity,_that.message,_that.inventoryId,_that.store,_that.product,_that.totalStock,_that.reservedStock,_that.availableStock,_that.lowStockThreshold,_that.expiryDate,_that.daysUntilExpiry,_that.expiryDateLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: InventoryAlertType.unknown)  InventoryAlertType type,  String? severity,  String message,  String? inventoryId, @StoreRefConverter()  EntityRef<Store>? store, @ProductRefConverter()  EntityRef<Product>? product,  int totalStock,  int reservedStock,  int availableStock,  int lowStockThreshold,  DateTime? expiryDate,  int? daysUntilExpiry,  String? expiryDateLabel)  $default,) {final _that = this;
switch (_that) {
case _InventoryAlert():
return $default(_that.type,_that.severity,_that.message,_that.inventoryId,_that.store,_that.product,_that.totalStock,_that.reservedStock,_that.availableStock,_that.lowStockThreshold,_that.expiryDate,_that.daysUntilExpiry,_that.expiryDateLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: InventoryAlertType.unknown)  InventoryAlertType type,  String? severity,  String message,  String? inventoryId, @StoreRefConverter()  EntityRef<Store>? store, @ProductRefConverter()  EntityRef<Product>? product,  int totalStock,  int reservedStock,  int availableStock,  int lowStockThreshold,  DateTime? expiryDate,  int? daysUntilExpiry,  String? expiryDateLabel)?  $default,) {final _that = this;
switch (_that) {
case _InventoryAlert() when $default != null:
return $default(_that.type,_that.severity,_that.message,_that.inventoryId,_that.store,_that.product,_that.totalStock,_that.reservedStock,_that.availableStock,_that.lowStockThreshold,_that.expiryDate,_that.daysUntilExpiry,_that.expiryDateLabel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InventoryAlert extends InventoryAlert {
  const _InventoryAlert({@JsonKey(unknownEnumValue: InventoryAlertType.unknown) this.type = InventoryAlertType.unknown, this.severity, this.message = '', this.inventoryId, @StoreRefConverter() this.store, @ProductRefConverter() this.product, this.totalStock = 0, this.reservedStock = 0, this.availableStock = 0, this.lowStockThreshold = 5, this.expiryDate, this.daysUntilExpiry, this.expiryDateLabel}): super._();
  factory _InventoryAlert.fromJson(Map<String, dynamic> json) => _$InventoryAlertFromJson(json);

@override@JsonKey(unknownEnumValue: InventoryAlertType.unknown) final  InventoryAlertType type;
/// Ví dụ `CRITICAL` khi tồn bằng 0.
@override final  String? severity;
@override@JsonKey() final  String message;
@override final  String? inventoryId;
@override@StoreRefConverter() final  EntityRef<Store>? store;
@override@ProductRefConverter() final  EntityRef<Product>? product;
@override@JsonKey() final  int totalStock;
@override@JsonKey() final  int reservedStock;
@override@JsonKey() final  int availableStock;
@override@JsonKey() final  int lowStockThreshold;
@override final  DateTime? expiryDate;
@override final  int? daysUntilExpiry;
@override final  String? expiryDateLabel;

/// Create a copy of InventoryAlert
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryAlertCopyWith<_InventoryAlert> get copyWith => __$InventoryAlertCopyWithImpl<_InventoryAlert>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InventoryAlertToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryAlert&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.message, message) || other.message == message)&&(identical(other.inventoryId, inventoryId) || other.inventoryId == inventoryId)&&(identical(other.store, store) || other.store == store)&&(identical(other.product, product) || other.product == product)&&(identical(other.totalStock, totalStock) || other.totalStock == totalStock)&&(identical(other.reservedStock, reservedStock) || other.reservedStock == reservedStock)&&(identical(other.availableStock, availableStock) || other.availableStock == availableStock)&&(identical(other.lowStockThreshold, lowStockThreshold) || other.lowStockThreshold == lowStockThreshold)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.daysUntilExpiry, daysUntilExpiry) || other.daysUntilExpiry == daysUntilExpiry)&&(identical(other.expiryDateLabel, expiryDateLabel) || other.expiryDateLabel == expiryDateLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,severity,message,inventoryId,store,product,totalStock,reservedStock,availableStock,lowStockThreshold,expiryDate,daysUntilExpiry,expiryDateLabel);
}

@override
String toString() {
    return 'InventoryAlert(type: $type, severity: $severity, message: $message, inventoryId: $inventoryId, store: $store, product: $product, totalStock: $totalStock, reservedStock: $reservedStock, availableStock: $availableStock, lowStockThreshold: $lowStockThreshold, expiryDate: $expiryDate, daysUntilExpiry: $daysUntilExpiry, expiryDateLabel: $expiryDateLabel)';
}


}

/// @nodoc
abstract mixin class _$InventoryAlertCopyWith<$Res> implements $InventoryAlertCopyWith<$Res> {
  factory _$InventoryAlertCopyWith(_InventoryAlert value, $Res Function(_InventoryAlert) _then) = __$InventoryAlertCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: InventoryAlertType.unknown) InventoryAlertType type, String? severity, String message, String? inventoryId,@StoreRefConverter() EntityRef<Store>? store,@ProductRefConverter() EntityRef<Product>? product, int totalStock, int reservedStock, int availableStock, int lowStockThreshold, DateTime? expiryDate, int? daysUntilExpiry, String? expiryDateLabel
});




}
/// @nodoc
class __$InventoryAlertCopyWithImpl<$Res>
    implements _$InventoryAlertCopyWith<$Res> {
  __$InventoryAlertCopyWithImpl(this._self, this._then);

  final _InventoryAlert _self;
  final $Res Function(_InventoryAlert) _then;

/// Create a copy of InventoryAlert
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? severity = freezed,Object? message = null,Object? inventoryId = freezed,Object? store = freezed,Object? product = freezed,Object? totalStock = null,Object? reservedStock = null,Object? availableStock = null,Object? lowStockThreshold = null,Object? expiryDate = freezed,Object? daysUntilExpiry = freezed,Object? expiryDateLabel = freezed,}) {
  return _then(_InventoryAlert(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InventoryAlertType,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,inventoryId: freezed == inventoryId ? _self.inventoryId : inventoryId // ignore: cast_nullable_to_non_nullable
as String?,store: freezed == store ? _self.store : store // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as EntityRef<Product>?,totalStock: null == totalStock ? _self.totalStock : totalStock // ignore: cast_nullable_to_non_nullable
as int,reservedStock: null == reservedStock ? _self.reservedStock : reservedStock // ignore: cast_nullable_to_non_nullable
as int,availableStock: null == availableStock ? _self.availableStock : availableStock // ignore: cast_nullable_to_non_nullable
as int,lowStockThreshold: null == lowStockThreshold ? _self.lowStockThreshold : lowStockThreshold // ignore: cast_nullable_to_non_nullable
as int,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,daysUntilExpiry: freezed == daysUntilExpiry ? _self.daysUntilExpiry : daysUntilExpiry // ignore: cast_nullable_to_non_nullable
as int?,expiryDateLabel: freezed == expiryDateLabel ? _self.expiryDateLabel : expiryDateLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RestockRequest {

@JsonKey(name: '_id') String get id;@JsonKey(readValue: _readStore)@StoreRefConverter() EntityRef<Store>? get storeId;@JsonKey(readValue: _readProduct)@ProductRefConverter() EntityRef<Product>? get productId;@UserRefConverter() EntityRef<AppUser>? get requestedBy;@UserRefConverter() EntityRef<AppUser>? get handledBy;@UserRefConverter() EntityRef<AppUser>? get acknowledgedBy; int get currentAvailableStock; int get requestedQuantity; String? get reason; RestockStatus get status; String? get managerNote; DateTime? get resolvedAt; DateTime? get acknowledgedAt; int? get forwardedQuantity;@UserRefConverter() EntityRef<AppUser>? get forwardedBy; DateTime? get forwardedAt; int? get approvedQuantity;@UserRefConverter() EntityRef<AppUser>? get approvedBy; DateTime? get approvedAt; String? get ownerNote;@StringishConverter() String? get transferId; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of RestockRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestockRequestCopyWith<RestockRequest> get copyWith => _$RestockRequestCopyWithImpl<RestockRequest>(this as RestockRequest, _$identity);

  /// Serializes this RestockRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RestockRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestockRequest&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.storeId, _this.storeId) || other.storeId == _this.storeId)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.requestedBy, _this.requestedBy) || other.requestedBy == _this.requestedBy)&&(identical(other.handledBy, _this.handledBy) || other.handledBy == _this.handledBy)&&(identical(other.acknowledgedBy, _this.acknowledgedBy) || other.acknowledgedBy == _this.acknowledgedBy)&&(identical(other.currentAvailableStock, _this.currentAvailableStock) || other.currentAvailableStock == _this.currentAvailableStock)&&(identical(other.requestedQuantity, _this.requestedQuantity) || other.requestedQuantity == _this.requestedQuantity)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.managerNote, _this.managerNote) || other.managerNote == _this.managerNote)&&(identical(other.resolvedAt, _this.resolvedAt) || other.resolvedAt == _this.resolvedAt)&&(identical(other.acknowledgedAt, _this.acknowledgedAt) || other.acknowledgedAt == _this.acknowledgedAt)&&(identical(other.forwardedQuantity, _this.forwardedQuantity) || other.forwardedQuantity == _this.forwardedQuantity)&&(identical(other.forwardedBy, _this.forwardedBy) || other.forwardedBy == _this.forwardedBy)&&(identical(other.forwardedAt, _this.forwardedAt) || other.forwardedAt == _this.forwardedAt)&&(identical(other.approvedQuantity, _this.approvedQuantity) || other.approvedQuantity == _this.approvedQuantity)&&(identical(other.approvedBy, _this.approvedBy) || other.approvedBy == _this.approvedBy)&&(identical(other.approvedAt, _this.approvedAt) || other.approvedAt == _this.approvedAt)&&(identical(other.ownerNote, _this.ownerNote) || other.ownerNote == _this.ownerNote)&&(identical(other.transferId, _this.transferId) || other.transferId == _this.transferId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RestockRequest;
  return Object.hashAll([runtimeType,_this.id,_this.storeId,_this.productId,_this.requestedBy,_this.handledBy,_this.acknowledgedBy,_this.currentAvailableStock,_this.requestedQuantity,_this.reason,_this.status,_this.managerNote,_this.resolvedAt,_this.acknowledgedAt,_this.forwardedQuantity,_this.forwardedBy,_this.forwardedAt,_this.approvedQuantity,_this.approvedBy,_this.approvedAt,_this.ownerNote,_this.transferId,_this.createdAt,_this.updatedAt]);
}

@override
String toString() {
  final _this = this as RestockRequest;
  return 'RestockRequest(id: ${_this.id}, storeId: ${_this.storeId}, productId: ${_this.productId}, requestedBy: ${_this.requestedBy}, handledBy: ${_this.handledBy}, acknowledgedBy: ${_this.acknowledgedBy}, currentAvailableStock: ${_this.currentAvailableStock}, requestedQuantity: ${_this.requestedQuantity}, reason: ${_this.reason}, status: ${_this.status}, managerNote: ${_this.managerNote}, resolvedAt: ${_this.resolvedAt}, acknowledgedAt: ${_this.acknowledgedAt}, forwardedQuantity: ${_this.forwardedQuantity}, forwardedBy: ${_this.forwardedBy}, forwardedAt: ${_this.forwardedAt}, approvedQuantity: ${_this.approvedQuantity}, approvedBy: ${_this.approvedBy}, approvedAt: ${_this.approvedAt}, ownerNote: ${_this.ownerNote}, transferId: ${_this.transferId}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $RestockRequestCopyWith<$Res>  {
  factory $RestockRequestCopyWith(RestockRequest value, $Res Function(RestockRequest) _then) = _$RestockRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id,@JsonKey(readValue: _readStore)@StoreRefConverter() EntityRef<Store>? storeId,@JsonKey(readValue: _readProduct)@ProductRefConverter() EntityRef<Product>? productId,@UserRefConverter() EntityRef<AppUser>? requestedBy,@UserRefConverter() EntityRef<AppUser>? handledBy,@UserRefConverter() EntityRef<AppUser>? acknowledgedBy, int currentAvailableStock, int requestedQuantity, String? reason, RestockStatus status, String? managerNote, DateTime? resolvedAt, DateTime? acknowledgedAt, int? forwardedQuantity,@UserRefConverter() EntityRef<AppUser>? forwardedBy, DateTime? forwardedAt, int? approvedQuantity,@UserRefConverter() EntityRef<AppUser>? approvedBy, DateTime? approvedAt, String? ownerNote,@StringishConverter() String? transferId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$RestockRequestCopyWithImpl<$Res>
    implements $RestockRequestCopyWith<$Res> {
  _$RestockRequestCopyWithImpl(this._self, this._then);

  final RestockRequest _self;
  final $Res Function(RestockRequest) _then;

/// Create a copy of RestockRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = freezed,Object? productId = freezed,Object? requestedBy = freezed,Object? handledBy = freezed,Object? acknowledgedBy = freezed,Object? currentAvailableStock = null,Object? requestedQuantity = null,Object? reason = freezed,Object? status = null,Object? managerNote = freezed,Object? resolvedAt = freezed,Object? acknowledgedAt = freezed,Object? forwardedQuantity = freezed,Object? forwardedBy = freezed,Object? forwardedAt = freezed,Object? approvedQuantity = freezed,Object? approvedBy = freezed,Object? approvedAt = freezed,Object? ownerNote = freezed,Object? transferId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(RestockRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as EntityRef<Product>?,requestedBy: freezed == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,handledBy: freezed == handledBy ? _self.handledBy : handledBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,acknowledgedBy: freezed == acknowledgedBy ? _self.acknowledgedBy : acknowledgedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,currentAvailableStock: null == currentAvailableStock ? _self.currentAvailableStock : currentAvailableStock // ignore: cast_nullable_to_non_nullable
as int,requestedQuantity: null == requestedQuantity ? _self.requestedQuantity : requestedQuantity // ignore: cast_nullable_to_non_nullable
as int,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RestockStatus,managerNote: freezed == managerNote ? _self.managerNote : managerNote // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,acknowledgedAt: freezed == acknowledgedAt ? _self.acknowledgedAt : acknowledgedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,forwardedQuantity: freezed == forwardedQuantity ? _self.forwardedQuantity : forwardedQuantity // ignore: cast_nullable_to_non_nullable
as int?,forwardedBy: freezed == forwardedBy ? _self.forwardedBy : forwardedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,forwardedAt: freezed == forwardedAt ? _self.forwardedAt : forwardedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedQuantity: freezed == approvedQuantity ? _self.approvedQuantity : approvedQuantity // ignore: cast_nullable_to_non_nullable
as int?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ownerNote: freezed == ownerNote ? _self.ownerNote : ownerNote // ignore: cast_nullable_to_non_nullable
as String?,transferId: freezed == transferId ? _self.transferId : transferId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RestockRequest].
extension RestockRequestPatterns on RestockRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RestockRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RestockRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RestockRequest value)  $default,){
final _that = this;
switch (_that) {
case _RestockRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RestockRequest value)?  $default,){
final _that = this;
switch (_that) {
case _RestockRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id, @JsonKey(readValue: _readStore)@StoreRefConverter()  EntityRef<Store>? storeId, @JsonKey(readValue: _readProduct)@ProductRefConverter()  EntityRef<Product>? productId, @UserRefConverter()  EntityRef<AppUser>? requestedBy, @UserRefConverter()  EntityRef<AppUser>? handledBy, @UserRefConverter()  EntityRef<AppUser>? acknowledgedBy,  int currentAvailableStock,  int requestedQuantity,  String? reason,  RestockStatus status,  String? managerNote,  DateTime? resolvedAt,  DateTime? acknowledgedAt,  int? forwardedQuantity, @UserRefConverter()  EntityRef<AppUser>? forwardedBy,  DateTime? forwardedAt,  int? approvedQuantity, @UserRefConverter()  EntityRef<AppUser>? approvedBy,  DateTime? approvedAt,  String? ownerNote, @StringishConverter()  String? transferId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RestockRequest() when $default != null:
return $default(_that.id,_that.storeId,_that.productId,_that.requestedBy,_that.handledBy,_that.acknowledgedBy,_that.currentAvailableStock,_that.requestedQuantity,_that.reason,_that.status,_that.managerNote,_that.resolvedAt,_that.acknowledgedAt,_that.forwardedQuantity,_that.forwardedBy,_that.forwardedAt,_that.approvedQuantity,_that.approvedBy,_that.approvedAt,_that.ownerNote,_that.transferId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id, @JsonKey(readValue: _readStore)@StoreRefConverter()  EntityRef<Store>? storeId, @JsonKey(readValue: _readProduct)@ProductRefConverter()  EntityRef<Product>? productId, @UserRefConverter()  EntityRef<AppUser>? requestedBy, @UserRefConverter()  EntityRef<AppUser>? handledBy, @UserRefConverter()  EntityRef<AppUser>? acknowledgedBy,  int currentAvailableStock,  int requestedQuantity,  String? reason,  RestockStatus status,  String? managerNote,  DateTime? resolvedAt,  DateTime? acknowledgedAt,  int? forwardedQuantity, @UserRefConverter()  EntityRef<AppUser>? forwardedBy,  DateTime? forwardedAt,  int? approvedQuantity, @UserRefConverter()  EntityRef<AppUser>? approvedBy,  DateTime? approvedAt,  String? ownerNote, @StringishConverter()  String? transferId,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RestockRequest():
return $default(_that.id,_that.storeId,_that.productId,_that.requestedBy,_that.handledBy,_that.acknowledgedBy,_that.currentAvailableStock,_that.requestedQuantity,_that.reason,_that.status,_that.managerNote,_that.resolvedAt,_that.acknowledgedAt,_that.forwardedQuantity,_that.forwardedBy,_that.forwardedAt,_that.approvedQuantity,_that.approvedBy,_that.approvedAt,_that.ownerNote,_that.transferId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id, @JsonKey(readValue: _readStore)@StoreRefConverter()  EntityRef<Store>? storeId, @JsonKey(readValue: _readProduct)@ProductRefConverter()  EntityRef<Product>? productId, @UserRefConverter()  EntityRef<AppUser>? requestedBy, @UserRefConverter()  EntityRef<AppUser>? handledBy, @UserRefConverter()  EntityRef<AppUser>? acknowledgedBy,  int currentAvailableStock,  int requestedQuantity,  String? reason,  RestockStatus status,  String? managerNote,  DateTime? resolvedAt,  DateTime? acknowledgedAt,  int? forwardedQuantity, @UserRefConverter()  EntityRef<AppUser>? forwardedBy,  DateTime? forwardedAt,  int? approvedQuantity, @UserRefConverter()  EntityRef<AppUser>? approvedBy,  DateTime? approvedAt,  String? ownerNote, @StringishConverter()  String? transferId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RestockRequest() when $default != null:
return $default(_that.id,_that.storeId,_that.productId,_that.requestedBy,_that.handledBy,_that.acknowledgedBy,_that.currentAvailableStock,_that.requestedQuantity,_that.reason,_that.status,_that.managerNote,_that.resolvedAt,_that.acknowledgedAt,_that.forwardedQuantity,_that.forwardedBy,_that.forwardedAt,_that.approvedQuantity,_that.approvedBy,_that.approvedAt,_that.ownerNote,_that.transferId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RestockRequest implements RestockRequest {
  const _RestockRequest({@JsonKey(name: '_id') required this.id, @JsonKey(readValue: _readStore)@StoreRefConverter() this.storeId, @JsonKey(readValue: _readProduct)@ProductRefConverter() this.productId, @UserRefConverter() this.requestedBy, @UserRefConverter() this.handledBy, @UserRefConverter() this.acknowledgedBy, this.currentAvailableStock = 0, this.requestedQuantity = 0, this.reason, this.status = RestockStatus.open, this.managerNote, this.resolvedAt, this.acknowledgedAt, this.forwardedQuantity, @UserRefConverter() this.forwardedBy, this.forwardedAt, this.approvedQuantity, @UserRefConverter() this.approvedBy, this.approvedAt, this.ownerNote, @StringishConverter() this.transferId, this.createdAt, this.updatedAt});
  factory _RestockRequest.fromJson(Map<String, dynamic> json) => _$RestockRequestFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override@JsonKey(readValue: _readStore)@StoreRefConverter() final  EntityRef<Store>? storeId;
@override@JsonKey(readValue: _readProduct)@ProductRefConverter() final  EntityRef<Product>? productId;
@override@UserRefConverter() final  EntityRef<AppUser>? requestedBy;
@override@UserRefConverter() final  EntityRef<AppUser>? handledBy;
@override@UserRefConverter() final  EntityRef<AppUser>? acknowledgedBy;
@override@JsonKey() final  int currentAvailableStock;
@override@JsonKey() final  int requestedQuantity;
@override final  String? reason;
@override@JsonKey() final  RestockStatus status;
@override final  String? managerNote;
@override final  DateTime? resolvedAt;
@override final  DateTime? acknowledgedAt;
@override final  int? forwardedQuantity;
@override@UserRefConverter() final  EntityRef<AppUser>? forwardedBy;
@override final  DateTime? forwardedAt;
@override final  int? approvedQuantity;
@override@UserRefConverter() final  EntityRef<AppUser>? approvedBy;
@override final  DateTime? approvedAt;
@override final  String? ownerNote;
@override@StringishConverter() final  String? transferId;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of RestockRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestockRequestCopyWith<_RestockRequest> get copyWith => __$RestockRequestCopyWithImpl<_RestockRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RestockRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestockRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy)&&(identical(other.handledBy, handledBy) || other.handledBy == handledBy)&&(identical(other.acknowledgedBy, acknowledgedBy) || other.acknowledgedBy == acknowledgedBy)&&(identical(other.currentAvailableStock, currentAvailableStock) || other.currentAvailableStock == currentAvailableStock)&&(identical(other.requestedQuantity, requestedQuantity) || other.requestedQuantity == requestedQuantity)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.managerNote, managerNote) || other.managerNote == managerNote)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.acknowledgedAt, acknowledgedAt) || other.acknowledgedAt == acknowledgedAt)&&(identical(other.forwardedQuantity, forwardedQuantity) || other.forwardedQuantity == forwardedQuantity)&&(identical(other.forwardedBy, forwardedBy) || other.forwardedBy == forwardedBy)&&(identical(other.forwardedAt, forwardedAt) || other.forwardedAt == forwardedAt)&&(identical(other.approvedQuantity, approvedQuantity) || other.approvedQuantity == approvedQuantity)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.ownerNote, ownerNote) || other.ownerNote == ownerNote)&&(identical(other.transferId, transferId) || other.transferId == transferId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,storeId,productId,requestedBy,handledBy,acknowledgedBy,currentAvailableStock,requestedQuantity,reason,status,managerNote,resolvedAt,acknowledgedAt,forwardedQuantity,forwardedBy,forwardedAt,approvedQuantity,approvedBy,approvedAt,ownerNote,transferId,createdAt,updatedAt]);
}

@override
String toString() {
    return 'RestockRequest(id: $id, storeId: $storeId, productId: $productId, requestedBy: $requestedBy, handledBy: $handledBy, acknowledgedBy: $acknowledgedBy, currentAvailableStock: $currentAvailableStock, requestedQuantity: $requestedQuantity, reason: $reason, status: $status, managerNote: $managerNote, resolvedAt: $resolvedAt, acknowledgedAt: $acknowledgedAt, forwardedQuantity: $forwardedQuantity, forwardedBy: $forwardedBy, forwardedAt: $forwardedAt, approvedQuantity: $approvedQuantity, approvedBy: $approvedBy, approvedAt: $approvedAt, ownerNote: $ownerNote, transferId: $transferId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RestockRequestCopyWith<$Res> implements $RestockRequestCopyWith<$Res> {
  factory _$RestockRequestCopyWith(_RestockRequest value, $Res Function(_RestockRequest) _then) = __$RestockRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id,@JsonKey(readValue: _readStore)@StoreRefConverter() EntityRef<Store>? storeId,@JsonKey(readValue: _readProduct)@ProductRefConverter() EntityRef<Product>? productId,@UserRefConverter() EntityRef<AppUser>? requestedBy,@UserRefConverter() EntityRef<AppUser>? handledBy,@UserRefConverter() EntityRef<AppUser>? acknowledgedBy, int currentAvailableStock, int requestedQuantity, String? reason, RestockStatus status, String? managerNote, DateTime? resolvedAt, DateTime? acknowledgedAt, int? forwardedQuantity,@UserRefConverter() EntityRef<AppUser>? forwardedBy, DateTime? forwardedAt, int? approvedQuantity,@UserRefConverter() EntityRef<AppUser>? approvedBy, DateTime? approvedAt, String? ownerNote,@StringishConverter() String? transferId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$RestockRequestCopyWithImpl<$Res>
    implements _$RestockRequestCopyWith<$Res> {
  __$RestockRequestCopyWithImpl(this._self, this._then);

  final _RestockRequest _self;
  final $Res Function(_RestockRequest) _then;

/// Create a copy of RestockRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = freezed,Object? productId = freezed,Object? requestedBy = freezed,Object? handledBy = freezed,Object? acknowledgedBy = freezed,Object? currentAvailableStock = null,Object? requestedQuantity = null,Object? reason = freezed,Object? status = null,Object? managerNote = freezed,Object? resolvedAt = freezed,Object? acknowledgedAt = freezed,Object? forwardedQuantity = freezed,Object? forwardedBy = freezed,Object? forwardedAt = freezed,Object? approvedQuantity = freezed,Object? approvedBy = freezed,Object? approvedAt = freezed,Object? ownerNote = freezed,Object? transferId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_RestockRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as EntityRef<Product>?,requestedBy: freezed == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,handledBy: freezed == handledBy ? _self.handledBy : handledBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,acknowledgedBy: freezed == acknowledgedBy ? _self.acknowledgedBy : acknowledgedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,currentAvailableStock: null == currentAvailableStock ? _self.currentAvailableStock : currentAvailableStock // ignore: cast_nullable_to_non_nullable
as int,requestedQuantity: null == requestedQuantity ? _self.requestedQuantity : requestedQuantity // ignore: cast_nullable_to_non_nullable
as int,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RestockStatus,managerNote: freezed == managerNote ? _self.managerNote : managerNote // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,acknowledgedAt: freezed == acknowledgedAt ? _self.acknowledgedAt : acknowledgedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,forwardedQuantity: freezed == forwardedQuantity ? _self.forwardedQuantity : forwardedQuantity // ignore: cast_nullable_to_non_nullable
as int?,forwardedBy: freezed == forwardedBy ? _self.forwardedBy : forwardedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,forwardedAt: freezed == forwardedAt ? _self.forwardedAt : forwardedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedQuantity: freezed == approvedQuantity ? _self.approvedQuantity : approvedQuantity // ignore: cast_nullable_to_non_nullable
as int?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ownerNote: freezed == ownerNote ? _self.ownerNote : ownerNote // ignore: cast_nullable_to_non_nullable
as String?,transferId: freezed == transferId ? _self.transferId : transferId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$InventoryReceipt {

@JsonKey(name: '_id') String get id;@JsonKey(readValue: _readStore)@StoreRefConverter() EntityRef<Store>? get storeId;@JsonKey(readValue: _readProduct)@ProductRefConverter() EntityRef<Product>? get productId; int get quantity; DateTime? get expiryDate; ReceiptSource get source; String? get note; String? get referenceId;@UserRefConverter() EntityRef<AppUser>? get receivedBy; DateTime? get createdAt;
/// Create a copy of InventoryReceipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryReceiptCopyWith<InventoryReceipt> get copyWith => _$InventoryReceiptCopyWithImpl<InventoryReceipt>(this as InventoryReceipt, _$identity);

  /// Serializes this InventoryReceipt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InventoryReceipt;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryReceipt&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.storeId, _this.storeId) || other.storeId == _this.storeId)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.expiryDate, _this.expiryDate) || other.expiryDate == _this.expiryDate)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.referenceId, _this.referenceId) || other.referenceId == _this.referenceId)&&(identical(other.receivedBy, _this.receivedBy) || other.receivedBy == _this.receivedBy)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InventoryReceipt;
  return Object.hash(runtimeType,_this.id,_this.storeId,_this.productId,_this.quantity,_this.expiryDate,_this.source,_this.note,_this.referenceId,_this.receivedBy,_this.createdAt);
}

@override
String toString() {
  final _this = this as InventoryReceipt;
  return 'InventoryReceipt(id: ${_this.id}, storeId: ${_this.storeId}, productId: ${_this.productId}, quantity: ${_this.quantity}, expiryDate: ${_this.expiryDate}, source: ${_this.source}, note: ${_this.note}, referenceId: ${_this.referenceId}, receivedBy: ${_this.receivedBy}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $InventoryReceiptCopyWith<$Res>  {
  factory $InventoryReceiptCopyWith(InventoryReceipt value, $Res Function(InventoryReceipt) _then) = _$InventoryReceiptCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id,@JsonKey(readValue: _readStore)@StoreRefConverter() EntityRef<Store>? storeId,@JsonKey(readValue: _readProduct)@ProductRefConverter() EntityRef<Product>? productId, int quantity, DateTime? expiryDate, ReceiptSource source, String? note, String? referenceId,@UserRefConverter() EntityRef<AppUser>? receivedBy, DateTime? createdAt
});




}
/// @nodoc
class _$InventoryReceiptCopyWithImpl<$Res>
    implements $InventoryReceiptCopyWith<$Res> {
  _$InventoryReceiptCopyWithImpl(this._self, this._then);

  final InventoryReceipt _self;
  final $Res Function(InventoryReceipt) _then;

/// Create a copy of InventoryReceipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = freezed,Object? productId = freezed,Object? quantity = null,Object? expiryDate = freezed,Object? source = null,Object? note = freezed,Object? referenceId = freezed,Object? receivedBy = freezed,Object? createdAt = freezed,}) {
  return _then(InventoryReceipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as EntityRef<Product>?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ReceiptSource,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,receivedBy: freezed == receivedBy ? _self.receivedBy : receivedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryReceipt].
extension InventoryReceiptPatterns on InventoryReceipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryReceipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryReceipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryReceipt value)  $default,){
final _that = this;
switch (_that) {
case _InventoryReceipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryReceipt value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryReceipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id, @JsonKey(readValue: _readStore)@StoreRefConverter()  EntityRef<Store>? storeId, @JsonKey(readValue: _readProduct)@ProductRefConverter()  EntityRef<Product>? productId,  int quantity,  DateTime? expiryDate,  ReceiptSource source,  String? note,  String? referenceId, @UserRefConverter()  EntityRef<AppUser>? receivedBy,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryReceipt() when $default != null:
return $default(_that.id,_that.storeId,_that.productId,_that.quantity,_that.expiryDate,_that.source,_that.note,_that.referenceId,_that.receivedBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id, @JsonKey(readValue: _readStore)@StoreRefConverter()  EntityRef<Store>? storeId, @JsonKey(readValue: _readProduct)@ProductRefConverter()  EntityRef<Product>? productId,  int quantity,  DateTime? expiryDate,  ReceiptSource source,  String? note,  String? referenceId, @UserRefConverter()  EntityRef<AppUser>? receivedBy,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _InventoryReceipt():
return $default(_that.id,_that.storeId,_that.productId,_that.quantity,_that.expiryDate,_that.source,_that.note,_that.referenceId,_that.receivedBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id, @JsonKey(readValue: _readStore)@StoreRefConverter()  EntityRef<Store>? storeId, @JsonKey(readValue: _readProduct)@ProductRefConverter()  EntityRef<Product>? productId,  int quantity,  DateTime? expiryDate,  ReceiptSource source,  String? note,  String? referenceId, @UserRefConverter()  EntityRef<AppUser>? receivedBy,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InventoryReceipt() when $default != null:
return $default(_that.id,_that.storeId,_that.productId,_that.quantity,_that.expiryDate,_that.source,_that.note,_that.referenceId,_that.receivedBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InventoryReceipt implements InventoryReceipt {
  const _InventoryReceipt({@JsonKey(name: '_id') required this.id, @JsonKey(readValue: _readStore)@StoreRefConverter() this.storeId, @JsonKey(readValue: _readProduct)@ProductRefConverter() this.productId, this.quantity = 0, this.expiryDate, this.source = ReceiptSource.direct, this.note, this.referenceId, @UserRefConverter() this.receivedBy, this.createdAt});
  factory _InventoryReceipt.fromJson(Map<String, dynamic> json) => _$InventoryReceiptFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override@JsonKey(readValue: _readStore)@StoreRefConverter() final  EntityRef<Store>? storeId;
@override@JsonKey(readValue: _readProduct)@ProductRefConverter() final  EntityRef<Product>? productId;
@override@JsonKey() final  int quantity;
@override final  DateTime? expiryDate;
@override@JsonKey() final  ReceiptSource source;
@override final  String? note;
@override final  String? referenceId;
@override@UserRefConverter() final  EntityRef<AppUser>? receivedBy;
@override final  DateTime? createdAt;

/// Create a copy of InventoryReceipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryReceiptCopyWith<_InventoryReceipt> get copyWith => __$InventoryReceiptCopyWithImpl<_InventoryReceipt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InventoryReceiptToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryReceipt&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.source, source) || other.source == source)&&(identical(other.note, note) || other.note == note)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.receivedBy, receivedBy) || other.receivedBy == receivedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,storeId,productId,quantity,expiryDate,source,note,referenceId,receivedBy,createdAt);
}

@override
String toString() {
    return 'InventoryReceipt(id: $id, storeId: $storeId, productId: $productId, quantity: $quantity, expiryDate: $expiryDate, source: $source, note: $note, referenceId: $referenceId, receivedBy: $receivedBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InventoryReceiptCopyWith<$Res> implements $InventoryReceiptCopyWith<$Res> {
  factory _$InventoryReceiptCopyWith(_InventoryReceipt value, $Res Function(_InventoryReceipt) _then) = __$InventoryReceiptCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id,@JsonKey(readValue: _readStore)@StoreRefConverter() EntityRef<Store>? storeId,@JsonKey(readValue: _readProduct)@ProductRefConverter() EntityRef<Product>? productId, int quantity, DateTime? expiryDate, ReceiptSource source, String? note, String? referenceId,@UserRefConverter() EntityRef<AppUser>? receivedBy, DateTime? createdAt
});




}
/// @nodoc
class __$InventoryReceiptCopyWithImpl<$Res>
    implements _$InventoryReceiptCopyWith<$Res> {
  __$InventoryReceiptCopyWithImpl(this._self, this._then);

  final _InventoryReceipt _self;
  final $Res Function(_InventoryReceipt) _then;

/// Create a copy of InventoryReceipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = freezed,Object? productId = freezed,Object? quantity = null,Object? expiryDate = freezed,Object? source = null,Object? note = freezed,Object? referenceId = freezed,Object? receivedBy = freezed,Object? createdAt = freezed,}) {
  return _then(_InventoryReceipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as EntityRef<Product>?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ReceiptSource,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,receivedBy: freezed == receivedBy ? _self.receivedBy : receivedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$InventoryAdjustment {

@JsonKey(name: '_id') String get id;@JsonKey(readValue: _readStore)@StoreRefConverter() EntityRef<Store>? get storeId;@JsonKey(readValue: _readProduct)@ProductRefConverter() EntityRef<Product>? get productId; AdjustmentType get type; int get quantity; String? get note;@UserRefConverter() EntityRef<AppUser>? get createdBy; DateTime? get createdAt;
/// Create a copy of InventoryAdjustment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryAdjustmentCopyWith<InventoryAdjustment> get copyWith => _$InventoryAdjustmentCopyWithImpl<InventoryAdjustment>(this as InventoryAdjustment, _$identity);

  /// Serializes this InventoryAdjustment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InventoryAdjustment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryAdjustment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.storeId, _this.storeId) || other.storeId == _this.storeId)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InventoryAdjustment;
  return Object.hash(runtimeType,_this.id,_this.storeId,_this.productId,_this.type,_this.quantity,_this.note,_this.createdBy,_this.createdAt);
}

@override
String toString() {
  final _this = this as InventoryAdjustment;
  return 'InventoryAdjustment(id: ${_this.id}, storeId: ${_this.storeId}, productId: ${_this.productId}, type: ${_this.type}, quantity: ${_this.quantity}, note: ${_this.note}, createdBy: ${_this.createdBy}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $InventoryAdjustmentCopyWith<$Res>  {
  factory $InventoryAdjustmentCopyWith(InventoryAdjustment value, $Res Function(InventoryAdjustment) _then) = _$InventoryAdjustmentCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id,@JsonKey(readValue: _readStore)@StoreRefConverter() EntityRef<Store>? storeId,@JsonKey(readValue: _readProduct)@ProductRefConverter() EntityRef<Product>? productId, AdjustmentType type, int quantity, String? note,@UserRefConverter() EntityRef<AppUser>? createdBy, DateTime? createdAt
});




}
/// @nodoc
class _$InventoryAdjustmentCopyWithImpl<$Res>
    implements $InventoryAdjustmentCopyWith<$Res> {
  _$InventoryAdjustmentCopyWithImpl(this._self, this._then);

  final InventoryAdjustment _self;
  final $Res Function(InventoryAdjustment) _then;

/// Create a copy of InventoryAdjustment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = freezed,Object? productId = freezed,Object? type = null,Object? quantity = null,Object? note = freezed,Object? createdBy = freezed,Object? createdAt = freezed,}) {
  return _then(InventoryAdjustment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as EntityRef<Product>?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AdjustmentType,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryAdjustment].
extension InventoryAdjustmentPatterns on InventoryAdjustment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryAdjustment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryAdjustment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryAdjustment value)  $default,){
final _that = this;
switch (_that) {
case _InventoryAdjustment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryAdjustment value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryAdjustment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id, @JsonKey(readValue: _readStore)@StoreRefConverter()  EntityRef<Store>? storeId, @JsonKey(readValue: _readProduct)@ProductRefConverter()  EntityRef<Product>? productId,  AdjustmentType type,  int quantity,  String? note, @UserRefConverter()  EntityRef<AppUser>? createdBy,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryAdjustment() when $default != null:
return $default(_that.id,_that.storeId,_that.productId,_that.type,_that.quantity,_that.note,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id, @JsonKey(readValue: _readStore)@StoreRefConverter()  EntityRef<Store>? storeId, @JsonKey(readValue: _readProduct)@ProductRefConverter()  EntityRef<Product>? productId,  AdjustmentType type,  int quantity,  String? note, @UserRefConverter()  EntityRef<AppUser>? createdBy,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _InventoryAdjustment():
return $default(_that.id,_that.storeId,_that.productId,_that.type,_that.quantity,_that.note,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id, @JsonKey(readValue: _readStore)@StoreRefConverter()  EntityRef<Store>? storeId, @JsonKey(readValue: _readProduct)@ProductRefConverter()  EntityRef<Product>? productId,  AdjustmentType type,  int quantity,  String? note, @UserRefConverter()  EntityRef<AppUser>? createdBy,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InventoryAdjustment() when $default != null:
return $default(_that.id,_that.storeId,_that.productId,_that.type,_that.quantity,_that.note,_that.createdBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InventoryAdjustment implements InventoryAdjustment {
  const _InventoryAdjustment({@JsonKey(name: '_id') required this.id, @JsonKey(readValue: _readStore)@StoreRefConverter() this.storeId, @JsonKey(readValue: _readProduct)@ProductRefConverter() this.productId, this.type = AdjustmentType.other, this.quantity = 0, this.note, @UserRefConverter() this.createdBy, this.createdAt});
  factory _InventoryAdjustment.fromJson(Map<String, dynamic> json) => _$InventoryAdjustmentFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override@JsonKey(readValue: _readStore)@StoreRefConverter() final  EntityRef<Store>? storeId;
@override@JsonKey(readValue: _readProduct)@ProductRefConverter() final  EntityRef<Product>? productId;
@override@JsonKey() final  AdjustmentType type;
@override@JsonKey() final  int quantity;
@override final  String? note;
@override@UserRefConverter() final  EntityRef<AppUser>? createdBy;
@override final  DateTime? createdAt;

/// Create a copy of InventoryAdjustment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryAdjustmentCopyWith<_InventoryAdjustment> get copyWith => __$InventoryAdjustmentCopyWithImpl<_InventoryAdjustment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InventoryAdjustmentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryAdjustment&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.type, type) || other.type == type)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,storeId,productId,type,quantity,note,createdBy,createdAt);
}

@override
String toString() {
    return 'InventoryAdjustment(id: $id, storeId: $storeId, productId: $productId, type: $type, quantity: $quantity, note: $note, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InventoryAdjustmentCopyWith<$Res> implements $InventoryAdjustmentCopyWith<$Res> {
  factory _$InventoryAdjustmentCopyWith(_InventoryAdjustment value, $Res Function(_InventoryAdjustment) _then) = __$InventoryAdjustmentCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id,@JsonKey(readValue: _readStore)@StoreRefConverter() EntityRef<Store>? storeId,@JsonKey(readValue: _readProduct)@ProductRefConverter() EntityRef<Product>? productId, AdjustmentType type, int quantity, String? note,@UserRefConverter() EntityRef<AppUser>? createdBy, DateTime? createdAt
});




}
/// @nodoc
class __$InventoryAdjustmentCopyWithImpl<$Res>
    implements _$InventoryAdjustmentCopyWith<$Res> {
  __$InventoryAdjustmentCopyWithImpl(this._self, this._then);

  final _InventoryAdjustment _self;
  final $Res Function(_InventoryAdjustment) _then;

/// Create a copy of InventoryAdjustment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = freezed,Object? productId = freezed,Object? type = null,Object? quantity = null,Object? note = freezed,Object? createdBy = freezed,Object? createdAt = freezed,}) {
  return _then(_InventoryAdjustment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as EntityRef<Product>?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AdjustmentType,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$InventoryReturnRequest {

@JsonKey(name: '_id') String get id;@JsonKey(readValue: _readStore)@StoreRefConverter() EntityRef<Store>? get storeId;@JsonKey(readValue: _readProduct)@ProductRefConverter() EntityRef<Product>? get productId; int get quantity; int get currentAvailableStock; ReturnReasonType get reasonType; String? get managerNote; String? get reviewNote; ReturnRequestStatus get status;@UserRefConverter() EntityRef<AppUser>? get requestedBy;@UserRefConverter() EntityRef<AppUser>? get reviewedBy; DateTime? get reviewedAt; DateTime? get createdAt;
/// Create a copy of InventoryReturnRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryReturnRequestCopyWith<InventoryReturnRequest> get copyWith => _$InventoryReturnRequestCopyWithImpl<InventoryReturnRequest>(this as InventoryReturnRequest, _$identity);

  /// Serializes this InventoryReturnRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InventoryReturnRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryReturnRequest&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.storeId, _this.storeId) || other.storeId == _this.storeId)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.currentAvailableStock, _this.currentAvailableStock) || other.currentAvailableStock == _this.currentAvailableStock)&&(identical(other.reasonType, _this.reasonType) || other.reasonType == _this.reasonType)&&(identical(other.managerNote, _this.managerNote) || other.managerNote == _this.managerNote)&&(identical(other.reviewNote, _this.reviewNote) || other.reviewNote == _this.reviewNote)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.requestedBy, _this.requestedBy) || other.requestedBy == _this.requestedBy)&&(identical(other.reviewedBy, _this.reviewedBy) || other.reviewedBy == _this.reviewedBy)&&(identical(other.reviewedAt, _this.reviewedAt) || other.reviewedAt == _this.reviewedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InventoryReturnRequest;
  return Object.hash(runtimeType,_this.id,_this.storeId,_this.productId,_this.quantity,_this.currentAvailableStock,_this.reasonType,_this.managerNote,_this.reviewNote,_this.status,_this.requestedBy,_this.reviewedBy,_this.reviewedAt,_this.createdAt);
}

@override
String toString() {
  final _this = this as InventoryReturnRequest;
  return 'InventoryReturnRequest(id: ${_this.id}, storeId: ${_this.storeId}, productId: ${_this.productId}, quantity: ${_this.quantity}, currentAvailableStock: ${_this.currentAvailableStock}, reasonType: ${_this.reasonType}, managerNote: ${_this.managerNote}, reviewNote: ${_this.reviewNote}, status: ${_this.status}, requestedBy: ${_this.requestedBy}, reviewedBy: ${_this.reviewedBy}, reviewedAt: ${_this.reviewedAt}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $InventoryReturnRequestCopyWith<$Res>  {
  factory $InventoryReturnRequestCopyWith(InventoryReturnRequest value, $Res Function(InventoryReturnRequest) _then) = _$InventoryReturnRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id,@JsonKey(readValue: _readStore)@StoreRefConverter() EntityRef<Store>? storeId,@JsonKey(readValue: _readProduct)@ProductRefConverter() EntityRef<Product>? productId, int quantity, int currentAvailableStock, ReturnReasonType reasonType, String? managerNote, String? reviewNote, ReturnRequestStatus status,@UserRefConverter() EntityRef<AppUser>? requestedBy,@UserRefConverter() EntityRef<AppUser>? reviewedBy, DateTime? reviewedAt, DateTime? createdAt
});




}
/// @nodoc
class _$InventoryReturnRequestCopyWithImpl<$Res>
    implements $InventoryReturnRequestCopyWith<$Res> {
  _$InventoryReturnRequestCopyWithImpl(this._self, this._then);

  final InventoryReturnRequest _self;
  final $Res Function(InventoryReturnRequest) _then;

/// Create a copy of InventoryReturnRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = freezed,Object? productId = freezed,Object? quantity = null,Object? currentAvailableStock = null,Object? reasonType = null,Object? managerNote = freezed,Object? reviewNote = freezed,Object? status = null,Object? requestedBy = freezed,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? createdAt = freezed,}) {
  return _then(InventoryReturnRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as EntityRef<Product>?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,currentAvailableStock: null == currentAvailableStock ? _self.currentAvailableStock : currentAvailableStock // ignore: cast_nullable_to_non_nullable
as int,reasonType: null == reasonType ? _self.reasonType : reasonType // ignore: cast_nullable_to_non_nullable
as ReturnReasonType,managerNote: freezed == managerNote ? _self.managerNote : managerNote // ignore: cast_nullable_to_non_nullable
as String?,reviewNote: freezed == reviewNote ? _self.reviewNote : reviewNote // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReturnRequestStatus,requestedBy: freezed == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryReturnRequest].
extension InventoryReturnRequestPatterns on InventoryReturnRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryReturnRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryReturnRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryReturnRequest value)  $default,){
final _that = this;
switch (_that) {
case _InventoryReturnRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryReturnRequest value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryReturnRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id, @JsonKey(readValue: _readStore)@StoreRefConverter()  EntityRef<Store>? storeId, @JsonKey(readValue: _readProduct)@ProductRefConverter()  EntityRef<Product>? productId,  int quantity,  int currentAvailableStock,  ReturnReasonType reasonType,  String? managerNote,  String? reviewNote,  ReturnRequestStatus status, @UserRefConverter()  EntityRef<AppUser>? requestedBy, @UserRefConverter()  EntityRef<AppUser>? reviewedBy,  DateTime? reviewedAt,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryReturnRequest() when $default != null:
return $default(_that.id,_that.storeId,_that.productId,_that.quantity,_that.currentAvailableStock,_that.reasonType,_that.managerNote,_that.reviewNote,_that.status,_that.requestedBy,_that.reviewedBy,_that.reviewedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id, @JsonKey(readValue: _readStore)@StoreRefConverter()  EntityRef<Store>? storeId, @JsonKey(readValue: _readProduct)@ProductRefConverter()  EntityRef<Product>? productId,  int quantity,  int currentAvailableStock,  ReturnReasonType reasonType,  String? managerNote,  String? reviewNote,  ReturnRequestStatus status, @UserRefConverter()  EntityRef<AppUser>? requestedBy, @UserRefConverter()  EntityRef<AppUser>? reviewedBy,  DateTime? reviewedAt,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _InventoryReturnRequest():
return $default(_that.id,_that.storeId,_that.productId,_that.quantity,_that.currentAvailableStock,_that.reasonType,_that.managerNote,_that.reviewNote,_that.status,_that.requestedBy,_that.reviewedBy,_that.reviewedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id, @JsonKey(readValue: _readStore)@StoreRefConverter()  EntityRef<Store>? storeId, @JsonKey(readValue: _readProduct)@ProductRefConverter()  EntityRef<Product>? productId,  int quantity,  int currentAvailableStock,  ReturnReasonType reasonType,  String? managerNote,  String? reviewNote,  ReturnRequestStatus status, @UserRefConverter()  EntityRef<AppUser>? requestedBy, @UserRefConverter()  EntityRef<AppUser>? reviewedBy,  DateTime? reviewedAt,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InventoryReturnRequest() when $default != null:
return $default(_that.id,_that.storeId,_that.productId,_that.quantity,_that.currentAvailableStock,_that.reasonType,_that.managerNote,_that.reviewNote,_that.status,_that.requestedBy,_that.reviewedBy,_that.reviewedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InventoryReturnRequest implements InventoryReturnRequest {
  const _InventoryReturnRequest({@JsonKey(name: '_id') required this.id, @JsonKey(readValue: _readStore)@StoreRefConverter() this.storeId, @JsonKey(readValue: _readProduct)@ProductRefConverter() this.productId, this.quantity = 0, this.currentAvailableStock = 0, this.reasonType = ReturnReasonType.other, this.managerNote, this.reviewNote, this.status = ReturnRequestStatus.pending, @UserRefConverter() this.requestedBy, @UserRefConverter() this.reviewedBy, this.reviewedAt, this.createdAt});
  factory _InventoryReturnRequest.fromJson(Map<String, dynamic> json) => _$InventoryReturnRequestFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override@JsonKey(readValue: _readStore)@StoreRefConverter() final  EntityRef<Store>? storeId;
@override@JsonKey(readValue: _readProduct)@ProductRefConverter() final  EntityRef<Product>? productId;
@override@JsonKey() final  int quantity;
@override@JsonKey() final  int currentAvailableStock;
@override@JsonKey() final  ReturnReasonType reasonType;
@override final  String? managerNote;
@override final  String? reviewNote;
@override@JsonKey() final  ReturnRequestStatus status;
@override@UserRefConverter() final  EntityRef<AppUser>? requestedBy;
@override@UserRefConverter() final  EntityRef<AppUser>? reviewedBy;
@override final  DateTime? reviewedAt;
@override final  DateTime? createdAt;

/// Create a copy of InventoryReturnRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryReturnRequestCopyWith<_InventoryReturnRequest> get copyWith => __$InventoryReturnRequestCopyWithImpl<_InventoryReturnRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InventoryReturnRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryReturnRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.currentAvailableStock, currentAvailableStock) || other.currentAvailableStock == currentAvailableStock)&&(identical(other.reasonType, reasonType) || other.reasonType == reasonType)&&(identical(other.managerNote, managerNote) || other.managerNote == managerNote)&&(identical(other.reviewNote, reviewNote) || other.reviewNote == reviewNote)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,storeId,productId,quantity,currentAvailableStock,reasonType,managerNote,reviewNote,status,requestedBy,reviewedBy,reviewedAt,createdAt);
}

@override
String toString() {
    return 'InventoryReturnRequest(id: $id, storeId: $storeId, productId: $productId, quantity: $quantity, currentAvailableStock: $currentAvailableStock, reasonType: $reasonType, managerNote: $managerNote, reviewNote: $reviewNote, status: $status, requestedBy: $requestedBy, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InventoryReturnRequestCopyWith<$Res> implements $InventoryReturnRequestCopyWith<$Res> {
  factory _$InventoryReturnRequestCopyWith(_InventoryReturnRequest value, $Res Function(_InventoryReturnRequest) _then) = __$InventoryReturnRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id,@JsonKey(readValue: _readStore)@StoreRefConverter() EntityRef<Store>? storeId,@JsonKey(readValue: _readProduct)@ProductRefConverter() EntityRef<Product>? productId, int quantity, int currentAvailableStock, ReturnReasonType reasonType, String? managerNote, String? reviewNote, ReturnRequestStatus status,@UserRefConverter() EntityRef<AppUser>? requestedBy,@UserRefConverter() EntityRef<AppUser>? reviewedBy, DateTime? reviewedAt, DateTime? createdAt
});




}
/// @nodoc
class __$InventoryReturnRequestCopyWithImpl<$Res>
    implements _$InventoryReturnRequestCopyWith<$Res> {
  __$InventoryReturnRequestCopyWithImpl(this._self, this._then);

  final _InventoryReturnRequest _self;
  final $Res Function(_InventoryReturnRequest) _then;

/// Create a copy of InventoryReturnRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = freezed,Object? productId = freezed,Object? quantity = null,Object? currentAvailableStock = null,Object? reasonType = null,Object? managerNote = freezed,Object? reviewNote = freezed,Object? status = null,Object? requestedBy = freezed,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_InventoryReturnRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as EntityRef<Product>?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,currentAvailableStock: null == currentAvailableStock ? _self.currentAvailableStock : currentAvailableStock // ignore: cast_nullable_to_non_nullable
as int,reasonType: null == reasonType ? _self.reasonType : reasonType // ignore: cast_nullable_to_non_nullable
as ReturnReasonType,managerNote: freezed == managerNote ? _self.managerNote : managerNote // ignore: cast_nullable_to_non_nullable
as String?,reviewNote: freezed == reviewNote ? _self.reviewNote : reviewNote // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReturnRequestStatus,requestedBy: freezed == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$TransferItem {

@JsonKey(readValue: _readProduct)@ProductRefConverter() EntityRef<Product> get productId; int get quantity;
/// Create a copy of TransferItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferItemCopyWith<TransferItem> get copyWith => _$TransferItemCopyWithImpl<TransferItem>(this as TransferItem, _$identity);

  /// Serializes this TransferItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TransferItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferItem&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TransferItem;
  return Object.hash(runtimeType,_this.productId,_this.quantity);
}

@override
String toString() {
  final _this = this as TransferItem;
  return 'TransferItem(productId: ${_this.productId}, quantity: ${_this.quantity})';
}


}

/// @nodoc
abstract mixin class $TransferItemCopyWith<$Res>  {
  factory $TransferItemCopyWith(TransferItem value, $Res Function(TransferItem) _then) = _$TransferItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readProduct)@ProductRefConverter() EntityRef<Product> productId, int quantity
});




}
/// @nodoc
class _$TransferItemCopyWithImpl<$Res>
    implements $TransferItemCopyWith<$Res> {
  _$TransferItemCopyWithImpl(this._self, this._then);

  final TransferItem _self;
  final $Res Function(TransferItem) _then;

/// Create a copy of TransferItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? quantity = null,}) {
  return _then(TransferItem(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as EntityRef<Product>,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TransferItem].
extension TransferItemPatterns on TransferItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransferItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransferItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransferItem value)  $default,){
final _that = this;
switch (_that) {
case _TransferItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransferItem value)?  $default,){
final _that = this;
switch (_that) {
case _TransferItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readProduct)@ProductRefConverter()  EntityRef<Product> productId,  int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransferItem() when $default != null:
return $default(_that.productId,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readProduct)@ProductRefConverter()  EntityRef<Product> productId,  int quantity)  $default,) {final _that = this;
switch (_that) {
case _TransferItem():
return $default(_that.productId,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readProduct)@ProductRefConverter()  EntityRef<Product> productId,  int quantity)?  $default,) {final _that = this;
switch (_that) {
case _TransferItem() when $default != null:
return $default(_that.productId,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransferItem implements TransferItem {
  const _TransferItem({@JsonKey(readValue: _readProduct)@ProductRefConverter() required this.productId, this.quantity = 0});
  factory _TransferItem.fromJson(Map<String, dynamic> json) => _$TransferItemFromJson(json);

@override@JsonKey(readValue: _readProduct)@ProductRefConverter() final  EntityRef<Product> productId;
@override@JsonKey() final  int quantity;

/// Create a copy of TransferItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransferItemCopyWith<_TransferItem> get copyWith => __$TransferItemCopyWithImpl<_TransferItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransferItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransferItem&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,quantity);
}

@override
String toString() {
    return 'TransferItem(productId: $productId, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$TransferItemCopyWith<$Res> implements $TransferItemCopyWith<$Res> {
  factory _$TransferItemCopyWith(_TransferItem value, $Res Function(_TransferItem) _then) = __$TransferItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readProduct)@ProductRefConverter() EntityRef<Product> productId, int quantity
});




}
/// @nodoc
class __$TransferItemCopyWithImpl<$Res>
    implements _$TransferItemCopyWith<$Res> {
  __$TransferItemCopyWithImpl(this._self, this._then);

  final _TransferItem _self;
  final $Res Function(_TransferItem) _then;

/// Create a copy of TransferItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? quantity = null,}) {
  return _then(_TransferItem(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as EntityRef<Product>,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$StockTransfer {

@JsonKey(name: '_id') String get id;@StoreRefConverter() EntityRef<Store>? get fromStoreId;@StoreRefConverter() EntityRef<Store>? get toStoreId; List<TransferItem> get items; TransferStatus get status;@UserRefConverter() EntityRef<AppUser>? get createdBy;@UserRefConverter() EntityRef<AppUser>? get confirmedBy; String? get note;@StringishConverter() String? get restockRequestId; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of StockTransfer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockTransferCopyWith<StockTransfer> get copyWith => _$StockTransferCopyWithImpl<StockTransfer>(this as StockTransfer, _$identity);

  /// Serializes this StockTransfer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StockTransfer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockTransfer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fromStoreId, _this.fromStoreId) || other.fromStoreId == _this.fromStoreId)&&(identical(other.toStoreId, _this.toStoreId) || other.toStoreId == _this.toStoreId)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.confirmedBy, _this.confirmedBy) || other.confirmedBy == _this.confirmedBy)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.restockRequestId, _this.restockRequestId) || other.restockRequestId == _this.restockRequestId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StockTransfer;
  return Object.hash(runtimeType,_this.id,_this.fromStoreId,_this.toStoreId,const DeepCollectionEquality().hash(_this.items),_this.status,_this.createdBy,_this.confirmedBy,_this.note,_this.restockRequestId,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as StockTransfer;
  return 'StockTransfer(id: ${_this.id}, fromStoreId: ${_this.fromStoreId}, toStoreId: ${_this.toStoreId}, items: ${_this.items}, status: ${_this.status}, createdBy: ${_this.createdBy}, confirmedBy: ${_this.confirmedBy}, note: ${_this.note}, restockRequestId: ${_this.restockRequestId}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $StockTransferCopyWith<$Res>  {
  factory $StockTransferCopyWith(StockTransfer value, $Res Function(StockTransfer) _then) = _$StockTransferCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id,@StoreRefConverter() EntityRef<Store>? fromStoreId,@StoreRefConverter() EntityRef<Store>? toStoreId, List<TransferItem> items, TransferStatus status,@UserRefConverter() EntityRef<AppUser>? createdBy,@UserRefConverter() EntityRef<AppUser>? confirmedBy, String? note,@StringishConverter() String? restockRequestId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$StockTransferCopyWithImpl<$Res>
    implements $StockTransferCopyWith<$Res> {
  _$StockTransferCopyWithImpl(this._self, this._then);

  final StockTransfer _self;
  final $Res Function(StockTransfer) _then;

/// Create a copy of StockTransfer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fromStoreId = freezed,Object? toStoreId = freezed,Object? items = null,Object? status = null,Object? createdBy = freezed,Object? confirmedBy = freezed,Object? note = freezed,Object? restockRequestId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(StockTransfer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromStoreId: freezed == fromStoreId ? _self.fromStoreId : fromStoreId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,toStoreId: freezed == toStoreId ? _self.toStoreId : toStoreId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<TransferItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransferStatus,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,confirmedBy: freezed == confirmedBy ? _self.confirmedBy : confirmedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,restockRequestId: freezed == restockRequestId ? _self.restockRequestId : restockRequestId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StockTransfer].
extension StockTransferPatterns on StockTransfer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockTransfer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockTransfer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockTransfer value)  $default,){
final _that = this;
switch (_that) {
case _StockTransfer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockTransfer value)?  $default,){
final _that = this;
switch (_that) {
case _StockTransfer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id, @StoreRefConverter()  EntityRef<Store>? fromStoreId, @StoreRefConverter()  EntityRef<Store>? toStoreId,  List<TransferItem> items,  TransferStatus status, @UserRefConverter()  EntityRef<AppUser>? createdBy, @UserRefConverter()  EntityRef<AppUser>? confirmedBy,  String? note, @StringishConverter()  String? restockRequestId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockTransfer() when $default != null:
return $default(_that.id,_that.fromStoreId,_that.toStoreId,_that.items,_that.status,_that.createdBy,_that.confirmedBy,_that.note,_that.restockRequestId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id, @StoreRefConverter()  EntityRef<Store>? fromStoreId, @StoreRefConverter()  EntityRef<Store>? toStoreId,  List<TransferItem> items,  TransferStatus status, @UserRefConverter()  EntityRef<AppUser>? createdBy, @UserRefConverter()  EntityRef<AppUser>? confirmedBy,  String? note, @StringishConverter()  String? restockRequestId,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _StockTransfer():
return $default(_that.id,_that.fromStoreId,_that.toStoreId,_that.items,_that.status,_that.createdBy,_that.confirmedBy,_that.note,_that.restockRequestId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id, @StoreRefConverter()  EntityRef<Store>? fromStoreId, @StoreRefConverter()  EntityRef<Store>? toStoreId,  List<TransferItem> items,  TransferStatus status, @UserRefConverter()  EntityRef<AppUser>? createdBy, @UserRefConverter()  EntityRef<AppUser>? confirmedBy,  String? note, @StringishConverter()  String? restockRequestId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _StockTransfer() when $default != null:
return $default(_that.id,_that.fromStoreId,_that.toStoreId,_that.items,_that.status,_that.createdBy,_that.confirmedBy,_that.note,_that.restockRequestId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StockTransfer extends StockTransfer {
  const _StockTransfer({@JsonKey(name: '_id') required this.id, @StoreRefConverter() this.fromStoreId, @StoreRefConverter() this.toStoreId,  List<TransferItem> items = const <TransferItem>[], this.status = TransferStatus.pending, @UserRefConverter() this.createdBy, @UserRefConverter() this.confirmedBy, this.note, @StringishConverter() this.restockRequestId, this.createdAt, this.updatedAt}): _items = items,super._();
  factory _StockTransfer.fromJson(Map<String, dynamic> json) => _$StockTransferFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override@StoreRefConverter() final  EntityRef<Store>? fromStoreId;
@override@StoreRefConverter() final  EntityRef<Store>? toStoreId;
 final  List<TransferItem> _items;
@override@JsonKey() List<TransferItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  TransferStatus status;
@override@UserRefConverter() final  EntityRef<AppUser>? createdBy;
@override@UserRefConverter() final  EntityRef<AppUser>? confirmedBy;
@override final  String? note;
@override@StringishConverter() final  String? restockRequestId;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of StockTransfer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockTransferCopyWith<_StockTransfer> get copyWith => __$StockTransferCopyWithImpl<_StockTransfer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StockTransferToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockTransfer&&(identical(other.id, id) || other.id == id)&&(identical(other.fromStoreId, fromStoreId) || other.fromStoreId == fromStoreId)&&(identical(other.toStoreId, toStoreId) || other.toStoreId == toStoreId)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.confirmedBy, confirmedBy) || other.confirmedBy == confirmedBy)&&(identical(other.note, note) || other.note == note)&&(identical(other.restockRequestId, restockRequestId) || other.restockRequestId == restockRequestId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,fromStoreId,toStoreId,const DeepCollectionEquality().hash(_items),status,createdBy,confirmedBy,note,restockRequestId,createdAt,updatedAt);
}

@override
String toString() {
    return 'StockTransfer(id: $id, fromStoreId: $fromStoreId, toStoreId: $toStoreId, items: $items, status: $status, createdBy: $createdBy, confirmedBy: $confirmedBy, note: $note, restockRequestId: $restockRequestId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$StockTransferCopyWith<$Res> implements $StockTransferCopyWith<$Res> {
  factory _$StockTransferCopyWith(_StockTransfer value, $Res Function(_StockTransfer) _then) = __$StockTransferCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id,@StoreRefConverter() EntityRef<Store>? fromStoreId,@StoreRefConverter() EntityRef<Store>? toStoreId, List<TransferItem> items, TransferStatus status,@UserRefConverter() EntityRef<AppUser>? createdBy,@UserRefConverter() EntityRef<AppUser>? confirmedBy, String? note,@StringishConverter() String? restockRequestId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$StockTransferCopyWithImpl<$Res>
    implements _$StockTransferCopyWith<$Res> {
  __$StockTransferCopyWithImpl(this._self, this._then);

  final _StockTransfer _self;
  final $Res Function(_StockTransfer) _then;

/// Create a copy of StockTransfer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fromStoreId = freezed,Object? toStoreId = freezed,Object? items = null,Object? status = null,Object? createdBy = freezed,Object? confirmedBy = freezed,Object? note = freezed,Object? restockRequestId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_StockTransfer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromStoreId: freezed == fromStoreId ? _self.fromStoreId : fromStoreId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,toStoreId: freezed == toStoreId ? _self.toStoreId : toStoreId // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<TransferItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransferStatus,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,confirmedBy: freezed == confirmedBy ? _self.confirmedBy : confirmedBy // ignore: cast_nullable_to_non_nullable
as EntityRef<AppUser>?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,restockRequestId: freezed == restockRequestId ? _self.restockRequestId : restockRequestId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
