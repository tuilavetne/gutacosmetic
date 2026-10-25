import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../customer/data/order_repository.dart';
import '../../session/session_controller.dart';
import '../../shared/data/payment_repository.dart';
import '../../shared/models/models.dart';
import 'stock_history.dart';

final managerRepositoryProvider = Provider<ManagerRepository>(
  (ref) => ManagerRepository(
    ref.watch(apiClientProvider),
    ref.watch(orderRepositoryProvider),
    ref.watch(paymentRepositoryProvider),
  ),
);

/// Đơn tại quầy Sales đã gửi sang, đang chờ thu ngân thu tiền. Theo dõi chi
/// nhánh để đổi chi nhánh thì tải lại.
final cashierOrdersProvider = FutureProvider.autoDispose<List<Order>>((ref) {
  ref.watch(activeStoreProvider.select((store) => store?.id));
  return ref.watch(managerRepositoryProvider).fetchCashierOrders();
});

/// Đơn online của chi nhánh theo trạng thái; `null` = tất cả.
final managerOnlineOrdersProvider = FutureProvider.autoDispose
    .family<List<Order>, OrderStatus?>((ref, status) {
      ref.watch(activeStoreProvider.select((store) => store?.id));
      return ref
          .watch(managerRepositoryProvider)
          .fetchOnlineOrders(status: status);
    });

/// Tồn kho mọi sản phẩm (kèm tồn ở mọi chi nhánh) — màn Kho lấy dòng của chi
/// nhánh đang làm.
final managerStockProvider = FutureProvider.autoDispose<List<ProductInventory>>(
  (ref) {
    ref.watch(activeStoreProvider.select((store) => store?.id));
    return ref.watch(managerRepositoryProvider).fetchStock();
  },
);

final managerReceiptsProvider =
    FutureProvider.autoDispose<List<InventoryReceipt>>((ref) {
      ref.watch(activeStoreProvider.select((store) => store?.id));
      return ref.watch(managerRepositoryProvider).fetchReceipts();
    });

final managerAdjustmentsProvider =
    FutureProvider.autoDispose<List<InventoryAdjustment>>((ref) {
      ref.watch(activeStoreProvider.select((store) => store?.id));
      return ref.watch(managerRepositoryProvider).fetchAdjustments();
    });

/// Đề xuất nhập hàng của Sales theo trạng thái; `null` = tất cả.
final managerRestockRequestsProvider = FutureProvider.autoDispose
    .family<List<RestockRequest>, RestockStatus?>((ref, status) {
      ref.watch(activeStoreProvider.select((store) => store?.id));
      return ref
          .watch(managerRepositoryProvider)
          .fetchRestockRequests(status: status);
    });

/// Yêu cầu trả hàng lỗi theo trạng thái; `null` = tất cả.
final managerReturnRequestsProvider = FutureProvider.autoDispose
    .family<List<InventoryReturnRequest>, ReturnRequestStatus?>((ref, status) {
      ref.watch(activeStoreProvider.select((store) => store?.id));
      return ref
          .watch(managerRepositoryProvider)
          .fetchReturnRequests(status: status);
    });

/// Phiếu chuyển hàng đến chi nhánh theo trạng thái; `null` = tất cả.
final managerIncomingTransfersProvider = FutureProvider.autoDispose
    .family<List<StockTransfer>, TransferStatus?>((ref, status) {
      ref.watch(activeStoreProvider.select((store) => store?.id));
      return ref
          .watch(managerRepositoryProvider)
          .fetchIncomingTransfers(status: status);
    });

/// Bộ lọc lịch sử kho: loại (`null` = tất cả) và sản phẩm (`null` = tất cả).
typedef StockHistoryQuery = ({StockHistoryType? type, String? productId});

final managerStockHistoryProvider = FutureProvider.autoDispose
    .family<List<StockHistoryEntry>, StockHistoryQuery>((ref, query) {
      ref.watch(activeStoreProvider.select((store) => store?.id));
      return ref
          .watch(managerRepositoryProvider)
          .fetchStockHistory(type: query.type, productId: query.productId);
    });

/// Lịch sử đổi quà: theo khách khi truyền `customerId`, `null` = chi nhánh.
final managerRedemptionsProvider = FutureProvider.autoDispose
    .family<List<RewardRedemption>, String?>((ref, customerId) {
      ref.watch(activeStoreProvider.select((store) => store?.id));
      return ref
          .watch(managerRepositoryProvider)
          .fetchRedemptions(customerId: customerId);
    });

/// Nghiệp vụ của Manager/Thu ngân tại chi nhánh đang làm.
class ManagerRepository {
  ManagerRepository(this._api, this._orders, this._payments);

  final ApiClient _api;
  final OrderRepository _orders;
  final PaymentRepository _payments;

  // ---------------------------------------------------------------------------
  // Thu ngân
  // ---------------------------------------------------------------------------

  /// `GET /orders?channel=OFFLINE&status=PENDING_PAYMENT`
  Future<List<Order>> fetchCashierOrders() =>
      _orders.fetchOfflineOrders(status: OrderStatus.pendingPayment.apiValue);

  /// `GET /orders/:id`
  Future<Order> fetchOrder(String orderId) => _orders.fetchOrder(orderId);

  /// `PATCH /orders/:id/pay` — thu tiền mặt hoặc thẻ, thu đúng tổng tiền (không
  /// có chiết khấu thủ công). Đơn chuyển COMPLETED: trừ kho, cộng điểm.
  /// QR PayOS còn mở của đơn sẽ bị backend hủy trước khi thu.
  Future<Order> payAtCounter(String orderId, PaymentMethod method) async {
    assert(
      method == PaymentMethod.cash || method == PaymentMethod.card,
      'Thu tay chỉ nhận tiền mặt hoặc thẻ; chuyển khoản phải qua PayOS',
    );
    final json = await _api.patch(
      '/orders/$orderId/pay',
      data: {'paymentMethod': method.apiValue},
    );
    return Order.fromJson(requireObject(json, 'order'));
  }

  /// Lấy (hoặc tạo mới nếu đã hết hạn) mã QR PayOS cho đơn tại quầy.
  Future<PayosPayment> fetchPosPayment(String orderId) =>
      _payments.fetchPosPaymentLink(orderId);

  /// Hỏi PayOS khách đã chuyển khoản chưa; đã nhận tiền thì đơn tự hoàn tất.
  Future<PayosSyncResult> syncPosPayment(String orderId) =>
      _payments.syncPosPayment(orderId);

  /// `PATCH /orders/:id/cancel` — hủy đơn, hàng đang giữ trả về kho. Đơn online
  /// bắt buộc lý do ≥ 15 ký tự; đơn tại quầy được để trống.
  Future<Order> cancelOrder(String orderId, {String reason = ''}) =>
      _orders.cancelOrder(orderId, reason: reason);

  // ---------------------------------------------------------------------------
  // Đơn online
  // ---------------------------------------------------------------------------

  /// `GET /orders?channel=ONLINE&status=...` — bỏ qua đơn lỗi dữ liệu thay vì
  /// làm hỏng cả danh sách.
  Future<List<Order>> fetchOnlineOrders({OrderStatus? status}) async {
    final json = await _api.get(
      '/orders',
      query: {'channel': 'ONLINE', 'status': ?status?.apiValue},
    );
    final raw = json['orders'];
    if (raw is! List) return const [];
    return [
      for (final item in raw.whereType<Map<dynamic, dynamic>>())
        ?_tryParseOrder(item),
    ];
  }

  static Order? _tryParseOrder(Map<dynamic, dynamic> json) {
    try {
      return Order.fromJson(Map<String, dynamic>.from(json));
    } catch (_) {
      return null;
    }
  }

  /// `PATCH /orders/:id/online-status`. Hoàn tất đơn chuyển khoản mà khách chưa
  /// chuyển thì phải [collectedCash] = true (đã thu tiền mặt khi nhận/giao);
  /// QR còn mở sẽ bị hủy trước.
  Future<Order> updateOnlineStatus(
    String orderId,
    OrderStatus next, {
    bool collectedCash = false,
  }) async {
    final json = await _api.patch(
      '/orders/$orderId/online-status',
      data: {'status': next.apiValue, if (collectedCash) 'collectedCash': true},
    );
    return Order.fromJson(requireObject(json, 'order'));
  }

  // ---------------------------------------------------------------------------
  // Kho (backend tự giới hạn theo chi nhánh đang làm)
  // ---------------------------------------------------------------------------

  /// `GET /inventory/products`
  Future<List<ProductInventory>> fetchStock() async {
    final json = await _api.get('/inventory/products');
    return parseList(json, 'products', ProductInventory.fromJson);
  }

  /// `POST /inventory/receipts` — phiếu nhập trực tiếp: tăng totalStock và
  /// availableStock (tối đa 1.000/lần). [expiryDate] là HSD của lô nhập.
  Future<void> createReceipt({
    required String productId,
    required int quantity,
    DateTime? expiryDate,
    String note = '',
  }) async {
    await _api.post(
      '/inventory/receipts',
      data: {
        'productId': productId,
        'quantity': quantity,
        if (expiryDate != null) 'expiryDate': _dateOnly(expiryDate),
        if (note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
  }

  /// `POST /inventory/adjustments` — ghi giảm (hỏng/lỗi/mất/hết hạn): giảm
  /// totalStock và availableStock; không đụng tới hàng đang giữ cho đơn.
  Future<void> createAdjustment({
    required String productId,
    required AdjustmentType type,
    required int quantity,
    String note = '',
  }) async {
    await _api.post(
      '/inventory/adjustments',
      data: {
        'productId': productId,
        'type': type.apiValue,
        'quantity': quantity,
        if (note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
  }

  /// `PATCH /inventory/expiry` — sửa HSD đang theo dõi; `null` = bỏ theo dõi.
  Future<void> updateExpiry(String productId, DateTime? expiryDate) async {
    await _api.patch(
      '/inventory/expiry',
      data: {
        'productId': productId,
        'expiryDate': expiryDate == null ? null : _dateOnly(expiryDate),
      },
    );
  }

  /// `GET /inventory/receipts` (100 phiếu gần nhất).
  Future<List<InventoryReceipt>> fetchReceipts() async {
    final json = await _api.get('/inventory/receipts');
    return parseList(json, 'receipts', InventoryReceipt.fromJson);
  }

  /// `GET /inventory/adjustments` (100 phiếu gần nhất).
  Future<List<InventoryAdjustment>> fetchAdjustments() async {
    final json = await _api.get('/inventory/adjustments');
    return parseList(json, 'adjustments', InventoryAdjustment.fromJson);
  }

  // ---------------------------------------------------------------------------
  // Đề xuất nhập hàng của Sales
  // ---------------------------------------------------------------------------

  /// `GET /inventory/restock-requests?status=...` (backend mặc định OPEN nên
  /// gửi `ALL` khi không lọc).
  Future<List<RestockRequest>> fetchRestockRequests({
    RestockStatus? status,
  }) async {
    final json = await _api.get(
      '/inventory/restock-requests',
      query: {'status': status?.apiValue ?? 'ALL'},
    );
    return parseList(json, 'requests', RestockRequest.fromJson);
  }

  /// Báo cho Sales biết Manager đã xem đề xuất.
  Future<void> acknowledgeRestock(String requestId) async {
    await _api.post('/inventory/restock-requests/$requestId/acknowledge');
  }

  /// Nhận hàng theo đề xuất (≤ số đề xuất): cộng kho, tạo phiếu nhập nguồn
  /// "Theo đề xuất Sales", đề xuất chuyển RESOLVED.
  Future<void> receiveRestock(
    String requestId, {
    required int quantity,
    DateTime? expiryDate,
    String note = '',
  }) async {
    await _api.post(
      '/inventory/restock-requests/$requestId/receive',
      data: {
        'receivedQuantity': quantity,
        if (expiryDate != null) 'expiryDate': _dateOnly(expiryDate),
        if (note.trim().isNotEmpty) 'managerNote': note.trim(),
      },
    );
  }

  /// Hủy đề xuất — bắt buộc ghi lý do để Sales biết.
  Future<void> cancelRestock(String requestId, String note) async {
    await _api.patch(
      '/inventory/restock-requests/$requestId',
      data: {'status': RestockStatus.cancelled.apiValue, 'managerNote': note},
    );
  }

  // ---------------------------------------------------------------------------
  // Trả hàng lỗi + hàng chuyển đến
  // ---------------------------------------------------------------------------

  /// `GET /inventory/return-requests?status=...`
  Future<List<InventoryReturnRequest>> fetchReturnRequests({
    ReturnRequestStatus? status,
  }) async {
    final json = await _api.get(
      '/inventory/return-requests',
      query: {'status': status?.apiValue ?? 'ALL'},
    );
    return parseList(json, 'requests', InventoryReturnRequest.fromJson);
  }

  /// `POST /inventory/return-requests` — số hàng bị khóa ngay (không bán được)
  /// tới khi Owner duyệt (trừ kho) hoặc từ chối (trả lại hàng bán được).
  Future<void> createReturnRequest({
    required String productId,
    required int quantity,
    required ReturnReasonType reason,
    String note = '',
  }) async {
    await _api.post(
      '/inventory/return-requests',
      data: {
        'productId': productId,
        'quantity': quantity,
        'reasonType': reason.apiValue,
        if (note.trim().isNotEmpty) 'managerNote': note.trim(),
      },
    );
  }

  /// `GET /inventory/transfers/incoming?status=...`
  Future<List<StockTransfer>> fetchIncomingTransfers({
    TransferStatus? status,
  }) async {
    final json = await _api.get(
      '/inventory/transfers/incoming',
      query: {'status': status?.apiValue ?? 'ALL'},
    );
    return parseList(json, 'transfers', StockTransfer.fromJson);
  }

  /// `POST /inventory/transfers/:id/confirm` — đã nhận đủ hàng: cộng kho chi
  /// nhánh và ghi phiếu nhập nguồn "Hàng chuyển đến".
  Future<void> confirmTransfer(String transferId) async {
    await _api.post('/inventory/transfers/$transferId/confirm');
  }

  /// `GET /inventory/history` — phiếu nhập, ghi giảm, trả hàng gộp một dòng
  /// thời gian (mới nhất trước, tối đa 200 dòng).
  Future<List<StockHistoryEntry>> fetchStockHistory({
    StockHistoryType? type,
    String? productId,
  }) async {
    final json = await _api.get(
      '/inventory/history',
      query: {'limit': 200, 'type': ?type?.apiValue, 'productId': ?productId},
    );
    final raw = json['entries'];
    if (raw is! List) return const [];
    return [
      for (final item in raw.whereType<Map<dynamic, dynamic>>())
        ?StockHistoryEntry.tryParse(Map<String, dynamic>.from(item)),
    ];
  }

  // ---------------------------------------------------------------------------
  // Đổi quà bằng điểm
  // ---------------------------------------------------------------------------

  /// `GET /users/search?query=...` — chỉ trả thành viên (khách vãng lai không
  /// có tài khoản tích điểm).
  Future<List<CustomerSearchResult>> searchMembers(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];
    final json = await _api.get('/users/search', query: {'query': trimmed});
    return parseList(
      json,
      'customers',
      CustomerSearchResult.fromJson,
    ).where((c) => c.isMember).toList();
  }

  /// `POST /users/:id/redeem-points` — trừ điểm và lưu lịch sử. Trả về số điểm
  /// còn lại của khách.
  Future<int> redeemPoints(
    String customerId, {
    required int points,
    required String rewardName,
    String note = '',
  }) async {
    final json = await _api.post(
      '/users/$customerId/redeem-points',
      data: {
        'points': points,
        'rewardName': rewardName.trim(),
        if (note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
    final remaining = requireObject(json, 'customer')['points'];
    return remaining is num ? remaining.toInt() : 0;
  }

  /// `GET /users/redemptions[?customerId=]` (mới nhất trước).
  Future<List<RewardRedemption>> fetchRedemptions({String? customerId}) async {
    final json = await _api.get(
      '/users/redemptions',
      query: {'customerId': ?customerId},
    );
    return parseList(json, 'redemptions', RewardRedemption.fromJson);
  }

  /// Ngày theo lịch địa phương, không lệch múi giờ khi backend đọc.
  static String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
