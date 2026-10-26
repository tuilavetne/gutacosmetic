import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../shared/models/models.dart';

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(ref.watch(apiClientProvider)),
);

/// Mọi đơn của khách đang đăng nhập, mới nhất trước.
final customerOrdersProvider = FutureProvider.autoDispose<List<Order>>(
  (ref) => ref.watch(orderRepositoryProvider).fetchOrders(),
);

/// Chi tiết một đơn hàng.
final customerOrderProvider = FutureProvider.autoDispose.family<Order, String>(
  (ref, id) => ref.watch(orderRepositoryProvider).fetchOrder(id),
);

/// Thông tin đặt đơn online gửi lên `POST /orders/online`.
typedef OnlineOrderRequest = ({
  String storeId,
  FulfillmentType fulfillmentType,
  PaymentMethod paymentMethod,
  List<({String productId, int quantity})> items,
  ShippingAddress? shippingAddress,
});

/// Thông tin tạo đơn offline gửi lên `POST /orders/offline`.
typedef OfflineOrderRequest = ({
  String storeId,
  String? customerId,
  String customerName,
  String customerPhone,
  List<({String productId, int quantity})> items,
});

class OrderRepository {
  OrderRepository(this._api);

  final ApiClient _api;

  /// `GET /orders` — backend tự lọc theo khách đang đăng nhập và hủy các đơn
  /// chuyển khoản đã hết hạn QR trước khi trả về.
  ///
  /// Đơn có dữ liệu hỏng (không đọc được) bị bỏ qua để không làm hỏng cả
  /// danh sách.
  Future<List<Order>> fetchOrders() async {
    final json = await _api.get('/orders');
    final raw = json['orders'];
    if (raw is! List) return const [];
    final orders = <Order>[];
    for (final item in raw.whereType<Map<dynamic, dynamic>>()) {
      try {
        orders.add(Order.fromJson(Map<String, dynamic>.from(item)));
      } catch (e) {
        debugPrint('Bỏ qua đơn ${item['orderCode'] ?? item['_id']}: $e');
      }
    }
    return orders;
  }

  /// `GET /orders/:id`
  Future<Order> fetchOrder(String id) async {
    final json = await _api.get('/orders/$id');
    return Order.fromJson(requireObject(json, 'order'));
  }

  /// `POST /orders/online` — giữ hàng tại [OnlineOrderRequest.storeId]. Đơn
  /// chuyển khoản trả kèm link/QR PayOS (hiệu lực 15 phút). Phí ship do
  /// server tính.
  Future<PlacedOrder> placeOnlineOrder(OnlineOrderRequest request) async {
    final json = await _api.post(
      '/orders/online',
      data: {
        'storeId': request.storeId,
        'fulfillmentType': request.fulfillmentType.apiValue,
        'paymentMethod': request.paymentMethod.apiValue,
        'items': [
          for (final item in request.items)
            {'productId': item.productId, 'quantity': item.quantity},
        ],
        'shippingAddress': request.shippingAddress?.toJson(),
      },
    );
    return PlacedOrder.fromJson(json);
  }

  /// `POST /orders/offline` — tạo đơn offline tại quầy.
  ///
  /// Mặc định là giỏ tạm (PENDING_APPROVAL): chỉ kiểm tra còn hàng, chưa giữ kho.
  /// [submitToCashier] = true thì tạo và gửi thu ngân luôn (PENDING_PAYMENT,
  /// giữ kho) trong một transaction — thiếu hàng thì không tạo đơn nào.
  Future<Order> createOfflineOrder(
    OfflineOrderRequest request, {
    bool submitToCashier = false,
  }) async {
    final json = await _api.post(
      '/orders/offline',
      data: _offlineOrderBody(request, submitToCashier: submitToCashier),
    );
    return Order.fromJson(requireObject(json, 'order'));
  }

  /// `PATCH /orders/:id/items` — Sales sửa giỏ tạm (thay toàn bộ sản phẩm và
  /// khách) khi đơn còn PENDING_APPROVAL. [submitToCashier] = true thì lưu xong
  /// gửi thu ngân luôn; thiếu hàng thì giỏ tạm giữ nguyên như trước.
  Future<Order> updateOfflineOrder(
    String orderId,
    OfflineOrderRequest request, {
    bool submitToCashier = false,
  }) async {
    final json = await _api.patch(
      '/orders/$orderId/items',
      data: _offlineOrderBody(request, submitToCashier: submitToCashier),
    );
    return Order.fromJson(requireObject(json, 'order'));
  }

  Map<String, Object?> _offlineOrderBody(
    OfflineOrderRequest request, {
    required bool submitToCashier,
  }) => {
    'storeId': request.storeId,
    if (submitToCashier) 'submitToCashier': true,
    if (request.customerId != null) 'customerId': request.customerId,
    'customerName': request.customerName,
    'customerPhone': request.customerPhone,
    'items': [
      for (final item in request.items)
        {'productId': item.productId, 'quantity': item.quantity},
    ],
  };

  /// `PATCH /orders/:id/approve` — Sales duyệt giỏ tạm gửi thu ngân (chuyển sang PENDING_PAYMENT).
  /// Lúc này mới tăng reservedStock và giảm availableStock.
  Future<Order> approveOfflineOrder(String orderId) async {
    final json = await _api.patch('/orders/$orderId/approve');
    return Order.fromJson(requireObject(json, 'order'));
  }

  /// `GET /orders?channel=OFFLINE` — lấy danh sách đơn offline tại chi nhánh của Sales.
  Future<List<Order>> fetchOfflineOrders({String? status}) async {
    final json = await _api.get(
      '/orders',
      query: {
        'channel': 'OFFLINE',
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    final raw = json['orders'];
    if (raw is! List) return const [];
    final orders = <Order>[];
    for (final item in raw.whereType<Map<dynamic, dynamic>>()) {
      try {
        orders.add(Order.fromJson(Map<String, dynamic>.from(item)));
      } catch (e) {
        debugPrint('Bỏ qua đơn ${item['orderCode'] ?? item['_id']}: $e');
      }
    }
    return orders;
  }

  /// `PATCH /orders/:id/cancel` — khách chỉ hủy được đơn đang chờ xác nhận,
  /// lý do 15–255 ký tự. Đơn đã trả tiền trả về `refundStatus: PENDING_REFUND`.
  Future<Order> cancelOrder(String id, {required String reason}) async {
    final json = await _api.patch(
      '/orders/$id/cancel',
      data: {'reason': reason},
    );
    return Order.fromJson(requireObject(json, 'order'));
  }

  /// `GET /payments/payos/orders/:id/link` — dùng lại link còn hạn, hết hạn
  /// thì tạo link mới.
  Future<PayosPayment> fetchPaymentLink(String orderId) async {
    final json = await _api.get('/payments/payos/orders/$orderId/link');
    return PayosPayment.fromJson(requireObject(json, 'payment'));
  }

  /// `POST /payments/payos/orders/:id/sync` — hỏi PayOS trạng thái giao dịch
  /// và cập nhật đơn (không cần webhook).
  Future<PayosSyncResult> syncPayment(String orderId) async {
    final json = await _api.post('/payments/payos/orders/$orderId/sync');
    return PayosSyncResult.fromJson(json);
  }
}
