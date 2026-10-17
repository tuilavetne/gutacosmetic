import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_messenger.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/state_views.dart';
import '../cart/cart_controller.dart';
import '../cart/cart_item.dart';
import '../catalog/catalog_filter.dart';
import 'widgets/order_widgets.dart';

/// Giỏ hàng: chỉnh số lượng, xóa sản phẩm, sang bước thanh toán.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    CartItem item,
  ) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Xóa sản phẩm',
      message: 'Xóa "${item.name}" khỏi giỏ hàng?',
      confirmLabel: 'Xóa',
      destructive: true,
    );
    if (ok) ref.read(cartControllerProvider.notifier).remove(item.productId);
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Xóa giỏ hàng',
      message: 'Xóa tất cả sản phẩm trong giỏ hàng?',
      confirmLabel: 'Xóa tất cả',
      destructive: true,
    );
    if (ok) ref.read(cartControllerProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartControllerProvider);
    final count = ref.watch(cartCountProvider);
    final subtotal = ref.watch(cartSubtotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(items.isEmpty ? 'Giỏ hàng' : 'Giỏ hàng ($count)'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: 'Xóa tất cả',
              onPressed: () => _confirmClear(context, ref),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.shopping_bag_outlined,
              message: 'Giỏ hàng đang trống',
              hint: 'Hãy chọn thêm sản phẩm bạn yêu thích nhé.',
              action: FilledButton(
                onPressed: () {
                  ref.read(catalogFilterProvider.notifier).browse();
                  context.go(AppRoutes.customerCategory);
                },
                child: const Text('Khám phá sản phẩm'),
              ),
            )
          : OrderContentWidth(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _CartLine(
                    item: item,
                    onOpen: () =>
                        context.push(AppRoutes.customerProduct(item.productId)),
                    onRemove: () => _confirmRemove(context, ref, item),
                    onQuantityChanged: (q) {
                      if (q < AppConstants.minCartQuantity) {
                        _confirmRemove(context, ref, item);
                        return;
                      }
                      ref
                          .read(cartControllerProvider.notifier)
                          .setQuantity(item.productId, q);
                    },
                  );
                },
              ),
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : BottomActionBar(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tạm tính ($count sản phẩm)',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          formatVnd(subtotal),
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.customerCheckout),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Thanh toán'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({
    required this.item,
    required this.onOpen,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  final CartItem item;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ItemThumbnail(url: item.image, size: 76),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.brand.isNotEmpty)
                      Text(
                        item.brand.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatVnd(item.unitPrice),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CartQuantityStepper(
                          value: item.quantity,
                          onChanged: onQuantityChanged,
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Xóa khỏi giỏ',
                          onPressed: onRemove,
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nút −/+ số lượng; giảm từ 1 thì báo cho bên ngoài (hỏi xóa).
class CartQuantityStepper extends StatelessWidget {
  const CartQuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final style = IconButton.styleFrom(
      minimumSize: const Size(32, 32),
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
          iconSize: 16,
          onPressed: () => onChanged(value - 1),
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          tooltip: 'Tăng số lượng',
          style: style,
          iconSize: 16,
          onPressed: value < AppConstants.maxCartQuantity
              ? () => onChanged(value + 1)
              : () => showAppSnackBar(
                  'Mỗi sản phẩm chỉ mua tối đa '
                  '${AppConstants.maxCartQuantity}.',
                ),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
