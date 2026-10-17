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
