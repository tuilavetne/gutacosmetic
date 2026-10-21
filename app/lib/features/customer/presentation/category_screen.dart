import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/state_views.dart';
import '../../shared/models/models.dart';
import '../catalog/catalog_filter.dart';
import '../data/product_repository.dart';
import 'home_screen.dart' show customerContentMaxWidth;
import 'widgets/cart_icon_button.dart';
import 'widgets/product_card.dart';
import 'widgets/product_filter_sheet.dart';

/// Tab Danh mục: tìm kiếm, lọc theo danh mục / loại da và bộ lọc nâng cao.
class CustomerCategoryScreen extends ConsumerStatefulWidget {
  const CustomerCategoryScreen({super.key});

  @override
  ConsumerState<CustomerCategoryScreen> createState() =>
      _CustomerCategoryScreenState();
}

class _CustomerCategoryScreenState
    extends ConsumerState<CustomerCategoryScreen> {
  late final TextEditingController _search;
  Timer? _debounce;

  /// Kết quả lần trước — vẫn hiển thị trong lúc tải điều kiện lọc mới.
  List<Product>? _lastProducts;

  CatalogFilterController get _filter =>
      ref.read(catalogFilterProvider.notifier);

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(
      text: ref.read(catalogFilterProvider).search,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(AppConstants.searchDebounce, () {
      if (mounted) _filter.setSearch(value);
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _search.clear();
    _filter.setSearch('');
  }

  @override
  Widget build(BuildContext context) {
    // Trang chủ đổi từ khóa (browse) → cập nhật ô tìm kiếm.
    ref.listen(catalogFilterProvider.select((f) => f.search), (_, next) {
      if (_search.text.trim() == next) return;
      _debounce?.cancel();
      _search.text = next;
    });

    final filter = ref.watch(catalogFilterProvider);
    final query = filter.serverQuery;
    final productsAsync = ref.watch(productsProvider(query));
    if (productsAsync.hasValue) _lastProducts = productsAsync.value;
    final serverProducts =
        productsAsync.value ?? (productsAsync.isLoading ? _lastProducts : null);
    final products = serverProducts == null
        ? null
        : filter.apply(serverProducts);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục'),
        actions: [
          IconButton(
            tooltip: 'Yêu thích',
            onPressed: () => context.push(AppRoutes.customerWishlist),
            icon: const Icon(Icons.favorite_border),
          ),
          const CartIconButton(),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: customerContentMaxWidth),
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(productsProvider(query).future),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: _SearchRow(
                          controller: _search,
                          onChanged: _onSearchChanged,
                          onClear: _clearSearch,
                          advancedCount: filter.advancedCount,
                          onOpenFilter: () => showProductFilterSheet(
                            context,
                            brands: brandsOf(serverProducts ?? const []),
                          ),
                        ),
                      ),
                      _ChipStrip(
                        allLabel: 'Tất cả danh mục',
                        options: [for (final c in productCategories) c.name],
                        selected: filter.category,
                        onSelected: _filter.setCategory,
                      ),
                      _ChipStrip(
                        allLabel: 'Mọi loại da',
                        options: skinTypeOptions,
                        selected: filter.skinType,
                        onSelected: _filter.setSkinType,
                      ),
                      if (filter.hasAdvanced) _ActiveFilters(filter: filter),
                      SizedBox(
                        height: 3,
                        child: productsAsync.isLoading && products != null
                            ? const LinearProgressIndicator()
                            : null,
                      ),
                      if (products != null && products.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                          child: Text(
                            _resultSummary(products.length, filter),
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                ..._results(productsAsync, products, serverProducts, filter),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _resultSummary(int count, CatalogFilter filter) {
    final search = filter.search.trim();
    return search.isEmpty ? '$count sản phẩm' : '$count sản phẩm cho "$search"';
  }

  List<Widget> _results(
    AsyncValue<List<Product>> async,
    List<Product>? products,
    List<Product>? serverProducts,
    CatalogFilter filter,
  ) {
    Widget fill(Widget child) =>
        SliverFillRemaining(hasScrollBody: false, child: child);

    if (products == null) {
      if (async case AsyncError(:final error)) {
        return [
          fill(
            ErrorState(
              error: error,
              onRetry: () =>
                  ref.invalidate(productsProvider(filter.serverQuery)),
            ),
          ),
        ];
      }
      return [fill(const LoadingView())];
    }
    if (products.isNotEmpty) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: ProductSliverGrid(products: products),
        ),
      ];
    }
    // Server có kết quả nhưng bộ lọc nâng cao loại hết.
    if (serverProducts != null && serverProducts.isNotEmpty) {
      return [
        fill(
          EmptyState(
            icon: Icons.filter_alt_off_outlined,
            message: 'Không có sản phẩm phù hợp với bộ lọc',
            hint: 'Hãy thử nới khoảng giá hoặc chọn thương hiệu khác.',
            action: OutlinedButton(
              onPressed: _filter.clearAdvanced,
              child: const Text('Xóa bộ lọc nâng cao'),
            ),
          ),
        ),
      ];
    }
    return [
      fill(
        const EmptyState(
          icon: Icons.search_off_outlined,
          message: 'Không tìm thấy sản phẩm',
          hint: 'Hãy thử từ khóa khác hoặc bỏ bớt bộ lọc.',
        ),
      ),
    ];
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.advancedCount,
    required this.onOpenFilter,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final int advancedCount;
  final VoidCallback onOpenFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Tìm sản phẩm chăm sóc da...',
                prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                suffixIcon: value.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Xóa',
                        onPressed: onClear,
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Badge(
          isLabelVisible: advancedCount > 0,
          backgroundColor: AppColors.accent,
          label: Text('$advancedCount'),
          child: IconButton.filled(
            tooltip: 'Bộ lọc nâng cao',
            style: IconButton.styleFrom(
              backgroundColor: advancedCount > 0
                  ? AppColors.primary
                  : AppColors.ink,
              minimumSize: const Size(50, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            onPressed: onOpenFilter,
            icon: const Icon(Icons.tune),
          ),
        ),
      ],
    );
  }
}

/// Hàng chip chọn một (hoặc "tất cả" = `null`), cuộn ngang.
class _ChipStrip extends StatelessWidget {
  const _ChipStrip({
    required this.allLabel,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String allLabel;
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final values = <String?>[null, ...options];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final value = values[i];
          final isSelected = value == selected;
          return ChoiceChip(
            label: Text(value ?? allLabel),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: AppColors.ink,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) => onSelected(value),
          );
        },
      ),
    );
  }
}

/// Các bộ lọc nâng cao đang bật, bấm × để bỏ từng cái.
class _ActiveFilters extends ConsumerWidget {
  const _ActiveFilters({required this.filter});

  final CatalogFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(catalogFilterProvider.notifier);
    Widget chip(IconData icon, String label, VoidCallback onDeleted) =>
        InputChip(
          avatar: Icon(icon, size: 16, color: AppColors.accent),
          label: Text(label),
          onDeleted: onDeleted,
          deleteButtonTooltipMessage: 'Bỏ lọc',
        );

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          if (filter.hasPriceRange)
            chip(
              Icons.payments_outlined,
              priceRangeLabel(filter.minPrice, filter.maxPrice),
              notifier.clearPriceRange,
            ),
          if (filter.brand != null)
            chip(Icons.sell_outlined, filter.brand!, notifier.clearBrand),
          if (filter.sort != ProductSort.newest)
            chip(Icons.sort, filter.sort.label, notifier.clearSort),
          TextButton.icon(
            onPressed: notifier.clearAdvanced,
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Xóa tất cả'),
          ),
        ].expand((w) => [w, const SizedBox(width: 8)]).toList(),
      ),
    );
  }
}
