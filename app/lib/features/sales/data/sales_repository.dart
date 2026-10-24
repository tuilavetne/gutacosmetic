import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../customer/data/order_repository.dart';
import '../../shared/models/models.dart';

final salesRepositoryProvider = Provider<SalesRepository>(
  (ref) => SalesRepository(
    ref.watch(apiClientProvider),
    ref.watch(orderRepositoryProvider),
  ),
);

/// Query lọc sản phẩm POS tại quầy
typedef SalesProductQuery = ({
  String search,
  String category,
  String skinType,
});

const SalesProductQuery defaultSalesProductQuery = (
  search: '',
  category: '',
  skinType: '',
);

/// Provider lấy danh sách sản phẩm kèm tồn kho của chi nhánh
final salesProductsProvider = FutureProvider.autoDispose
    .family<List<ProductInventory>, SalesProductQuery>((ref, query) {
  return ref.watch(salesRepositoryProvider).fetchProductsWithInventory(
        search: query.search,
        category: query.category,
        skinType: query.skinType,
      );
});

/// Provider danh sách đơn offline của chi nhánh
final salesOrdersProvider = FutureProvider.autoDispose
    .family<List<Order>, String?>((ref, status) {
  return ref.watch(salesRepositoryProvider).fetchOfflineOrders(status: status);
});

/// Repository chuyên biệt phục vụ các luồng nghiệp vụ Sales POS
class SalesRepository {
  SalesRepository(this._api, this._orders);

  final ApiClient _api;
  final OrderRepository _orders;

  /// `GET /users/search-customers?query=...`
  /// Tìm kiếm khách hàng thành viên (có điểm, tài khoản) hoặc khách vãng lai (qua SĐT đơn cũ)
  Future<List<CustomerSearchResult>> searchCustomers(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];

    final json = await _api.get(
      '/users/search',
      query: {'query': trimmed},
    );
    return parseList(json, 'customers', CustomerSearchResult.fromJson);
  }

  /// `GET /inventory/products`
  /// Lấy danh sách sản phẩm kèm tồn kho thời gian thực ở mọi chi nhánh
  Future<List<ProductInventory>> fetchProductsWithInventory({
    String? search,
    String? category,
    String? skinType,
  }) async {
    final json = await _api.get(
      '/inventory/products',
      query: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
        if (skinType != null && skinType.isNotEmpty) 'skinType': skinType,
      },
    );
    return parseList(json, 'products', ProductInventory.fromJson);
  }

  /// `POST /orders/offline`
  /// Tạo giỏ hàng tạm tại quầy (status: PENDING_APPROVAL). Chưa giữ hàng trong kho.
  Future<Order> createOfflineOrder(OfflineOrderRequest request) {
    return _orders.createOfflineOrder(request);
  }

  /// `POST /orders/offline` với `submitToCashier: true`
  /// Tạo đơn và gửi thu ngân ngay (status: PENDING_PAYMENT, giữ kho) trong một
  /// transaction. Thiếu hàng thì backend không tạo đơn nào.
  Future<Order> submitOfflineOrder(OfflineOrderRequest request) {
    return _orders.createOfflineOrder(request, submitToCashier: true);
  }

  /// `PATCH /orders/:id/approve`
  /// Sales duyệt giỏ tạm gửi sang thu ngân (status: PENDING_PAYMENT). Lúc này mới giữ hàng (tăng reservedStock).
  Future<Order> approveOfflineOrder(String orderId) {
    return _orders.approveOfflineOrder(orderId);
  }

  /// `PATCH /orders/:id/cancel`
  /// Hủy đơn tại quầy (khách đổi ý). Đơn đã gửi thu ngân được trả hàng về kho.
  /// Lý do có thể để trống với nhân viên.
  Future<Order> cancelOfflineOrder(String orderId, {String reason = ''}) {
    return _orders.cancelOrder(orderId, reason: reason);
  }

  /// `GET /orders?channel=OFFLINE`
  /// Xem danh sách đơn offline của chi nhánh
  Future<List<Order>> fetchOfflineOrders({String? status}) {
    return _orders.fetchOfflineOrders(status: status);
  }

  /// `GET /orders/:id`
  Future<Order> fetchOrderDetail(String orderId) {
    return _orders.fetchOrder(orderId);
  }

}
