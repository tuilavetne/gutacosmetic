import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../shared/models/models.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ReviewRepository(ref.watch(apiClientProvider)),
);

/// Một trang đánh giá của `GET /reviews`.
class ReviewPage {
  const ReviewPage({
    required this.reviews,
    required this.total,
    required this.hasMore,
  });

  final List<Review> reviews;

  /// Tổng số đánh giá của sản phẩm (mọi trang).
  final int total;
  final bool hasMore;
}

/// `/reviews`
class ReviewRepository {
  ReviewRepository(this._api);

  final ApiClient _api;

  /// `GET /reviews?productId=&page=&limit=` — mới nhất trước.
  ///
  /// Backend cũ không trả `pagination` thì coi như đã hết trang.
  Future<ReviewPage> fetchProductReviews(
    String productId, {
    required int page,
    required int limit,
  }) async {
    final json = await _api.get(
      '/reviews',
      query: {'productId': productId, 'page': page, 'limit': limit},
    );
    final reviews = parseList(json, 'reviews', Review.fromJson);
    final pagination = json['pagination'];
    if (pagination is! Map) {
      return ReviewPage(
        reviews: reviews,
        total: reviews.length,
        hasMore: false,
      );
    }
    return ReviewPage(
      reviews: reviews,
      total: (pagination['total'] as num?)?.toInt() ?? reviews.length,
      hasMore: pagination['hasMore'] == true,
    );
  }
}
