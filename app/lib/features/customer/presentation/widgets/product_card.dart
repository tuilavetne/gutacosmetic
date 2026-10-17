import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../shared/models/models.dart';
import '../../cart/cart_controller.dart';
import '../../wishlist/wishlist_controller.dart';
import 'product_image.dart';

/// Thẻ sản phẩm trong lưới: ảnh vuông, nút thích, giá, nút thêm nhanh vào giỏ.
class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  /// Chiều cao phần chữ dưới ảnh — lưới dùng để tính chiều cao ô.
  static const double infoHeight = 138;

  void _addToCart(WidgetRef ref) {
    final added = ref.read(cartControllerProvider.notifier).add(product);
    showAppSnackBar(
      added > 0
          ? 'Đã thêm "${product.name}" vào giỏ hàng.'
          : 'Mỗi sản phẩm chỉ mua tối đa ${AppConstants.maxCartQuantity}.',
      isError: added == 0,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final liked = ref.watch(
      wishlistControllerProvider.select((ids) => ids.contains(product.id)),
    );
    final discount = discountPercentOf(
      price: product.price,
      originalPrice: product.originalPrice,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.customerProduct(product.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(url: product.coverImage),
                  if (discount != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-$discount%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      tooltip: liked ? 'Bỏ thích' : 'Yêu thích',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        minimumSize: const Size(34, 34),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                      ),
                      iconSize: 18,
                      onPressed: () => ref
                          .read(wishlistControllerProvider.notifier)
                          .toggle(product.id),
                      icon: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? AppColors.accent : AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: infoHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatVnd(product.price),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: product.hasDiscount
                              ? Text(
                                  formatVnd(product.originalPrice),
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                )
                              : Text(
                                  product.category ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                        ),
                        IconButton.filled(
                          tooltip: 'Thêm vào giỏ hàng',
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(32, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          iconSize: 18,
                          onPressed: () => _addToCart(ref),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lưới sản phẩm dạng sliver; số cột theo bề rộng (tối thiểu 2).
class ProductSliverGrid extends StatelessWidget {
  const ProductSliverGrid({super.key, required this.products});

  final List<Product> products;

  static const double _spacing = 12;
  static const double _targetTileWidth = 210;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final columns = math.max(2, (width / _targetTileWidth).floor());
        final tileWidth = (width - _spacing * (columns - 1)) / columns;
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: _spacing,
            crossAxisSpacing: _spacing,
            // Card có viền 1px trên và dưới.
            mainAxisExtent: tileWidth + ProductCard.infoHeight + 2,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) => ProductCard(product: products[i]),
            childCount: products.length,
          ),
        );
      },
    );
  }
}
