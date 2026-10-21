import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../shared/models/models.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ReviewRepository(ref.watch(apiClientProvider)),
);

/// Đánh giá của một đơn (`null` nếu chưa đánh giá).
final orderReviewProvider = FutureProvider.autoDispose.family<Review?, String>(
  (ref, orderId) =>
      ref.watch(reviewRepositoryProvider).fetchOrderReview(orderId),
);

/// Ảnh mới chọn từ máy, chưa upload.
typedef ReviewImageUpload = ({
  List<int> bytes,
  String fileName,
  String mimeType,
});

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

  /// `GET /reviews/order/:orderId` — `{review: null}` khi chưa đánh giá.
  Future<Review?> fetchOrderReview(String orderId) async {
    final json = await _api.get('/reviews/order/$orderId');
    final raw = json['review'];
    return raw is Map ? Review.fromJson(Map<String, dynamic>.from(raw)) : null;
  }

  /// `POST /reviews` (multipart) — chỉ đơn đã hoàn tất, mỗi đơn một đánh
  /// giá; đánh giá gắn với sản phẩm đầu tiên của đơn.
  Future<Review> createReview({
    required String orderId,
    required int rating,
    required String comment,
    List<ReviewImageUpload> images = const [],
  }) async {
    final json = await _api.postMultipart(
      '/reviews',
      reviewFormData(
        orderId: orderId,
        rating: rating,
        comment: comment,
        newImages: images,
      ),
    );
    return Review.fromJson(requireObject(json, 'review'));
  }

  /// `PUT /reviews/:id` (multipart) — [keptImages] là URL ảnh cũ giữ lại,
  /// ghép với [newImages] (tối đa 5).
  Future<Review> updateReview(
    String id, {
    required int rating,
    required String comment,
    required List<String> keptImages,
    List<ReviewImageUpload> newImages = const [],
  }) async {
    final json = await _api.putMultipart(
      '/reviews/$id',
      reviewFormData(
        rating: rating,
        comment: comment,
        keptImages: keptImages,
        newImages: newImages,
      ),
    );
    return Review.fromJson(requireObject(json, 'review'));
  }

  /// `DELETE /reviews/:id` — đơn quay lại trạng thái chưa đánh giá.
  Future<void> deleteReview(String id) => _api.delete('/reviews/$id');

  /// Form gửi lên backend: ảnh mới ở trường `images` (lặp lại), ảnh cũ giữ
  /// lại ở `existingImages` dạng chuỗi JSON (chỉ khi sửa).
  static FormData reviewFormData({
    String? orderId,
    required int rating,
    required String comment,
    List<String>? keptImages,
    List<ReviewImageUpload> newImages = const [],
  }) {
    return FormData()
      ..fields.addAll([
        if (orderId != null) MapEntry('orderId', orderId),
        MapEntry('rating', '$rating'),
        MapEntry('comment', comment.trim()),
        if (keptImages != null)
          MapEntry('existingImages', jsonEncode(keptImages)),
      ])
      ..files.addAll([
        for (final image in newImages)
          MapEntry(
            'images',
            MultipartFile.fromBytes(
              image.bytes,
              filename: image.fileName,
              contentType: DioMediaType.parse(image.mimeType),
            ),
          ),
      ]);
  }
}
