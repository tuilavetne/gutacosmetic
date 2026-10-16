// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RevenueSummary {

 num get paidRevenue; num get monthlyRevenue; num get grossProfit; num get monthlyGrossProfit; num get estimatedNetProfit; num get soldCost; num get writeOffCost; num get stockInCost; num get inventoryValue; int get paidOrders; int get totalOrders; num get averageOrderValue; int get missingCostProductCount;/// Tên (tối đa 5) sản phẩm chưa có giá vốn.
 List<String> get missingCostProducts;
/// Create a copy of RevenueSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueSummaryCopyWith<RevenueSummary> get copyWith => _$RevenueSummaryCopyWithImpl<RevenueSummary>(this as RevenueSummary, _$identity);

  /// Serializes this RevenueSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RevenueSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevenueSummary&&(identical(other.paidRevenue, _this.paidRevenue) || other.paidRevenue == _this.paidRevenue)&&(identical(other.monthlyRevenue, _this.monthlyRevenue) || other.monthlyRevenue == _this.monthlyRevenue)&&(identical(other.grossProfit, _this.grossProfit) || other.grossProfit == _this.grossProfit)&&(identical(other.monthlyGrossProfit, _this.monthlyGrossProfit) || other.monthlyGrossProfit == _this.monthlyGrossProfit)&&(identical(other.estimatedNetProfit, _this.estimatedNetProfit) || other.estimatedNetProfit == _this.estimatedNetProfit)&&(identical(other.soldCost, _this.soldCost) || other.soldCost == _this.soldCost)&&(identical(other.writeOffCost, _this.writeOffCost) || other.writeOffCost == _this.writeOffCost)&&(identical(other.stockInCost, _this.stockInCost) || other.stockInCost == _this.stockInCost)&&(identical(other.inventoryValue, _this.inventoryValue) || other.inventoryValue == _this.inventoryValue)&&(identical(other.paidOrders, _this.paidOrders) || other.paidOrders == _this.paidOrders)&&(identical(other.totalOrders, _this.totalOrders) || other.totalOrders == _this.totalOrders)&&(identical(other.averageOrderValue, _this.averageOrderValue) || other.averageOrderValue == _this.averageOrderValue)&&(identical(other.missingCostProductCount, _this.missingCostProductCount) || other.missingCostProductCount == _this.missingCostProductCount)&&const DeepCollectionEquality().equals(other.missingCostProducts, _this.missingCostProducts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RevenueSummary;
  return Object.hash(runtimeType,_this.paidRevenue,_this.monthlyRevenue,_this.grossProfit,_this.monthlyGrossProfit,_this.estimatedNetProfit,_this.soldCost,_this.writeOffCost,_this.stockInCost,_this.inventoryValue,_this.paidOrders,_this.totalOrders,_this.averageOrderValue,_this.missingCostProductCount,const DeepCollectionEquality().hash(_this.missingCostProducts));
}

@override
String toString() {
  final _this = this as RevenueSummary;
  return 'RevenueSummary(paidRevenue: ${_this.paidRevenue}, monthlyRevenue: ${_this.monthlyRevenue}, grossProfit: ${_this.grossProfit}, monthlyGrossProfit: ${_this.monthlyGrossProfit}, estimatedNetProfit: ${_this.estimatedNetProfit}, soldCost: ${_this.soldCost}, writeOffCost: ${_this.writeOffCost}, stockInCost: ${_this.stockInCost}, inventoryValue: ${_this.inventoryValue}, paidOrders: ${_this.paidOrders}, totalOrders: ${_this.totalOrders}, averageOrderValue: ${_this.averageOrderValue}, missingCostProductCount: ${_this.missingCostProductCount}, missingCostProducts: ${_this.missingCostProducts})';
}


}

/// @nodoc
abstract mixin class $RevenueSummaryCopyWith<$Res>  {
  factory $RevenueSummaryCopyWith(RevenueSummary value, $Res Function(RevenueSummary) _then) = _$RevenueSummaryCopyWithImpl;
@useResult
$Res call({
 num paidRevenue, num monthlyRevenue, num grossProfit, num monthlyGrossProfit, num estimatedNetProfit, num soldCost, num writeOffCost, num stockInCost, num inventoryValue, int paidOrders, int totalOrders, num averageOrderValue, int missingCostProductCount, List<String> missingCostProducts
});




}
/// @nodoc
class _$RevenueSummaryCopyWithImpl<$Res>
    implements $RevenueSummaryCopyWith<$Res> {
  _$RevenueSummaryCopyWithImpl(this._self, this._then);

  final RevenueSummary _self;
  final $Res Function(RevenueSummary) _then;

/// Create a copy of RevenueSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? paidRevenue = null,Object? monthlyRevenue = null,Object? grossProfit = null,Object? monthlyGrossProfit = null,Object? estimatedNetProfit = null,Object? soldCost = null,Object? writeOffCost = null,Object? stockInCost = null,Object? inventoryValue = null,Object? paidOrders = null,Object? totalOrders = null,Object? averageOrderValue = null,Object? missingCostProductCount = null,Object? missingCostProducts = null,}) {
  return _then(RevenueSummary(
paidRevenue: null == paidRevenue ? _self.paidRevenue : paidRevenue // ignore: cast_nullable_to_non_nullable
as num,monthlyRevenue: null == monthlyRevenue ? _self.monthlyRevenue : monthlyRevenue // ignore: cast_nullable_to_non_nullable
as num,grossProfit: null == grossProfit ? _self.grossProfit : grossProfit // ignore: cast_nullable_to_non_nullable
as num,monthlyGrossProfit: null == monthlyGrossProfit ? _self.monthlyGrossProfit : monthlyGrossProfit // ignore: cast_nullable_to_non_nullable
as num,estimatedNetProfit: null == estimatedNetProfit ? _self.estimatedNetProfit : estimatedNetProfit // ignore: cast_nullable_to_non_nullable
as num,soldCost: null == soldCost ? _self.soldCost : soldCost // ignore: cast_nullable_to_non_nullable
as num,writeOffCost: null == writeOffCost ? _self.writeOffCost : writeOffCost // ignore: cast_nullable_to_non_nullable
as num,stockInCost: null == stockInCost ? _self.stockInCost : stockInCost // ignore: cast_nullable_to_non_nullable
as num,inventoryValue: null == inventoryValue ? _self.inventoryValue : inventoryValue // ignore: cast_nullable_to_non_nullable
as num,paidOrders: null == paidOrders ? _self.paidOrders : paidOrders // ignore: cast_nullable_to_non_nullable
as int,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,averageOrderValue: null == averageOrderValue ? _self.averageOrderValue : averageOrderValue // ignore: cast_nullable_to_non_nullable
as num,missingCostProductCount: null == missingCostProductCount ? _self.missingCostProductCount : missingCostProductCount // ignore: cast_nullable_to_non_nullable
as int,missingCostProducts: null == missingCostProducts ? _self.missingCostProducts : missingCostProducts // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [RevenueSummary].
extension RevenueSummaryPatterns on RevenueSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevenueSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevenueSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevenueSummary value)  $default,){
final _that = this;
switch (_that) {
case _RevenueSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevenueSummary value)?  $default,){
final _that = this;
switch (_that) {
case _RevenueSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num paidRevenue,  num monthlyRevenue,  num grossProfit,  num monthlyGrossProfit,  num estimatedNetProfit,  num soldCost,  num writeOffCost,  num stockInCost,  num inventoryValue,  int paidOrders,  int totalOrders,  num averageOrderValue,  int missingCostProductCount,  List<String> missingCostProducts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevenueSummary() when $default != null:
return $default(_that.paidRevenue,_that.monthlyRevenue,_that.grossProfit,_that.monthlyGrossProfit,_that.estimatedNetProfit,_that.soldCost,_that.writeOffCost,_that.stockInCost,_that.inventoryValue,_that.paidOrders,_that.totalOrders,_that.averageOrderValue,_that.missingCostProductCount,_that.missingCostProducts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num paidRevenue,  num monthlyRevenue,  num grossProfit,  num monthlyGrossProfit,  num estimatedNetProfit,  num soldCost,  num writeOffCost,  num stockInCost,  num inventoryValue,  int paidOrders,  int totalOrders,  num averageOrderValue,  int missingCostProductCount,  List<String> missingCostProducts)  $default,) {final _that = this;
switch (_that) {
case _RevenueSummary():
return $default(_that.paidRevenue,_that.monthlyRevenue,_that.grossProfit,_that.monthlyGrossProfit,_that.estimatedNetProfit,_that.soldCost,_that.writeOffCost,_that.stockInCost,_that.inventoryValue,_that.paidOrders,_that.totalOrders,_that.averageOrderValue,_that.missingCostProductCount,_that.missingCostProducts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num paidRevenue,  num monthlyRevenue,  num grossProfit,  num monthlyGrossProfit,  num estimatedNetProfit,  num soldCost,  num writeOffCost,  num stockInCost,  num inventoryValue,  int paidOrders,  int totalOrders,  num averageOrderValue,  int missingCostProductCount,  List<String> missingCostProducts)?  $default,) {final _that = this;
switch (_that) {
case _RevenueSummary() when $default != null:
return $default(_that.paidRevenue,_that.monthlyRevenue,_that.grossProfit,_that.monthlyGrossProfit,_that.estimatedNetProfit,_that.soldCost,_that.writeOffCost,_that.stockInCost,_that.inventoryValue,_that.paidOrders,_that.totalOrders,_that.averageOrderValue,_that.missingCostProductCount,_that.missingCostProducts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevenueSummary implements RevenueSummary {
  const _RevenueSummary({this.paidRevenue = 0, this.monthlyRevenue = 0, this.grossProfit = 0, this.monthlyGrossProfit = 0, this.estimatedNetProfit = 0, this.soldCost = 0, this.writeOffCost = 0, this.stockInCost = 0, this.inventoryValue = 0, this.paidOrders = 0, this.totalOrders = 0, this.averageOrderValue = 0, this.missingCostProductCount = 0,  List<String> missingCostProducts = const <String>[]}): _missingCostProducts = missingCostProducts;
  factory _RevenueSummary.fromJson(Map<String, dynamic> json) => _$RevenueSummaryFromJson(json);

@override@JsonKey() final  num paidRevenue;
@override@JsonKey() final  num monthlyRevenue;
@override@JsonKey() final  num grossProfit;
@override@JsonKey() final  num monthlyGrossProfit;
@override@JsonKey() final  num estimatedNetProfit;
@override@JsonKey() final  num soldCost;
@override@JsonKey() final  num writeOffCost;
@override@JsonKey() final  num stockInCost;
@override@JsonKey() final  num inventoryValue;
@override@JsonKey() final  int paidOrders;
@override@JsonKey() final  int totalOrders;
@override@JsonKey() final  num averageOrderValue;
@override@JsonKey() final  int missingCostProductCount;
/// Tên (tối đa 5) sản phẩm chưa có giá vốn.
 final  List<String> _missingCostProducts;
/// Tên (tối đa 5) sản phẩm chưa có giá vốn.
@override@JsonKey() List<String> get missingCostProducts {
  if (_missingCostProducts is EqualUnmodifiableListView) return _missingCostProducts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missingCostProducts);
}


/// Create a copy of RevenueSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueSummaryCopyWith<_RevenueSummary> get copyWith => __$RevenueSummaryCopyWithImpl<_RevenueSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueSummary&&(identical(other.paidRevenue, paidRevenue) || other.paidRevenue == paidRevenue)&&(identical(other.monthlyRevenue, monthlyRevenue) || other.monthlyRevenue == monthlyRevenue)&&(identical(other.grossProfit, grossProfit) || other.grossProfit == grossProfit)&&(identical(other.monthlyGrossProfit, monthlyGrossProfit) || other.monthlyGrossProfit == monthlyGrossProfit)&&(identical(other.estimatedNetProfit, estimatedNetProfit) || other.estimatedNetProfit == estimatedNetProfit)&&(identical(other.soldCost, soldCost) || other.soldCost == soldCost)&&(identical(other.writeOffCost, writeOffCost) || other.writeOffCost == writeOffCost)&&(identical(other.stockInCost, stockInCost) || other.stockInCost == stockInCost)&&(identical(other.inventoryValue, inventoryValue) || other.inventoryValue == inventoryValue)&&(identical(other.paidOrders, paidOrders) || other.paidOrders == paidOrders)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders)&&(identical(other.averageOrderValue, averageOrderValue) || other.averageOrderValue == averageOrderValue)&&(identical(other.missingCostProductCount, missingCostProductCount) || other.missingCostProductCount == missingCostProductCount)&&const DeepCollectionEquality().equals(other.missingCostProducts, _missingCostProducts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,paidRevenue,monthlyRevenue,grossProfit,monthlyGrossProfit,estimatedNetProfit,soldCost,writeOffCost,stockInCost,inventoryValue,paidOrders,totalOrders,averageOrderValue,missingCostProductCount,const DeepCollectionEquality().hash(_missingCostProducts));
}

@override
String toString() {
    return 'RevenueSummary(paidRevenue: $paidRevenue, monthlyRevenue: $monthlyRevenue, grossProfit: $grossProfit, monthlyGrossProfit: $monthlyGrossProfit, estimatedNetProfit: $estimatedNetProfit, soldCost: $soldCost, writeOffCost: $writeOffCost, stockInCost: $stockInCost, inventoryValue: $inventoryValue, paidOrders: $paidOrders, totalOrders: $totalOrders, averageOrderValue: $averageOrderValue, missingCostProductCount: $missingCostProductCount, missingCostProducts: $missingCostProducts)';
}


}

/// @nodoc
abstract mixin class _$RevenueSummaryCopyWith<$Res> implements $RevenueSummaryCopyWith<$Res> {
  factory _$RevenueSummaryCopyWith(_RevenueSummary value, $Res Function(_RevenueSummary) _then) = __$RevenueSummaryCopyWithImpl;
@override @useResult
$Res call({
 num paidRevenue, num monthlyRevenue, num grossProfit, num monthlyGrossProfit, num estimatedNetProfit, num soldCost, num writeOffCost, num stockInCost, num inventoryValue, int paidOrders, int totalOrders, num averageOrderValue, int missingCostProductCount, List<String> missingCostProducts
});




}
/// @nodoc
class __$RevenueSummaryCopyWithImpl<$Res>
    implements _$RevenueSummaryCopyWith<$Res> {
  __$RevenueSummaryCopyWithImpl(this._self, this._then);

  final _RevenueSummary _self;
  final $Res Function(_RevenueSummary) _then;

/// Create a copy of RevenueSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paidRevenue = null,Object? monthlyRevenue = null,Object? grossProfit = null,Object? monthlyGrossProfit = null,Object? estimatedNetProfit = null,Object? soldCost = null,Object? writeOffCost = null,Object? stockInCost = null,Object? inventoryValue = null,Object? paidOrders = null,Object? totalOrders = null,Object? averageOrderValue = null,Object? missingCostProductCount = null,Object? missingCostProducts = null,}) {
  return _then(_RevenueSummary(
paidRevenue: null == paidRevenue ? _self.paidRevenue : paidRevenue // ignore: cast_nullable_to_non_nullable
as num,monthlyRevenue: null == monthlyRevenue ? _self.monthlyRevenue : monthlyRevenue // ignore: cast_nullable_to_non_nullable
as num,grossProfit: null == grossProfit ? _self.grossProfit : grossProfit // ignore: cast_nullable_to_non_nullable
as num,monthlyGrossProfit: null == monthlyGrossProfit ? _self.monthlyGrossProfit : monthlyGrossProfit // ignore: cast_nullable_to_non_nullable
as num,estimatedNetProfit: null == estimatedNetProfit ? _self.estimatedNetProfit : estimatedNetProfit // ignore: cast_nullable_to_non_nullable
as num,soldCost: null == soldCost ? _self.soldCost : soldCost // ignore: cast_nullable_to_non_nullable
as num,writeOffCost: null == writeOffCost ? _self.writeOffCost : writeOffCost // ignore: cast_nullable_to_non_nullable
as num,stockInCost: null == stockInCost ? _self.stockInCost : stockInCost // ignore: cast_nullable_to_non_nullable
as num,inventoryValue: null == inventoryValue ? _self.inventoryValue : inventoryValue // ignore: cast_nullable_to_non_nullable
as num,paidOrders: null == paidOrders ? _self.paidOrders : paidOrders // ignore: cast_nullable_to_non_nullable
as int,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,averageOrderValue: null == averageOrderValue ? _self.averageOrderValue : averageOrderValue // ignore: cast_nullable_to_non_nullable
as num,missingCostProductCount: null == missingCostProductCount ? _self.missingCostProductCount : missingCostProductCount // ignore: cast_nullable_to_non_nullable
as int,missingCostProducts: null == missingCostProducts ? _self._missingCostProducts : missingCostProducts // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$StoreRevenue {

@StoreRefConverter() EntityRef<Store>? get store; int get orderCount; int get paidOrderCount;/// Doanh thu đã thu (tổng online + offline).
 num get revenue; num get onlineRevenue; num get offlineRevenue; num get soldCost; num get grossProfit; num get writeOffCost; num get stockInCost; num get estimatedNetProfit; num get inventoryValue; int get totalStockUnits;
/// Create a copy of StoreRevenue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreRevenueCopyWith<StoreRevenue> get copyWith => _$StoreRevenueCopyWithImpl<StoreRevenue>(this as StoreRevenue, _$identity);

  /// Serializes this StoreRevenue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StoreRevenue;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreRevenue&&(identical(other.store, _this.store) || other.store == _this.store)&&(identical(other.orderCount, _this.orderCount) || other.orderCount == _this.orderCount)&&(identical(other.paidOrderCount, _this.paidOrderCount) || other.paidOrderCount == _this.paidOrderCount)&&(identical(other.revenue, _this.revenue) || other.revenue == _this.revenue)&&(identical(other.onlineRevenue, _this.onlineRevenue) || other.onlineRevenue == _this.onlineRevenue)&&(identical(other.offlineRevenue, _this.offlineRevenue) || other.offlineRevenue == _this.offlineRevenue)&&(identical(other.soldCost, _this.soldCost) || other.soldCost == _this.soldCost)&&(identical(other.grossProfit, _this.grossProfit) || other.grossProfit == _this.grossProfit)&&(identical(other.writeOffCost, _this.writeOffCost) || other.writeOffCost == _this.writeOffCost)&&(identical(other.stockInCost, _this.stockInCost) || other.stockInCost == _this.stockInCost)&&(identical(other.estimatedNetProfit, _this.estimatedNetProfit) || other.estimatedNetProfit == _this.estimatedNetProfit)&&(identical(other.inventoryValue, _this.inventoryValue) || other.inventoryValue == _this.inventoryValue)&&(identical(other.totalStockUnits, _this.totalStockUnits) || other.totalStockUnits == _this.totalStockUnits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StoreRevenue;
  return Object.hash(runtimeType,_this.store,_this.orderCount,_this.paidOrderCount,_this.revenue,_this.onlineRevenue,_this.offlineRevenue,_this.soldCost,_this.grossProfit,_this.writeOffCost,_this.stockInCost,_this.estimatedNetProfit,_this.inventoryValue,_this.totalStockUnits);
}

@override
String toString() {
  final _this = this as StoreRevenue;
  return 'StoreRevenue(store: ${_this.store}, orderCount: ${_this.orderCount}, paidOrderCount: ${_this.paidOrderCount}, revenue: ${_this.revenue}, onlineRevenue: ${_this.onlineRevenue}, offlineRevenue: ${_this.offlineRevenue}, soldCost: ${_this.soldCost}, grossProfit: ${_this.grossProfit}, writeOffCost: ${_this.writeOffCost}, stockInCost: ${_this.stockInCost}, estimatedNetProfit: ${_this.estimatedNetProfit}, inventoryValue: ${_this.inventoryValue}, totalStockUnits: ${_this.totalStockUnits})';
}


}

/// @nodoc
abstract mixin class $StoreRevenueCopyWith<$Res>  {
  factory $StoreRevenueCopyWith(StoreRevenue value, $Res Function(StoreRevenue) _then) = _$StoreRevenueCopyWithImpl;
@useResult
$Res call({
@StoreRefConverter() EntityRef<Store>? store, int orderCount, int paidOrderCount, num revenue, num onlineRevenue, num offlineRevenue, num soldCost, num grossProfit, num writeOffCost, num stockInCost, num estimatedNetProfit, num inventoryValue, int totalStockUnits
});




}
/// @nodoc
class _$StoreRevenueCopyWithImpl<$Res>
    implements $StoreRevenueCopyWith<$Res> {
  _$StoreRevenueCopyWithImpl(this._self, this._then);

  final StoreRevenue _self;
  final $Res Function(StoreRevenue) _then;

/// Create a copy of StoreRevenue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? store = freezed,Object? orderCount = null,Object? paidOrderCount = null,Object? revenue = null,Object? onlineRevenue = null,Object? offlineRevenue = null,Object? soldCost = null,Object? grossProfit = null,Object? writeOffCost = null,Object? stockInCost = null,Object? estimatedNetProfit = null,Object? inventoryValue = null,Object? totalStockUnits = null,}) {
  return _then(StoreRevenue(
store: freezed == store ? _self.store : store // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,orderCount: null == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as int,paidOrderCount: null == paidOrderCount ? _self.paidOrderCount : paidOrderCount // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as num,onlineRevenue: null == onlineRevenue ? _self.onlineRevenue : onlineRevenue // ignore: cast_nullable_to_non_nullable
as num,offlineRevenue: null == offlineRevenue ? _self.offlineRevenue : offlineRevenue // ignore: cast_nullable_to_non_nullable
as num,soldCost: null == soldCost ? _self.soldCost : soldCost // ignore: cast_nullable_to_non_nullable
as num,grossProfit: null == grossProfit ? _self.grossProfit : grossProfit // ignore: cast_nullable_to_non_nullable
as num,writeOffCost: null == writeOffCost ? _self.writeOffCost : writeOffCost // ignore: cast_nullable_to_non_nullable
as num,stockInCost: null == stockInCost ? _self.stockInCost : stockInCost // ignore: cast_nullable_to_non_nullable
as num,estimatedNetProfit: null == estimatedNetProfit ? _self.estimatedNetProfit : estimatedNetProfit // ignore: cast_nullable_to_non_nullable
as num,inventoryValue: null == inventoryValue ? _self.inventoryValue : inventoryValue // ignore: cast_nullable_to_non_nullable
as num,totalStockUnits: null == totalStockUnits ? _self.totalStockUnits : totalStockUnits // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StoreRevenue].
extension StoreRevenuePatterns on StoreRevenue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreRevenue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreRevenue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreRevenue value)  $default,){
final _that = this;
switch (_that) {
case _StoreRevenue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreRevenue value)?  $default,){
final _that = this;
switch (_that) {
case _StoreRevenue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@StoreRefConverter()  EntityRef<Store>? store,  int orderCount,  int paidOrderCount,  num revenue,  num onlineRevenue,  num offlineRevenue,  num soldCost,  num grossProfit,  num writeOffCost,  num stockInCost,  num estimatedNetProfit,  num inventoryValue,  int totalStockUnits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreRevenue() when $default != null:
return $default(_that.store,_that.orderCount,_that.paidOrderCount,_that.revenue,_that.onlineRevenue,_that.offlineRevenue,_that.soldCost,_that.grossProfit,_that.writeOffCost,_that.stockInCost,_that.estimatedNetProfit,_that.inventoryValue,_that.totalStockUnits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@StoreRefConverter()  EntityRef<Store>? store,  int orderCount,  int paidOrderCount,  num revenue,  num onlineRevenue,  num offlineRevenue,  num soldCost,  num grossProfit,  num writeOffCost,  num stockInCost,  num estimatedNetProfit,  num inventoryValue,  int totalStockUnits)  $default,) {final _that = this;
switch (_that) {
case _StoreRevenue():
return $default(_that.store,_that.orderCount,_that.paidOrderCount,_that.revenue,_that.onlineRevenue,_that.offlineRevenue,_that.soldCost,_that.grossProfit,_that.writeOffCost,_that.stockInCost,_that.estimatedNetProfit,_that.inventoryValue,_that.totalStockUnits);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@StoreRefConverter()  EntityRef<Store>? store,  int orderCount,  int paidOrderCount,  num revenue,  num onlineRevenue,  num offlineRevenue,  num soldCost,  num grossProfit,  num writeOffCost,  num stockInCost,  num estimatedNetProfit,  num inventoryValue,  int totalStockUnits)?  $default,) {final _that = this;
switch (_that) {
case _StoreRevenue() when $default != null:
return $default(_that.store,_that.orderCount,_that.paidOrderCount,_that.revenue,_that.onlineRevenue,_that.offlineRevenue,_that.soldCost,_that.grossProfit,_that.writeOffCost,_that.stockInCost,_that.estimatedNetProfit,_that.inventoryValue,_that.totalStockUnits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoreRevenue extends StoreRevenue {
  const _StoreRevenue({@StoreRefConverter() this.store, this.orderCount = 0, this.paidOrderCount = 0, this.revenue = 0, this.onlineRevenue = 0, this.offlineRevenue = 0, this.soldCost = 0, this.grossProfit = 0, this.writeOffCost = 0, this.stockInCost = 0, this.estimatedNetProfit = 0, this.inventoryValue = 0, this.totalStockUnits = 0}): super._();
  factory _StoreRevenue.fromJson(Map<String, dynamic> json) => _$StoreRevenueFromJson(json);

@override@StoreRefConverter() final  EntityRef<Store>? store;
@override@JsonKey() final  int orderCount;
@override@JsonKey() final  int paidOrderCount;
/// Doanh thu đã thu (tổng online + offline).
@override@JsonKey() final  num revenue;
@override@JsonKey() final  num onlineRevenue;
@override@JsonKey() final  num offlineRevenue;
@override@JsonKey() final  num soldCost;
@override@JsonKey() final  num grossProfit;
@override@JsonKey() final  num writeOffCost;
@override@JsonKey() final  num stockInCost;
@override@JsonKey() final  num estimatedNetProfit;
@override@JsonKey() final  num inventoryValue;
@override@JsonKey() final  int totalStockUnits;

/// Create a copy of StoreRevenue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreRevenueCopyWith<_StoreRevenue> get copyWith => __$StoreRevenueCopyWithImpl<_StoreRevenue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreRevenueToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreRevenue&&(identical(other.store, store) || other.store == store)&&(identical(other.orderCount, orderCount) || other.orderCount == orderCount)&&(identical(other.paidOrderCount, paidOrderCount) || other.paidOrderCount == paidOrderCount)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.onlineRevenue, onlineRevenue) || other.onlineRevenue == onlineRevenue)&&(identical(other.offlineRevenue, offlineRevenue) || other.offlineRevenue == offlineRevenue)&&(identical(other.soldCost, soldCost) || other.soldCost == soldCost)&&(identical(other.grossProfit, grossProfit) || other.grossProfit == grossProfit)&&(identical(other.writeOffCost, writeOffCost) || other.writeOffCost == writeOffCost)&&(identical(other.stockInCost, stockInCost) || other.stockInCost == stockInCost)&&(identical(other.estimatedNetProfit, estimatedNetProfit) || other.estimatedNetProfit == estimatedNetProfit)&&(identical(other.inventoryValue, inventoryValue) || other.inventoryValue == inventoryValue)&&(identical(other.totalStockUnits, totalStockUnits) || other.totalStockUnits == totalStockUnits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,store,orderCount,paidOrderCount,revenue,onlineRevenue,offlineRevenue,soldCost,grossProfit,writeOffCost,stockInCost,estimatedNetProfit,inventoryValue,totalStockUnits);
}

@override
String toString() {
    return 'StoreRevenue(store: $store, orderCount: $orderCount, paidOrderCount: $paidOrderCount, revenue: $revenue, onlineRevenue: $onlineRevenue, offlineRevenue: $offlineRevenue, soldCost: $soldCost, grossProfit: $grossProfit, writeOffCost: $writeOffCost, stockInCost: $stockInCost, estimatedNetProfit: $estimatedNetProfit, inventoryValue: $inventoryValue, totalStockUnits: $totalStockUnits)';
}


}

/// @nodoc
abstract mixin class _$StoreRevenueCopyWith<$Res> implements $StoreRevenueCopyWith<$Res> {
  factory _$StoreRevenueCopyWith(_StoreRevenue value, $Res Function(_StoreRevenue) _then) = __$StoreRevenueCopyWithImpl;
@override @useResult
$Res call({
@StoreRefConverter() EntityRef<Store>? store, int orderCount, int paidOrderCount, num revenue, num onlineRevenue, num offlineRevenue, num soldCost, num grossProfit, num writeOffCost, num stockInCost, num estimatedNetProfit, num inventoryValue, int totalStockUnits
});




}
/// @nodoc
class __$StoreRevenueCopyWithImpl<$Res>
    implements _$StoreRevenueCopyWith<$Res> {
  __$StoreRevenueCopyWithImpl(this._self, this._then);

  final _StoreRevenue _self;
  final $Res Function(_StoreRevenue) _then;

/// Create a copy of StoreRevenue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? store = freezed,Object? orderCount = null,Object? paidOrderCount = null,Object? revenue = null,Object? onlineRevenue = null,Object? offlineRevenue = null,Object? soldCost = null,Object? grossProfit = null,Object? writeOffCost = null,Object? stockInCost = null,Object? estimatedNetProfit = null,Object? inventoryValue = null,Object? totalStockUnits = null,}) {
  return _then(_StoreRevenue(
store: freezed == store ? _self.store : store // ignore: cast_nullable_to_non_nullable
as EntityRef<Store>?,orderCount: null == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as int,paidOrderCount: null == paidOrderCount ? _self.paidOrderCount : paidOrderCount // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as num,onlineRevenue: null == onlineRevenue ? _self.onlineRevenue : onlineRevenue // ignore: cast_nullable_to_non_nullable
as num,offlineRevenue: null == offlineRevenue ? _self.offlineRevenue : offlineRevenue // ignore: cast_nullable_to_non_nullable
as num,soldCost: null == soldCost ? _self.soldCost : soldCost // ignore: cast_nullable_to_non_nullable
as num,grossProfit: null == grossProfit ? _self.grossProfit : grossProfit // ignore: cast_nullable_to_non_nullable
as num,writeOffCost: null == writeOffCost ? _self.writeOffCost : writeOffCost // ignore: cast_nullable_to_non_nullable
as num,stockInCost: null == stockInCost ? _self.stockInCost : stockInCost // ignore: cast_nullable_to_non_nullable
as num,estimatedNetProfit: null == estimatedNetProfit ? _self.estimatedNetProfit : estimatedNetProfit // ignore: cast_nullable_to_non_nullable
as num,inventoryValue: null == inventoryValue ? _self.inventoryValue : inventoryValue // ignore: cast_nullable_to_non_nullable
as num,totalStockUnits: null == totalStockUnits ? _self.totalStockUnits : totalStockUnits // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RevenueAnalytics {

 RevenueSummary get summary; List<StoreRevenue> get stores;
/// Create a copy of RevenueAnalytics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueAnalyticsCopyWith<RevenueAnalytics> get copyWith => _$RevenueAnalyticsCopyWithImpl<RevenueAnalytics>(this as RevenueAnalytics, _$identity);

  /// Serializes this RevenueAnalytics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RevenueAnalytics;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevenueAnalytics&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&const DeepCollectionEquality().equals(other.stores, _this.stores));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RevenueAnalytics;
  return Object.hash(runtimeType,_this.summary,const DeepCollectionEquality().hash(_this.stores));
}

@override
String toString() {
  final _this = this as RevenueAnalytics;
  return 'RevenueAnalytics(summary: ${_this.summary}, stores: ${_this.stores})';
}


}

/// @nodoc
abstract mixin class $RevenueAnalyticsCopyWith<$Res>  {
  factory $RevenueAnalyticsCopyWith(RevenueAnalytics value, $Res Function(RevenueAnalytics) _then) = _$RevenueAnalyticsCopyWithImpl;
@useResult
$Res call({
 RevenueSummary summary, List<StoreRevenue> stores
});


$RevenueSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$RevenueAnalyticsCopyWithImpl<$Res>
    implements $RevenueAnalyticsCopyWith<$Res> {
  _$RevenueAnalyticsCopyWithImpl(this._self, this._then);

  final RevenueAnalytics _self;
  final $Res Function(RevenueAnalytics) _then;

/// Create a copy of RevenueAnalytics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summary = null,Object? stores = null,}) {
  return _then(RevenueAnalytics(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as RevenueSummary,stores: null == stores ? _self.stores : stores // ignore: cast_nullable_to_non_nullable
as List<StoreRevenue>,
  ));
}
/// Create a copy of RevenueAnalytics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RevenueSummaryCopyWith<$Res> get summary {
  
  return $RevenueSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [RevenueAnalytics].
extension RevenueAnalyticsPatterns on RevenueAnalytics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevenueAnalytics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevenueAnalytics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevenueAnalytics value)  $default,){
final _that = this;
switch (_that) {
case _RevenueAnalytics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevenueAnalytics value)?  $default,){
final _that = this;
switch (_that) {
case _RevenueAnalytics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RevenueSummary summary,  List<StoreRevenue> stores)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevenueAnalytics() when $default != null:
return $default(_that.summary,_that.stores);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RevenueSummary summary,  List<StoreRevenue> stores)  $default,) {final _that = this;
switch (_that) {
case _RevenueAnalytics():
return $default(_that.summary,_that.stores);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RevenueSummary summary,  List<StoreRevenue> stores)?  $default,) {final _that = this;
switch (_that) {
case _RevenueAnalytics() when $default != null:
return $default(_that.summary,_that.stores);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevenueAnalytics implements RevenueAnalytics {
  const _RevenueAnalytics({this.summary = const RevenueSummary(),  List<StoreRevenue> stores = const <StoreRevenue>[]}): _stores = stores;
  factory _RevenueAnalytics.fromJson(Map<String, dynamic> json) => _$RevenueAnalyticsFromJson(json);

@override@JsonKey() final  RevenueSummary summary;
 final  List<StoreRevenue> _stores;
@override@JsonKey() List<StoreRevenue> get stores {
  if (_stores is EqualUnmodifiableListView) return _stores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stores);
}


/// Create a copy of RevenueAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueAnalyticsCopyWith<_RevenueAnalytics> get copyWith => __$RevenueAnalyticsCopyWithImpl<_RevenueAnalytics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueAnalyticsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueAnalytics&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.stores, _stores));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,summary,const DeepCollectionEquality().hash(_stores));
}

@override
String toString() {
    return 'RevenueAnalytics(summary: $summary, stores: $stores)';
}


}

/// @nodoc
abstract mixin class _$RevenueAnalyticsCopyWith<$Res> implements $RevenueAnalyticsCopyWith<$Res> {
  factory _$RevenueAnalyticsCopyWith(_RevenueAnalytics value, $Res Function(_RevenueAnalytics) _then) = __$RevenueAnalyticsCopyWithImpl;
@override @useResult
$Res call({
 RevenueSummary summary, List<StoreRevenue> stores
});


@override $RevenueSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class __$RevenueAnalyticsCopyWithImpl<$Res>
    implements _$RevenueAnalyticsCopyWith<$Res> {
  __$RevenueAnalyticsCopyWithImpl(this._self, this._then);

  final _RevenueAnalytics _self;
  final $Res Function(_RevenueAnalytics) _then;

/// Create a copy of RevenueAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summary = null,Object? stores = null,}) {
  return _then(_RevenueAnalytics(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as RevenueSummary,stores: null == stores ? _self._stores : stores // ignore: cast_nullable_to_non_nullable
as List<StoreRevenue>,
  ));
}

/// Create a copy of RevenueAnalytics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RevenueSummaryCopyWith<$Res> get summary {
  
  return $RevenueSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

// dart format on
