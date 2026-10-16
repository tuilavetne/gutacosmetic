import 'package:json_annotation/json_annotation.dart';

import 'product.dart';
import 'store.dart';
import 'user.dart';

/// Trường tham chiếu của backend: có thể là chuỗi ObjectId hoặc object đã
/// populate. [data] chỉ có khi backend populate.
class EntityRef<T> {
  const EntityRef(this.id, [this.data]);

  final String id;
  final T? data;

  bool get isPopulated => data != null;

  @override
  bool operator ==(Object other) =>
      other is EntityRef<T> && other.id == id && other.data == data;

  @override
  int get hashCode => Object.hash(id, data);

  @override
  String toString() => 'EntityRef<$T>($id${data == null ? '' : ', populated'})';
}

EntityRef<T> _parseRef<T>(
  Object json,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (json is Map) {
    final map = Map<String, dynamic>.from(json);
    final id = (map['_id'] ?? map['id'] ?? '').toString();
    try {
      return EntityRef<T>(id, fromJson(map));
    } catch (_) {
      // Populate một phần không đủ trường — vẫn giữ được id.
      return EntityRef<T>(id);
    }
  }
  return EntityRef<T>(json.toString());
}

class StoreRefConverter implements JsonConverter<EntityRef<Store>, Object> {
  const StoreRefConverter();

  @override
  EntityRef<Store> fromJson(Object json) => _parseRef(json, Store.fromJson);

  @override
  Object toJson(EntityRef<Store> ref) => ref.data?.toJson() ?? ref.id;
}

class ProductRefConverter implements JsonConverter<EntityRef<Product>, Object> {
  const ProductRefConverter();

  @override
  EntityRef<Product> fromJson(Object json) => _parseRef(json, Product.fromJson);

  @override
  Object toJson(EntityRef<Product> ref) => ref.data?.toJson() ?? ref.id;
}

class UserRefConverter implements JsonConverter<EntityRef<AppUser>, Object> {
  const UserRefConverter();

  @override
  EntityRef<AppUser> fromJson(Object json) => _parseRef(json, AppUser.fromJson);

  @override
  Object toJson(EntityRef<AppUser> ref) => ref.data?.toJson() ?? ref.id;
}

/// Mảng id hoặc mảng object → danh sách id (ví dụ `wishlist`).
class IdListConverter implements JsonConverter<List<String>, Object> {
  const IdListConverter();

  @override
  List<String> fromJson(Object json) {
    if (json is! List) return const [];
    return json
        .map(
          (e) => e is Map ? (e['_id'] ?? e['id'])?.toString() : e?.toString(),
        )
        .whereType<String>()
        .toList();
  }

  @override
  Object toJson(List<String> ids) => ids;
}

/// Ngày giờ dạng ISO string hoặc epoch (giây/mili giây) — PayOS trả
/// `expiredAt` dạng epoch giây.
class FlexibleDateTimeConverter implements JsonConverter<DateTime, Object> {
  const FlexibleDateTimeConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is num) {
      final value = json.toInt();
      return value < 100000000000
          ? DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true)
          : DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    final asInt = int.tryParse(json.toString());
    if (asInt != null) return fromJson(asInt);
    return DateTime.parse(json.toString());
  }

  @override
  Object toJson(DateTime value) => value.toUtc().toIso8601String();
}

/// Đọc chuỗi bất kể backend trả số, chuỗi hay object populate (lấy `_id`).
/// Ví dụ `paymentOrderCode` (số) hoặc `Review.orderId`.
class StringishConverter implements JsonConverter<String, Object> {
  const StringishConverter();

  @override
  String fromJson(Object json) => json is Map
      ? (json['_id'] ?? json['id'] ?? '').toString()
      : json.toString();

  @override
  Object toJson(String value) => value;
}
