import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Được override trong `main()` sau khi `SharedPreferences.getInstance()`.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider chưa override'),
);

final localStorageProvider = Provider<LocalStorage>(
  (ref) => LocalStorage(ref.watch(sharedPreferencesProvider)),
);

/// Dữ liệu không nhạy cảm: user, chi nhánh đang chọn, giỏ hàng theo user.
class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _userKey = 'guta_cosmetic_user';
  static const _activeStoreKey = 'guta_cosmetic_active_store';
  static const _cartKeyPrefix = 'guta_cosmetic_cart_';

  Map<String, dynamic>? readUser() => _readJson(_userKey);
  Future<void> writeUser(Map<String, dynamic> json) =>
      _writeJson(_userKey, json);
  Future<void> clearUser() => _prefs.remove(_userKey);

  Map<String, dynamic>? readActiveStore() => _readJson(_activeStoreKey);
  Future<void> writeActiveStore(Map<String, dynamic> json) =>
      _writeJson(_activeStoreKey, json);
  Future<void> clearActiveStore() => _prefs.remove(_activeStoreKey);

  /// Giỏ hàng lưu riêng theo `userId`, không bị xóa khi logout.
  List<Map<String, dynamic>> readCart(String userId) {
    final raw = _prefs.getString('$_cartKeyPrefix$userId');
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> writeCart(String userId, List<Map<String, dynamic>> items) =>
      _prefs.setString('$_cartKeyPrefix$userId', jsonEncode(items));

  Map<String, dynamic>? _readJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeJson(String key, Map<String, dynamic> json) =>
      _prefs.setString(key, jsonEncode(json));
}
