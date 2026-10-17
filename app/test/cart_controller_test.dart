import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/core/storage/local_storage.dart';
import 'package:gutacosmetic/core/utils/constants.dart';
import 'package:gutacosmetic/features/customer/cart/cart_controller.dart';
import 'package:gutacosmetic/features/customer/cart/cart_item.dart';
import 'package:gutacosmetic/features/session/session_controller.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _serum = Product(id: 'p1', sku: 'SKU1', name: 'Serum', price: 200000);
const _toner = Product(id: 'p2', name: 'Toner', price: 150000);

Future<ProviderContainer> _container({
  AppUser? user = const AppUser(id: 'u1', role: UserRole.customer),
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      currentUserProvider.overrideWithValue(user),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('thêm sản phẩm, cộng dồn số lượng, tính tổng', () async {
    final c = await _container();
    final cart = c.read(cartControllerProvider.notifier);

    expect(cart.add(_serum), 1);
    expect(cart.add(_serum, quantity: 2), 2);
    expect(cart.add(_toner), 1);

    final items = c.read(cartControllerProvider);
    expect(items.map((e) => (e.productId, e.quantity)), [('p1', 3), ('p2', 1)]);
    expect(c.read(cartCountProvider), 4);
    expect(c.read(cartSubtotalProvider), 3 * 200000 + 150000);
  });

  test('giới hạn tối đa mỗi sản phẩm', () async {
    final c = await _container();
    final cart = c.read(cartControllerProvider.notifier);
    const max = AppConstants.maxCartQuantity;

    expect(cart.add(_serum, quantity: max - 1), max - 1);
    expect(cart.add(_serum, quantity: 5), 1);
    expect(cart.add(_serum), 0);
    expect(c.read(cartControllerProvider).single.quantity, max);
  });

  test('setQuantity <= 0 thì xóa; remove; clear', () async {
    final c = await _container();
    final cart = c.read(cartControllerProvider.notifier)
      ..add(_serum)
      ..add(_toner);

    cart.setQuantity('p1', 0);
    expect(c.read(cartControllerProvider).map((e) => e.productId), ['p2']);
    cart.remove('p2');
    expect(c.read(cartControllerProvider), isEmpty);
    cart
      ..add(_serum)
      ..clear();
    expect(c.read(cartControllerProvider), isEmpty);
  });

  test('lưu theo user và đọc lại khi mở app', () async {
    final first = await _container();
    first.read(cartControllerProvider.notifier).add(_serum, quantity: 2);
    await Future<void>.delayed(Duration.zero);

    final sp = await SharedPreferences.getInstance();
    final saved = sp.getString('guta_cosmetic_cart_u1');
    expect(saved, isNotNull);

    final second = await _container(prefs: {'guta_cosmetic_cart_u1': saved!});
    final items = second.read(cartControllerProvider);
    expect(items.single.productId, 'p1');
    expect(items.single.quantity, 2);
    expect(items.single.unitPrice, 200000);
  });

  test('dữ liệu hỏng bị bỏ qua, không làm mất cả giỏ', () async {
    final c = await _container(
      prefs: {
        'guta_cosmetic_cart_u1': '[{"productId":"p1","quantity":1},{"quantity":"x"},{"productId":"p2","quantity":0}]',
      },
    );
    expect(c.read(cartControllerProvider).map((e) => e.productId), ['p1']);
  });

  test('không phải khách hàng → giỏ rỗng, không thêm được', () async {
    final c = await _container(
      user: const AppUser(id: 's1', role: UserRole.sales),
    );
    expect(c.read(cartControllerProvider.notifier).add(_serum), 0);
    expect(c.read(cartControllerProvider), isEmpty);
  });

  test('addItems ("Mua lại") cộng dồn và giới hạn tối đa', () async {
    final c = await _container();
    final cart = c.read(cartControllerProvider.notifier)
      ..add(_serum, quantity: AppConstants.maxCartQuantity - 1);

    final added = cart.addItems([
      CartItem.fromProduct(_serum, 3),
      CartItem.fromProduct(_toner, 2),
      const CartItem(productId: '', quantity: 1),
    ]);

    expect(added, 1 + 2);
    expect(
      c.read(cartControllerProvider).map((e) => (e.productId, e.quantity)),
      [('p1', AppConstants.maxCartQuantity), ('p2', 2)],
    );
    expect(cart.addItems([CartItem.fromProduct(_serum, 1)]), 0);
  });

  test('refreshProducts cập nhật giá mới, giữ số lượng', () async {
    final c = await _container();
    final cart = c.read(cartControllerProvider.notifier)
      ..add(_serum, quantity: 2)
      ..add(_toner);

    expect(cart.refreshProducts([_serum, _toner]), isFalse);
    expect(
      cart.refreshProducts([_serum.copyWith(price: 180000, name: 'Serum mới')]),
      isTrue,
    );

    final items = c.read(cartControllerProvider);
    expect(items.first.unitPrice, 180000);
    expect(items.first.name, 'Serum mới');
    expect(items.first.quantity, 2);
    expect(items.last.unitPrice, 150000);
    expect(c.read(cartSubtotalProvider), 2 * 180000 + 150000);
  });
}
