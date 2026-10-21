import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/features/customer/catalog/catalog_filter.dart';
import 'package:gutacosmetic/features/customer/presentation/widgets/product_filter_sheet.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';

const _products = [
  Product(id: 'a', name: 'Sữa rửa mặt', brand: 'CeraVe', price: 300000),
  Product(
    id: 'b',
    name: 'Kem chống nắng',
    brand: 'La Roche-Posay',
    price: 450000,
  ),
  Product(id: 'c', name: 'Toner', brand: 'cerave', price: 150000),
  Product(id: 'd', name: 'Serum', brand: 'Vichy', price: 800000),
];

List<String> _ids(List<Product> list) => [for (final p in list) p.id];

void main() {
  test('không bật bộ lọc nâng cao → giữ nguyên thứ tự server', () {
    const f = CatalogFilter();
    expect(f.hasAdvanced, isFalse);
    expect(_ids(f.apply(_products)), ['a', 'b', 'c', 'd']);
  });

  test('lọc khoảng giá (bao gồm 2 đầu)', () {
    const f = CatalogFilter(minPrice: 150000, maxPrice: 450000);
    expect(_ids(f.apply(_products)), ['a', 'b', 'c']);
    expect(_ids(const CatalogFilter(minPrice: 450000).apply(_products)), [
      'b',
      'd',
    ]);
    expect(_ids(const CatalogFilter(maxPrice: 200000).apply(_products)), ['c']);
  });

  test('lọc thương hiệu không phân biệt hoa thường', () {
    const f = CatalogFilter(brand: 'CeraVe');
    expect(_ids(f.apply(_products)), ['a', 'c']);
  });

  test('sắp xếp theo giá', () {
    expect(
      _ids(const CatalogFilter(sort: ProductSort.priceAsc).apply(_products)),
      ['c', 'a', 'b', 'd'],
    );
    expect(
      _ids(const CatalogFilter(sort: ProductSort.priceDesc).apply(_products)),
      ['d', 'b', 'a', 'c'],
    );
  });

  test('đếm nhóm bộ lọc nâng cao; khoảng giá tính là 1', () {
    const f = CatalogFilter(
      minPrice: 1,
      maxPrice: 2,
      brand: 'Vichy',
      sort: ProductSort.priceAsc,
      skinType: 'Da dầu',
    );
    expect(f.advancedCount, 3);
  });

  test('serverQuery bỏ khoảng trắng, null → chuỗi rỗng', () {
    const f = CatalogFilter(search: '  serum ', skinType: 'Da dầu');
    expect(f.serverQuery, (search: 'serum', category: '', skinType: 'Da dầu'));
  });

  test('brandsOf gộp trùng (hoa thường) và sắp ABC', () {
    expect(brandsOf(_products), ['CeraVe', 'La Roche-Posay', 'Vichy']);
  });

  test('nhãn khoảng giá', () {
    expect(priceRangeLabel(100000, 500000), '100.000đ – 500.000đ');
    expect(priceRangeLabel(100000, null), 'Từ 100.000đ');
    expect(priceRangeLabel(null, 500000), 'Đến 500.000đ');
  });
}
