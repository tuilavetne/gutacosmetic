import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/app/theme.dart';
import 'package:gutacosmetic/core/utils/formatters.dart';
import 'package:gutacosmetic/core/widgets/app_messenger.dart';
import 'package:gutacosmetic/features/manager/data/manager_repository.dart';
import 'package:gutacosmetic/features/manager/presentation/cashier/cashier_order_screen.dart';
import 'package:gutacosmetic/features/manager/presentation/cashier/cashier_screen.dart';
import 'package:gutacosmetic/features/manager/presentation/manager_shell.dart';
import 'package:gutacosmetic/features/session/session_controller.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';
import 'package:material_ui/material_ui.dart';

Order _order({
  String id = 'ord_1',
  OrderStatus status = OrderStatus.pendingPayment,
  bool member = true,
  int total = 175000,
}) => Order(
  id: id,
  orderCode: 'GUTA-$id',
  channel: OrderChannel.offline,
  status: status,
  customerId: member
      ? const EntityRef(
          'cus_1',
          AppUser(id: 'cus_1', fullName: 'Chị Lan', role: UserRole.customer),
        )
      : null,
  customerName: member ? 'Chị Lan' : 'Khách lẻ',
  items: [
    OrderItem(
      productId: const EntityRef('p1'),
      sku: 'SR-01',
      name: 'Serum',
      quantity: 1,
      unitPrice: total,
      lineTotal: total,
    ),
  ],
  subtotal: total,
  totalPrice: total,
);

class _FakeManagerRepository implements ManagerRepository {
  _FakeManagerRepository(this.order);

  Order order;
  List<Order> waiting = const [];
  PaymentMethod? paidWith;
  String? cancelledId;
  int syncCalls = 0;
  bool payosPaid = false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<Order>> fetchCashierOrders() async => waiting;

  @override
  Future<List<RewardRedemption>> fetchRedemptions({String? customerId}) async =>
      const [];

  @override
  Future<Order> fetchOrder(String orderId) async => order;

  Order _completed(PaymentMethod method) => order = order.copyWith(
    status: OrderStatus.completed,
    paymentStatus: PaymentStatus.paid,
    paymentMethod: method,
    pointsEarned: order.customerId == null ? 0 : order.totalPrice ~/ 10000,
  );

  @override
  Future<Order> payAtCounter(String orderId, PaymentMethod method) async {
    paidWith = method;
    return _completed(method);
  }

  @override
  Future<Order> cancelOrder(String orderId, {String reason = ''}) async {
    cancelledId = orderId;
    return order = order.copyWith(status: OrderStatus.cancelled);
  }

  @override
  Future<PayosPayment> fetchPosPayment(String orderId) async =>
      PayosPayment(expiredAt: DateTime.now().add(const Duration(minutes: 15)));

  @override
  Future<PayosSyncResult> syncPosPayment(String orderId) async {
    syncCalls++;
    return PayosSyncResult(
      order: payosPaid ? _completed(PaymentMethod.bankTransfer) : order,
      payosStatus: payosPaid ? 'PAID' : 'PENDING',
    );
  }
}

Future<_FakeManagerRepository> _pumpOrder(
  WidgetTester tester, {
  bool member = true,
}) async {
  final repo = _FakeManagerRepository(_order(member: member));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        managerRepositoryProvider.overrideWithValue(repo),
        activeStoreProvider.overrideWithValue(const Store(id: 's1')),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: buildAppTheme(),
        home: const CashierOrderScreen(orderId: 'ord_1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('Danh sách thu ngân: hiện đơn chờ và tổng tiền', (tester) async {
    final repo = _FakeManagerRepository(_order())
      ..waiting = [
        _order(id: 'a'),
        _order(id: 'b', member: false, total: 55000),
      ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          managerRepositoryProvider.overrideWithValue(repo),
          activeStoreProvider.overrideWithValue(const Store(id: 's1')),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const Scaffold(body: CashierScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('GUTA-a'), findsOneWidget);
    expect(find.text('GUTA-b'), findsOneWidget);
    expect(
      find.text('2 đơn chờ thu • tổng ${formatVnd(230000)}'),
      findsOneWidget,
    );
    // Màn tự làm mới định kỳ: bỏ cây widget để hủy timer.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Thu tiền mặt: tính tiền thối, hoàn tất và báo cộng điểm', (
    tester,
  ) async {
    final repo = await _pumpOrder(tester);

    expect(
      find.text('Khách sẽ được cộng 17 điểm (10.000đ = 1 điểm).'),
      findsOneWidget,
    );
    await tester.tap(find.text('Tiền mặt'));
    await tester.pumpAndSettle();

    // Khách đưa thiếu: không cho xác nhận
    await tester.enterText(
      find.byKey(const ValueKey('cash-received')),
      '100000',
    );
    await tester.pump();
    expect(find.text('Khách đưa chưa đủ tiền'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Đã nhận tiền'),
          )
          .onPressed,
      isNull,
    );

    await tester.enterText(
      find.byKey(const ValueKey('cash-received')),
      '200000',
    );
    await tester.pump();
    expect(find.text('Tiền thối lại: ${formatVnd(25000)}'), findsOneWidget);
    await tester.tap(find.text('Đã nhận tiền'));
    await tester.pumpAndSettle();

    expect(repo.paidWith, PaymentMethod.cash);
    expect(find.textContaining('Khách được cộng 17 điểm'), findsWidgets);
    // Đơn đã hoàn tất: không còn nút thu tiền
    expect(find.text('Quẹt thẻ'), findsNothing);
  });

  testWidgets('Không có ô chiết khấu; quẹt thẻ cần xác nhận', (tester) async {
    final repo = await _pumpOrder(tester, member: false);

    expect(find.textContaining('chiết khấu'), findsNothing);
    expect(find.textContaining('Giảm'), findsNothing);
    expect(find.text('Không tích điểm'), findsOneWidget);

    await tester.tap(find.text('Quẹt thẻ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đã quẹt thẻ'));
    await tester.pumpAndSettle();

    expect(repo.paidWith, PaymentMethod.card);
  });

  testWidgets('QR PayOS: kiểm tra thanh toán, PayOS báo đã nhận thì hoàn tất', (
    tester,
  ) async {
    final repo = await _pumpOrder(tester);

    await tester.tap(find.text('QR PayOS'));
    await tester.pumpAndSettle();
    expect(find.text('Kiểm tra thanh toán'), findsOneWidget);

    // Chưa chuyển khoản
    await tester.tap(find.text('Kiểm tra thanh toán'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Chưa nhận được tiền'), findsOneWidget);

    // Khách chuyển khoản xong: lần kiểm tra tự động kế tiếp hoàn tất đơn
    repo.payosPaid = true;
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    expect(find.text('Kiểm tra thanh toán'), findsNothing);
    expect(repo.paidWith, isNull); // không thu tay
    expect(find.textContaining('Chuyển khoản QR'), findsWidgets);
    expect(repo.syncCalls, greaterThanOrEqualTo(2));
  });

  testWidgets('Hủy đơn khi khách không mua', (tester) async {
    final repo = await _pumpOrder(tester);

    await tester.tap(find.text('Hủy đơn (khách không mua)'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Hủy đơn'));
    await tester.pumpAndSettle();

    expect(repo.cancelledId, 'ord_1');
    expect(find.text('Đơn đã hủy, hàng đã trả về kho.'), findsOneWidget);
  });

  testWidgets('Khung Manager: 4 tab, badge số đơn chờ thu ngân', (
    tester,
  ) async {
    final repo = _FakeManagerRepository(_order())
      ..waiting = [_order(id: 'a'), _order(id: 'b')];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          managerRepositoryProvider.overrideWithValue(repo),
          activeStoreProvider.overrideWithValue(
            const Store(id: 's1', name: 'Chi nhánh 2'),
          ),
          currentUserProvider.overrideWithValue(
            const AppUser(
              id: 'm1',
              fullName: 'Quản lý A',
              role: UserRole.manager,
            ),
          ),
        ],
        child: MaterialApp(theme: buildAppTheme(), home: const ManagerShell()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chi nhánh 2'), findsOneWidget);
    expect(find.text('Quản lý: Quản lý A'), findsOneWidget);
    for (final label in ['Thu ngân', 'Đơn online', 'Kho', 'Đổi quà']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('2'), findsWidgets); // badge số đơn chờ
    expect(find.text('GUTA-a'), findsOneWidget);

    await tester.tap(find.text('Đổi quà'));
    await tester.pumpAndSettle();
    expect(
      find.text('Tìm khách thành viên theo tên, SĐT hoặc email'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });
}
