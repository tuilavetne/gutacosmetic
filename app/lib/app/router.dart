import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/widgets/phase_placeholder.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/customer/presentation/customer_shell.dart';
import '../features/session/presentation/select_store_screen.dart';
import '../features/session/presentation/splash_screen.dart';
import '../features/session/session_controller.dart';
import 'route_guard.dart';
import 'routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  // Chỉ những thay đổi ảnh hưởng tới điều hướng mới kích hoạt redirect
  // (cập nhật điểm thành viên thì không).
  final refresh = ValueNotifier<Object?>(null);
  ref.listen(
    sessionControllerProvider.select(
      (s) =>
          (s.isRestoring, s.token, s.user?.id, s.user?.role, s.activeStore?.id),
    ),
    (_, next) => refresh.value = next,
  );

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: false,
    redirect: (context, state) => resolveRedirect(
      ref.read(sessionControllerProvider),
      state.matchedLocation,
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // ---- Auth ----
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.selectStore,
        builder: (context, state) => const SelectStoreScreen(),
      ),

      // ---- Owner (giai đoạn 7) ----
      GoRoute(
        path: AppRoutes.owner,
        builder: (context, state) =>
            const PhasePlaceholder(title: 'Trang chủ Owner', phase: 7),
      ),

      // ---- Manager (giai đoạn 6) ----
      GoRoute(
        path: AppRoutes.manager,
        builder: (context, state) =>
            const PhasePlaceholder(title: 'Trang chủ Quản lý', phase: 6),
      ),

      // ---- Sales (giai đoạn 5) ----
      GoRoute(
        path: AppRoutes.sales,
        builder: (context, state) =>
            const PhasePlaceholder(title: 'Trang chủ Sales', phase: 5),
      ),

      // ---- Customer: 4 tab, mỗi tab giữ stack riêng (giai đoạn 3–4) ----
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => CustomerShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customerHome,
                builder: (context, state) =>
                    const PhasePlaceholder(title: 'Trang chủ', phase: 3),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customerCategory,
                builder: (context, state) =>
                    const PhasePlaceholder(title: 'Danh mục', phase: 3),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customerOrders,
                builder: (context, state) =>
                    const PhasePlaceholder(title: 'Đơn hàng', phase: 4),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customerAccount,
                builder: (context, state) =>
                    const PhasePlaceholder(title: 'Tài khoản', phase: 4),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const PhasePlaceholder(
      title: 'Không tìm thấy trang',
      message: 'Đường dẫn không tồn tại.',
    ),
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
