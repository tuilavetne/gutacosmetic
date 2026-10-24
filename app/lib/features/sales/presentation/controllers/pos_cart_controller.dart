import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/constants.dart';
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
  });

  final String? storeId;
  final CustomerSearchResult? customer;
  final String customName;
  final String customPhone;
  final List<PosCartLine> items;
  final bool isSubmitting;

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

  /// Nghiệp vụ 15: Tạo giỏ tạm (PENDING_APPROVAL) - Chưa giữ hàng trong kho
  Future<Order> createDraftOrder() async {
    final activeStore = ref.read(activeStoreProvider);
    if (activeStore == null) {
      throw StateError('Chưa chọn chi nhánh làm việc');
    }
    if (state.isEmpty) {
      throw StateError('Giỏ hàng đang trống');
    }

    state = state.copyWith(isSubmitting: true);
    try {
      final repo = ref.read(salesRepositoryProvider);
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

      final order = await repo.createOfflineOrder(request);
      reset();
      return order;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  /// Nghiệp vụ 15: Duyệt giỏ gửi thu ngân (PENDING_PAYMENT) - Lúc này mới tăng reservedStock
  Future<Order> submitAndApproveOrder() async {
    final activeStore = ref.read(activeStoreProvider);
    if (activeStore == null) {
      throw StateError('Chưa chọn chi nhánh làm việc');
    }
    if (state.isEmpty) {
      throw StateError('Giỏ hàng đang trống');
    }

    state = state.copyWith(isSubmitting: true);
    try {
      final repo = ref.read(salesRepositoryProvider);
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

      final order = await repo.createOfflineOrder(request);
      final approvedOrder = await repo.approveOfflineOrder(order.id);
      reset();
      return approvedOrder;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
