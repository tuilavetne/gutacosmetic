import 'package:dio/dio.dart';

import 'error_messages.dart';

/// Lỗi chuẩn hóa từ backend: `{ message, code?, details? }`.
class ApiException implements Exception {
  const ApiException(this.message, {this.status, this.code, this.details});

  final String message;
  final int? status;
  final String? code;
  final Object? details;

  static const networkErrorCode = 'NETWORK_ERROR';
  static const timeoutCode = 'TIMEOUT';
  static const cancelledCode = 'CANCELLED';

  bool get isNetworkError => code == networkErrorCode || code == timeoutCode;
  bool get isUnauthorized => status == 401;

  factory ApiException.fromDio(DioException error) {
    final inner = error.error;
    if (inner is ApiException) return inner;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          'Máy chủ phản hồi quá lâu. Vui lòng thử lại.',
          code: timeoutCode,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'Không thể kết nối máy chủ. Kiểm tra mạng hoặc địa chỉ API.',
          code: networkErrorCode,
        );
      case DioExceptionType.cancel:
        return const ApiException('Yêu cầu đã bị hủy.', code: cancelledCode);
      case DioExceptionType.badCertificate:
        return const ApiException(
          'Chứng chỉ bảo mật của máy chủ không hợp lệ.',
          code: networkErrorCode,
        );
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        break;
    }

    final response = error.response;
    final status = response?.statusCode;
    final data = response?.data;
    if (data is Map) {
      final code = data['code'] as String?;
      final details = data['details'];
      return ApiException(
        _resolveMessage(status, code, details, data['message']),
        status: status,
        code: code,
        details: details,
      );
    }
    if (response == null) {
      return const ApiException(
        'Không thể kết nối máy chủ. Kiểm tra mạng hoặc địa chỉ API.',
        code: networkErrorCode,
      );
    }
    return ApiException(_fallbackMessage(status), status: status);
  }

  static final _vietnameseChars = RegExp(
    '[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]',
    caseSensitive: false,
  );

  /// Ưu tiên bản dịch theo `code`; giữ `message` của backend nếu đã là
  /// tiếng Việt; còn lại dùng thông điệp chung theo HTTP status.
  static String _resolveMessage(
    int? status,
    String? code,
    Object? details,
    Object? rawMessage,
  ) {
    final translated = translateErrorCode(code, details);
    if (translated != null) return translated;
    if (rawMessage is String && _vietnameseChars.hasMatch(rawMessage)) {
      return rawMessage;
    }
    // Lỗi trùng khóa MongoDB (11000) không có `code`.
    if (status == 409 &&
        rawMessage is String &&
        rawMessage.contains('already exists')) {
      return 'Thông tin này đã tồn tại trong hệ thống.';
    }
    return _fallbackMessage(status);
  }

  static String _fallbackMessage(int? status) => switch (status) {
    400 => 'Dữ liệu gửi lên không hợp lệ.',
    401 => 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
    403 => 'Bạn không có quyền thực hiện thao tác này.',
    404 => 'Không tìm thấy dữ liệu.',
    409 => 'Dữ liệu đã thay đổi, vui lòng tải lại.',
    final s? when s >= 500 => 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau.',
    _ => 'Đã có lỗi xảy ra. Vui lòng thử lại.',
  };

  @override
  String toString() => 'ApiException($status, $code): $message';
}

/// Lấy thông điệp tiếng Việt hiển thị được từ một lỗi bất kỳ.
String errorMessageOf(Object error) {
  if (error is ApiException) return error.message;
  if (error is DioException) return ApiException.fromDio(error).message;
  return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
}
