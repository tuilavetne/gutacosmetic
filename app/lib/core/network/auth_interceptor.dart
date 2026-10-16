import 'package:dio/dio.dart';

/// Gắn `Authorization` và `X-Active-Store-Id`, đồng thời phát hiện phiên
/// hết hạn (401) và chi nhánh bị khóa (403 `ACTIVE_STORE_INVALID`).
///
/// Interceptor không phụ thuộc trực tiếp vào state; nó đọc qua callback để
/// tránh vòng phụ thuộc giữa Dio và SessionController.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.readToken,
    required this.readActiveStoreId,
    required this.onUnauthorized,
    required this.onActiveStoreInvalid,
  });

  final String? Function() readToken;

  /// Chỉ trả về giá trị khi user là MANAGER/SALES và đã chọn chi nhánh.
  final String? Function() readActiveStoreId;
  final void Function() onUnauthorized;
  final void Function() onActiveStoreInvalid;

  static const activeStoreHeader = 'X-Active-Store-Id';
  static const activeStoreInvalidCode = 'ACTIVE_STORE_INVALID';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept'] = 'application/json';
    final token = readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    final storeId = readActiveStoreId();
    if (storeId != null && storeId.isNotEmpty) {
      options.headers[activeStoreHeader] = storeId;
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    final sentToken = err.requestOptions.headers['Authorization'] != null;
    // 401 của request chưa đăng nhập (ví dụ sai mật khẩu) không phải hết phiên.
    if (status == 401 && sentToken) {
      onUnauthorized();
    } else if (status == 403) {
      final data = err.response?.data;
      if (data is Map && data['code'] == activeStoreInvalidCode) {
        onActiveStoreInvalid();
      }
    }
    handler.next(err);
  }
}
