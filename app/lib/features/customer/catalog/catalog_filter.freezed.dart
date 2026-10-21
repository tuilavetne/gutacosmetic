// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CatalogFilter {

 String get search; String? get category; String? get skinType; int? get minPrice; int? get maxPrice; String? get brand; ProductSort get sort;
/// Create a copy of CatalogFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogFilterCopyWith<CatalogFilter> get copyWith => _$CatalogFilterCopyWithImpl<CatalogFilter>(this as CatalogFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CatalogFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogFilter&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.skinType, _this.skinType) || other.skinType == _this.skinType)&&(identical(other.minPrice, _this.minPrice) || other.minPrice == _this.minPrice)&&(identical(other.maxPrice, _this.maxPrice) || other.maxPrice == _this.maxPrice)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.sort, _this.sort) || other.sort == _this.sort));
}


@override
int get hashCode {
  final _this = this as CatalogFilter;
  return Object.hash(runtimeType,_this.search,_this.category,_this.skinType,_this.minPrice,_this.maxPrice,_this.brand,_this.sort);
}

@override
String toString() {
  final _this = this as CatalogFilter;
  return 'CatalogFilter(search: ${_this.search}, category: ${_this.category}, skinType: ${_this.skinType}, minPrice: ${_this.minPrice}, maxPrice: ${_this.maxPrice}, brand: ${_this.brand}, sort: ${_this.sort})';
}


}

/// @nodoc
abstract mixin class $CatalogFilterCopyWith<$Res>  {
  factory $CatalogFilterCopyWith(CatalogFilter value, $Res Function(CatalogFilter) _then) = _$CatalogFilterCopyWithImpl;
@useResult
$Res call({
 String search, String? category, String? skinType, int? minPrice, int? maxPrice, String? brand, ProductSort sort
});




}
/// @nodoc
class _$CatalogFilterCopyWithImpl<$Res>
    implements $CatalogFilterCopyWith<$Res> {
  _$CatalogFilterCopyWithImpl(this._self, this._then);

  final CatalogFilter _self;
  final $Res Function(CatalogFilter) _then;

/// Create a copy of CatalogFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? category = freezed,Object? skinType = freezed,Object? minPrice = freezed,Object? maxPrice = freezed,Object? brand = freezed,Object? sort = null,}) {
  return _then(CatalogFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,skinType: freezed == skinType ? _self.skinType : skinType // ignore: cast_nullable_to_non_nullable
as String?,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as int?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as int?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as ProductSort,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogFilter].
extension CatalogFilterPatterns on CatalogFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogFilter value)  $default,){
final _that = this;
switch (_that) {
case _CatalogFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogFilter value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String search,  String? category,  String? skinType,  int? minPrice,  int? maxPrice,  String? brand,  ProductSort sort)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogFilter() when $default != null:
return $default(_that.search,_that.category,_that.skinType,_that.minPrice,_that.maxPrice,_that.brand,_that.sort);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String search,  String? category,  String? skinType,  int? minPrice,  int? maxPrice,  String? brand,  ProductSort sort)  $default,) {final _that = this;
switch (_that) {
case _CatalogFilter():
return $default(_that.search,_that.category,_that.skinType,_that.minPrice,_that.maxPrice,_that.brand,_that.sort);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String search,  String? category,  String? skinType,  int? minPrice,  int? maxPrice,  String? brand,  ProductSort sort)?  $default,) {final _that = this;
switch (_that) {
case _CatalogFilter() when $default != null:
return $default(_that.search,_that.category,_that.skinType,_that.minPrice,_that.maxPrice,_that.brand,_that.sort);case _:
  return null;

}
}

}

/// @nodoc


class _CatalogFilter extends CatalogFilter {
  const _CatalogFilter({this.search = '', this.category, this.skinType, this.minPrice, this.maxPrice, this.brand, this.sort = ProductSort.newest}): super._();
  

@override@JsonKey() final  String search;
@override final  String? category;
@override final  String? skinType;
@override final  int? minPrice;
@override final  int? maxPrice;
@override final  String? brand;
@override@JsonKey() final  ProductSort sort;

/// Create a copy of CatalogFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogFilterCopyWith<_CatalogFilter> get copyWith => __$CatalogFilterCopyWithImpl<_CatalogFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogFilter&&(identical(other.search, search) || other.search == search)&&(identical(other.category, category) || other.category == category)&&(identical(other.skinType, skinType) || other.skinType == skinType)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.sort, sort) || other.sort == sort));
}


@override
int get hashCode {
    return Object.hash(runtimeType,search,category,skinType,minPrice,maxPrice,brand,sort);
}

@override
String toString() {
    return 'CatalogFilter(search: $search, category: $category, skinType: $skinType, minPrice: $minPrice, maxPrice: $maxPrice, brand: $brand, sort: $sort)';
}


}

/// @nodoc
abstract mixin class _$CatalogFilterCopyWith<$Res> implements $CatalogFilterCopyWith<$Res> {
  factory _$CatalogFilterCopyWith(_CatalogFilter value, $Res Function(_CatalogFilter) _then) = __$CatalogFilterCopyWithImpl;
@override @useResult
$Res call({
 String search, String? category, String? skinType, int? minPrice, int? maxPrice, String? brand, ProductSort sort
});




}
/// @nodoc
class __$CatalogFilterCopyWithImpl<$Res>
    implements _$CatalogFilterCopyWith<$Res> {
  __$CatalogFilterCopyWithImpl(this._self, this._then);

  final _CatalogFilter _self;
  final $Res Function(_CatalogFilter) _then;

/// Create a copy of CatalogFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? category = freezed,Object? skinType = freezed,Object? minPrice = freezed,Object? maxPrice = freezed,Object? brand = freezed,Object? sort = null,}) {
  return _then(_CatalogFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,skinType: freezed == skinType ? _self.skinType : skinType // ignore: cast_nullable_to_non_nullable
as String?,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as int?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as int?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as ProductSort,
  ));
}


}

// dart format on
