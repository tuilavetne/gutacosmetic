import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../session/session_controller.dart';
import '../../shared/models/models.dart';
import '../cart/cart_controller.dart';
import '../catalog/catalog_filter.dart';
import '../data/product_repository.dart';
import '../wishlist/wishlist_controller.dart';
import 'widgets/cart_icon_button.dart';
import 'widgets/member_avatar.dart';
import 'widgets/product_card.dart';
import 'widgets/product_image.dart';
import 'widgets/store_list_sheet.dart';

/// Số sản phẩm gợi ý ở Trang chủ.
const _recommendedLimit = 6;

/// Bề rộng tối đa của nội dung (khi chạy trên web/tablet).
const customerContentMaxWidth = 960.0;

/// Tab Trang chủ của khách hàng.
class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Mở tab Danh mục với điều kiện mới.
  void _browse({String? category, String search = ''}) {
    ref
        .read(catalogFilterProvider.notifier)
        .browse(category: category, search: search);
    context.go(AppRoutes.customerCategory);
  }

  void _submitSearch() {
    final text = _search.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    _search.clear();
    _browse(search: text);
  }

  Future<void> _refresh() async {
    final session = ref.read(sessionControllerProvider.notifier);
    await Future.wait<void>([
      ref.refresh(productsProvider(allProductsQuery).future),
      session.refreshUser().then<void>((_) {}, onError: (_) {}),
      ref.read(wishlistControllerProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final productsAsync = ref.watch(productsProvider(allProductsQuery));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: customerContentMaxWidth,
            ),
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    sliver: SliverList.list(
                      children: [
                        _TopBar(user: user),
                        const SizedBox(height: 16),
                        _Greeting(user: user),
                        const SizedBox(height: 16),
                        _SearchBar(
                          controller: _search,
                          onSubmit: _submitSearch,
                        ),
                        const SizedBox(height: 16),
                        _QuickCartCard(onShop: () => _browse()),
                        const SizedBox(height: 16),
                        _Banner(onExplore: () => _browse()),
                        const SizedBox(height: 20),
                        _QuickMenu(onNewArrivals: () => _browse()),
                        const SizedBox(height: 24),
                        _SectionHeader(
                          title: 'Mua theo danh mục',
                          caption: 'Đủ bước cho mọi quy trình chăm sóc',
                          onViewAll: () => _browse(),
                        ),
                        const SizedBox(height: 12),
                        _CategoryStrip(
                          onSelect: (name) => _browse(category: name),
                        ),
                        const SizedBox(height: 24),
                        _SectionHeader(
                          title: 'Gợi ý cho bạn',
                          onViewAll: () => _browse(),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  ..._recommended(productsAsync),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _recommended(AsyncValue<List<Product>> async) {
    Widget box(Widget child) => SliverToBoxAdapter(child: child);
    return switch (async) {
      AsyncValue(:final value?) when value.isNotEmpty => [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: ProductSliverGrid(
            products: value.take(_recommendedLimit).toList(),
          ),
        ),
      ],
      AsyncValue(hasValue: true) => [
        box(
          const EmptyState(
            icon: Icons.shopping_bag_outlined,
            message: 'Sản phẩm đang được cập nhật',
            hint: 'Quay lại sau nhé!',
          ),
        ),
      ],
      AsyncError(:final error) => [
        box(
          ErrorState(
            error: error,
            onRetry: () => ref.invalidate(productsProvider(allProductsQuery)),
          ),
        ),
      ],
      _ => [box(const LoadingView())],
    };
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GUTA',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            Text(
              'COSMETIC',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Yêu thích',
          onPressed: () => context.push(AppRoutes.customerWishlist),
          icon: const Icon(Icons.favorite_border),
        ),
        const CartIconButton(),
        const SizedBox(width: 4),
        Tooltip(
          message: 'Tài khoản',
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            onTap: () => context.go(AppRoutes.customerAccount),
            child: user == null
                ? const SizedBox.square(dimension: 40)
                : MemberAvatar(user: user!, size: 40, showBadge: false),
          ),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.user});

  final AppUser? user;

  /// Tên gọi tiếng Việt là từ cuối: "Nguyễn Thị Lan" → "Lan".
  static String _givenName(AppUser? user) {
    final parts = (user?.displayName ?? '').trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? '' : parts.last;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = _givenName(user);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? 'Xin chào!' : 'Xin chào, $name',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tìm sản phẩm phù hợp với làn da của bạn hôm nay.',
                style: TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
        if (user != null) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  '${formatNumber(user!.points)} điểm',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmit(),
      decoration: InputDecoration(
        hintText: 'Tìm sản phẩm...',
        prefixIcon: const Icon(Icons.search, color: AppColors.muted),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(5),
          child: IconButton.filled(
            tooltip: 'Tìm kiếm',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.ink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onSubmit,
            icon: const Icon(Icons.arrow_forward, size: 20),
          ),
        ),
      ),
    );
  }
}

/// Tóm tắt giỏ hàng: trống thì mời mua sắm, có hàng thì hiện ảnh + tạm tính.
class _QuickCartCard extends ConsumerWidget {
  const _QuickCartCard({required this.onShop});

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartControllerProvider);
    final subtotal = ref.watch(cartSubtotalProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Giỏ hàng của bạn',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            if (items.isEmpty) ...[
              const SizedBox(height: 12),
              const Icon(
                Icons.shopping_bag_outlined,
                size: 30,
                color: AppColors.border,
              ),
              const SizedBox(height: 6),
              const Text(
                'Giỏ hàng của bạn đang trống',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              Center(
                child: FilledButton(
                  onPressed: onShop,
                  child: const Text('Đi mua sắm ngay'),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 62,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) => _CartThumb(
                    image: items[i].image,
                    quantity: items[i].quantity,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Tạm tính: ',
                        style: const TextStyle(color: AppColors.muted),
                        children: [
                          TextSpan(
                            text: formatVnd(subtotal),
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => context.push(AppRoutes.customerCart),
                    child: const Text('Xem giỏ hàng'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartThumb extends StatelessWidget {
  const _CartThumb({required this.image, required this.quantity});

  final String? image;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 62,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 56,
                height: 56,
                child: ProductImage(url: image, iconSize: 18),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                'x$quantity',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        height: 180,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/home_banner.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: Color(0xFFEDF1ED)),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.6,
                heightFactor: 1,
                child: Container(
                  color: Colors.white.withValues(alpha: 0.8),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ƯU ĐÃI TUẦN NÀY',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Làn da khỏe bắt đầu từ đây',
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Xây dựng quy trình đơn giản cho làn da của bạn.',
                        maxLines: 2,
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          minimumSize: const Size(0, 34),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        onPressed: onExplore,
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.arrow_forward, size: 15),
                        label: const Text('Khám phá ngay'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickMenu extends StatelessWidget {
  const _QuickMenu({required this.onNewArrivals});

  final VoidCallback onNewArrivals;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.auto_awesome_outlined, 'Hàng mới về', onNewArrivals),
      (
        Icons.favorite_border,
        'Yêu thích',
        () => context.push(AppRoutes.customerWishlist),
      ),
      (
        Icons.shopping_bag_outlined,
        'Giỏ hàng',
        () => context.push(AppRoutes.customerCart),
      ),
      (
        Icons.storefront_outlined,
        'Cửa hàng',
        () => showStoreListSheet(context),
      ),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          for (final (icon, label, onTap) in items)
            Expanded(
              child: _IconTile(icon: icon, label: label, onTap: onTap),
            ),
        ],
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.onSelect});

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Icon 56 + nhãn 2 dòng + padding.
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: productCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final category = productCategories[i];
          return SizedBox(
            width: 80,
            child: _IconTile(
              icon: category.icon,
              label: category.name,
              round: true,
              onTap: () => onSelect(category.name),
            ),
          );
        },
      ),
    );
  }
}

/// Ô icon + nhãn 2 dòng (menu nhanh, danh mục).
class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.round = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool round;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: round ? 56 : 46,
              height: round ? 56 : 46,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F2),
                borderRadius: round ? null : BorderRadius.circular(10),
                shape: round ? BoxShape.circle : BoxShape.rectangle,
              ),
              child: Icon(icon, color: AppColors.accent, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onViewAll,
    this.caption,
  });

  final String title;
  final String? caption;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (caption != null)
                Text(
                  caption!,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
            ],
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(foregroundColor: AppColors.accent),
          child: const Text('Xem tất cả'),
        ),
      ],
    );
  }
}
