import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../shared/models/models.dart';
import '../../catalog/product_reviews_controller.dart';
import '../../catalog/rating_summary.dart';
import 'product_gallery.dart';
import 'product_image.dart';

const _starColor = Color(0xFFF5A623);

/// 5 ngôi sao, hỗ trợ nửa sao (ví dụ 4,5).
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.size = 16});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Làm tròn tới 0,5 sao.
    final halves = (rating * 2).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            halves >= i * 2
                ? Icons.star_rounded
                : halves == i * 2 - 1
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded,
            size: size,
            color: _starColor,
          ),
      ],
    );
  }
}

/// Điểm trung bình, phân bố sao (số liệu backend tổng hợp) và danh sách đánh
/// giá tải theo trang, bấm "Xem thêm" để tải trang kế tiếp.
class ProductReviewsSection extends StatelessWidget {
  const ProductReviewsSection({
    super.key,
    required this.product,
    required this.reviews,
    required this.onRetry,
    required this.onLoadMore,
  });

  final Product product;
  final AsyncValue<ReviewFeed> reviews;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final summary = RatingSummary.of(product);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SummaryCard(summary: summary),
        const SizedBox(height: 12),
        reviews.when(
          skipLoadingOnRefresh: true,
          skipLoadingOnReload: true,
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => InlineError(
            message: 'Không tải được đánh giá. ${errorMessageOf(error)}',
            onRetry: onRetry,
          ),
          data: (feed) {
            if (feed.reviews.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Chưa có đánh giá nào cho sản phẩm này. Mua và nhận hàng '
                  'để trở thành người đánh giá đầu tiên.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final review in feed.reviews) ...[
                  ReviewCard(review: review),
                  const SizedBox(height: 10),
                ],
                if (feed.loadMoreError != null)
                  InlineError(
                    message:
                        'Không tải thêm được. '
                        '${errorMessageOf(feed.loadMoreError!)}',
                    onRetry: onLoadMore,
                  )
                else if (feed.hasMore)
                  OutlinedButton(
                    onPressed: feed.isLoadingMore ? null : onLoadMore,
                    child: feed.isLoadingMore
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Xem thêm đánh giá '
                            '(còn ${formatNumber(feed.remaining)})',
                          ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final RatingSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Column(
                children: [
                  Text(
                    summary.hasReviews ? summary.averageLabel : '—',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const Text(
                    'trên 5',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  StarRating(rating: summary.average),
                  const SizedBox(height: 4),
                  Text(
                    summary.hasReviews
                        ? '${formatNumber(summary.count)} đánh giá'
                        : 'Chưa có đánh giá',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  for (var star = 5; star >= 1; star--)
                    _StarBar(
                      star: star,
                      fraction: summary.fractionOf(star),
                      count: summary.countOf(star),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarBar extends StatelessWidget {
  const _StarBar({
    required this.star,
    required this.fraction,
    required this.count,
  });

  final int star;
  final double fraction;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Text(
              '$star',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
          const Icon(Icons.star_rounded, size: 14, color: _starColor),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                color: _starColor,
                backgroundColor: AppColors.border,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Một đánh giá: tên, thời gian, số sao, nội dung và ảnh đính kèm.
class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final name = review.customerName.trim().isEmpty
        ? 'Khách hàng'
        : review.customerName.trim();
    final images = review.images.where((e) => e.isNotEmpty).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    name.characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  formatRelativeTime(review.createdAt),
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StarRating(rating: review.rating.toDouble(), size: 14),
                const SizedBox(width: 6),
                Text(
                  reviewRatingLabels[review.rating.clamp(1, 5)]!,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (review.comment.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(review.comment.trim(), style: const TextStyle(height: 1.4)),
            ],
            if (images.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < images.length; i++)
                    GestureDetector(
                      onTap: () =>
                          showImageViewer(context, images, initialIndex: i),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox.square(
                          dimension: 64,
                          child: ProductImage(url: images[i], iconSize: 20),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
