import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/app/theme.dart';
import 'package:gutacosmetic/core/widgets/app_messenger.dart';
import 'package:gutacosmetic/features/customer/data/order_repository.dart';
import 'package:gutacosmetic/features/customer/presentation/payos_payment_screen.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';
import 'package:material_ui/material_ui.dart';

class _FakeOrderRepository implements OrderRepository {
  _FakeOrderRepository(this.order);

  Order order;
  int linkCalls = 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Order> fetchOrder(String id) async => order;

  /// Lần đầu trả QR đã hết hạn, lần sau tạo mã mới còn hạn.
  @override
  Future<PayosPayment> fetchPaymentLink(String orderId) async {
    linkCalls++;
    return PayosPayment(
      expiredAt: linkCalls == 1
          ? DateTime.now().subtract(const Duration(minutes: 1))
          : DateTime.now().add(const Duration(minutes: 15)),
    );
  }

  @override
  Future<PayosSyncResult> syncPayment(String orderId) async =>
      PayosSyncResult(order: order);
}

Order _transferOrder(OrderStatus status) => Order(
  id: 'o1',
  orderCode: 'GUTA-O1',
  channel: OrderChannel.online,
  fulfillmentType: FulfillmentType.storePickup,
  status: status,
  paymentMethod: PaymentMethod.bankTransfer,
  totalPrice: 120000,
);

Future<_FakeOrderRepository> _pump(WidgetTester tester, Order order) async {
  final repo = _FakeOrderRepository(order);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [orderRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: buildAppTheme(),
        home: const PayosPaymentScreen(orderId: 'o1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('QR hết hạn: đơn vẫn giữ (không tự hủy), tạo được mã QR mới', (
    tester,
  ) async {
    final repo = await _pump(tester, _transferOrder(OrderStatus.pending));

    expect(find.text('Mã QR đã hết hạn'), findsOneWidget);
    expect(find.textContaining('vẫn được giữ'), findsOneWidget);
    expect(find.textContaining('tự động hủy'), findsNothing);

    await tester.tap(find.text('Tạo mã QR mới'));
    await tester.pumpAndSettle();

    expect(repo.linkCalls, 2);
    expect(find.text('Mã QR đã hết hạn'), findsNothing);
    await tester.pumpWidget(const SizedBox()); // hủy timer đếm ngược
  });

  testWidgets('Cửa hàng đang chuẩn bị hàng: khách vẫn thanh toán được', (
    tester,
  ) async {
    final repo = await _pump(tester, _transferOrder(OrderStatus.preparing));

    expect(repo.linkCalls, 1);
    expect(find.text('Đơn hàng đã hủy'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Đơn đã hủy: báo đã hủy, không tạo QR', (tester) async {
    final repo = await _pump(tester, _transferOrder(OrderStatus.cancelled));

    expect(find.text('Đơn hàng đã hủy'), findsOneWidget);
    expect(repo.linkCalls, 0);
  });
}
