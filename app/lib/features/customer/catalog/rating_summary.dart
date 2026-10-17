import '../../shared/models/models.dart';

/// Điểm trung bình và phân bố số sao của một sản phẩm — lấy từ số liệu
/// backend tổng hợp ở `GET /products/:id` (`rating`, `reviewCount`,
/// `ratingBreakdown`), không cần tải hết danh sách đánh giá.
class RatingSummary {
  const RatingSummary({
    required this.average,
    required this.count,
    this.starCounts = const {},
  });

  factory RatingSummary.of(Product product) {
    final starCounts = <int, int>{
      for (final MapEntry(:key, :value) in product.ratingBreakdown.entries)
        if (int.tryParse(key) case final star?
            when star >= 1 && star <= 5 && value > 0)
          star: value,
    };
    final count =
        product.reviewCount ?? starCounts.values.fold<int>(0, (s, e) => s + e);
    if (count <= 0) return empty;
    return RatingSummary(
      average: product.rating ?? 0,
      count: count,
      starCounts: starCounts,
    );
  }

  static const empty = RatingSummary(average: 0, count: 0);

  final double average;
  final int count;

  /// Số đánh giá theo từng mức sao (1–5).
  final Map<int, int> starCounts;

  bool get hasReviews => count > 0;

  /// Backend có trả phân bố sao không (backend cũ thì không).
  bool get hasBreakdown => starCounts.isNotEmpty;

  int countOf(int star) => starCounts[star] ?? 0;

  /// Tỉ lệ 0–1 của mức [star] trên tổng số đánh giá.
  double fractionOf(int star) => count == 0 ? 0 : countOf(star) / count;

  /// `4.5` → `4,5` (dấu phẩy thập phân kiểu Việt).
  String get averageLabel => average.toStringAsFixed(1).replaceAll('.', ',');
}
