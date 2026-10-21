import 'package:freezed_annotation/freezed_annotation.dart';

import '../../shared/models/models.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

/// Một dòng trong giỏ hàng (lưu local). Giá là giá lúc thêm vào giỏ; server
/// tính lại khi đặt hàng.
@freezed
abstract class CartItem with _$CartItem {
  const CartItem._();

  const factory CartItem({
    required String productId,
    @Default('') String sku,
    @Default('') String name,
    @Default('') String brand,
    String? image,
    @Default(0) int unitPrice,
    @Default(1) int quantity,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  factory CartItem.fromProduct(Product product, int quantity) => CartItem(
    productId: product.id,
    sku: product.sku,
    name: product.name,
    brand: product.brand,
    image: product.coverImage,
    unitPrice: product.price,
    quantity: quantity,
  );

  int get lineTotal => unitPrice * quantity;
}
