import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'store.freezed.dart';
part 'store.g.dart';

@freezed
abstract class Store with _$Store {
  const Store._();

  const factory Store({
    @JsonKey(name: '_id') required String id,
    @Default('') String name,
    @Default(StoreType.branch) StoreType type,
    @Default('') String address,
    @Default('') String phone,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

  bool get isCentral => type == StoreType.central;
}
