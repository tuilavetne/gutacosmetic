import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../shared/models/models.dart';

/// Tham số lọc phía server của `GET /products`. Chuỗi rỗng = không lọc.
typedef ProductQuery = ({String search, String category, String skinType});

const ProductQuery allProductsQuery = (search: '', category: '', skinType: '');

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepository(ref.watch(apiClientProvider)),
);

/// Danh sách sản phẩm đang bán, mới nhất trước.
final productsProvider = FutureProvider.autoDispose
    .family<List<Product>, ProductQuery>(
      (ref, query) => ref.watch(productRepositoryProvider).fetchProducts(query),
    );

/// Chi tiết một sản phẩm, kèm điểm đánh giá trung bình và số đánh giá.
final productDetailProvider = FutureProvider.autoDispose
    .family<Product, String>(
      (ref, id) => ref.watch(productRepositoryProvider).fetchProduct(id),
    );

/// Tồn kho còn bán được (`availableStock`) của sản phẩm tại từng cửa hàng.
final productStockProvider = FutureProvider.autoDispose
    .family<List<StoreStock>, String>(
      (ref, id) => ref.watch(productRepositoryProvider).fetchStoreStocks(id),
    );

class ProductRepository {
  ProductRepository(this._api);

  final ApiClient _api;

  /// `GET /products?search=&category=&skinType=`
  ///
  /// Backend tìm theo tên (không phân biệt hoa thường); lọc `skinType` có
  /// kèm sản phẩm "Da thường/Mọi loại da".
  Future<List<Product>> fetchProducts([
    ProductQuery query = allProductsQuery,
  ]) async {
    final json = await _api.get(
      '/products',
      query: {
        'search': query.search,
        'category': query.category,
        'skinType': query.skinType,
      },
    );
    return parseList(json, 'products', Product.fromJson);
  }

  /// `GET /products/:id` — có thêm `rating` (trung bình, làm tròn 1 chữ số)
  /// và `reviewCount`.
  Future<Product> fetchProduct(String id) async {
    final json = await _api.get('/products/$id');
    return Product.fromJson(requireObject(json, 'product'));
  }

  /// `GET /inventory/products?productIds=` — mỗi cửa hàng đang hoạt động một
  /// dòng (chưa từng nhập thì tồn = 0). Chi nhánh trước, kho tổng sau cùng;
  /// trong mỗi nhóm giữ thứ tự tên của backend.
  Future<List<StoreStock>> fetchStoreStocks(String productId) async {
    final json = await _api.get(
      '/inventory/products',
      query: {'productIds': productId},
    );
    final products = parseList(json, 'products', ProductInventory.fromJson);
    final stocks = [
      for (final p in products)
        if (p.product.id == productId) ...p.inventories,
    ];
    return [
      ...stocks.where((e) => !e.store.isCentral),
      ...stocks.where((e) => e.store.isCentral),
    ];
  }
}
