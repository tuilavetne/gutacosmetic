import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../session/session_controller.dart';
import '../controllers/pos_cart_controller.dart';
import 'customer_select_dialog.dart';

class PosCartBottomSheet extends ConsumerWidget {
  const PosCartBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PosCartBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeStore = ref.watch(activeStoreProvider);
    final cart = ref.watch(posCartControllerProvider);
    final controller = ref.read(posCartControllerProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                const Icon(Icons.point_of_sale, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Giỏ hàng POS (${cart.totalItems})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (activeStore != null)
                        Text(
                          'Chi nhánh: ${activeStore.name}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!cart.isEmpty)
                  TextButton.icon(
                    icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                    label: const Text('Xóa giỏ'),
                    onPressed: controller.clearCart,
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Customer selection banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.background,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: cart.customer?.isMember == true
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.white,
                  child: Icon(
                    cart.customer?.isMember == true
                        ? Icons.star_rounded
                        : Icons.person_outline,
                    color: cart.customer?.isMember == true
                        ? AppColors.primary
                        : AppColors.muted,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cart.effectiveCustomerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        cart.effectiveCustomerPhone.isNotEmpty
                            ? cart.effectiveCustomerPhone
                            : (cart.customer?.isMember == true
                                  ? 'Thành viên (${formatNumber(cart.customer!.points)} điểm)'
                                  : 'Khách vãng lai tại quầy'),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Đổi khách'),
                  onPressed: () async {
                    final selected = await CustomerSelectDialog.show(
                      context,
                      current: cart.customer,
                    );
                    if (selected != null) {
                      controller.selectCustomer(selected);
                    }
                  },
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: cart.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: AppColors.muted,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Chưa có sản phẩm nào trong giỏ',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, _) => const Divider(height: 20),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.product.image ?? '',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 56,
                                height: 56,
                                color: AppColors.background,
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'SKU: ${item.product.sku}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatVnd(item.product.price),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    onPressed: () => controller.updateQuantity(
                                      item.product.id,
                                      item.quantity - 1,
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed:
                                        item.quantity >= item.availableStock
                                        ? null
                                        : () => controller.updateQuantity(
                                            item.product.id,
                                            item.quantity + 1,
                                          ),
                                  ),
                                ],
                              ),
                              Text(
                                formatVnd(item.lineTotal),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // Bottom action panel
          if (!cart.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng tiền tạm tính:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          formatVnd(cart.subtotal),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        // Nút 1: Lưu giỏ tạm (PENDING_APPROVAL - Chưa giữ hàng)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.primary),
                            ),
                            onPressed: cart.isSubmitting
                                ? null
                                : () async {
                                    try {
                                      final order = await controller
                                          .createDraftOrder();
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        showAppSnackBar(
                                          'Đã lưu giỏ tạm (${order.orderCode})! Hàng chưa bị giữ trong kho.',
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        showAppSnackBar(
                                          'Lỗi lưu giỏ tạm: ${errorMessageOf(e)}',
                                          isError: true,
                                        );
                                      }
                                    }
                                  },
                            child: const Text(
                              'Lưu giỏ tạm\n(Chờ duyệt)',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Nút 2: Duyệt gửi thu ngân (PENDING_PAYMENT - Tăng reservedStock)
                        Expanded(
                          flex: 2,
                          child: AppButton(
                            label: 'Duyệt gửi thu ngân',
                            icon: Icons.send_rounded,
                            loading: cart.isSubmitting,
                            onPressed: () async {
                              try {
                                final order = await controller
                                    .submitAndApproveOrder();
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  showAppSnackBar(
                                    'Đã duyệt đơn ${order.orderCode} gửi sang thu ngân! Đã giữ tồn kho.',
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  showAppSnackBar(
                                    'Lỗi duyệt đơn: ${errorMessageOf(e)}',
                                    isError: true,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: const Text(
                          'Tiếp tục chọn thêm sản phẩm vào giỏ',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
