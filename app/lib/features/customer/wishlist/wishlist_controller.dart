import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/widgets/app_messenger.dart';
import '../../session/session_controller.dart';
import '../../shared/models/models.dart';
import '../data/wishlist_repository.dart';

final wishlistControllerProvider =
    NotifierProvider<WishlistController, Set<String>>(WishlistController.new);

/// Sản phẩm yêu thích (màn Yêu thích).
final wishlistProductsProvider = FutureProvider.autoDispose<List<Product>>(
  (ref) => ref.watch(wishlistRepositoryProvider).fetchWishlist(),
);

/// Id sản phẩm khách đã thích — dùng cho nút trái tim.
///
/// Khởi tạo ngay từ `user.wishlist` rồi đồng bộ nền với `GET /wishlist`.
/// Bấm thích cập nhật lạc quan, lỗi thì hoàn tác.
class WishlistController extends Notifier<Set<String>> {
  final _pending = <String>{};

  WishlistRepository get _repo => ref.read(wishlistRepositoryProvider);

  @override
  Set<String> build() {
    final userId = ref.watch(
      currentUserProvider.select(
        (u) => u?.role == UserRole.customer ? u?.id : null,
      ),
    );
    if (userId == null) return const {};
    unawaited(refresh());
    return ref.read(currentUserProvider)?.wishlist.toSet() ?? const {};
  }

  Future<void> refresh() async {
    try {
      final products = await _repo.fetchWishlist();
      if (!ref.mounted) return;
      state = {for (final p in products) p.id};
    } catch (_) {
      // Giữ danh sách hiện có nếu đồng bộ lỗi.
    }
  }

  Future<void> toggle(String productId) async {
    // Bỏ qua bấm liên tục khi request trước chưa xong.
    if (!_pending.add(productId)) return;
    final wasLiked = state.contains(productId);
    _set(productId, liked: !wasLiked);
    try {
      final liked = await _repo.toggle(productId);
      if (!ref.mounted) return;
      _set(productId, liked: liked);
      ref.invalidate(wishlistProductsProvider);
    } catch (e) {
      if (!ref.mounted) return;
      _set(productId, liked: wasLiked);
      showAppSnackBar(errorMessageOf(e), isError: true);
    } finally {
      _pending.remove(productId);
    }
  }

  void _set(String productId, {required bool liked}) {
    state = liked ? {...state, productId} : ({...state}..remove(productId));
  }
}
