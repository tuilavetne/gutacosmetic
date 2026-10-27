import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../session/session_controller.dart';
import '../data/owner_repository.dart';
import 'admin/admin_screen.dart';
import 'dashboard/owner_dashboard_screen.dart';
import 'products/owner_products_screen.dart';
import 'revenue/revenue_screen.dart';
import 'stock/owner_stock_screen.dart';

/// Thứ tự trùng với các tab dưới cùng của [OwnerShell].
enum OwnerTab { dashboard, revenue, stock, products, admin }

/// Tab Owner đang mở; về Tổng quan mỗi khi đổi tài khoản.
final ownerTabProvider = NotifierProvider<OwnerTabController, OwnerTab>(
  OwnerTabController.new,
);

class OwnerTabController extends Notifier<OwnerTab> {
  @override
  OwnerTab build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    return OwnerTab.dashboard;
  }

  void show(OwnerTab tab) => state = tab;
}

/// Khung role Owner (chủ chuỗi): dữ liệu toàn bộ chi nhánh.
class OwnerShell extends ConsumerWidget {
  const OwnerShell({super.key});

  static const _pages = [
    OwnerDashboardScreen(),
    RevenueScreen(),
    OwnerStockScreen(),
    OwnerProductsScreen(),
    AdminScreen(),
  ];

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Đăng xuất',
      message: 'Bạn có chắc muốn đăng xuất khỏi tài khoản chủ chuỗi?',
      confirmLabel: 'Đăng xuất',
      destructive: true,
    );
    if (ok) await ref.read(sessionControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final tab = ref.watch(ownerTabProvider);
    final dashboard = ref.watch(ownerDashboardProvider).value;
    final pending = dashboard == null
        ? 0
        : dashboard.pendingRestock + dashboard.pendingReturns;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GUTA Cosmetic • Toàn chuỗi',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            if (user != null)
              Text(
                'Chủ chuỗi: ${user.displayName}',
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout, color: AppColors.muted, size: 20),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      body: IndexedStack(index: tab.index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.index,
        onDestinationSelected: (index) =>
            ref.read(ownerTabProvider.notifier).show(OwnerTab.values[index]),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
            label: 'Tổng quan',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: AppColors.primary),
            label: 'Doanh thu',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              child: const Icon(Icons.inventory_2_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              child: const Icon(Icons.inventory_2, color: AppColors.primary),
            ),
            label: 'Kho & duyệt',
          ),
          const NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa, color: AppColors.primary),
            label: 'Sản phẩm',
          ),
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: AppColors.primary),
            label: 'Cửa hàng & NV',
          ),
        ],
      ),
    );
  }
}
