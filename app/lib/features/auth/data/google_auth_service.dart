import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/env.dart';
import '../../../core/network/api_exception.dart';

final googleAuthServiceProvider = Provider<GoogleAuthService>(
  (ref) => GoogleAuthService(GoogleSignIn.instance),
);

/// Lấy Google `idToken` có `aud` = Web Client ID để gửi `POST /auth/google`.
class GoogleAuthService {
  GoogleAuthService(this._signIn);

  final GoogleSignIn _signIn;
  Future<void>? _initialization;

  /// `initialize` chỉ được gọi đúng một lần cho cả vòng đời app.
  Future<void> _ensureInitialized() => _initialization ??= _signIn.initialize(
    serverClientId: Env.googleWebClientId,
  );

  /// Trả về `null` nếu người dùng đóng hộp chọn tài khoản.
  Future<String?> requestIdToken() async {
    if (!Env.hasGoogleSignIn) {
      throw const ApiException('Ứng dụng chưa cấu hình GOOGLE_WEB_CLIENT_ID.');
    }
    if (kIsWeb) {
      // Web cần nút Google riêng (renderButton) — bản web chỉ dùng để test.
      throw const ApiException(
        'Đăng nhập Google chỉ hỗ trợ trên app Android/iOS. '
        'Trên trình duyệt vui lòng đăng nhập bằng Gmail/SĐT.',
      );
    }
    try {
      await _ensureInitialized();
      if (!_signIn.supportsAuthenticate()) {
        throw const ApiException('Thiết bị này không hỗ trợ đăng nhập Google.');
      }
      final account = await _signIn.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const ApiException('Google không trả về mã xác thực (idToken).');
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
        case GoogleSignInExceptionCode.interrupted:
          return null;
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
          throw const ApiException(
            'Đăng nhập Google chưa được cấu hình cho ứng dụng này '
            '(thiếu OAuth client Android với SHA-1 trong Google Cloud).',
          );
        case GoogleSignInExceptionCode.uiUnavailable:
          throw const ApiException('Không mở được cửa sổ đăng nhập Google.');
        default:
          throw ApiException(
            'Đăng nhập Google thất bại${e.description == null ? '' : ': ${e.description}'}.',
          );
      }
    }
  }

  /// Đăng xuất Google để lần sau hiện lại hộp chọn tài khoản.
  Future<void> signOut() async {
    if (_initialization == null) return;
    try {
      await _initialization;
      await _signIn.signOut();
    } catch (_) {}
  }
}
