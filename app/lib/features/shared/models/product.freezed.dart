// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Ingredient {

/// Tên icon Ionicons — map sang Material bằng `materialIconForIonicon`.
 String? get icon; String get title; String get subtitle;
/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngredientCopyWith<Ingredient> get copyWith => _$IngredientCopyWithImpl<Ingredient>(this as Ingredient, _$identity);

  /// Serializes this Ingredient to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Ingredient;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ingredient&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.subtitle, _this.subtitle) || other.subtitle == _this.subtitle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Ingredient;
  return Object.hash(runtimeType,_this.icon,_this.title,_this.subtitle);
}

@override
String toString() {
  final _this = this as Ingredient;
  return 'Ingredient(icon: ${_this.icon}, title: ${_this.title}, subtitle: ${_this.subtitle})';
}


}

/// @nodoc
abstract mixin class $IngredientCopyWith<$Res>  {
  factory $IngredientCopyWith(Ingredient value, $Res Function(Ingredient) _then) = _$IngredientCopyWithImpl;
@useResult
$Res call({
 String? icon, String title, String subtitle
});




}
/// @nodoc
class _$IngredientCopyWithImpl<$Res>
    implements $IngredientCopyWith<$Res> {
  _$IngredientCopyWithImpl(this._self, this._then);

  final Ingredient _self;
  final $Res Function(Ingredient) _then;

/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? icon = freezed,Object? title = null,Object? subtitle = null,}) {
  return _then(Ingredient(
icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Ingredient].
extension IngredientPatterns on Ingredient {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Ingredient value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Ingredient value)  $default,){
final _that = this;
switch (_that) {
case _Ingredient():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Ingredient value)?  $default,){
final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? icon,  String title,  String subtitle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
return $default(_that.icon,_that.title,_that.subtitle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? icon,  String title,  String subtitle)  $default,) {final _that = this;
switch (_that) {
case _Ingredient():
return $default(_that.icon,_that.title,_that.subtitle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? icon,  String title,  String subtitle)?  $default,) {final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
return $default(_that.icon,_that.title,_that.subtitle);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Ingredient implements Ingredient {
  const _Ingredient({this.icon, this.title = '', this.subtitle = ''});
  factory _Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);

/// Tên icon Ionicons — map sang Material bằng `materialIconForIonicon`.
@override final  String? icon;
@override@JsonKey() final  String title;
@override@JsonKey() final  String subtitle;

/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IngredientCopyWith<_Ingredient> get copyWith => __$IngredientCopyWithImpl<_Ingredient>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IngredientToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ingredient&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,icon,title,subtitle);
}

@override
String toString() {
    return 'Ingredient(icon: $icon, title: $title, subtitle: $subtitle)';
}


}

/// @nodoc
abstract mixin class _$IngredientCopyWith<$Res> implements $IngredientCopyWith<$Res> {
  factory _$IngredientCopyWith(_Ingredient value, $Res Function(_Ingredient) _then) = __$IngredientCopyWithImpl;
@override @useResult
$Res call({
 String? icon, String title, String subtitle
});




}
/// @nodoc
class __$IngredientCopyWithImpl<$Res>
    implements _$IngredientCopyWith<$Res> {
  __$IngredientCopyWithImpl(this._self, this._then);

  final _Ingredient _self;
  final $Res Function(_Ingredient) _then;

/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? icon = freezed,Object? title = null,Object? subtitle = null,}) {
  return _then(_Ingredient(
icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Product {

@JsonKey(name: '_id') String get id; String get sku; String get name; String get brand; int get price; int? get costPrice; int? get originalPrice; String? get description; String? get image; List<String> get images; String? get category; List<String> get skinTypes; String? get volume; String? get origin;/// Chuỗi mô tả, ví dụ "36 tháng kể từ NSX".
 String? get expiryDate; List<Ingredient> get ingredients; bool get isActive;/// Chỉ có ở `GET /products/:id`.
 double? get rating; int? get reviewCount;/// Số đánh giá theo mức sao, khóa `"1"`…`"5"` — chỉ có ở
/// `GET /products/:id`.
 Map<String, int> get ratingBreakdown; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Product;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sku, _this.sku) || other.sku == _this.sku)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.costPrice, _this.costPrice) || other.costPrice == _this.costPrice)&&(identical(other.originalPrice, _this.originalPrice) || other.originalPrice == _this.originalPrice)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.image, _this.image) || other.image == _this.image)&&const DeepCollectionEquality().equals(other.images, _this.images)&&(identical(other.category, _this.category) || other.category == _this.category)&&const DeepCollectionEquality().equals(other.skinTypes, _this.skinTypes)&&(identical(other.volume, _this.volume) || other.volume == _this.volume)&&(identical(other.origin, _this.origin) || other.origin == _this.origin)&&(identical(other.expiryDate, _this.expiryDate) || other.expiryDate == _this.expiryDate)&&const DeepCollectionEquality().equals(other.ingredients, _this.ingredients)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.reviewCount, _this.reviewCount) || other.reviewCount == _this.reviewCount)&&const DeepCollectionEquality().equals(other.ratingBreakdown, _this.ratingBreakdown)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Product;
  return Object.hashAll([runtimeType,_this.id,_this.sku,_this.name,_this.brand,_this.price,_this.costPrice,_this.originalPrice,_this.description,_this.image,const DeepCollectionEquality().hash(_this.images),_this.category,const DeepCollectionEquality().hash(_this.skinTypes),_this.volume,_this.origin,_this.expiryDate,const DeepCollectionEquality().hash(_this.ingredients),_this.isActive,_this.rating,_this.reviewCount,const DeepCollectionEquality().hash(_this.ratingBreakdown),_this.createdAt,_this.updatedAt]);
}

@override
String toString() {
  final _this = this as Product;
  return 'Product(id: ${_this.id}, sku: ${_this.sku}, name: ${_this.name}, brand: ${_this.brand}, price: ${_this.price}, costPrice: ${_this.costPrice}, originalPrice: ${_this.originalPrice}, description: ${_this.description}, image: ${_this.image}, images: ${_this.images}, category: ${_this.category}, skinTypes: ${_this.skinTypes}, volume: ${_this.volume}, origin: ${_this.origin}, expiryDate: ${_this.expiryDate}, ingredients: ${_this.ingredients}, isActive: ${_this.isActive}, rating: ${_this.rating}, reviewCount: ${_this.reviewCount}, ratingBreakdown: ${_this.ratingBreakdown}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String sku, String name, String brand, int price, int? costPrice, int? originalPrice, String? description, String? image, List<String> images, String? category, List<String> skinTypes, String? volume, String? origin, String? expiryDate, List<Ingredient> ingredients, bool isActive, double? rating, int? reviewCount, Map<String, int> ratingBreakdown, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sku = null,Object? name = null,Object? brand = null,Object? price = null,Object? costPrice = freezed,Object? originalPrice = freezed,Object? description = freezed,Object? image = freezed,Object? images = null,Object? category = freezed,Object? skinTypes = null,Object? volume = freezed,Object? origin = freezed,Object? expiryDate = freezed,Object? ingredients = null,Object? isActive = null,Object? rating = freezed,Object? reviewCount = freezed,Object? ratingBreakdown = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,costPrice: freezed == costPrice ? _self.costPrice : costPrice // ignore: cast_nullable_to_non_nullable
as int?,originalPrice: freezed == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,skinTypes: null == skinTypes ? _self.skinTypes : skinTypes // ignore: cast_nullable_to_non_nullable
as List<String>,volume: freezed == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as String?,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as String?,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<Ingredient>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,reviewCount: freezed == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int?,ratingBreakdown: null == ratingBreakdown ? _self.ratingBreakdown : ratingBreakdown // ignore: cast_nullable_to_non_nullable
as Map<String, int>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String sku,  String name,  String brand,  int price,  int? costPrice,  int? originalPrice,  String? description,  String? image,  List<String> images,  String? category,  List<String> skinTypes,  String? volume,  String? origin,  String? expiryDate,  List<Ingredient> ingredients,  bool isActive,  double? rating,  int? reviewCount,  Map<String, int> ratingBreakdown,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.sku,_that.name,_that.brand,_that.price,_that.costPrice,_that.originalPrice,_that.description,_that.image,_that.images,_that.category,_that.skinTypes,_that.volume,_that.origin,_that.expiryDate,_that.ingredients,_that.isActive,_that.rating,_that.reviewCount,_that.ratingBreakdown,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String sku,  String name,  String brand,  int price,  int? costPrice,  int? originalPrice,  String? description,  String? image,  List<String> images,  String? category,  List<String> skinTypes,  String? volume,  String? origin,  String? expiryDate,  List<Ingredient> ingredients,  bool isActive,  double? rating,  int? reviewCount,  Map<String, int> ratingBreakdown,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.sku,_that.name,_that.brand,_that.price,_that.costPrice,_that.originalPrice,_that.description,_that.image,_that.images,_that.category,_that.skinTypes,_that.volume,_that.origin,_that.expiryDate,_that.ingredients,_that.isActive,_that.rating,_that.reviewCount,_that.ratingBreakdown,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String sku,  String name,  String brand,  int price,  int? costPrice,  int? originalPrice,  String? description,  String? image,  List<String> images,  String? category,  List<String> skinTypes,  String? volume,  String? origin,  String? expiryDate,  List<Ingredient> ingredients,  bool isActive,  double? rating,  int? reviewCount,  Map<String, int> ratingBreakdown,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.sku,_that.name,_that.brand,_that.price,_that.costPrice,_that.originalPrice,_that.description,_that.image,_that.images,_that.category,_that.skinTypes,_that.volume,_that.origin,_that.expiryDate,_that.ingredients,_that.isActive,_that.rating,_that.reviewCount,_that.ratingBreakdown,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product extends Product {
  const _Product({@JsonKey(name: '_id') required this.id, this.sku = '', this.name = '', this.brand = '', this.price = 0, this.costPrice, this.originalPrice, this.description, this.image,  List<String> images = const <String>[], this.category,  List<String> skinTypes = const <String>[], this.volume, this.origin, this.expiryDate,  List<Ingredient> ingredients = const <Ingredient>[], this.isActive = true, this.rating, this.reviewCount,  Map<String, int> ratingBreakdown = const <String, int>{}, this.createdAt, this.updatedAt}): _images = images,_skinTypes = skinTypes,_ingredients = ingredients,_ratingBreakdown = ratingBreakdown,super._();
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override@JsonKey() final  String sku;
@override@JsonKey() final  String name;
@override@JsonKey() final  String brand;
@override@JsonKey() final  int price;
@override final  int? costPrice;
@override final  int? originalPrice;
@override final  String? description;
@override final  String? image;
 final  List<String> _images;
@override@JsonKey() List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override final  String? category;
 final  List<String> _skinTypes;
@override@JsonKey() List<String> get skinTypes {
  if (_skinTypes is EqualUnmodifiableListView) return _skinTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skinTypes);
}

@override final  String? volume;
@override final  String? origin;
/// Chuỗi mô tả, ví dụ "36 tháng kể từ NSX".
@override final  String? expiryDate;
 final  List<Ingredient> _ingredients;
@override@JsonKey() List<Ingredient> get ingredients {
  if (_ingredients is EqualUnmodifiableListView) return _ingredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredients);
}

@override@JsonKey() final  bool isActive;
/// Chỉ có ở `GET /products/:id`.
@override final  double? rating;
@override final  int? reviewCount;
/// Số đánh giá theo mức sao, khóa `"1"`…`"5"` — chỉ có ở
/// `GET /products/:id`.
 final  Map<String, int> _ratingBreakdown;
/// Số đánh giá theo mức sao, khóa `"1"`…`"5"` — chỉ có ở
/// `GET /products/:id`.
@override@JsonKey() Map<String, int> get ratingBreakdown {
  if (_ratingBreakdown is EqualUnmodifiableMapView) return _ratingBreakdown;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_ratingBreakdown);
}

@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.price, price) || other.price == price)&&(identical(other.costPrice, costPrice) || other.costPrice == costPrice)&&(identical(other.originalPrice, originalPrice) || other.originalPrice == originalPrice)&&(identical(other.description, description) || other.description == description)&&(identical(other.image, image) || other.image == image)&&const DeepCollectionEquality().equals(other.images, _images)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.skinTypes, _skinTypes)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&const DeepCollectionEquality().equals(other.ingredients, _ingredients)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&const DeepCollectionEquality().equals(other.ratingBreakdown, _ratingBreakdown)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,sku,name,brand,price,costPrice,originalPrice,description,image,const DeepCollectionEquality().hash(_images),category,const DeepCollectionEquality().hash(_skinTypes),volume,origin,expiryDate,const DeepCollectionEquality().hash(_ingredients),isActive,rating,reviewCount,const DeepCollectionEquality().hash(_ratingBreakdown),createdAt,updatedAt]);
}

@override
String toString() {
    return 'Product(id: $id, sku: $sku, name: $name, brand: $brand, price: $price, costPrice: $costPrice, originalPrice: $originalPrice, description: $description, image: $image, images: $images, category: $category, skinTypes: $skinTypes, volume: $volume, origin: $origin, expiryDate: $expiryDate, ingredients: $ingredients, isActive: $isActive, rating: $rating, reviewCount: $reviewCount, ratingBreakdown: $ratingBreakdown, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String sku, String name, String brand, int price, int? costPrice, int? originalPrice, String? description, String? image, List<String> images, String? category, List<String> skinTypes, String? volume, String? origin, String? expiryDate, List<Ingredient> ingredients, bool isActive, double? rating, int? reviewCount, Map<String, int> ratingBreakdown, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sku = null,Object? name = null,Object? brand = null,Object? price = null,Object? costPrice = freezed,Object? originalPrice = freezed,Object? description = freezed,Object? image = freezed,Object? images = null,Object? category = freezed,Object? skinTypes = null,Object? volume = freezed,Object? origin = freezed,Object? expiryDate = freezed,Object? ingredients = null,Object? isActive = null,Object? rating = freezed,Object? reviewCount = freezed,Object? ratingBreakdown = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,costPrice: freezed == costPrice ? _self.costPrice : costPrice // ignore: cast_nullable_to_non_nullable
as int?,originalPrice: freezed == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,skinTypes: null == skinTypes ? _self._skinTypes : skinTypes // ignore: cast_nullable_to_non_nullable
as List<String>,volume: freezed == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as String?,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as String?,ingredients: null == ingredients ? _self._ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<Ingredient>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,reviewCount: freezed == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int?,ratingBreakdown: null == ratingBreakdown ? _self._ratingBreakdown : ratingBreakdown // ignore: cast_nullable_to_non_nullable
as Map<String, int>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
