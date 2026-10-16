import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'json_converters.dart';
import 'store.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class AppUser with _$AppUser {
  const AppUser._();

  const factory AppUser({
    @JsonKey(name: '_id') required String id,
    @Default('') String fullName,
    @Default('') String email,
    required UserRole role,
    String? phone,
    String? address,
    @Default(false) bool emailVerified,
    @JsonKey(unknownEnumValue: AuthProvider.local)
    @Default(AuthProvider.local)
    AuthProvider authProvider,
    String? avatarUrl,
    @StoreRefConverter() EntityRef<Store>? storeId,
    @Default(0) int points,
    @Default(true) bool isActive,
    DateTime? disabledAt,
    String? disabledReason,
    @IdListConverter() @Default(<String>[]) List<String> wishlist,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  String get displayName => fullName.isNotEmpty ? fullName : email;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return String.fromCharCode(parts.last.runes.first).toUpperCase();
  }

  /// Tên chi nhánh được gán (nếu backend populate).
  String? get assignedStoreName => storeId?.data?.name;
}
