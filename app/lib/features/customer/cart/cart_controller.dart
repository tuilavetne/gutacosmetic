import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/utils/constants.dart';
import '../../session/session_controller.dart';
import '../../shared/models/models.dart';
import 'cart_item.dart';

final cartControllerProvider = NotifierProvider<CartController, List<CartItem>>(
  CartController.new,
);

/// Tổng số lượng sản phẩm (badge giỏ hàng).
final cartCountProvider = Provider<int>(
  (ref) =>
      ref.watch(cartControllerProvider).fold(0, (sum, e) => sum + e.quantity),
);

/// Tạm tính theo giá lúc thêm vào giỏ.
final cartSubtotalProvider = Provider<int>(
  (ref) =>
      ref.watch(cartControllerProvider).fold(0, (sum, e) => sum + e.lineTotal),
);

/// Giỏ hàng của khách đang đăng nhập, lưu theo `userId` trong
/// [LocalStorage] (giữ lại sau khi đăng xuất). Mỗi sản phẩm tối đa
/// [AppConstants.maxCartQuantity].
class CartController extends Notifier<List<CartItem>> {
  String? _userId;

  LocalStorage get _local => ref.read(localStorageProvider);

  @override
  List<CartItem> build() {
    _userId = ref.watch(
      currentUserProvider.select(
        (u) => u?.role == UserRole.customer ? u?.id : null,
      ),
    );
    final userId = _userId;
    if (userId == null) return const [];
    final items = <CartItem>[];
    for (final json in _local.readCart(userId)) {
      try {
        final item = CartItem.fromJson(json);
        if (item.productId.isNotEmpty && item.quantity > 0) items.add(item);
      } catch (_) {
        // Bỏ dòng hỏng thay vì làm mất cả giỏ.
      }
    }
    return List.unmodifiable(items);
  }

  /// Thêm [quantity] sản phẩm; trả về số lượng thực sự được thêm (0 nếu đã
  /// đạt tối đa).
  int add(Product product, {int quantity = 1}) {
    if (_userId == null || quantity <= 0) return 0;
    final index = state.indexWhere((e) => e.productId == product.id);
    final current = index < 0 ? 0 : state[index].quantity;
    final next = (current + quantity).clamp(0, AppConstants.maxCartQuantity);
    final added = next - current;
    if (added <= 0) return 0;

    final items = [...state];
    if (index < 0) {
      items.add(CartItem.fromProduct(product, next));
    } else {
      // Cập nhật luôn tên/giá/ảnh mới nhất của sản phẩm.
      items[index] = CartItem.fromProduct(product, next);
    }
    _save(items);
    return added;
  }

  /// Thêm nhiều dòng một lúc ("Mua lại" một đơn cũ); trả về tổng số lượng
  /// thực sự được thêm.
  int addItems(Iterable<CartItem> lines) {
    if (_userId == null) return 0;
    final items = [...state];
    var added = 0;
    for (final line in lines) {
      if (line.productId.isEmpty || line.quantity <= 0) continue;
      final index = items.indexWhere((e) => e.productId == line.productId);
      final current = index < 0 ? 0 : items[index].quantity;
      final next = (current + line.quantity).clamp(
        0,
        AppConstants.maxCartQuantity,
      );
      if (next <= current) continue;
      added += next - current;
      if (index < 0) {
        items.add(line.copyWith(quantity: next));
      } else {
        items[index] = items[index].copyWith(quantity: next);
      }
    }
    if (added > 0) _save(items);
    return added;
  }

  /// Cập nhật tên/giá/ảnh theo dữ liệu mới nhất từ server (giữ số lượng).
  /// Trả về `true` nếu có giá thay đổi.
  bool refreshProducts(Iterable<Product> products) {
    final byId = {for (final p in products) p.id: p};
    var priceChanged = false;
    var changed = false;
    final items = <CartItem>[];
    for (final e in state) {
      final product = byId[e.productId];
      final fresh = product == null
          ? e
          : CartItem.fromProduct(product, e.quantity);
      if (fresh.unitPrice != e.unitPrice) priceChanged = true;
      if (fresh != e) changed = true;
      items.add(fresh);
    }
    if (changed) _save(items);
    return priceChanged;
  }

  /// Đặt số lượng; `<= 0` thì xóa khỏi giỏ.
  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) return remove(productId);
    final clamped = quantity.clamp(1, AppConstants.maxCartQuantity);
    _save([
      for (final e in state)
        e.productId == productId ? e.copyWith(quantity: clamped) : e,
    ]);
  }

  void remove(String productId) =>
      _save(state.where((e) => e.productId != productId).toList());

  void clear() => _save(const []);

  void _save(List<CartItem> items) {
    state = List.unmodifiable(items);
    final userId = _userId;
    if (userId == null) return;
    unawaited(_local.writeCart(userId, items.map((e) => e.toJson()).toList()));
  }
}
