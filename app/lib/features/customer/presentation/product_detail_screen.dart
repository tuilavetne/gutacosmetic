import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ionicon_map.dart';
import '../../../core/widgets/app_messenger.dart';
import '../../../core/widgets/state_views.dart';
import '../../shared/models/models.dart';
import '../cart/cart_controller.dart';
import '../catalog/product_reviews_controller.dart';
import '../catalog/rating_summary.dart';
import '../data/product_repository.dart';
import '../wishlist/wishlist_controller.dart';
import 'widgets/cart_icon_button.dart';
import 'widgets/product_gallery.dart';
import 'widgets/product_reviews_section.dart';
import 'widgets/store_stock_section.dart';

/// Bề rộng tối đa của phần nội dung trên màn hình rộng (web/tablet).
const _contentMaxWidth = 720.0;

/// Chi tiết sản phẩm: ảnh, giá, tồn kho từng cửa hàng, thành phần, đánh giá.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    return productAsync.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      loading: () => Scaffold(appBar: AppBar(), body: const LoadingView()),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
        body: ErrorState(
          error: error,
          onRetry: () => ref.invalidate(productDetailProvider(productId)),
        ),
      ),
      data: (product) => _ProductDetailView(product: product),
    );
  }
}

class _ProductDetailView extends ConsumerStatefulWidget {
  const _ProductDetailView({required this.product});

  final Product product;

  @override
  ConsumerState<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends ConsumerState<_ProductDetailView> {
  final _reviewsKey = GlobalKey();
  int _quantity = 1;

  Product get _product => widget.product;

  Future<void> _refresh() {
    final id = _product.id;
    ref
      ..invalidate(productStockProvider(id))
      ..invalidate(productReviewsProvider(id));
    return ref.refresh(productDetailProvider(id).future);
  }

  void _scrollToReviews() {
    final context = _reviewsKey.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  /// Thêm vào giỏ; trả về `false` nếu không thêm được sản phẩm nào.
  bool _addToCart({bool silent = false}) {
    final added = ref
        .read(cartControllerProvider.notifier)
        .add(_product, quantity: _quantity);
    if (added == 0) {
      showAppSnackBar(
        'Mỗi sản phẩm chỉ mua tối đa ${AppConstants.maxCartQuantity}. '
        'Giỏ hàng của bạn đã đủ số lượng này.',
        isError: true,
      );
      return false;
    }
    if (added < _quantity) {
      showAppSnackBar(
        'Chỉ thêm được $added sản phẩm — mỗi sản phẩm tối đa '
        '${AppConstants.maxCartQuantity}.',
      );
    } else if (!silent) {
      showAppSnackBar('Đã thêm $added "${_product.name}" vào giỏ hàng.');
    }
    return true;
  }

  void _buyNow() {
    final inCart = ref
        .read(cartControllerProvider)
        .any((e) => e.productId == _product.id);
    // Đã đủ tối đa trong giỏ thì vẫn mở giỏ để thanh toán.
    if (_addToCart(silent: true) || inCart) {
      context.push(AppRoutes.customerCart);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final stocksAsync = ref.watch(productStockProvider(product.id));
    final reviewsAsync = ref.watch(productReviewsProvider(product.id));
    final liked = ref.watch(
      wishlistControllerProvider.select((ids) => ids.contains(product.id)),
    );

    // Giới hạn số lượng theo cửa hàng còn nhiều hàng nhất: mỗi đơn chỉ lấy
    // hàng từ một cửa hàng. Chưa tải được tồn kho thì chỉ giới hạn theo giỏ.
    final stocks = stocksAsync.value;
    final bestStoreStock = stocks?.fold(
      0,
      (best, e) => math.max(best, e.availableStock),
    );
    final soldOut = bestStoreStock == 0;
    final maxQuantity = math.max(
      1,
      math.min(
        AppConstants.maxCartQuantity,
        bestStoreStock ?? AppConstants.maxCartQuantity,
      ),
    );
    if (_quantity > maxQuantity) _quantity = maxQuantity;

    final width = MediaQuery.sizeOf(context).width;
    final galleryHeight = math.min(width, 420.0);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        edgeOffset: kToolbarHeight + MediaQuery.paddingOf(context).top,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: galleryHeight,
              backgroundColor: AppColors.surface,
              leading: Padding(
                padding: const EdgeInsets.all(6),
                child: _RoundButton(
                  child: IconButton(
                    tooltip: 'Quay lại',
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
              ),
              actions: [
                _RoundButton(
                  child: IconButton(
                    tooltip: liked ? 'Bỏ thích' : 'Yêu thích',
                    onPressed: () => ref
                        .read(wishlistControllerProvider.notifier)
                        .toggle(product.id),
                    icon: Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      color: liked ? AppColors.accent : AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const _RoundButton(child: CartIconButton()),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: ColoredBox(
                  color: const Color(0xFFF0F1EE),
                  child: Center(
                    child: SizedBox(
                      width: galleryHeight,
                      height: galleryHeight,
                      child: ProductGallery(images: product.gallery),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _InfoHeader(
                          product: product,
                          summary: RatingSummary.of(product),
                          onRatingTap: _scrollToReviews,
                        ),
                        const _SectionTitle('Tồn kho tại cửa hàng'),
                        StoreStockSection(
                          stocks: stocksAsync,
                          onRetry: () =>
                              ref.invalidate(productStockProvider(product.id)),
                        ),
                        if ((product.description ?? '').trim().isNotEmpty) ...[
                          const _SectionTitle('Mô tả sản phẩm'),
                          Text(
                            product.description!.trim(),
                            style: const TextStyle(height: 1.5),
                          ),
                        ],
                        if (_specsOf(product).isNotEmpty) ...[
                          const _SectionTitle('Thông tin sản phẩm'),
                          _SpecsCard(specs: _specsOf(product)),
                        ],
                        const _SectionTitle('Thành phần nổi bật'),
                        _Ingredients(ingredients: product.ingredients),
                        _SectionTitle('Đánh giá sản phẩm', key: _reviewsKey),
                        ProductReviewsSection(
                          product: product,
                          reviews: reviewsAsync,
                          onRetry: () => ref.invalidate(
                            productReviewsProvider(product.id),
                          ),
                          onLoadMore: () => ref
                              .read(productReviewsProvider(product.id).notifier)
                              .loadMore(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _PurchaseBar(
        quantity: _quantity,
        maxQuantity: maxQuantity,
        soldOut: soldOut,
        onQuantityChanged: (q) => setState(() => _quantity = q),
        onAddToCart: () => _addToCart(),
        onBuyNow: _buyNow,
      ),
    );
  }
}

typedef _Spec = ({IconData icon, String label, String value});

List<_Spec> _specsOf(Product p) => [
  if (p.sku.isNotEmpty) (icon: Icons.qr_code_2, label: 'Mã SP', value: p.sku),
  if ((p.category ?? '').isNotEmpty)
    (icon: Icons.category_outlined, label: 'Danh mục', value: p.category!),
  if ((p.volume ?? '').isNotEmpty)
    (icon: Icons.inventory_2_outlined, label: 'Dung tích', value: p.volume!),
  if ((p.origin ?? '').isNotEmpty)
    (icon: Icons.public, label: 'Xuất xứ', value: p.origin!),
  if ((p.expiryDate ?? '').isNotEmpty)
    (
      icon: Icons.calendar_today_outlined,
      label: 'Hạn sử dụng',
      value: p.expiryDate!,
    ),
  if (p.skinTypes.isNotEmpty)
    (
      icon: Icons.face_outlined,
      label: 'Loại da',
      value: p.skinTypes.join(', '),
    ),
];

/// Nền tròn trắng cho nút nằm đè trên ảnh.
class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 6)],
      ),
      child: child,
    );
  }
}

class _InfoHeader extends StatelessWidget {
  const _InfoHeader({
    required this.product,
    required this.summary,
    required this.onRatingTap,
  });

  final Product product;
  final RatingSummary summary;
  final VoidCallback onRatingTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final discount = discountPercentOf(
      price: product.price,
      originalPrice: product.originalPrice,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.brand.isNotEmpty)
          Text(
            product.brand.toUpperCase(),
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          product.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onRatingTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StarRating(rating: summary.average),
                const SizedBox(width: 6),
                Text(
                  summary.hasReviews
                      ? '${summary.averageLabel} '
                            '(${formatNumber(summary.count)} đánh giá)'
                      : 'Chưa có đánh giá',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 4,
          children: [
            Text(
              formatVnd(product.price),
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (product.hasDiscount)
              Text(
                formatVnd(product.originalPrice),
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 15,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            if (discount != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-$discount%',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SpecsCard extends StatelessWidget {
  const _SpecsCard({required this.specs});

  final List<_Spec> specs;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < specs.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 14, endIndent: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(specs[i].icon, size: 18, color: AppColors.muted),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 96,
                    child: Text(
                      specs[i].label,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      specs[i].value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Ingredients extends StatelessWidget {
  const _Ingredients({required this.ingredients});

  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    final items = ingredients
        .where((e) => e.title.trim().isNotEmpty || e.subtitle.trim().isNotEmpty)
        .toList();
    if (items.isEmpty) {
      return const Text(
        'Chưa có thông tin thành phần.',
        style: TextStyle(color: AppColors.muted),
      );
    }
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        materialIconForIonicon(item.icon),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.title.trim().isNotEmpty)
                            Text(
                              item.title.trim(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          if (item.subtitle.trim().isNotEmpty)
                            Text(
                              item.subtitle.trim(),
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Thanh dưới: chọn số lượng, "Thêm vào giỏ" và "Mua ngay".
class _PurchaseBar extends StatelessWidget {
  const _PurchaseBar({
    required this.quantity,
    required this.maxQuantity,
    required this.soldOut,
    required this.onQuantityChanged,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  final int quantity;
  final int maxQuantity;
  final bool soldOut;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Số lượng',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      _QuantityStepper(
                        value: quantity,
                        max: maxQuantity,
                        enabled: !soldOut,
                        onChanged: onQuantityChanged,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: OutlinedButton.icon(
                          onPressed: soldOut ? null : onAddToCart,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                          ),
                          icon: const Icon(Icons.add_shopping_cart, size: 20),
                          label: const Text('Thêm vào giỏ'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 5,
                        child: FilledButton(
                          onPressed: soldOut ? null : onBuyNow,
                          child: Text(soldOut ? 'Tạm hết hàng' : 'Mua ngay'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.value,
    required this.max,
    required this.enabled,
    required this.onChanged,
  });

  final int value;
  final int max;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final style = IconButton.styleFrom(
      minimumSize: const Size(36, 36),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Giảm số lượng',
          style: style,
          iconSize: 18,
          onPressed: enabled && value > AppConstants.minCartQuantity
              ? () => onChanged(value - 1)
              : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          tooltip: 'Tăng số lượng',
          style: style,
          iconSize: 18,
          onPressed: !enabled
              ? null
              : value < max
              ? () => onChanged(value + 1)
              : () => showAppSnackBar(
                  max < AppConstants.maxCartQuantity
                      ? 'Mỗi cửa hàng hiện chỉ còn tối đa $max sản phẩm.'
                      : 'Mỗi sản phẩm chỉ mua tối đa $max.',
                ),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
