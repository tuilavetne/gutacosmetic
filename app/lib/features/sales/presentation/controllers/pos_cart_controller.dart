import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/constants.dart';
import '../../../customer/data/order_repository.dart';
import '../../../session/session_controller.dart';
import '../../../shared/models/models.dart';
import '../../data/sales_repository.dart';

class PosCartLine {
  const PosCartLine({
    required this.product,
    required this.quantity,
    required this.availableStock,
  });

  final Product product;
  final int quantity;
  final int availableStock;

  int get lineTotal => product.price * quantity;

  PosCartLine copyWith({
    Product? product,
    int? quantity,
    int? availableStock,
  }) => PosCartLine(
    product: product ?? this.product,
    quantity: quantity ?? this.quantity,
    availableStock: availableStock ?? this.availableStock,
  );
}

class PosCartState {
  const PosCartState({
    this.storeId,
    this.customer,
    this.customName = '',
    this.customPhone = '',
    this.items = const [],
    this.isSubmitting = false,
    this.editingOrderId,
    this.editingOrderCode,
  });

  final String? storeId;
  final CustomerSearchResult? customer;
  final String customName;
  final String customPhone;
  final List<PosCartLine> items;
  final bool isSubmitting;

  /// Giỏ tạm (đơn chờ duyệt) đang được mở lại để thêm/bớt sản phẩm; `null`
  /// khi đang soạn giỏ mới.
  final String? editingOrderId;
  final String? editingOrderCode;

  bool get isEditingDraft => editingOrderId != null;

  String get effectiveCustomerName {
    if (customer != null && customer!.fullName.isNotEmpty) {
      return customer!.fullName;
    }
    return customName.trim().isNotEmpty ? customName.trim() : 'Khách vãng lai';
  }

  String get effectiveCustomerPhone {
    if (customer != null && (customer!.phone?.isNotEmpty ?? false)) {
      return customer!.phone!;
    }
    return customPhone.trim();
  }

  String? get customerId => customer?.orderCustomerId;

  int get totalItems => items.fold(0, (sum, e) => sum + e.quantity);
  int get itemCount => items.length;
  int get subtotal => items.fold(0, (sum, e) => sum + e.lineTotal);

  bool get isEmpty => items.isEmpty;

  PosCartState copyWith({
    String? storeId,
    CustomerSearchResult? Function()? customer,
    String? customName,
    String? customPhone,
    List<PosCartLine>? items,
    bool? isSubmitting,
  }) {
    return PosCartState(
      storeId: storeId ?? this.storeId,
      customer: customer != null ? customer() : this.customer,
      customName: customName ?? this.customName,
      customPhone: customPhone ?? this.customPhone,
      items: items ?? this.items,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      // Giữ nguyên: chỉ loadDraft/reset mới đổi giỏ tạm đang sửa.
      editingOrderId: editingOrderId,
      editingOrderCode: editingOrderCode,
    );
  }
}

final posCartControllerProvider =
    NotifierProvider<PosCartController, PosCartState>(PosCartController.new);

class PosCartController extends Notifier<PosCartState> {
  @override
  PosCartState build() {
    // Theo dõi chi nhánh làm việc: Khi đổi chi nhánh hoặc đăng xuất (activeStore thay đổi/null),
    // provider sẽ tự động khởi tạo lại state mới cho chi nhánh đó, giỏ cũ của chi nhánh trước sẽ mất luôn.
    final activeStore = ref.watch(activeStoreProvider);
    return PosCartState(storeId: activeStore?.id);
  }

  void selectCustomer(CustomerSearchResult? customer) {
    state = state.copyWith(
      customer: () => customer,
      customName: customer?.fullName ?? '',
      customPhone: customer?.phone ?? '',
    );
  }

  void setCustomCustomer({required String name, required String phone}) {
    state = state.copyWith(
      customer: () => null,
      customName: name,
      customPhone: phone,
    );
  }

  void clearCustomer() {
    state = state.copyWith(
      customer: () => null,
      customName: '',
      customPhone: '',
    );
  }

  /// Thêm hoặc tăng số lượng sản phẩm vào giỏ POS của chi nhánh đang chọn
  bool addProduct(Product product, int availableStock, {int quantity = 1}) {
    final activeStore = ref.read(activeStoreProvider);
    if (activeStore == null) {
      return false;
    }
    if (state.storeId != null && state.storeId != activeStore.id) {
      state = PosCartState(storeId: activeStore.id);
    } else if (state.storeId == null) {
      state = state.copyWith(storeId: activeStore.id);
    }

    if (availableStock <= 0) return false;

    final existingIndex = state.items.indexWhere(
      (e) => e.product.id == product.id,
    );

    final currentQty = existingIndex >= 0
        ? state.items[existingIndex].quantity
        : 0;
    final newQty = currentQty + quantity;

    if (newQty > availableStock || newQty > AppConstants.maxCartQuantity) {
      return false;
    }

    final newItems = [...state.items];
    if (existingIndex >= 0) {
      newItems[existingIndex] = newItems[existingIndex].copyWith(
        quantity: newQty,
        availableStock: availableStock,
      );
    } else {
      newItems.add(
        PosCartLine(
          product: product,
          quantity: newQty,
          availableStock: availableStock,
        ),
      );
    }

    state = state.copyWith(items: newItems);
    return true;
  }

  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }

    final index = state.items.indexWhere((e) => e.product.id == productId);
    if (index < 0) return;

    final item = state.items[index];
    final clamped = newQuantity.clamp(1, item.availableStock);

    final newItems = [...state.items];
    newItems[index] = item.copyWith(quantity: clamped);
    state = state.copyWith(items: newItems);
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((e) => e.product.id != productId).toList(),
    );
  }

  void clearCart() {
    state = state.copyWith(items: const []);
  }

  /// Reset toàn bộ giỏ hàng và thông tin khách hàng của chi nhánh
  void reset() {
    final activeStore = ref.read(activeStoreProvider);
    state = PosCartState(storeId: activeStore?.id);
  }

  /// Mở lại giỏ tạm (đơn chờ duyệt) vào POS để Sales thêm/bớt sản phẩm.
  ///
  /// Tồn kho lấy mới từ server để giới hạn số lượng đúng thời điểm hiện tại.
  Future<void> loadDraft(Order order) async {
    final activeStore = ref.read(activeStoreProvider);
    if (activeStore == null) {
      throw StateError('Chưa chọn chi nhánh làm việc');
    }

    final inventories = await ref
        .read(salesRepositoryProvider)
        .fetchProductsWithInventory(
          productIds: [for (final item in order.items) item.productId.id],
        );
    final byId = {for (final inv in inventories) inv.product.id: inv};

    final member = order.customerId;
    state = PosCartState(
      storeId: activeStore.id,
      editingOrderId: order.id,
      editingOrderCode: order.orderCode,
      customer: member == null
          ? null
          : CustomerSearchResult(
              id: member.id,
              fullName: member.data?.fullName ?? order.customerName ?? '',
              phone: member.data?.phone ?? order.customerPhone,
              points: member.data?.points ?? 0,
            ),
      customName: order.customerName ?? '',
      customPhone: order.customerPhone ?? '',
      items: [
        for (final item in order.items)
          PosCartLine(
            product:
                byId[item.productId.id]?.product ??
                Product(
                  id: item.productId.id,
                  sku: item.sku,
                  name: item.name,
                  image: item.image,
                  price: item.unitPrice,
                ),
            quantity: item.quantity,
            availableStock:
                byId[item.productId.id]?.availableAt(activeStore.id) ?? 0,
          ),
      ],
    );
  }

  /// Nghiệp vụ 15: Lưu giỏ tạm (PENDING_APPROVAL) - Chưa giữ hàng trong kho.
  /// Đang mở lại giỏ tạm thì cập nhật chính đơn đó thay vì tạo đơn mới.
  Future<Order> createDraftOrder() {
    final draftId = state.editingOrderId;
    return _submit(
      (repo, request) => draftId == null
          ? repo.createOfflineOrder(request)
          : repo.updateDraftOrder(draftId, request),
    );
  }

  /// Nghiệp vụ 15: Duyệt giỏ gửi thu ngân (PENDING_PAYMENT) - Giữ kho ngay.
  ///
  /// Tạo (hoặc lưu giỏ tạm đang sửa) và gửi thu ngân trong một request: nếu
  /// thiếu hàng thì backend không tạo/đổi đơn nào và giỏ được giữ nguyên để
  /// Sales chỉnh rồi gửi lại.
  Future<Order> submitAndApproveOrder() {
    final draftId = state.editingOrderId;
    return _submit(
      (repo, request) => draftId == null
          ? repo.submitOfflineOrder(request)
          : repo.submitDraftOrder(draftId, request),
    );
  }

  Future<Order> _submit(
    Future<Order> Function(SalesRepository repo, OfflineOrderRequest request)
    send,
  ) async {
    final activeStore = ref.read(activeStoreProvider);
    if (activeStore == null) {
      throw StateError('Chưa chọn chi nhánh làm việc');
    }
    if (state.isEmpty) {
      throw StateError('Giỏ hàng đang trống');
    }

    state = state.copyWith(isSubmitting: true);
    try {
      final request = (
        storeId: activeStore.id,
        customerId: state.customerId,
        customerName: state.effectiveCustomerName,
        customerPhone: state.effectiveCustomerPhone,
        items: [
          for (final line in state.items)
            (productId: line.product.id, quantity: line.quantity),
        ],
      );

      final order = await send(ref.read(salesRepositoryProvider), request);
      reset();
      return order;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
