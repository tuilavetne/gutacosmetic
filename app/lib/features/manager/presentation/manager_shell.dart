import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../session/session_controller.dart';
import '../data/manager_repository.dart';
import 'cashier/cashier_screen.dart';
import 'online/online_orders_screen.dart';
import 'rewards/rewards_screen.dart';
import 'stock/manager_stock_screen.dart';

/// Thứ tự trùng với các tab dưới cùng của [ManagerShell].
enum ManagerTab { cashier, onlineOrders, stock, rewards }

/// Tab Manager đang mở; về tab Thu ngân mỗi khi đổi tài khoản.
final managerTabProvider = NotifierProvider<ManagerTabController, ManagerTab>(
  ManagerTabController.new,
);

class ManagerTabController extends Notifier<ManagerTab> {
  @override
  ManagerTab build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    return ManagerTab.cashier;
  }

  void show(ManagerTab tab) => state = tab;
}

/// Khung role Manager/Thu ngân: Thu ngân · Đơn online · Kho · Đổi quà.
class ManagerShell extends ConsumerWidget {
  const ManagerShell({super.key});

  static const _pages = [
    CashierScreen(),
    OnlineOrdersScreen(),
    ManagerStockScreen(),
    RewardsScreen(),
  ];

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Đăng xuất',
      message: 'Bạn có chắc muốn đăng xuất khỏi tài khoản quản lý?',
      confirmLabel: 'Đăng xuất',
      destructive: true,
    );
    if (ok) await ref.read(sessionControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final activeStore = ref.watch(activeStoreProvider);
    final tab = ref.watch(managerTabProvider);
    final waitingOrders = ref.watch(cashierOrdersProvider).value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.storefront,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    activeStore?.name ?? 'GUTA Cosmetic',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (user != null)
              Text(
                'Quản lý: ${user.displayName}',
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: AppColors.primary,
            ),
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: const Text(
              'Đổi chi nhánh',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: () => context.push(AppRoutes.selectStore),
          ),
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
        onDestinationSelected: (index) => ref
            .read(managerTabProvider.notifier)
            .show(ManagerTab.values[index]),
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: waitingOrders > 0,
              label: Text('$waitingOrders'),
              child: const Icon(Icons.point_of_sale_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: waitingOrders > 0,
              label: Text('$waitingOrders'),
              child: const Icon(Icons.point_of_sale, color: AppColors.primary),
            ),
            label: 'Thu ngân',
          ),
          const NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping, color: AppColors.primary),
            label: 'Đơn online',
          ),
          const NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: AppColors.primary),
            label: 'Kho',
          ),
          const NavigationDestination(
            icon: Icon(Icons.card_giftcard_outlined),
            selectedIcon: Icon(Icons.card_giftcard, color: AppColors.primary),
            label: 'Đổi quà',
          ),
        ],
      ),
    );
  }
}

