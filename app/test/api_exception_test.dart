import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/core/network/api_exception.dart';

ApiException _fromResponse(int status, Object? data) {
  final request = RequestOptions(path: '/x');
  return ApiException.fromDio(
    DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: request,
        statusCode: status,
        data: data,
      ),
    ),
  );
}

void main() {
  test('dịch mã lỗi backend sang tiếng Việt', () {
    final e = _fromResponse(401, {
      'message': 'Invalid Gmail/phone or password',
      'code': 'INVALID_CREDENTIALS',
    });
    expect(e.message, 'Gmail/số điện thoại hoặc mật khẩu không đúng.');
    expect(e.code, 'INVALID_CREDENTIALS');
    expect(e.status, 401);
  });

  test('OTP sai kèm số lần còn lại', () {
    final e = _fromResponse(400, {
      'message': 'OTP is incorrect',
      'code': 'OTP_INCORRECT',
      'details': {'attemptsRemaining': 3},
    });
    expect(e.message, 'Mã OTP không đúng. Bạn còn 3 lần thử.');
  });

  test('giữ nguyên message tiếng Việt của backend khi chưa có bản dịch', () {
    final e = _fromResponse(403, {
      'message': 'Chi nhánh đang làm việc không hợp lệ hoặc đã bị khóa',
      'code': 'SOME_NEW_CODE',
    });
    expect(e.message, 'Chi nhánh đang làm việc không hợp lệ hoặc đã bị khóa');
  });

  test('message tiếng Anh không có mã → thông điệp chung theo status', () {
    expect(
      _fromResponse(401, {
        'message': 'Password was changed. Please sign in again.',
      }).message,
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
    );
    expect(
      _fromResponse(409, {'message': 'email already exists'}).message,
      'Thông tin này đã tồn tại trong hệ thống.',
    );
  });

  test('mất kết nối', () {
    final e = ApiException.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      ),
    );
    expect(e.isNetworkError, isTrue);
  });
}
