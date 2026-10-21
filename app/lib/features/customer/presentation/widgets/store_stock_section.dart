import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../shared/models/models.dart';

/// Tồn kho còn bán được (`availableStock`) của sản phẩm tại từng cửa hàng.
class StoreStockSection extends StatelessWidget {
  const StoreStockSection({
    super.key,
    required this.stocks,
    required this.onRetry,
  });

  final AsyncValue<List<StoreStock>> stocks;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return stocks.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => InlineError(
        message: 'Không tải được tồn kho. ${errorMessageOf(error)}',
        onRetry: onRetry,
      ),
      data: (list) {
        if (list.isEmpty) {
          return const Text(
            'Chưa có cửa hàng nào đang hoạt động.',
            style: TextStyle(color: AppColors.muted),
          );
        }
        final inStock = list.where((e) => !e.isOutOfStock).length;
        final total = list.fold<int>(0, (s, e) => s + e.availableStock);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              inStock == 0
                  ? 'Sản phẩm đang tạm hết hàng ở tất cả cửa hàng.'
                  : 'Còn hàng tại $inStock/${list.length} cửa hàng · '
                        'tổng ${formatNumber(total)} '
                        'sản phẩm có thể bán.',
              style: TextStyle(
                color: inStock == 0 ? AppColors.accent : AppColors.muted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < list.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: 14),
                    _StoreStockTile(list[i]),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StoreStockTile extends StatelessWidget {
  const _StoreStockTile(this.stock);

  final StoreStock stock;

  @override
  Widget build(BuildContext context) {
    final store = stock.store;
    final (label, color) = stock.isOutOfStock
        ? ('Hết hàng', AppColors.muted)
        : stock.isLowStock
        ? (
            'Sắp hết · còn ${formatNumber(stock.availableStock)}',
            AppColors.warning,
          )
        : ('Còn ${formatNumber(stock.availableStock)}', AppColors.success);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(
            store.isCentral ? Icons.warehouse_outlined : Icons.storefront,
            color: stock.isOutOfStock ? AppColors.muted : AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.isCentral ? '${store.name} (kho tổng)' : store.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (store.address.isNotEmpty)
                  Text(
                    store.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
