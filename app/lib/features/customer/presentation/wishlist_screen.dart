import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../core/widgets/state_views.dart';
import '../catalog/catalog_filter.dart';
import '../wishlist/wishlist_controller.dart';
import 'home_screen.dart' show customerContentMaxWidth;
import 'widgets/cart_icon_button.dart';
import 'widgets/product_card.dart';

/// Sản phẩm khách đã bấm thích.
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(wishlistProductsProvider);
    // Bỏ thích ở đây thì ẩn ngay, không chờ tải lại.
    final likedIds = ref.watch(wishlistControllerProvider);

    Future<void> refresh() => ref.refresh(wishlistProductsProvider.future);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu thích'),
        actions: const [CartIconButton(), SizedBox(width: 4)],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: customerContentMaxWidth),
          child: AsyncValueView(
            value: productsAsync,
            onRetry: () => ref.invalidate(wishlistProductsProvider),
            data: (all) {
              final products = all
                  .where((p) => likedIds.contains(p.id))
                  .toList();
              if (products.isEmpty) {
                return RefreshableFill(
                  onRefresh: refresh,
                  child: EmptyState(
                    icon: Icons.favorite_border,
                    message: 'Chưa có sản phẩm yêu thích',
                    hint: 'Bấm biểu tượng trái tim để lưu sản phẩm bạn thích.',
                    action: FilledButton(
                      onPressed: () {
                        ref.read(catalogFilterProvider.notifier).browse();
                        context.go(AppRoutes.customerCategory);
                      },
                      child: const Text('Khám phá sản phẩm'),
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: refresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: ProductSliverGrid(products: products),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
