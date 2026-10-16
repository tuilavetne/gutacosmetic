import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';
import 'product.dart';
import 'user.dart';

part 'review.freezed.dart';
part 'review.g.dart';

@freezed
abstract class Review with _$Review {
  const factory Review({
    @JsonKey(name: '_id') required String id,
    @ProductRefConverter() EntityRef<Product>? productId,
    @StringishConverter() String? orderId,
    @UserRefConverter() EntityRef<AppUser>? customerId,
    @Default('') String customerName,
    @Default(5) int rating,
    @Default('') String comment,

    /// URL Cloudinary.
    @Default(<String>[]) List<String> images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}

const reviewRatingLabels = <int, String>{
  1: 'Rất tệ',
  2: 'Tệ',
  3: 'Bình thường',
  4: 'Tốt',
  5: 'Tuyệt vời',
};
