import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/features/customer/catalog/rating_summary.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';

const _store = Store(id: 's1', name: 'Chi nhánh 1');

void main() {
  test('lấy điểm TB, số đánh giá và phân bố sao từ backend', () {
    final product = Product.fromJson({
      '_id': 'p',
      'rating': 4.5,
      'reviewCount': 4,
      'ratingBreakdown': {'1': 0, '2': 0, '3': 1, '4': 0, '5': 3},
    });
    final s = RatingSummary.of(product);
    expect(s.average, 4.5);
    expect(s.averageLabel, '4,5');
    expect(s.count, 4);
    expect(s.hasBreakdown, isTrue);
    expect(s.countOf(5), 3);
    expect(s.countOf(4), 0);
    expect(s.fractionOf(5), 0.75);
    expect(s.fractionOf(3), 0.25);
  });

  test('bỏ khóa sao không hợp lệ; thiếu reviewCount thì cộng từ phân bố', () {
    const product = Product(
      id: 'p',
      rating: 4,
      ratingBreakdown: {'4': 2, '9': 5, 'x': 1},
    );
    final s = RatingSummary.of(product);
    expect(s.count, 2);
    expect(s.starCounts, {4: 2});
  });

  test('chưa có đánh giá / backend cũ không có phân bố', () {
    expect(
      RatingSummary.of(const Product(id: 'p', rating: 0, reviewCount: 0)),
      same(RatingSummary.empty),
    );
    expect(RatingSummary.empty.fractionOf(5), 0);

    final old = RatingSummary.of(
      const Product(id: 'p', rating: 3.7, reviewCount: 3),
    );
    expect(old.hasReviews, isTrue);
    expect(old.hasBreakdown, isFalse);
    expect(old.fractionOf(5), 0);
  });

  test('trạng thái tồn kho theo availableStock', () {
    const out = StoreStock(store: _store, totalStock: 3, reservedStock: 3);
    expect(out.isOutOfStock, isTrue);
    expect(out.isLowStock, isFalse);

    const low = StoreStock(store: _store, availableStock: 5);
    expect(low.isLowStock, isTrue);

    const plenty = StoreStock(
      store: _store,
      availableStock: 6,
      lowStockThreshold: 5,
    );
    expect(plenty.isOutOfStock, isFalse);
    expect(plenty.isLowStock, isFalse);
  });
}
