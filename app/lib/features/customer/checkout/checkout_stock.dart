import '../../shared/models/models.dart';
import '../cart/cart_item.dart';

/// Một sản phẩm trong giỏ mà cửa hàng không đủ hàng.
typedef StockShortage = ({String name, int requested, int available});

/// Khả năng đáp ứng cả giỏ hàng của một cửa hàng — mỗi đơn chỉ lấy hàng từ
/// một cửa hàng.
class StoreAvailability {
  const StoreAvailability(this.store, this.shortages);

  final Store store;
  final List<StockShortage> shortages;

  bool get isAvailable => shortages.isEmpty;

  /// Ví dụ: `Serum B5: cần 3, còn 1`.
  String get shortageSummary => shortages
      .map((s) => '${s.name}: cần ${s.requested}, còn ${s.available}')
      .join('\n');
}

/// Kết quả đối chiếu giỏ hàng với `GET /inventory/products`.
class CheckoutStock {
  const CheckoutStock({
    required this.stores,
    required this.products,
    required this.unavailableItems,
  });

  /// Từ giỏ hàng và tồn kho; cửa hàng giữ thứ tự của backend (theo tên).
  factory CheckoutStock.analyze(
    List<CartItem> items,
    List<ProductInventory> inventories,
  ) {
    final byProduct = {for (final p in inventories) p.product.id: p};
    final unavailable = [
      for (final item in items)
        if (!byProduct.containsKey(item.productId)) item,
    ];

    // Mỗi sản phẩm liệt kê đủ các cửa hàng đang hoạt động.
    final stores = <String, Store>{};
    for (final p in inventories) {
      for (final stock in p.inventories) {
        stores.putIfAbsent(stock.store.id, () => stock.store);
      }
    }

    return CheckoutStock(
      products: [for (final p in inventories) p.product],
      unavailableItems: unavailable,
      stores: [
        for (final store in stores.values)
          StoreAvailability(store, [
            for (final item in items)
              if (byProduct[item.productId] case final inventory?)
                if (inventory.availableAt(store.id) < item.quantity)
                  (
                    name: item.name,
                    requested: item.quantity,
                    available: inventory.availableAt(store.id),
                  ),
          ]),
      ],
    );
  }

  final List<StoreAvailability> stores;

  /// Dữ liệu sản phẩm mới nhất (giá, tên, ảnh).
  final List<Product> products;

  /// Dòng giỏ hàng có sản phẩm đã ngừng bán.
  final List<CartItem> unavailableItems;

  StoreAvailability? availabilityOf(String? storeId) {
    for (final s in stores) {
      if (s.store.id == storeId) return s;
    }
    return null;
  }

  /// Cửa hàng xử lý đơn giao tận nơi: ưu tiên kho tổng, sau đó chi nhánh đầu
  /// tiên còn đủ cả giỏ.
  Store? get deliveryStore {
    final available = stores.where((s) => s.isAvailable).toList();
    if (available.isEmpty) return null;
    return available
        .firstWhere((s) => s.store.isCentral, orElse: () => available.first)
        .store;
  }

  /// Cửa hàng đầu tiên còn đủ hàng — chọn sẵn khi nhận tại cửa hàng.
  Store? get firstAvailableStore {
    for (final s in stores) {
      if (s.isAvailable) return s.store;
    }
    return null;
  }
}
