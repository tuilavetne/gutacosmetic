import '../features/shared/models/enums.dart';

/// Đường dẫn route. Mỗi role có một nhánh riêng.
abstract final class AppRoutes {
  static const splash = '/splash';

  static const authPrefix = '/auth';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';

  static const selectStore = '/staff/select-store';

  static const owner = '/owner';
  static const manager = '/manager';
  static const sales = '/sales';

  static const customerPrefix = '/customer';
  static const customerHome = '/customer/home';
  static const customerCategory = '/customer/category';
  static const customerOrders = '/customer/orders';
  static const customerAccount = '/customer/account';

  static String homeFor(UserRole role) => switch (role) {
    UserRole.owner => owner,
    UserRole.manager => manager,
    UserRole.sales => sales,
    UserRole.customer => customerHome,
  };

  /// Tiền tố nhánh route mà role được phép vào.
  static String prefixFor(UserRole role) => switch (role) {
    UserRole.owner => owner,
    UserRole.manager => manager,
    UserRole.sales => sales,
    UserRole.customer => customerPrefix,
  };

  /// `true` nếu [location] là [prefix] hoặc nằm dưới `prefix/`.
  static bool isUnder(String location, String prefix) =>
      location == prefix || location.startsWith('$prefix/');
}
