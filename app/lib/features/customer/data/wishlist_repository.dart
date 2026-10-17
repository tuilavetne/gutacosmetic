import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../shared/models/models.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>(
  (ref) => WishlistRepository(ref.watch(apiClientProvider)),
);

/// `/wishlist` — chỉ CUSTOMER.
class WishlistRepository {
  WishlistRepository(this._api);

  final ApiClient _api;

  /// `GET /wishlist` — sản phẩm đã populate, bỏ sản phẩm ngừng bán.
  Future<List<Product>> fetchWishlist() async {
    final json = await _api.get('/wishlist');
    return parseList(json, 'products', Product.fromJson);
  }

  /// `POST /wishlist/toggle` → `true` nếu sau thao tác sản phẩm đang được thích.
  Future<bool> toggle(String productId) async {
    final json = await _api.post(
      '/wishlist/toggle',
      data: {'productId': productId},
    );
    return json['isLiked'] == true;
  }
}
