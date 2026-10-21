import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/widgets/phase_placeholder.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/customer/presentation/account_screen.dart';
import '../features/customer/presentation/cart_screen.dart';
import '../features/customer/presentation/change_password_screen.dart';
import '../features/customer/presentation/category_screen.dart';
import '../features/customer/presentation/checkout_screen.dart';
import '../features/customer/presentation/customer_shell.dart';
import '../features/customer/presentation/edit_profile_screen.dart';
import '../features/customer/presentation/home_screen.dart';
import '../features/customer/presentation/order_detail_screen.dart';
import '../features/customer/presentation/orders_screen.dart';
import '../features/customer/presentation/payos_payment_screen.dart';
import '../features/customer/presentation/product_detail_screen.dart';
import '../features/customer/presentation/wishlist_screen.dart';
import '../features/customer/presentation/write_review_screen.dart';
import '../features/sales/presentation/sales_shell.dart';
import '../features/session/presentation/select_store_screen.dart';
import '../features/session/presentation/splash_screen.dart';
import '../features/session/session_controller.dart';
import 'route_guard.dart';
import 'routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  // Chỉ những thay đổi ảnh hưởng tới điều hướng mới kích hoạt redirect
  // (cập nhật điểm thành viên hay thay token sau khi đổi mật khẩu thì không —
  // refresh giữa lúc `pop()` sẽ dựng lại trang vừa đóng).
  final refresh = ValueNotifier<Object?>(null);
  ref.listen(
    sessionControllerProvider.select(
      (s) => (
        s.isRestoring,
        s.token != null,
        s.user?.id,
        s.user?.role,
        s.activeStore?.id,
      ),
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

      // ---- Sales (Bán hàng POS & Đơn tại quầy) ----
      GoRoute(
        path: AppRoutes.sales,
        builder: (context, state) => const SalesShell(),
      ),

      // ---- Customer: 4 tab, mỗi tab giữ stack riêng (giai đoạn 3–4) ----
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => CustomerShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customerHome,
                builder: (context, state) => const CustomerHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customerCategory,
                builder: (context, state) => const CustomerCategoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customerOrders,
                builder: (context, state) => const CustomerOrdersScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) =>
                        OrderDetailScreen(orderId: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'payment',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => PayosPaymentScreen(
                          orderId: state.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: 'review',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => WriteReviewScreen(
                          orderId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customerAccount,
                builder: (context, state) => const CustomerAccountScreen(),
              ),
            ],
          ),
        ],
      ),

      // ---- Customer: màn con, mở đè lên bottom navigation ----
      GoRoute(
        path: AppRoutes.customerWishlist,
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerEditProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerChangePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerProductPattern,
        builder: (context, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.customerCart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerCheckout,
        builder: (context, state) => const CheckoutScreen(),
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
