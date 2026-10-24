import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../shared/models/models.dart';

class OtherStoresStockDialog extends StatelessWidget {
  const OtherStoresStockDialog({
    super.key,
    required this.inventory,
    required this.currentStoreId,
  });

  final ProductInventory inventory;
  final String currentStoreId;

  static void show(
    BuildContext context, {
    required ProductInventory inventory,
    required String currentStoreId,
  }) {
    showDialog(
      context: context,
      builder: (_) => OtherStoresStockDialog(
        inventory: inventory,
        currentStoreId: currentStoreId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = inventory.product;
    final stores = inventory.inventories;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.image ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 50,
                        height: 50,
                        color: AppColors.background,
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'SKU: ${product.sku} • Hãng: ${product.brand}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                'Tồn kho trên toàn hệ thống',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: stores.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final stock = stores[index];
                    final isCurrent = stock.store.id == currentStoreId;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primary.withValues(alpha: 0.06)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                stock.store.isCentral
                                    ? Icons.warehouse_outlined
                                    : Icons.store_mall_directory_outlined,
                                size: 18,
                                color: isCurrent
                                    ? AppColors.primary
                                    : AppColors.muted,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  stock.store.name,
                                  style: TextStyle(
                                    fontWeight: isCurrent
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize: 14,
                                    color: isCurrent ? AppColors.primary : null,
                                  ),
                                ),
                              ),
                              if (isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Chi nhánh này',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else if (stock.store.isCentral)
                                const Chip(
                                  visualDensity: VisualDensity.compact,
                                  label: Text(
                                    'Tổng kho',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            stock.store.address,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Khả dụng: ${stock.availableStock}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: stock.availableStock > 0
                                      ? AppColors.success
                                      : AppColors.accent,
                                ),
                              ),
                              Text(
                                'Đang giữ: ${stock.reservedStock}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                              Text(
                                'Tổng tồn: ${stock.totalStock}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
