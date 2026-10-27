import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../shared/models/models.dart';
import 'owner_models.dart';

final ownerRepositoryProvider = Provider<OwnerRepository>(
  (ref) => OwnerRepository(ref.watch(apiClientProvider)),
);

/// Bộ lọc báo cáo doanh thu: `yyyy-mm-dd` (giờ VN) và cửa hàng (`null` = tất cả).
typedef RevenueQuery = ({String from, String to, String? storeId});

final ownerDashboardProvider = FutureProvider.autoDispose<OwnerDashboard>(
  (ref) => ref.watch(ownerRepositoryProvider).fetchDashboard(),
);

final ownerRevenueProvider = FutureProvider.autoDispose
    .family<RevenueReport, RevenueQuery>(
      (ref, query) => ref.watch(ownerRepositoryProvider).fetchRevenue(query),
    );

final ownerStoresProvider = FutureProvider.autoDispose<List<Store>>(
  (ref) => ref.watch(ownerRepositoryProvider).fetchStores(),
);

final ownerStaffProvider = FutureProvider.autoDispose<List<AppUser>>(
  (ref) => ref.watch(ownerRepositoryProvider).fetchStaff(),
);

final ownerProductsProvider = FutureProvider.autoDispose<List<Product>>(
  (ref) => ref.watch(ownerRepositoryProvider).fetchProducts(),
);

/// Tồn kho mọi sản phẩm ở mọi cửa hàng (chỉ xem).
final ownerStockProvider = FutureProvider.autoDispose<List<ProductInventory>>(
  (ref) => ref.watch(ownerRepositoryProvider).fetchStock(),
);

final ownerTransfersProvider = FutureProvider.autoDispose
    .family<List<StockTransfer>, TransferStatus?>(
      (ref, status) =>
          ref.watch(ownerRepositoryProvider).fetchTransfers(status: status),
    );

final ownerRestockRequestsProvider = FutureProvider.autoDispose
    .family<List<RestockRequest>, RestockStatus?>(
      (ref, status) => ref
          .watch(ownerRepositoryProvider)
          .fetchRestockRequests(status: status),
    );

final ownerReturnRequestsProvider = FutureProvider.autoDispose
    .family<List<InventoryReturnRequest>, ReturnRequestStatus?>(
      (ref, status) => ref
          .watch(ownerRepositoryProvider)
          .fetchReturnRequests(status: status),
    );

/// Đơn của một chi nhánh (Owner chỉ xem).
final ownerStoreOrdersProvider = FutureProvider.autoDispose
    .family<List<Order>, String>(
      (ref, storeId) =>
          ref.watch(ownerRepositoryProvider).fetchStoreOrders(storeId),
    );

/// Phiếu nhập hàng của một cửa hàng (Owner dùng cho kho tổng).
final ownerReceiptsProvider = FutureProvider.autoDispose
    .family<List<InventoryReceipt>, String>(
      (ref, storeId) =>
          ref.watch(ownerRepositoryProvider).fetchReceipts(storeId),
    );

/// Ảnh sản phẩm chọn từ máy, chờ tải lên Cloudinary.
typedef ImageUpload = ({Uint8List bytes, String fileName, String mimeType});

/// Nghiệp vụ của Owner trên toàn chuỗi.
class OwnerRepository {
  OwnerRepository(this._api);

  final ApiClient _api;

  // ---- Tổng quan & báo cáo -------------------------------------------------

  Future<OwnerDashboard> fetchDashboard() async {
    final json = await _api.get('/owner/dashboard');
    return OwnerDashboard.fromJson(requireObject(json, 'dashboard'));
  }

  Future<RevenueReport> fetchRevenue(RevenueQuery query) async {
    final json = await _api.get(
      '/owner/analytics/revenue',
      query: {'from': query.from, 'to': query.to, 'storeId': ?query.storeId},
    );
    return RevenueReport.fromJson(requireObject(json, 'report'));
  }

  Future<List<Order>> fetchStoreOrders(String storeId) async {
    final json = await _api.get('/orders', query: {'storeId': storeId});
    final raw = json['orders'];
    if (raw is! List) return const [];
    final orders = <Order>[];
    for (final item in raw.whereType<Map<dynamic, dynamic>>()) {
      try {
        orders.add(Order.fromJson(Map<String, dynamic>.from(item)));
      } catch (_) {
        // Bỏ qua đơn lỗi dữ liệu thay vì làm hỏng cả danh sách.
      }
    }
    return orders;
  }

  Future<List<ProductInventory>> fetchStock() async {
    final json = await _api.get('/inventory/products');
    return parseList(json, 'products', ProductInventory.fromJson);
  }

  // ---- Nhập hàng từ nhà cung cấp -----------------------------------------

  Future<List<InventoryReceipt>> fetchReceipts(String storeId) async {
    final json = await _api.get(
      '/inventory/receipts',
      query: {'storeId': storeId},
    );
    return parseList(json, 'receipts', InventoryReceipt.fromJson);
  }

  /// Phiếu nhập một sản phẩm (tối đa 1.000/lần). Backend chỉ cho Owner nhập
  /// vào kho tổng; chi nhánh nhận hàng qua phiếu chuyển.
  Future<void> createReceipt({
    required String storeId,
    required String productId,
    required int quantity,
    DateTime? expiryDate,
    String note = '',
  }) async {
    await _api.post(
      '/inventory/receipts',
      data: {
        'storeId': storeId,
        'productId': productId,
        'quantity': quantity,
        if (expiryDate != null)
          'expiryDate':
              '${expiryDate.year.toString().padLeft(4, '0')}-'
              '${expiryDate.month.toString().padLeft(2, '0')}-'
              '${expiryDate.day.toString().padLeft(2, '0')}',
        if (note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
  }

  // ---- Sản phẩm -----------------------------------------------------------

  Future<List<Product>> fetchProducts() async {
    final json = await _api.get(
      '/owner/products',
      query: {'includeInactive': 'true'},
    );
    return parseList(json, 'products', Product.fromJson);
  }

  /// Tải ảnh lên Cloudinary, trả về đường dẫn để gắn vào sản phẩm khi lưu.
  Future<List<String>> uploadProductImages(List<ImageUpload> images) async {
    final form = FormData()
      ..files.addAll([
        for (final image in images)
          MapEntry(
            'images',
            MultipartFile.fromBytes(
              image.bytes,
              filename: image.fileName,
              contentType: DioMediaType.parse(image.mimeType),
            ),
          ),
      ]);
    final json = await _api.postMultipart('/owner/products/images', form);
    return [for (final url in (json['images'] as List? ?? const [])) '$url'];
  }

  Future<Product> createProduct(Map<String, Object?> data) async {
    final json = await _api.post('/owner/products', data: data);
    return Product.fromJson(requireObject(json, 'product'));
  }

  /// SKU không đổi được sau khi tạo (backend từ chối).
  Future<Product> updateProduct(String id, Map<String, Object?> data) async {
    final json = await _api.patch('/owner/products/$id', data: data);
    return Product.fromJson(requireObject(json, 'product'));
  }

  // ---- Cửa hàng -----------------------------------------------------------

  Future<List<Store>> fetchStores() async {
    final json = await _api.get(
      '/owner/stores',
      query: {'includeInactive': 'true'},
    );
    return parseList(json, 'stores', Store.fromJson);
  }

  Future<Store> createStore(Map<String, Object?> data) async {
    final json = await _api.post('/owner/stores', data: data);
    return Store.fromJson(requireObject(json, 'store'));
  }

  /// Loại cửa hàng cố định; ngừng hoạt động bị chặn khi còn đơn, nhân viên
  /// hoặc phiếu chuyển chưa nhận.
  Future<Store> updateStore(String id, Map<String, Object?> data) async {
    final json = await _api.patch('/owner/stores/$id', data: data);
    return Store.fromJson(requireObject(json, 'store'));
  }

  // ---- Nhân viên ----------------------------------------------------------

  Future<List<AppUser>> fetchStaff() async {
    final json = await _api.get(
      '/owner/staff',
      query: {'includeInactive': 'true'},
    );
    return parseList(json, 'staff', AppUser.fromJson);
  }

  Future<AppUser> createStaff(Map<String, Object?> data) async {
    final json = await _api.post('/owner/staff', data: data);
    return AppUser.fromJson(requireObject(json, 'staff'));
  }

  Future<AppUser> updateStaff(String id, Map<String, Object?> data) async {
    final json = await _api.patch('/owner/staff/$id', data: data);
    return AppUser.fromJson(requireObject(json, 'staff'));
  }

  // ---- Chuyển hàng --------------------------------------------------------

  Future<List<StockTransfer>> fetchTransfers({TransferStatus? status}) async {
    final json = await _api.get(
      '/owner/transfers',
      query: {'status': status?.apiValue ?? 'ALL'},
    );
    return parseList(json, 'transfers', StockTransfer.fromJson);
  }

  /// Kho gửi bị trừ ngay; chi nhánh nhận được cộng khi Manager xác nhận.
  Future<void> createTransfer({
    required String fromStoreId,
    required String toStoreId,
    required List<({String productId, int quantity})> items,
    String note = '',
  }) async {
    await _api.post(
      '/owner/transfers',
      data: {
        'fromStoreId': fromStoreId,
        'toStoreId': toStoreId,
        'items': [
          for (final item in items)
            {'productId': item.productId, 'quantity': item.quantity},
        ],
        if (note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
  }

  /// Chỉ hủy được khi chưa nhận; hàng hoàn về kho gửi.
  Future<void> cancelTransfer(String transferId) async {
    await _api.patch('/owner/transfers/$transferId/cancel');
  }

  // ---- Duyệt yêu cầu kho --------------------------------------------------

  Future<List<RestockRequest>> fetchRestockRequests({
    RestockStatus? status,
  }) async {
    final json = await _api.get(
      '/inventory/restock-requests',
      query: {'status': status?.apiValue ?? 'ALL'},
    );
    return parseList(json, 'requests', RestockRequest.fromJson);
  }

  /// Duyệt: tạo phiếu chuyển hàng (mặc định từ kho tổng) tới chi nhánh.
  Future<void> approveRestock(
    String requestId, {
    String? fromStoreId,
    int? quantity,
    String note = '',
  }) async {
    await _api.post(
      '/owner/restock-requests/$requestId/approve',
      data: {
        'fromStoreId': ?fromStoreId,
        'quantity': ?quantity,
        if (note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
  }

  /// Từ chối — bắt buộc lý do.
  Future<void> rejectRestock(String requestId, String note) async {
    await _api.post(
      '/owner/restock-requests/$requestId/reject',
      data: {'note': note},
    );
  }

  Future<List<InventoryReturnRequest>> fetchReturnRequests({
    ReturnRequestStatus? status,
  }) async {
    final json = await _api.get(
      '/inventory/return-requests',
      query: {'status': status?.apiValue ?? 'ALL'},
    );
    return parseList(json, 'requests', InventoryReturnRequest.fromJson);
  }

  /// Duyệt: trừ hẳn hàng đã khóa; từ chối: trả lại hàng bán được.
  Future<void> reviewReturn(
    String requestId, {
    required bool approve,
    String note = '',
  }) async {
    await _api.patch(
      '/inventory/return-requests/$requestId/review',
      data: {
        'status': approve
            ? ReturnRequestStatus.approved.apiValue
            : ReturnRequestStatus.rejected.apiValue,
        if (note.trim().isNotEmpty) 'reviewNote': note.trim(),
      },
    );
  }
}
