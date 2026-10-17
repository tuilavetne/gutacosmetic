import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../cart/cart_controller.dart';

/// Nút giỏ hàng trên AppBar, có badge số lượng.
class CartIconButton extends ConsumerWidget {
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartCountProvider);
    return IconButton(
      tooltip: 'Giỏ hàng',
      onPressed: () => context.push(AppRoutes.customerCart),
      icon: Badge(
        isLabelVisible: count > 0,
        backgroundColor: AppColors.accent,
        label: Text(count > 99 ? '99+' : '$count'),
        child: const Icon(Icons.shopping_bag_outlined),
      ),
    );
  }
}
