import 'package:flutter/foundation.dart';

/// Cấu hình môi trường, truyền qua `--dart-define`.
///
/// ```
/// flutter run \
///   --dart-define=API_BASE_URL=http://192.168.1.10:5000/api \
///   --dart-define=GOOGLE_WEB_CLIENT_ID=xxxx.apps.googleusercontent.com
/// ```
abstract final class Env {
  static const String _apiBaseUrlDefine = String.fromEnvironment(
    'API_BASE_URL',
  );

  /// Không truyền `API_BASE_URL` thì: Android emulator → `10.0.2.2` (máy host),
  /// trình duyệt (Chrome) → `localhost`.
  static String get apiBaseUrl {
    if (_apiBaseUrlDefine.isNotEmpty) return _apiBaseUrlDefine;
    return kIsWeb ? 'http://localhost:5000/api' : 'http://10.0.2.2:5000/api';
  }

  /// Web Client ID của Google Cloud (giá trị trong `GOOGLE_CLIENT_IDS` của
  /// backend). Dùng làm `serverClientId` để `idToken` có `aud` khớp backend.
  ///
  /// Mặc định là Web Client ID mà app React Native cũ đang dùng.
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '550502262089-4ehta6ckc0daipi9i32g5kinsd7jfi8g.apps.googleusercontent.com',
  );

  static bool get hasGoogleSignIn => googleWebClientId.isNotEmpty;
}
