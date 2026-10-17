import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../session/session_controller.dart';
import '../../shared/models/models.dart';
import '../data/product_repository.dart';

part 'catalog_filter.freezed.dart';

enum ProductSort {
  newest,
  priceAsc,
  priceDesc;

  String get label => switch (this) {
    newest => 'Mới nhất',
    priceAsc => 'Giá tăng dần',
    priceDesc => 'Giá giảm dần',
  };
}

/// Bộ lọc màn Danh mục.
///
/// [search], [category], [skinType] lọc phía server; khoảng giá, thương hiệu
/// và sắp xếp ("bộ lọc nâng cao") lọc trên danh sách đã tải.
@freezed
abstract class CatalogFilter with _$CatalogFilter {
  const CatalogFilter._();

  const factory CatalogFilter({
    @Default('') String search,
    String? category,
    String? skinType,
    int? minPrice,
    int? maxPrice,
    String? brand,
    @Default(ProductSort.newest) ProductSort sort,
  }) = _CatalogFilter;

  ProductQuery get serverQuery => (
    search: search.trim(),
    category: category ?? '',
    skinType: skinType ?? '',
  );

  bool get hasPriceRange => minPrice != null || maxPrice != null;

  /// Số nhóm bộ lọc nâng cao đang bật (badge nút lọc).
  int get advancedCount => [
    hasPriceRange,
    brand != null,
    sort != ProductSort.newest,
  ].where((on) => on).length;

  bool get hasAdvanced => advancedCount > 0;

  /// Áp bộ lọc nâng cao và sắp xếp lên kết quả từ server.
  List<Product> apply(List<Product> products) {
    final brandKey = brand?.toLowerCase();
    final result = products.where((p) {
      if (minPrice != null && p.price < minPrice!) return false;
      if (maxPrice != null && p.price > maxPrice!) return false;
      if (brandKey != null && p.brand.toLowerCase() != brandKey) return false;
      return true;
    }).toList();
    switch (sort) {
      case ProductSort.newest:
        break; // Server đã sắp xếp mới nhất trước.
      case ProductSort.priceAsc:
        result.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceDesc:
        result.sort((a, b) => b.price.compareTo(a.price));
    }
    return result;
  }
}

/// Thương hiệu có trong [products] (để chọn trong bộ lọc), sắp theo ABC.
List<String> brandsOf(Iterable<Product> products) {
  final byKey = <String, String>{};
  for (final p in products) {
    final name = p.brand.trim();
    if (name.isNotEmpty) byKey.putIfAbsent(name.toLowerCase(), () => name);
  }
  return byKey.values.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
}

final catalogFilterProvider =
    NotifierProvider<CatalogFilterController, CatalogFilter>(
      CatalogFilterController.new,
    );

/// Dùng chung giữa Trang chủ (chọn danh mục / tìm kiếm) và tab Danh mục.
/// Reset khi đổi tài khoản.
class CatalogFilterController extends Notifier<CatalogFilter> {
  @override
  CatalogFilter build() {
    ref.watch(currentUserProvider.select((u) => u?.id));
    return const CatalogFilter();
  }

  /// Mở Danh mục với điều kiện mới, xóa các bộ lọc cũ.
  void browse({String? category, String search = ''}) =>
      state = CatalogFilter(category: category, search: search.trim());

  void setSearch(String value) => state = state.copyWith(search: value.trim());

  void setCategory(String? value) => state = state.copyWith(category: value);

  void setSkinType(String? value) => state = state.copyWith(skinType: value);

  void applyAdvanced({
    int? minPrice,
    int? maxPrice,
    String? brand,
    ProductSort sort = ProductSort.newest,
  }) => state = state.copyWith(
    minPrice: minPrice,
    maxPrice: maxPrice,
    brand: brand,
    sort: sort,
  );

  void clearPriceRange() =>
      state = state.copyWith(minPrice: null, maxPrice: null);

  void clearBrand() => state = state.copyWith(brand: null);

  void clearSort() => state = state.copyWith(sort: ProductSort.newest);

  void clearAdvanced() => state = state.copyWith(
    minPrice: null,
    maxPrice: null,
    brand: null,
    sort: ProductSort.newest,
  );
}
