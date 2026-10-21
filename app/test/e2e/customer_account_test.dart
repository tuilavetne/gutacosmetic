// Test end-to-end tab Tài khoản của khách hàng với BACKEND THẬT.
//
//   flutter test test/e2e --dart-define=E2E=true \
//     --dart-define=API_BASE_URL=http://localhost:5000/api
//
// Có sửa hồ sơ của customer demo, cuối test ghi lại giá trị ban đầu.
@Tags(['e2e'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/core/utils/formatters.dart';
import 'package:gutacosmetic/features/customer/data/profile_repository.dart';
import 'package:gutacosmetic/features/customer/presentation/edit_profile_screen.dart';
import 'package:gutacosmetic/features/session/session_controller.dart';
import 'package:material_ui/material_ui.dart';

import 'e2e_helpers.dart';

/// SĐT của tài khoản sales demo — dùng để thử trùng SĐT.
const _takenPhone = '0909000002';

/// SĐT chưa thuộc tài khoản nào (chỉ để kiểm tra, không lưu).
const _freePhone = '0987123999';

Finder _field(String label) => find.widgetWithText(TextFormField, label);
final _saveButton = find.widgetWithText(FilledButton, 'Lưu thay đổi');

/// Nút Lưu nằm cuối danh sách (có thể chưa được dựng) — cuộn tới rồi bấm.
Future<void> _tapSave(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    _saveButton,
    200,
    scrollable: find
        .descendant(
          of: find.byType(EditProfileScreen),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(_saveButton);
  await tester.pump();
}

void main() {
  testWidgets(
    'Khách hàng: xem hồ sơ, báo trùng SĐT, sửa họ tên + địa chỉ, đăng xuất',
    skip: !runE2E,
    (tester) async {
      final container = await startApp(tester);
      await login(tester, 'customer.guta.demo@gmail.com', demoPassword);
      await waitFor(tester, find.textContaining('Xin chào'));
      final original = container.read(currentUserProvider)!;

      // 1. Tab Tài khoản hiện hồ sơ.
      await tapCustomerTab(tester, 'Tài khoản');
      await waitFor(tester, find.text('Hồ sơ cá nhân'));
      expect(find.text(original.email), findsOneWidget);
      expect(find.text(formatPhone(original.phone)), findsOneWidget);
      expect(find.textContaining('điểm'), findsWidgets);

      // 2. Mở màn sửa: chưa đổi gì thì chưa lưu được.
      await tester.tap(find.text('Chỉnh sửa'));
      await waitFor(tester, find.text('Thông tin cá nhân'));
      expect(tester.widget<FilledButton>(_saveButton).onPressed, isNull);

      // 3. Gõ SĐT đã thuộc tài khoản khác → tự kiểm tra (chưa cần bấm Lưu),
      //    báo lỗi ngay dưới ô SĐT; bấm Lưu cũng không gửi đi.
      final phoneTaken = find.descendant(
        of: _field('Số điện thoại'),
        matching: find.text('Số điện thoại đã được đăng ký.'),
      );
      await tester.enterText(_field('Số điện thoại'), _takenPhone);
      await waitFor(tester, phoneTaken);
      clearSnackBars();
      await _tapSave(tester);
      await tester.pump(const Duration(milliseconds: 400));
      expect(phoneTaken, findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(container.read(currentUserProvider)!.phone, original.phone);
      expect(find.text('Thông tin cá nhân'), findsOneWidget);

      // 3b. Gõ SĐT chưa ai dùng → lỗi biến mất, báo "có thể sử dụng".
      await tester.enterText(_field('Số điện thoại'), _freePhone);
      await tester.pump();
      expect(phoneTaken, findsNothing);
      await waitFor(tester, find.text('Số điện thoại có thể sử dụng.'));

      // 3c. Trả về SĐT cũ thì không cần kiểm tra nữa.
      await tester.enterText(_field('Số điện thoại'), original.phone ?? '');
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Số điện thoại có thể sử dụng.'), findsNothing);
      expect(phoneTaken, findsNothing);

      // 4. Đổi họ tên + địa chỉ → lưu → về tab Tài khoản với dữ liệu mới.
      final newName = '${original.fullName} E2E';
      const newAddress = '12 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh (E2E)';
      await tester.enterText(_field('Họ và tên'), newName);
      await tester.enterText(_field('Địa chỉ nhận hàng'), newAddress);
      await _tapSave(tester);
      await waitFor(tester, find.text('Đã cập nhật thông tin cá nhân.'));
      await waitUntil(
        tester,
        () => find.text('Thông tin cá nhân').evaluate().isEmpty,
      );
      expect(find.text(newName), findsWidgets);
      expect(find.text(newAddress), findsOneWidget);
      final updated = container.read(currentUserProvider)!;
      expect(updated.fullName, newName);
      expect(updated.address, newAddress);
      expect(updated.phone, original.phone);

      // 5. Thoát khi còn thay đổi chưa lưu → hỏi xác nhận.
      clearSnackBars();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Chỉnh sửa'));
      await waitFor(tester, find.text('Thông tin cá nhân'));
      await tester.enterText(_field('Họ và tên'), 'Tên chưa lưu');
      await tester.pump();
      await tester.tap(find.byType(BackButton));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Bỏ thay đổi?'), findsOneWidget);
      await tester.tap(find.text('Tiếp tục sửa'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Thông tin cá nhân'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.widgetWithText(FilledButton, 'Bỏ thay đổi'));
      await waitUntil(
        tester,
        () => find.text('Thông tin cá nhân').evaluate().isEmpty,
      );
      expect(container.read(currentUserProvider)!.fullName, newName);

      // 6. Trả hồ sơ demo về như cũ rồi đăng xuất.
      await tester.runAsync(
        () => container
            .read(profileRepositoryProvider)
            .updateProfile(
              fullName: original.fullName,
              address: original.address,
            ),
      );
      await logoutCustomer(tester);
      expect(container.read(currentUserProvider), isNull);
      await finish(tester);
    },
  );
}
