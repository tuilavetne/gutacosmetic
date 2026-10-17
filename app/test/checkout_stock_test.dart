import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/features/customer/cart/cart_item.dart';
import 'package:gutacosmetic/features/customer/checkout/checkout_stock.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';

const _central = Store(id: 'c', name: 'Kho Quận 1', type: StoreType.central);
const _branch2 = Store(id: 'b2', name: 'Chi nhánh 2');
const _branch3 = Store(id: 'b3', name: 'Chi nhánh 3');

const _serum = Product(id: 'p1', name: 'Serum', price: 200000);
const _toner = Product(id: 'p2', name: 'Toner', price: 150000);

ProductInventory _inventory(Product product, Map<Store, int> available) =>
    ProductInventory(
      product: product,
      inventories: [
        for (final e in available.entries)
          StoreStock(store: e.key, availableStock: e.value),
      ],
    );

void main() {
  final cart = [
    CartItem.fromProduct(_serum, 2),
    CartItem.fromProduct(_toner, 1),
  ];

  test('cửa hàng chỉ đạt khi đủ mọi sản phẩm trong giỏ', () {
    final stock = CheckoutStock.analyze(cart, [
      _inventory(_serum, {_central: 0, _branch2: 2, _branch3: 5}),
      _inventory(_toner, {_central: 3, _branch2: 1, _branch3: 0}),
    ]);

    expect(stock.stores.map((s) => (s.store.id, s.isAvailable)), [
      ('c', false),
      ('b2', true),
      ('b3', false),
    ]);
    expect(stock.availabilityOf('c')!.shortageSummary, 'Serum: cần 2, còn 0');
    expect(stock.availabilityOf('b3')!.shortageSummary, 'Toner: cần 1, còn 0');
    expect(stock.firstAvailableStore, _branch2);
    expect(stock.deliveryStore, _branch2);
    expect(stock.unavailableItems, isEmpty);
  });

  test('giao hàng ưu tiên kho tổng khi kho tổng đủ hàng', () {
    final stock = CheckoutStock.analyze(cart, [
      _inventory(_serum, {_central: 9, _branch2: 2}),
      _inventory(_toner, {_central: 9, _branch2: 1}),
    ]);

    expect(stock.firstAvailableStore, _central);
    expect(stock.deliveryStore, _central);
  });

  test('không cửa hàng nào đủ hàng', () {
    final stock = CheckoutStock.analyze(cart, [
      _inventory(_serum, {_central: 1, _branch2: 1}),
      _inventory(_toner, {_central: 1, _branch2: 1}),
    ]);

    expect(stock.deliveryStore, isNull);
    expect(stock.firstAvailableStore, isNull);
  });

  test('sản phẩm ngừng bán (không có trong tồn kho) được tách riêng', () {
    final stock = CheckoutStock.analyze(cart, [
      _inventory(_serum, {_branch2: 5}),
    ]);

    expect(stock.unavailableItems.map((e) => e.productId), ['p2']);
    // Chỉ xét tồn của sản phẩm còn bán.
    expect(stock.availabilityOf('b2')!.isAvailable, isTrue);
    expect(stock.products, [_serum]);
  });
}
