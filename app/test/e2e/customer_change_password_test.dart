// Test end-to-end Đổi mật khẩu với BACKEND THẬT.
//
//   flutter test test/e2e/customer_change_password_test.dart \
//     --dart-define=E2E=true \
//     --dart-define=API_BASE_URL=http://localhost:5000/api --timeout 300s
//
// Đổi mật khẩu khách demo sang mật khẩu tạm rồi đổi lại; nếu test dừng giữa
// chừng, khối `finally` tự khôi phục mật khẩu demo.
@Tags(['e2e'])
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/core/config/env.dart';
import 'package:gutacosmetic/features/customer/data/order_repository.dart';
import 'package:gutacosmetic/features/customer/presentation/change_password_screen.dart';
import 'package:gutacosmetic/features/session/session_controller.dart';
import 'package:material_ui/material_ui.dart';

import 'e2e_helpers.dart';

const _customer = 'customer.guta.demo@gmail.com';
const _tempPassword = 'E2eTam@2026';

final _verticalScroll = find.byWidgetPredicate(
  (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
);

/// Dio riêng tạo trong zone thật của `runAsync`; không ném lỗi theo status.
Dio _dio() =>
    Dio(BaseOptions(baseUrl: Env.apiBaseUrl, validateStatus: (_) => true));

Future<void> _openChangePassword(WidgetTester tester) async {
  await tapCustomerTab(tester, 'Tài khoản');
  final entry = find.text('Đổi mật khẩu');
  await tester.scrollUntilVisible(
    entry,
    200,
    scrollable: _verticalScroll.first,
  );
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(entry);
  await waitFor(tester, find.byType(ChangePasswordScreen));
}

Future<void> _fillAndSubmit(
  WidgetTester tester, {
  required String current,
  required String next,
}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), current);
  await tester.enterText(fields.at(1), next);
  await tester.enterText(fields.at(2), next);
  await tester.pump();
  clearSnackBars();
  await tester.pump();
  await tester.tap(find.widgetWithText(FilledButton, 'Đổi mật khẩu'));
}

void main() {
  testWidgets(
    'Khách hàng: đổi mật khẩu → vẫn đăng nhập, token cũ hết hạn → đổi lại',
    skip: !runE2E,
    (tester) async {
      try {
        final container = await startApp(tester);
        await login(tester, _customer, demoPassword);
        await waitFor(tester, find.textContaining('Xin chào'));
        final oldToken = container.read(sessionControllerProvider).token!;

        // 1. Sai mật khẩu hiện tại → báo dưới ô nhập, chưa đổi gì.
        await _openChangePassword(tester);
        await _fillAndSubmit(tester, current: 'Sai@12345', next: _tempPassword);
        await waitFor(tester, find.text('Mật khẩu hiện tại không đúng.'));
        expect(container.read(sessionControllerProvider).token, oldToken);

        // 2. Đúng → nhận token mới, quay về Tài khoản.
        await _fillAndSubmit(
          tester,
          current: demoPassword,
          next: _tempPassword,
        );
        await waitUntil(
          tester,
          () => find.byType(ChangePasswordScreen).evaluate().isEmpty,
          description: 'đổi mật khẩu xong',
        );
        final newToken = container.read(sessionControllerProvider).token;
        expect(newToken, isNot(oldToken));

        // Token mới dùng được ngay: tab Đơn hàng tải xong, không bị đăng xuất.
        await tapCustomerTab(tester, 'Đơn hàng');
        final sub = container.listen(customerOrdersProvider, (_, _) {});
        addTearDown(sub.close);
        await waitUntil(
          tester,
          () => sub.read().hasValue,
          description: 'tải đơn bằng token mới',
        );
        expect(
          container.read(sessionControllerProvider).isAuthenticated,
          isTrue,
        );

        // Token cũ bị backend từ chối; đăng nhập bằng mật khẩu mới được.
        final check = await tester.runAsync(() async {
          final dio = _dio();
          final me = await dio.get<Object?>(
            '/auth/me',
            options: Options(headers: {'Authorization': 'Bearer $oldToken'}),
          );
          final relogin = await dio.post<Object?>(
            '/auth/login',
            data: {'identifier': _customer, 'password': _tempPassword},
          );
          return (me.statusCode, relogin.statusCode);
        });
        expect(check, (401, 200));

        // 3. Đổi lại mật khẩu demo qua giao diện.
        await _openChangePassword(tester);
        await _fillAndSubmit(
          tester,
          current: _tempPassword,
          next: demoPassword,
        );
        await waitUntil(
          tester,
          () => find.byType(ChangePasswordScreen).evaluate().isEmpty,
          description: 'đổi lại mật khẩu demo',
        );

        await finish(tester);
      } finally {
        // Khôi phục mật khẩu demo nếu vẫn đang là mật khẩu tạm.
        await tester.runAsync(() async {
          final dio = _dio();
          final res = await dio.post<Map<String, dynamic>>(
            '/auth/login',
            data: {'identifier': _customer, 'password': _tempPassword},
          );
          if (res.statusCode != 200) return;
          await dio.put<Object?>(
            '/auth/password',
            data: {
              'currentPassword': _tempPassword,
              'newPassword': demoPassword,
              'confirmPassword': demoPassword,
            },
            options: Options(
              headers: {'Authorization': 'Bearer ${res.data!['token']}'},
            ),
          );
        });
      }
    },
  );
}
