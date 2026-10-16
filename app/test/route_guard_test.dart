import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/app/route_guard.dart';
import 'package:gutacosmetic/app/routes.dart';
import 'package:gutacosmetic/features/session/session_state.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';

SessionState _signedIn(UserRole role, {Store? store}) => SessionState.signedIn(
  token: 't',
  user: AppUser(id: 'u1', role: role),
  activeStore: store,
);

const _store = Store(id: 's1', name: 'CN 1');

void main() {
  test('đang đọc session → splash', () {
    expect(
      resolveRedirect(const SessionState.restoring(), AppRoutes.login),
      AppRoutes.splash,
    );
    expect(
      resolveRedirect(const SessionState.restoring(), AppRoutes.splash),
      isNull,
    );
  });

  test('chưa đăng nhập → login, cho phép /auth/**', () {
    const s = SessionState.signedOut();
    expect(resolveRedirect(s, AppRoutes.splash), AppRoutes.login);
    expect(resolveRedirect(s, AppRoutes.owner), AppRoutes.login);
    expect(resolveRedirect(s, AppRoutes.register), isNull);
    expect(resolveRedirect(s, AppRoutes.forgotPassword), isNull);
  });

  test('staff chưa chọn chi nhánh → select-store', () {
    for (final role in [UserRole.manager, UserRole.sales]) {
      final s = _signedIn(role);
      expect(resolveRedirect(s, AppRoutes.login), AppRoutes.selectStore);
      expect(
        resolveRedirect(s, AppRoutes.homeFor(role)),
        AppRoutes.selectStore,
      );
      expect(resolveRedirect(s, AppRoutes.selectStore), isNull);
    }
  });

  test('staff đã chọn chi nhánh vẫn vào lại được select-store', () {
    final s = _signedIn(UserRole.sales, store: _store);
    expect(resolveRedirect(s, AppRoutes.selectStore), isNull);
    expect(resolveRedirect(s, AppRoutes.login), AppRoutes.sales);
    expect(resolveRedirect(s, AppRoutes.sales), isNull);
  });

  test('sai role → trang chủ của role hiện tại', () {
    final customer = _signedIn(UserRole.customer);
    expect(resolveRedirect(customer, AppRoutes.owner), AppRoutes.customerHome);
    expect(
      resolveRedirect(customer, AppRoutes.selectStore),
      AppRoutes.customerHome,
    );
    expect(resolveRedirect(customer, AppRoutes.customerOrders), isNull);
    expect(resolveRedirect(customer, '/customer'), AppRoutes.customerHome);

    final owner = _signedIn(UserRole.owner);
    expect(resolveRedirect(owner, AppRoutes.customerHome), AppRoutes.owner);
    expect(resolveRedirect(owner, '/owner/products'), isNull);
    // `/ownerx` không thuộc nhánh `/owner`.
    expect(resolveRedirect(owner, '/ownerx'), AppRoutes.owner);

    final manager = _signedIn(UserRole.manager, store: _store);
    expect(resolveRedirect(manager, AppRoutes.sales), AppRoutes.manager);
  });
}
