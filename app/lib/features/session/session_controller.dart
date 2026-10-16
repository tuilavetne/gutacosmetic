import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_storage.dart';
import '../../core/storage/token_storage.dart';
import '../auth/data/auth_models.dart';
import '../auth/data/auth_repository.dart';
import '../auth/data/google_auth_service.dart';
import '../shared/models/models.dart';
import 'session_state.dart';

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

/// User hiện tại (null khi chưa đăng nhập).
final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(sessionControllerProvider.select((s) => s.user)),
);

/// Chi nhánh đang làm việc của MANAGER/SALES.
final activeStoreProvider = Provider<Store?>(
  (ref) => ref.watch(sessionControllerProvider.select((s) => s.activeStore)),
);

/// Quản lý phiên đăng nhập và chi nhánh đang chọn.
///
/// Chi nhánh đang chọn được gộp chung vào session (thay vì controller riêng)
/// vì nó gắn chặt vòng đời với user: login/logout đều phải xóa nó.
class SessionController extends Notifier<SessionState> {
  TokenStorage get _tokens => ref.read(tokenStorageProvider);
  LocalStorage get _local => ref.read(localStorageProvider);

  @override
  SessionState build() {
    unawaited(_restore());
    return const SessionState.restoring();
  }

  Future<void> _restore() async {
    final token = await _tokens.read();
    final user = _parse(_local.readUser(), AppUser.fromJson);
    if (token == null || token.isEmpty || user == null) {
      await _clearStorage();
      state = const SessionState.signedOut();
      return;
    }
    final store = user.role.isStaff
        ? _parse(_local.readActiveStore(), Store.fromJson)
        : null;
    state = SessionState.signedIn(token: token, user: user, activeStore: store);

    // Làm mới user nền (điểm, trạng thái khóa); 401 sẽ tự đăng xuất.
    unawaited(refreshUser().then<void>((_) {}, onError: (_) {}));
  }

  /// Lưu phiên sau khi đăng nhập/đăng ký thành công; xóa chi nhánh cũ.
  Future<void> startSession(AuthResult result) async {
    await _tokens.write(result.token);
    await _local.writeUser(result.user.toJson());
    await _local.clearActiveStore();
    state = SessionState.signedIn(token: result.token, user: result.user);
  }

  /// Xóa token, user và chi nhánh đang chọn. Giỏ hàng giữ nguyên.
  Future<void> signOut() async {
    state = const SessionState.signedOut();
    await _clearStorage();
    unawaited(ref.read(googleAuthServiceProvider).signOut());
  }

  /// `GET /auth/me` — cập nhật điểm, thông tin sau khi đặt hàng...
  Future<AppUser?> refreshUser() async {
    if (!state.isAuthenticated) return null;
    final token = state.token;
    final user = await ref.read(authRepositoryProvider).me();
    // Bỏ qua nếu phiên đã đổi trong lúc chờ.
    if (state.token != token || !state.isAuthenticated) return null;
    await updateUser(user);
    return user;
  }

  Future<void> updateUser(AppUser user) async {
    if (!state.isAuthenticated) return;
    await _local.writeUser(user.toJson());
    state = state.copyWith(user: user);
  }

  Future<void> setActiveStore(Store store) async {
    if (!state.isStaff) return;
    await _local.writeActiveStore(store.toJson());
    state = state.copyWith(activeStore: store);
  }

  Future<void> clearActiveStore() async {
    await _local.clearActiveStore();
    state = state.withoutActiveStore();
  }

  Future<void> _clearStorage() async {
    await _tokens.clear();
    await _local.clearUser();
    await _local.clearActiveStore();
  }

  static T? _parse<T>(
    Map<String, dynamic>? json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (json == null) return null;
    try {
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
