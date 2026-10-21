// Test end-to-end luồng đăng nhập với BACKEND THẬT.
//
//   flutter test test/e2e --dart-define=E2E=true \
//     --dart-define=API_BASE_URL=http://localhost:5000/api
//
// Cần backend đang chạy và đã `npm run seed:demo-users` + `seed:demo-stores`.
@Tags(['e2e'])
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/features/session/session_controller.dart';
import 'package:material_ui/material_ui.dart';

import 'e2e_helpers.dart';

void main() {
  late ProviderContainer container;

  testWidgets(
    'Đăng nhập: sai mật khẩu, Sales chọn chi nhánh, Customer, Owner, Manager',
    skip: !runE2E,
    (tester) async {
      container = await startApp(tester);

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
      await login(tester, '012345', demoPassword);
      await tester.pump();
      expect(find.text('Số điện thoại Việt Nam không hợp lệ'), findsOneWidget);

      // 3. Sales đăng nhập bằng SĐT → màn chọn chi nhánh → chọn → trang Sales.
      await login(tester, '0909 000 002', demoPassword);
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

      // 4. Customer → tab Trang chủ có bottom navigation; đăng xuất ở tab
      //    Tài khoản.
      await login(tester, 'customer.guta.demo@gmail.com', demoPassword);
      await waitFor(tester, find.textContaining('Xin chào'));
      expect(find.byType(NavigationBar), findsOneWidget);
      await logoutCustomer(tester);

      // 5. Owner → trang Owner (không qua chọn chi nhánh).
      await login(tester, 'owner.guta.demo@gmail.com', demoPassword);
      await waitFor(tester, find.text('Trang chủ Owner'));
      await logoutFromPlaceholder(tester);

      // 6. Manager → bắt buộc chọn chi nhánh; chi nhánh được phân công chọn sẵn.
      await login(tester, 'manager.guta.demo@gmail.com', demoPassword);
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
    skip: !runE2E,
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
