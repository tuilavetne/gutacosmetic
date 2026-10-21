import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../session/session_controller.dart';
import 'pos_screen.dart';
import 'sales_orders_screen.dart';

class SalesShell extends ConsumerStatefulWidget {
  const SalesShell({super.key});

  @override
  ConsumerState<SalesShell> createState() => _SalesShellState();
}

class _SalesShellState extends ConsumerState<SalesShell> {
  int _currentIndex = 0;

  final _pages = const [
    PosScreen(),
    SalesOrdersScreen(),
  ];

  Future<void> _logout() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Đăng xuất',
      message: 'Bạn có chắc muốn đăng xuất khỏi tài khoản nhân viên?',
      confirmLabel: 'Đăng xuất',
      destructive: true,
    );
    if (ok) {
      await ref.read(sessionControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final activeStore = ref.watch(activeStoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.storefront, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        activeStore?.name ?? 'GUTA Cosmetic POS',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (user != null)
              Padding(
                padding: const EdgeInsets.only(top: 3, left: 2),
                child: Text(
                  'Nhân viên: ${user.displayName} • Ca bán hàng POS',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.swap_horiz, size: 16, color: AppColors.primary),
            label: const Text(
              'Đổi chi nhánh',
              style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
            onPressed: () => context.push(AppRoutes.selectStore),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout, color: AppColors.muted),
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale, color: AppColors.primary),
            label: 'Bán hàng (POS)',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: AppColors.primary),
            label: 'Đơn tại quầy',
          ),
        ],
      ),
    );
  }
}
