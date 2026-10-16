import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Ingredient with _$Ingredient {
  const factory Ingredient({
    /// Tên icon Ionicons — map sang Material bằng `materialIconForIonicon`.
    String? icon,
    @Default('') String title,
    @Default('') String subtitle,
  }) = _Ingredient;

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);
}

/// Thông tin sản phẩm (không chứa tồn kho).
@freezed
abstract class Product with _$Product {
  const Product._();

  const factory Product({
    @JsonKey(name: '_id') required String id,
    @Default('') String sku,
    @Default('') String name,
    @Default('') String brand,
    @Default(0) int price,
    int? costPrice,
    int? originalPrice,
    String? description,
    String? image,
    @Default(<String>[]) List<String> images,
    String? category,
    @Default(<String>[]) List<String> skinTypes,
    String? volume,
    String? origin,

    /// Chuỗi mô tả, ví dụ "36 tháng kể từ NSX".
    String? expiryDate,
    @Default(<Ingredient>[]) List<Ingredient> ingredients,
    @Default(true) bool isActive,

    /// Chỉ có ở `GET /products/:id`.
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  /// Ảnh đại diện: `image` hoặc ảnh đầu tiên trong `images`.
  String? get coverImage {
    if (image != null && image!.isNotEmpty) return image;
    return images.isNotEmpty ? images.first : null;
  }

  /// Toàn bộ ảnh cho carousel, không trùng lặp.
  List<String> get gallery => {
    if (image != null && image!.isNotEmpty) image!,
    ...images.where((e) => e.isNotEmpty),
  }.toList();

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
}
