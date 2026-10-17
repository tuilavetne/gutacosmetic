import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/app/app.dart';
import 'package:gutacosmetic/core/storage/local_storage.dart';
import 'package:gutacosmetic/core/storage/token_storage.dart';
import 'package:gutacosmetic/core/widgets/app_messenger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const runE2E = bool.fromEnvironment('E2E');
const demoPassword = 'Letien@0110';

class MemoryTokenStorage implements TokenStorage {
  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String value) async => token = value;

  @override
  Future<void> clear() async => token = null;
}

/// Mở app thật (màn hình điện thoại 360×800) với storage trong bộ nhớ, chờ
/// tới màn Login. Trả về container để kiểm tra state.
Future<ProviderContainer> startApp(WidgetTester tester) async {
  // flutter_test chặn mọi HTTP thật — bỏ chặn để gọi backend.
  HttpOverrides.global = null;
  _mockPathProvider();
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      tokenStorageProvider.overrideWithValue(MemoryTokenStorage()),
    ],
    retry: (_, _) => null,
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const GutaApp()),
  );
  await waitFor(tester, find.text('Chào mừng trở lại'));
  return container;
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

/// Đăng xuất từ màn placeholder (có nút "Đăng xuất" trên AppBar).
Future<void> logoutFromPlaceholder(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Đăng xuất'));
  await waitFor(tester, find.text('Chào mừng trở lại'));
}

/// Khách hàng đăng xuất ở tab Tài khoản (có hộp thoại xác nhận).
Future<void> logoutCustomer(WidgetTester tester) async {
  await tapCustomerTab(tester, 'Tài khoản');
  final button = find.widgetWithText(OutlinedButton, 'Đăng xuất');
  await tester.scrollUntilVisible(button, 200);
  await tester.pump();
  await tester.tap(button);
  await tester.pump(const Duration(milliseconds: 400));
  await tester.tap(find.widgetWithText(FilledButton, 'Đăng xuất'));
  await waitFor(tester, find.text('Chào mừng trở lại'));
}

/// Bấm một tab của bottom navigation khách hàng.
Future<void> tapCustomerTab(WidgetTester tester, String label) async {
  clearSnackBars();
  await tester.pump();
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pump(const Duration(milliseconds: 400));
}

/// Gỡ app và chạy hết timer còn treo (SnackBar, Tooltip, lịch dọn cache ảnh
/// 10 giây của flutter_cache_manager) trước khi test kết thúc.
Future<void> finish(WidgetTester tester) async {
  clearSnackBars();
  await tester.pumpWidget(const SizedBox.shrink());
  // Việc dọn cache dùng I/O thật rồi mới hẹn timer tiếp — xen kẽ vài vòng.
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump(const Duration(seconds: 11));
  }
}

/// Chờ tới khi [finder] xuất hiện, cho phép I/O thật (HTTP) chạy giữa các frame.
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) => waitUntil(
  tester,
  () => finder.evaluate().isNotEmpty,
  timeout: timeout,
  description: '$finder',
);

/// Chờ tới khi [condition] đúng (state, request nền...).
Future<void> waitUntil(
  WidgetTester tester,
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 20),
  String description = 'điều kiện',
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    if (condition()) {
      // Chờ hiệu ứng chuyển trang kết thúc để route cũ rời cây widget.
      await tester.pump(const Duration(milliseconds: 600));
      return;
    }
  }
  throw TestFailure('Hết thời gian chờ: $description');
}

/// `cached_network_image` cần thư mục cache từ `path_provider` — test không có
/// plugin native nên trả về một thư mục tạm.
void _mockPathProvider() {
  final dir = Directory.systemTemp.createTempSync('guta_e2e_');
  addTearDown(() {
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {
      // File cache có thể còn bị giữ — để hệ điều hành dọn.
    }
  });
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async => dir.path,
      );
}

/// SnackBar nổi ở đáy có thể che nút phía dưới — gỡ ngay (không chờ hiệu
/// ứng thoát) trước khi bấm.
void clearSnackBars() => rootScaffoldMessengerKey.currentState
  ?..clearSnackBars()
  ..removeCurrentSnackBar();
