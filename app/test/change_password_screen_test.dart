import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gutacosmetic/app/theme.dart';
import 'package:gutacosmetic/core/network/api_exception.dart';
import 'package:gutacosmetic/core/network/error_messages.dart';
import 'package:gutacosmetic/core/widgets/app_messenger.dart';
import 'package:gutacosmetic/features/auth/data/auth_models.dart';
import 'package:gutacosmetic/features/auth/data/auth_repository.dart';
import 'package:gutacosmetic/features/customer/presentation/change_password_screen.dart';
import 'package:gutacosmetic/features/session/session_controller.dart';
import 'package:gutacosmetic/features/session/session_state.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';
import 'package:material_ui/material_ui.dart';

const _local = AppUser(id: 'u1', role: UserRole.customer);
const _google = AppUser(
  id: 'u1',
  role: UserRole.customer,
  authProvider: AuthProvider.google,
);

/// Phiên đã đăng nhập; ghi lại token được thay.
class _FakeSession extends SessionController {
  _FakeSession(this.user);

  final AppUser user;

  @override
  SessionState build() => SessionState.signedIn(token: 'old', user: user);

  @override
  Future<void> renewSession(AuthResult result) async {
    state = SessionState.signedIn(token: result.token, user: result.user);
  }
}

/// Trả lỗi theo thứ tự trong [errors], hết lỗi thì thành công.
class _FakeAuth implements AuthRepository {
  _FakeAuth([this.errors = const []]);

  final List<String> errors;
  final calls = <String?>[];

  @override
  Future<AuthResult> changePassword({
    String? currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    calls.add(currentPassword);
    if (calls.length <= errors.length) {
      // Như ApiException.fromDio: thông điệp đã dịch theo mã lỗi.
      final code = errors[calls.length - 1];
      throw ApiException(
        translateErrorCode(code, null) ?? code,
        status: 400,
        code: code,
      );
    }
    return const AuthResult(user: _local, token: 'new');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  _FakeAuth auth, {
  AppUser user = _local,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      sessionControllerProvider.overrideWith(() => _FakeSession(user)),
      authRepositoryProvider.overrideWithValue(auth),
    ],
  );
  addTearDown(container.dispose);
  final router = GoRouter(
    initialLocation: '/password',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('Tài khoản')),
        routes: [
          GoRoute(
            path: 'password',
            builder: (_, _) => const ChangePasswordScreen(),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: buildAppTheme(),
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _fill(
  WidgetTester tester, {
  String? current,
  required String next,
  String? confirm,
}) async {
  final fields = find.byType(TextFormField);
  var i = 0;
  if (current != null) await tester.enterText(fields.at(i++), current);
  await tester.enterText(fields.at(i++), next);
  await tester.enterText(fields.at(i), confirm ?? next);
  await tester.pump();
}

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Đổi mật khẩu'));
  await tester.pumpAndSettle();
}

void main() {
  test('điều kiện mật khẩu mạnh', () {
    bool all(String v) => passwordRules.every((r) => r.test(v));
    expect(all('Abcdef12'), isTrue);
    expect(all('abcdef12'), isFalse);
    expect(all('ABCDEF12'), isFalse);
    expect(all('Abcdefgh'), isFalse);
    expect(all('Ab1'), isFalse);
  });

  testWidgets('kiểm tra phía client, báo sai mật khẩu hiện tại dưới ô nhập', (
    tester,
  ) async {
    final auth = _FakeAuth(['INVALID_CURRENT_PASSWORD']);
    final container = await _pump(tester, auth);

    expect(find.text('Mật khẩu hiện tại'), findsOneWidget);
    await _fill(tester, current: 'Cu@12345', next: 'Cu@12345');
    await _submit(tester);
    expect(
      find.text('Mật khẩu mới phải khác mật khẩu hiện tại'),
      findsOneWidget,
    );

    await _fill(
      tester,
      current: 'Cu@12345',
      next: 'Moi@12345',
      confirm: 'Moi@1234',
    );
    await _submit(tester);
    expect(find.text('Mật khẩu xác nhận không khớp'), findsOneWidget);
    expect(auth.calls, isEmpty);

    await _fill(tester, current: 'Sai@12345', next: 'Moi@12345');
    await _submit(tester);
    expect(auth.calls, ['Sai@12345']);
    expect(find.text('Mật khẩu hiện tại không đúng.'), findsOneWidget);
    expect(container.read(sessionControllerProvider).token, 'old');

    // Lần 2 thành công → thay token, quay về màn trước.
    await _fill(tester, current: 'Cu@12345', next: 'Moi@12345');
    await _submit(tester);
    expect(auth.calls.last, 'Cu@12345');
    expect(container.read(sessionControllerProvider).token, 'new');
    expect(find.text('Tài khoản'), findsOneWidget);
  });

  testWidgets('tài khoản Google: đặt mật khẩu, đã có thì hiện ô hiện tại', (
    tester,
  ) async {
    final auth = _FakeAuth(['CURRENT_PASSWORD_REQUIRED']);
    await _pump(tester, auth, user: _google);

    expect(find.text('Đặt mật khẩu'), findsWidgets);
    expect(find.text('Mật khẩu hiện tại'), findsNothing);
    await _fill(tester, next: 'Moi@12345');
    await tester.tap(find.widgetWithText(FilledButton, 'Đặt mật khẩu'));
    await tester.pumpAndSettle();

    expect(auth.calls, [null]);
    expect(find.text('Mật khẩu hiện tại'), findsOneWidget);
    expect(find.textContaining('Tài khoản đã có mật khẩu'), findsOneWidget);
  });
}
