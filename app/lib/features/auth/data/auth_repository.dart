import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/utils/validators.dart';
import '../../shared/models/models.dart';
import 'auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

/// `/auth/*`
class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  Future<AuthResult> login({
    required String identifier,
    required String password,
  }) async {
    final json = await _api.post(
      '/auth/login',
      data: {
        'identifier': Validators.normalizeIdentifier(identifier),
        'password': password,
      },
    );
    return AuthResult.fromJson(json);
  }

  Future<AuthResult> loginWithGoogle(String idToken) async {
    final json = await _api.post('/auth/google', data: {'idToken': idToken});
    return AuthResult.fromJson(json);
  }

  Future<OtpChallenge> requestRegisterOtp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String address,
  }) async {
    final json = await _api.post(
      '/auth/register/request-otp',
      data: {
        'fullName': fullName.trim(),
        'email': Validators.normalizeEmail(email),
        'phone': Validators.normalizePhone(phone),
        'password': password,
        'confirmPassword': confirmPassword,
        'address': address.trim(),
      },
    );
    return OtpChallenge.fromJson(json);
  }

  Future<AuthResult> verifyRegisterOtp({
    required String challengeId,
    required String otp,
  }) async {
    final json = await _api.post(
      '/auth/register/verify-otp',
      data: {'challengeId': challengeId, 'otp': otp.trim()},
    );
    return AuthResult.fromJson(json);
  }

  Future<OtpChallenge> requestPasswordResetOtp(String identifier) async {
    final json = await _api.post(
      '/auth/password/forgot/request-otp',
      data: {'identifier': Validators.normalizeIdentifier(identifier)},
    );
    return OtpChallenge.fromJson(json);
  }

  Future<PasswordResetToken> verifyPasswordResetOtp({
    required String challengeId,
    required String otp,
  }) async {
    final json = await _api.post(
      '/auth/password/forgot/verify-otp',
      data: {'challengeId': challengeId, 'otp': otp.trim()},
    );
    return PasswordResetToken.fromJson(json);
  }

  Future<String> resetPassword({
    required String resetToken,
    required String password,
    required String confirmPassword,
  }) async {
    final json = await _api.post(
      '/auth/password/reset',
      data: {
        'resetToken': resetToken,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
    return json['message'] as String? ?? 'Đổi mật khẩu thành công.';
  }

  /// `PUT /auth/password` — đổi mật khẩu khi đã đăng nhập. Tài khoản chưa có
  /// mật khẩu (tạo bằng Google) thì bỏ [currentPassword]. Trả về token mới:
  /// mọi token cũ, kể cả trên thiết bị khác, hết hiệu lực.
  Future<AuthResult> changePassword({
    String? currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final json = await _api.put(
      '/auth/password',
      data: {
        'currentPassword': ?currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
    return AuthResult.fromJson(json);
  }

  Future<AppUser> me() async {
    final json = await _api.get('/auth/me');
    return AppUser.fromJson(requireObject(json, 'user'));
  }
}
