import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/store.dart';

final storeRepositoryProvider = Provider<StoreRepository>(
  (ref) => StoreRepository(ref.watch(apiClientProvider)),
);

/// Các cửa hàng đang hoạt động (gồm cả kho tổng CENTRAL).
final activeStoresProvider = FutureProvider.autoDispose<List<Store>>(
  (ref) => ref.watch(storeRepositoryProvider).fetchActiveStores(),
);

class StoreRepository {
  StoreRepository(this._api);

  final ApiClient _api;

  /// `GET /stores`
  Future<List<Store>> fetchActiveStores() async {
    final json = await _api.get('/stores');
    return parseList(json, 'stores', Store.fromJson);
  }
}
