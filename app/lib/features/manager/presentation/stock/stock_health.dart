import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/constants.dart';
import '../../../shared/models/models.dart';

/// Tình trạng một dòng tồn kho — cùng quy tắc với `GET /inventory/alerts`:
/// sắp hết khi khả dụng dưới max(ngưỡng, 10); sắp hết hạn trong 60 ngày.
enum StockFlag {
  outOfStock('Hết hàng', AppColors.accent),
  lowStock('Sắp hết', AppColors.warning),
  expired('Đã hết hạn', AppColors.accent),
  expiringSoon('Sắp hết hạn', AppColors.warning);

  const StockFlag(this.label, this.color);

  final String label;
  final Color color;
}

extension StockHealth on StoreStock {
  int get alertThreshold => lowStockThreshold > AppConstants.minLowStockAlert
      ? lowStockThreshold
      : AppConstants.minLowStockAlert;

  List<StockFlag> flags([DateTime? now]) {
    final today = now ?? DateTime.now();
    final expiry = expiryDate;
    return [
      if (availableStock <= 0)
        StockFlag.outOfStock
      else if (availableStock < alertThreshold)
        StockFlag.lowStock,
      if (expiry != null && expiry.isBefore(today))
        StockFlag.expired
      else if (expiry != null &&
          expiry.difference(today).inDays < AppConstants.expiringSoonDays)
        StockFlag.expiringSoon,
    ];
  }
}

/// Một dòng tồn kho của chi nhánh đang làm.
typedef StockRow = ({Product product, StoreStock stock});

List<StockRow> stockRowsFor(List<ProductInventory> items, String storeId) => [
  for (final item in items)
    if (item.stockAt(storeId) case final stock?)
      (product: item.product, stock: stock),
];
