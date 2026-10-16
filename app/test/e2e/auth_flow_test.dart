// Test end-to-end luồng đăng nhập với BACKEND THẬT.
//
//   flutter test test/e2e --dart-define=E2E=true \
//     --dart-define=API_BASE_URL=http://localhost:5000/api
//
// Cần backend đang chạy và đã `npm run seed:demo-users` + `seed:demo-stores`.
@Tags(['e2e'])
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/app/app.dart';
import 'package:gutacosmetic/core/storage/local_storage.dart';
import 'package:gutacosmetic/core/widgets/app_messenger.dart';
import 'package:gutacosmetic/core/storage/token_storage.dart';
import 'package:gutacosmetic/features/session/session_controller.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _runE2E = bool.fromEnvironment('E2E');
const _password = 'Letien@0110';

class _MemoryTokenStorage implements TokenStorage {
  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String value) async => token = value;

  @override
  Future<void> clear() async => token = null;
}

void main() {
  late ProviderContainer container;

  Future<void> startApp(WidgetTester tester) async {
    // flutter_test chặn mọi HTTP thật — bỏ chặn để gọi backend.
    HttpOverrides.global = null;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        tokenStorageProvider.overrideWithValue(_MemoryTokenStorage()),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const GutaApp()),
    );
    await waitFor(tester, find.text('Chào mừng trở lại'));
  }

  Future<void> login(
    WidgetTester tester,
    String identifier,
    String password,
  ) async {
    clearSnackBars();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), identifier);
    await tester.enterText(fields.at(1), password);
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.pump();
  }

  Future<void> logoutFromPlaceholder(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Đăng xuất'));
    await waitFor(tester, find.text('Chào mừng trở lại'));
  }

  testWidgets(
    'Đăng nhập: sai mật khẩu, Sales chọn chi nhánh, Customer, Owner, Manager',
    skip: !_runE2E,
    (tester) async {
      await startApp(tester);

      // 1. Sai mật khẩu → thông báo tiếng Việt, vẫn ở màn Login.
      await login(tester, 'sales.guta.demo@gmail.com', 'SaiMatKhau1');
      await waitFor(
        tester,
        find.text('Gmail/số điện thoại hoặc mật khẩu không đúng.'),
      );
      expect(
        container.read(sessionControllerProvider).isAuthenticated,
        isFalse,
      );

      // 2. Validate phía client: SĐT sai định dạng không gọi API.
      await login(tester, '012345', _password);
      await tester.pump();
      expect(find.text('Số điện thoại Việt Nam không hợp lệ'), findsOneWidget);

      // 3. Sales đăng nhập bằng SĐT → màn chọn chi nhánh → chọn → trang Sales.
      await login(tester, '0909 000 002', _password);
      await waitFor(tester, find.text('Chọn chi nhánh'));
      await waitFor(tester, find.text('GUTA Cosmetic - Chi nhánh 2'));
      expect(find.text('Kho tổng'), findsOneWidget);
      await tester.tap(find.text('GUTA Cosmetic - Chi nhánh 2'));
      await tester.pump();
      clearSnackBars();
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
      await waitFor(tester, find.text('Trang chủ Sales'));
      final session = container.read(sessionControllerProvider);
      expect(session.activeStore?.name, 'GUTA Cosmetic - Chi nhánh 2');
      expect(session.activeStoreHeaderValue, session.activeStore?.id);

      // 3b. Đổi chi nhánh → quay lại màn chọn, có nút đóng.
      await tester.tap(find.byTooltip('Đổi chi nhánh'));
      await waitFor(tester, find.text('Đang làm việc'));
      await tester.tap(find.byTooltip('Quay lại'));
      await waitFor(tester, find.text('Trang chủ Sales'));
      await logoutFromPlaceholder(tester);
      expect(container.read(sessionControllerProvider).activeStore, isNull);

      // 4. Customer → tab Trang chủ có bottom navigation.
      await login(tester, 'customer.guta.demo@gmail.com', _password);
      await waitFor(tester, find.text('Tài khoản'));
      expect(find.byType(NavigationBar), findsOneWidget);
      await logoutFromPlaceholder(tester);

      // 5. Owner → trang Owner (không qua chọn chi nhánh).
      await login(tester, 'owner.guta.demo@gmail.com', _password);
      await waitFor(tester, find.text('Trang chủ Owner'));
      await logoutFromPlaceholder(tester);

      // 6. Manager → bắt buộc chọn chi nhánh; chi nhánh được phân công chọn sẵn.
      await login(tester, 'manager.guta.demo@gmail.com', _password);
      await waitFor(tester, find.text('Được phân công'));
      clearSnackBars();
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
      await waitFor(tester, find.text('Trang chủ Quản lý'));
      await finish(tester);
    },
  );

  testWidgets(
    'Quên mật khẩu: tài khoản không tồn tại báo lỗi tiếng Việt',
    skip: !_runE2E,
    (tester) async {
      await startApp(tester);
      await tester.tap(find.text('Quên mật khẩu?'));
      await waitFor(tester, find.text('Gửi mã OTP'));
      await tester.enterText(find.byType(TextFormField).first, '0388888888');
      await tester.tap(find.widgetWithText(FilledButton, 'Gửi mã OTP'));
      await waitFor(
        tester,
        find.text('Không tìm thấy tài khoản với Gmail/số điện thoại này.'),
      );
      await finish(tester);
    },
  );
}

/// Gỡ app và chạy hết timer còn treo (SnackBar, Tooltip) trước khi test kết thúc.
Future<void> finish(WidgetTester tester) async {
  clearSnackBars();
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 5));
}

/// Chờ tới khi [finder] xuất hiện, cho phép I/O thật (HTTP) chạy giữa các frame.
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      // Chờ hiệu ứng chuyển trang kết thúc để route cũ rời cây widget.
      await tester.pump(const Duration(milliseconds: 600));
      return;
    }
  }
  throw TestFailure('Hết thời gian chờ: $finder');
}

/// SnackBar nổi ở đáy có thể che nút phía dưới — xóa trước khi bấm.
void clearSnackBars() =>
    rootScaffoldMessengerKey.currentState?.clearSnackBars();
