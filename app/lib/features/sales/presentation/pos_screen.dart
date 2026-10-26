import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_messenger.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/state_views.dart';
import '../../session/session_controller.dart';
import '../../shared/models/models.dart';
import 'controllers/pos_cart_controller.dart';
import '../data/sales_repository.dart';
import 'widgets/customer_select_dialog.dart';
import 'widgets/other_stores_stock_dialog.dart';
import 'widgets/pos_cart_bottom_sheet.dart';

const _skinTypeOptions = [
  '',
  'Da dầu',
  'Da khô',
  'Da nhạy cảm',
  'Da hỗn hợp',
  'Da thường/Mọi loại da',
];

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _searchController = TextEditingController();
  String _selectedSkinType = '';
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _searchQuery = value.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeStore = ref.watch(activeStoreProvider);
    final activeStoreId = activeStore?.id ?? '';
    final cart = ref.watch(posCartControllerProvider);
    final cartController = ref.read(posCartControllerProvider.notifier);

    final query = (
      search: _searchQuery,
      category: '',
      skinType: _selectedSkinType,
    );
    final productsAsync = ref.watch(salesProductsProvider(query));

    return ColoredBox(
      color: AppColors.background,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          if (cart.isEditingDraft)
            _EditingDraftBanner(
              orderCode: cart.editingOrderCode ?? '',
              onStop: () async {
                final ok = await showConfirmDialog(
                  context,
                  title: 'Thôi sửa giỏ tạm?',
                  message:
                      'Các thay đổi chưa lưu sẽ bị bỏ. Giỏ tạm '
                      '${cart.editingOrderCode} vẫn giữ như lần lưu trước.',
                  confirmLabel: 'Thôi sửa',
                );
                if (ok) cartController.reset();
              },
            ),
          // Header: Customer bar + Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                // Quick customer selector
                InkWell(
                  onTap: () async {
                    final selected = await CustomerSelectDialog.show(
                      context,
                      current: cart.customer,
                    );
                    if (selected != null) {
                      cartController.selectCustomer(selected);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          cart.customer?.isMember == true
                              ? Icons.star_rounded
                              : Icons.person_outline,
                          color: cart.customer?.isMember == true
                              ? AppColors.primary
                              : AppColors.muted,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Khách: ${cart.effectiveCustomerName} ${cart.effectiveCustomerPhone.isNotEmpty ? "(${cart.effectiveCustomerPhone})" : ""}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Text(
                          'Đổi khách',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Search box
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Tra cứu tên, SKU, thương hiệu...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Skin types horizontal filter
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _skinTypeOptions.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final type = _skinTypeOptions[index];
                      final isSelected = _selectedSkinType == type;
                      return ChoiceChip(
                        label: Text(
                          type.isEmpty ? 'Tất cả loại da' : type,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.white,
                        onSelected: (val) {
                          setState(() => _selectedSkinType = val ? type : '');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Product list with inventory
          Expanded(
            child: AsyncValueView<List<ProductInventory>>(
              value: productsAsync,
              onRetry: () => ref.invalidate(salesProductsProvider(query)),
              data: (products) {
                if (products.isEmpty) {
                  return const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    message: 'Không tìm thấy sản phẩm phù hợp',
                    hint: 'Thử tìm từ khóa hoặc đổi bộ lọc loại da.',
                  );
                }

                return ListView.separated(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = products[index];
                    final product = item.product;
                    final stockAtBranch = item.stockAt(activeStoreId);
                    final available = stockAtBranch?.availableStock ?? 0;
                    final isOutOfStock = available <= 0;
                    final isLowStock =
                        stockAtBranch != null && stockAtBranch.isLowStock;

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.image ?? '',
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.spa_outlined,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'SKU: ${product.sku} • Hãng: ${product.brand}',
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        formatVnd(product.price),
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Stock badge at current store
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isOutOfStock
                                              ? AppColors.accent.withValues(alpha: 0.1)
                                              : isLowStock
                                                  ? AppColors.warning.withValues(alpha: 0.12)
                                                  : AppColors.success.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isOutOfStock
                                              ? 'Hết tại chi nhánh'
                                              : 'Còn $available tại quầy',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isOutOfStock
                                                ? AppColors.accent
                                                : isLowStock
                                                    ? AppColors.warning
                                                    : AppColors.success,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      // View other stores button
                                      TextButton.icon(
                                        style: TextButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                        ),
                                        icon: const Icon(
                                          Icons.storefront_outlined,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          'Kho khác',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                        onPressed: () {
                                          OtherStoresStockDialog.show(
                                            context,
                                            inventory: item,
                                            currentStoreId: activeStoreId,
                                          );
                                        },
                                      ),
                                      const Spacer(),
                                      // Add to POS cart button
                                      Builder(
                                        builder: (_) {
                                          final inCart = cart.items
                                              .where((e) => e.product.id == product.id)
                                              .firstOrNull;
                                          final inCartQty = inCart?.quantity ?? 0;

                                          if (inCartQty > 0) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.background,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: AppColors.primary.withValues(alpha: 0.3),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    visualDensity: VisualDensity.compact,
                                                    iconSize: 20,
                                                    padding: const EdgeInsets.all(4),
                                                    constraints: const BoxConstraints(
                                                      minWidth: 32,
                                                      minHeight: 32,
                                                    ),
                                                    icon: const Icon(
                                                      Icons.remove_circle_outline,
                                                      color: AppColors.primary,
                                                    ),
                                                    onPressed: () {
                                                      FocusScope.of(context).unfocus();
                                                      cartController.updateQuantity(
                                                        product.id,
                                                        inCartQty - 1,
                                                      );
                                                    },
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                                    child: Text(
                                                      '$inCartQty',
                                                      style: const TextStyle(
                                                        color: AppColors.primary,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    visualDensity: VisualDensity.compact,
                                                    iconSize: 20,
                                                    padding: const EdgeInsets.all(4),
                                                    constraints: const BoxConstraints(
                                                      minWidth: 32,
                                                      minHeight: 32,
                                                    ),
                                                    icon: Icon(
                                                      Icons.add_circle,
                                                      color: inCartQty >= available
                                                          ? AppColors.muted
                                                          : AppColors.primary,
                                                    ),
                                                    onPressed: inCartQty >= available
                                                        ? null
                                                        : () {
                                                            FocusScope.of(context).unfocus();
                                                            cartController.addProduct(
                                                              product,
                                                              available,
                                                            );
                                                          },
                                                  ),
                                                ],
                                              ),
                                            );
                                          }

                                          return ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: Colors.white,
                                              visualDensity: VisualDensity.compact,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            icon: const Icon(
                                              Icons.add_shopping_cart,
                                              size: 16,
                                            ),
                                            label: const Text(
                                              '+ Giỏ POS',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            onPressed: isOutOfStock
                                                ? null
                                                : () {
                                                    FocusScope.of(context).unfocus();
                                                    final added = cartController.addProduct(
                                                      product,
                                                      available,
                                                    );
                                                    if (added) {
                                                      showAppSnackBar(
                                                        'Đã thêm ${product.name} vào giỏ POS',
                                                      );
                                                    } else {
                                                      showAppSnackBar(
                                                        'Không thể thêm quá số lượng tồn kho ($available)',
                                                        isError: true,
                                                      );
                                                    }
                                                  },
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
              // Sticky cart bar docked at bottom of column
              if (!cart.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Badge(
                          label: Text('${cart.totalItems}'),
                          child: const Icon(
                            Icons.shopping_bag,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Đã chọn ${cart.itemCount} sp (${cart.totalItems} món)',
                              style: const TextStyle(fontSize: 11, color: AppColors.muted),
                            ),
                            Text(
                              formatVnd(cart.subtotal),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                          label: const Text(
                            'Xem giỏ & Gửi duyệt',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => PosCartBottomSheet.show(context),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nhắc Sales đang thêm/bớt sản phẩm cho một giỏ tạm đã lưu.
class _EditingDraftBanner extends StatelessWidget {
  const _EditingDraftBanner({required this.orderCode, required this.onStop});

  final String orderCode;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.info.withValues(alpha: 0.08),
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
      child: Row(
        children: [
          const Icon(Icons.edit_note, color: AppColors.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Đang sửa giỏ tạm $orderCode — chọn thêm sản phẩm rồi mở giỏ '
              'để lưu hoặc gửi thu ngân.',
              style: const TextStyle(fontSize: 12, color: AppColors.info),
            ),
          ),
          TextButton(onPressed: onStop, child: const Text('Thôi sửa')),
        ],
      ),
    );
  }
}
