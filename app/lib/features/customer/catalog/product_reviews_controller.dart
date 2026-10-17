import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/models.dart';
import '../data/review_repository.dart';

/// Đánh giá của một sản phẩm, tải từng trang [ProductReviewsController.pageSize].
final productReviewsProvider = AsyncNotifierProvider.autoDispose
    .family<ProductReviewsController, ReviewFeed, String>(
      ProductReviewsController.new,
    );

/// Các đánh giá đã tải và trạng thái "xem thêm".
class ReviewFeed {
  const ReviewFeed({
    required this.reviews,
    required this.total,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<Review> reviews;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;

  /// Lỗi của lần "xem thêm" gần nhất (các trang đã tải vẫn giữ nguyên).
  final Object? loadMoreError;

  /// Số đánh giá chưa tải.
  int get remaining => (total - reviews.length).clamp(0, total);
}

class ProductReviewsController extends AsyncNotifier<ReviewFeed> {
  ProductReviewsController(this.productId);

  final String productId;

  static const pageSize = 5;

  int _loadedPages = 0;

  ReviewRepository get _repo => ref.read(reviewRepositoryProvider);

  @override
  Future<ReviewFeed> build() async {
    _loadedPages = 0;
    final page = await ref
        .watch(reviewRepositoryProvider)
        .fetchProductReviews(productId, page: 1, limit: pageSize);
    _loadedPages = 1;
    return ReviewFeed(
      reviews: page.reviews,
      total: page.total,
      hasMore: page.hasMore,
    );
  }

  /// Tải trang kế tiếp; bỏ qua nếu đang tải hoặc đã hết.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(_copy(current, isLoadingMore: true));
    try {
      final page = await _repo.fetchProductReviews(
        productId,
        page: _loadedPages + 1,
        limit: pageSize,
      );
      if (!ref.mounted) return;
      _loadedPages++;
      // Có đánh giá mới chen vào giữa 2 lần tải thì trang sau bị lệch —
      // bỏ bản trùng.
      final seen = {for (final r in current.reviews) r.id};
      state = AsyncData(
        ReviewFeed(
          reviews: [
            ...current.reviews,
            ...page.reviews.where((r) => !seen.contains(r.id)),
          ],
          total: page.total,
          hasMore: page.hasMore,
        ),
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = AsyncData(_copy(current, loadMoreError: e));
    }
  }

  static ReviewFeed _copy(
    ReviewFeed feed, {
    bool isLoadingMore = false,
    Object? loadMoreError,
  }) => ReviewFeed(
    reviews: feed.reviews,
    total: feed.total,
    hasMore: feed.hasMore,
    isLoadingMore: isLoadingMore,
    loadMoreError: loadMoreError,
  );
}
