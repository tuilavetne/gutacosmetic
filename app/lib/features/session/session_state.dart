import 'package:flutter/foundation.dart';

import '../shared/models/models.dart';

/// Trạng thái phiên đăng nhập toàn app.
@immutable
class SessionState {
  const SessionState._({
    required this.isRestoring,
    this.token,
    this.user,
    this.activeStore,
  });

  /// Đang đọc session từ storage khi mở app (hiển thị splash).
  const SessionState.restoring() : this._(isRestoring: true);

  const SessionState.signedOut() : this._(isRestoring: false);

  const SessionState.signedIn({
    required String token,
    required AppUser user,
    Store? activeStore,
  }) : this._(
         isRestoring: false,
         token: token,
         user: user,
         activeStore: activeStore,
       );

  final bool isRestoring;
  final String? token;
  final AppUser? user;

  /// Chi nhánh đang làm việc — chỉ dùng cho MANAGER/SALES.
  final Store? activeStore;

  bool get isAuthenticated => token != null && user != null;
  UserRole? get role => user?.role;
  bool get isStaff => user?.role.isStaff ?? false;

  /// Staff đăng nhập nhưng chưa chọn chi nhánh.
  bool get needsActiveStore => isStaff && activeStore == null;

  /// Giá trị header `X-Active-Store-Id` — chỉ gửi khi là staff.
  String? get activeStoreHeaderValue => isStaff ? activeStore?.id : null;

  SessionState copyWith({AppUser? user, Store? activeStore}) => SessionState._(
    isRestoring: isRestoring,
    token: token,
    user: user ?? this.user,
    activeStore: activeStore ?? this.activeStore,
  );

  SessionState withoutActiveStore() =>
      SessionState._(isRestoring: isRestoring, token: token, user: user);

  @override
  bool operator ==(Object other) =>
      other is SessionState &&
      other.isRestoring == isRestoring &&
      other.token == token &&
      other.user == user &&
      other.activeStore == activeStore;

  @override
  int get hashCode => Object.hash(isRestoring, token, user, activeStore);
}
