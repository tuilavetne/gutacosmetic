import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';
import 'store.dart';
import 'user.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

/// Kết quả `GET /users/search` — khách thành viên hoặc khách vãng lai
/// (`_id` dạng `guest:<phone>`, `isGuest: true`).
@freezed
abstract class CustomerSearchResult with _$CustomerSearchResult {
  const CustomerSearchResult._();

  const factory CustomerSearchResult({
    @JsonKey(name: '_id') required String id,
    @Default('') String fullName,
    String? email,
    String? phone,
    @Default(0) int points,
    @Default(false) bool isGuest,
    int? orderCount,
  }) = _CustomerSearchResult;

  factory CustomerSearchResult.fromJson(Map<String, dynamic> json) =>
      _$CustomerSearchResultFromJson(json);

  bool get isMember => !isGuest && !id.startsWith('guest:');

  /// Giá trị `customerId` gửi khi tạo đơn offline (null với khách vãng lai).
  String? get orderCustomerId => isMember ? id : null;
}

/// Lịch sử đổi quà bằng điểm.
@freezed
abstract class RewardRedemption with _$RewardRedemption {
  const factory RewardRedemption({
    @JsonKey(name: '_id') required String id,
    @UserRefConverter() EntityRef<AppUser>? customerId,
    @StoreRefConverter() EntityRef<Store>? storeId,
    @UserRefConverter() EntityRef<AppUser>? redeemedBy,
    @Default('') String rewardName,
    @Default(0) int pointsUsed,
    String? note,
    DateTime? createdAt,
  }) = _RewardRedemption;

  factory RewardRedemption.fromJson(Map<String, dynamic> json) =>
      _$RewardRedemptionFromJson(json);
}

/// Response `POST /users/:customerId/redeem-points`.
@freezed
abstract class RedeemResult with _$RedeemResult {
  const factory RedeemResult({
    required CustomerSearchResult customer,
    RewardRedemption? redemption,
  }) = _RedeemResult;

  factory RedeemResult.fromJson(Map<String, dynamic> json) =>
      _$RedeemResultFromJson(json);
}
