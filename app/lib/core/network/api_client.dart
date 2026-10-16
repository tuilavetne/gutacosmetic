import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/session/session_controller.dart';
import '../config/env.dart';
import '../widgets/app_messenger.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';

typedef JsonMap = Map<String, dynamic>;

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 60),
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      readToken: () => ref.read(sessionControllerProvider).token,
      readActiveStoreId: () =>
          ref.read(sessionControllerProvider).activeStoreHeaderValue,
      onUnauthorized: () {
        final session = ref.read(sessionControllerProvider);
        if (!session.isAuthenticated) return;
        ref.read(sessionControllerProvider.notifier).signOut();
        showAppSnackBar('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      },
      onActiveStoreInvalid: () {
        if (ref.read(sessionControllerProvider).activeStore == null) return;
        ref.read(sessionControllerProvider.notifier).clearActiveStore();
        showAppSnackBar('Chi nhánh đang chọn đã bị khóa. Vui lòng chọn lại.');
      },
    ),
  );
  ref.onDispose(dio.close);
  return dio;
});

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(dioProvider)),
);

/// Bọc Dio: mọi lỗi được chuẩn hóa thành [ApiException], body luôn là JSON
/// object.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<JsonMap> get(String path, {Map<String, Object?>? query}) =>
      _send(() => _dio.get<Object?>(path, queryParameters: _clean(query)));

  Future<JsonMap> post(String path, {Object? data}) =>
      _send(() => _dio.post<Object?>(path, data: data));

  Future<JsonMap> put(String path, {Object? data}) =>
      _send(() => _dio.put<Object?>(path, data: data));

  Future<JsonMap> patch(String path, {Object? data}) =>
      _send(() => _dio.patch<Object?>(path, data: data));

  Future<JsonMap> delete(String path, {Object? data}) =>
      _send(() => _dio.delete<Object?>(path, data: data));

  /// Gửi `multipart/form-data`; Dio tự đặt Content-Type kèm boundary.
  Future<JsonMap> postMultipart(String path, FormData form) =>
      _send(() => _dio.post<Object?>(path, data: form));

  Future<JsonMap> putMultipart(String path, FormData form) =>
      _send(() => _dio.put<Object?>(path, data: form));

  Future<JsonMap> _send(Future<Response<Object?>> Function() request) async {
    try {
      final response = await request();
      final data = response.data;
      if (data is Map) return Map<String, dynamic>.from(data);
      if (data == null || data == '') return <String, dynamic>{};
      throw ApiException(
        'Phản hồi từ máy chủ không đúng định dạng.',
        status: response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Bỏ các tham số rỗng để không gửi `?search=` thừa.
  static Map<String, Object?>? _clean(Map<String, Object?>? query) {
    if (query == null) return null;
    final result = <String, Object?>{};
    query.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      if (value is Iterable) {
        if (value.isEmpty) return;
        result[key] = value.join(',');
        return;
      }
      result[key] = value;
    });
    return result;
  }
}

/// Tiện ích parse danh sách trong response: `{products: [...]}`.
List<T> parseList<T>(
  JsonMap json,
  String key,
  T Function(JsonMap json) fromJson,
) {
  final raw = json[key];
  if (raw is! List) return <T>[];
  return raw
      .whereType<Map<dynamic, dynamic>>()
      .map((e) => fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

/// Lấy object con trong response: `{order: {...}}`.
JsonMap requireObject(JsonMap json, String key) {
  final raw = json[key];
  if (raw is Map) return Map<String, dynamic>.from(raw);
  throw ApiException('Phản hồi từ máy chủ thiếu trường "$key".');
}
