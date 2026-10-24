import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/features/customer/data/order_repository.dart';
import 'package:gutacosmetic/features/sales/data/sales_repository.dart';
import 'package:gutacosmetic/features/sales/presentation/controllers/pos_cart_controller.dart';
import 'package:gutacosmetic/features/session/session_controller.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';

class FakeSalesRepository implements SalesRepository {
  OfflineOrderRequest? lastCreatedRequest;
  OfflineOrderRequest? lastSubmittedRequest;
  int requestCount = 0;
  Object? submitError;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Order> createOfflineOrder(OfflineOrderRequest request) async {
    requestCount++;
    lastCreatedRequest = request;
    return Order(
      id: 'ord_123',
      orderCode: 'GUTA-ORD-123',
      storeId: EntityRef(request.storeId),
      customerName: request.customerName,
      status: OrderStatus.pendingApproval,
    );
  }

  @override
  Future<Order> submitOfflineOrder(OfflineOrderRequest request) async {
    requestCount++;
    if (submitError != null) throw submitError!;
    lastSubmittedRequest = request;
    return Order(
      id: 'ord_123',
      orderCode: 'GUTA-ORD-123',
      storeId: EntityRef(request.storeId),
      customerName: request.customerName,
      status: OrderStatus.pendingPayment,
    );
  }
}

void main() {
  test('thêm được nhiều sản phẩm vào cùng một giỏ POS và tính toán chính xác', () {
    final container = ProviderContainer(
      overrides: [
        activeStoreProvider.overrideWithValue(const Store(id: 'store1')),
      ],
    );
    addTearDown(container.dispose);

    final cart = container.read(posCartControllerProvider.notifier);
    const serum = Product(id: 'p1', name: 'Serum', price: 200000);
    const toner = Product(id: 'p2', name: 'Toner', price: 150000);
    const cream = Product(id: 'p3', name: 'Cream', price: 300000);

    expect(cart.addProduct(serum, 5), isTrue);
    expect(cart.addProduct(toner, 3), isTrue);
    expect(cart.addProduct(serum, 5), isTrue);
    expect(cart.addProduct(cream, 2), isTrue);

    final state = container.read(posCartControllerProvider);
    expect(state.items.map((item) => (item.product.id, item.quantity)), [
      ('p1', 2),
      ('p2', 1),
      ('p3', 1),
    ]);
    expect(state.itemCount, 3);
    expect(state.totalItems, 4);
    expect(state.subtotal, 850000); // 200k*2 + 150k + 300k
  });

  test('tăng giảm số lượng và kiểm tra giới hạn tồn kho', () {
    final container = ProviderContainer(
      overrides: [
        activeStoreProvider.overrideWithValue(const Store(id: 'store1')),
      ],
    );
    addTearDown(container.dispose);

    final cart = container.read(posCartControllerProvider.notifier);
    const serum = Product(id: 'p1', name: 'Serum', price: 200000);

    expect(cart.addProduct(serum, 2), isTrue);
    expect(cart.addProduct(serum, 2), isTrue);
    // Vượt quá tồn kho 2 -> từ chối
    expect(cart.addProduct(serum, 2), isFalse);

    // Cập nhật số lượng về 0 -> xóa khỏi giỏ
    cart.updateQuantity('p1', 0);
    expect(container.read(posCartControllerProvider).isEmpty, isTrue);
  });

  test('submitAndApproveOrder: tạo và gửi thu ngân trong một request với đầy đủ sản phẩm', () async {
    final fakeRepo = FakeSalesRepository();
    final container = ProviderContainer(
      overrides: [
        activeStoreProvider.overrideWithValue(const Store(id: 'store1')),
        salesRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    final cart = container.read(posCartControllerProvider.notifier);
    const serum = Product(id: 'p1', name: 'Serum', price: 200000);
    const toner = Product(id: 'p2', name: 'Toner', price: 150000);

    cart.addProduct(serum, 10);
    cart.addProduct(serum, 10);
    cart.addProduct(toner, 10);

    final approvedOrder = await cart.submitAndApproveOrder();

    final request = fakeRepo.lastSubmittedRequest;
    expect(request, isNotNull);
    expect(request!.storeId, 'store1');
    expect(request.items.length, 2);
    expect(request.items[0].productId, 'p1');
    expect(request.items[0].quantity, 2);
    expect(request.items[1].productId, 'p2');
    expect(request.items[1].quantity, 1);

    // Chỉ một request, không tạo giỏ tạm riêng rồi mới duyệt
    expect(fakeRepo.requestCount, 1);
    expect(fakeRepo.lastCreatedRequest, isNull);
    expect(approvedOrder.status, OrderStatus.pendingPayment);

    // Giỏ hàng được làm mới sau khi gửi thành công
    expect(container.read(posCartControllerProvider).isEmpty, isTrue);
  });

  test('submitAndApproveOrder lỗi (thiếu hàng): giữ nguyên giỏ, gửi lại không tạo đơn thừa', () async {
    final fakeRepo = FakeSalesRepository()
      ..submitError = Exception('INSUFFICIENT_STOCK');
    final container = ProviderContainer(
      overrides: [
        activeStoreProvider.overrideWithValue(const Store(id: 'store1')),
        salesRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    final cart = container.read(posCartControllerProvider.notifier);
    cart.addProduct(const Product(id: 'p1', name: 'Serum', price: 200000), 5);

    await expectLater(cart.submitAndApproveOrder(), throwsException);

    final state = container.read(posCartControllerProvider);
    expect(state.items.length, 1);
    expect(state.isSubmitting, isFalse);
    expect(fakeRepo.requestCount, 1);
    expect(fakeRepo.lastCreatedRequest, isNull);

    // Gửi lại sau khi hết lỗi: vẫn chỉ đúng một đơn được tạo
    fakeRepo.submitError = null;
    await cart.submitAndApproveOrder();
    expect(fakeRepo.requestCount, 2);
    expect(fakeRepo.lastSubmittedRequest!.items.single.productId, 'p1');
    expect(container.read(posCartControllerProvider).isEmpty, isTrue);
  });
}
