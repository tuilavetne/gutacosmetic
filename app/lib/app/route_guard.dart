import '../features/session/session_state.dart';
import 'routes.dart';

/// Redirect toàn cục (hàm thuần để dễ test).
///
/// ```
/// đang đọc session                     → /splash
/// chưa có user                         → /auth/login (cho phép /auth/**)
/// MANAGER/SALES chưa chọn chi nhánh    → /staff/select-store
/// vào nhánh role khác / splash / auth  → trang chủ của role
/// ```
String? resolveRedirect(SessionState session, String location) {
  if (session.isRestoring) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  final user = session.user;
  final isAuthArea = AppRoutes.isUnder(location, AppRoutes.authPrefix);
  if (user == null || !session.isAuthenticated) {
    return isAuthArea ? null : AppRoutes.login;
  }

  final role = user.role;
  final home = AppRoutes.homeFor(role);
  final isSelectStore = location == AppRoutes.selectStore;

  if (session.needsActiveStore) {
    return isSelectStore ? null : AppRoutes.selectStore;
  }

  // Staff được quay lại màn chọn chi nhánh để đổi chi nhánh.
  if (isSelectStore) return role.isStaff ? null : home;

  if (location == AppRoutes.splash || isAuthArea) return home;

  final prefix = AppRoutes.prefixFor(role);
  if (!AppRoutes.isUnder(location, prefix)) return home;
  // `/customer` không có màn riêng → về `/customer/home`.
  if (location == prefix && prefix != home) return home;

  return null;
}
