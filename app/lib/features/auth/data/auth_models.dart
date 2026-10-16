import 'package:freezed_annotation/freezed_annotation.dart';

import '../../shared/models/user.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

/// `{user, token}` từ login / google / register verify.
@freezed
abstract class AuthResult with _$AuthResult {
  const factory AuthResult({required AppUser user, required String token}) =
      _AuthResult;

  factory AuthResult.fromJson(Map<String, dynamic> json) =>
      _$AuthResultFromJson(json);
}

/// Thử thách OTP vừa được gửi.
@freezed
abstract class OtpChallenge with _$OtpChallenge {
  const factory OtpChallenge({
    required String challengeId,
    @Default('EMAIL') String channel,

    /// Email đã che bớt, ví dụ `ng***@gmail.com`.
    @Default('') String deliveryTarget,

    /// Số giây OTP còn hiệu lực.
    @Default(300) int expiresIn,

    /// Chỉ có khi backend chạy `OTP_MODE=development`.
    String? developmentOtp,
  }) = _OtpChallenge;

  factory OtpChallenge.fromJson(Map<String, dynamic> json) =>
      _$OtpChallengeFromJson(json);
}

@freezed
abstract class PasswordResetToken with _$PasswordResetToken {
  const factory PasswordResetToken({
    required String resetToken,
    @Default(600) int expiresIn,
  }) = _PasswordResetToken;

  factory PasswordResetToken.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetTokenFromJson(json);
}
