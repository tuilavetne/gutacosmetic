import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/app/theme.dart';
import 'package:gutacosmetic/core/widgets/app_messenger.dart';
import 'package:gutacosmetic/features/manager/data/manager_repository.dart';
import 'package:gutacosmetic/features/manager/presentation/online/online_order_screen.dart';
import 'package:gutacosmetic/features/manager/presentation/online/online_orders_screen.dart';
import 'package:gutacosmetic/features/session/session_controller.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';
import 'package:material_ui/material_ui.dart';

Order _online({
  String id = 'o1',
  FulfillmentType type = FulfillmentType.storePickup,
  PaymentMethod method = PaymentMethod.bankTransfer,
  PaymentStatus paid = PaymentStatus.unpaid,
  OrderStatus status = OrderStatus.pending,
}) => Order(
  id: id,
  orderCode: 'GUTA-$id',
  channel: OrderChannel.online,
  fulfillmentType: type,
  status: status,
  paymentMethod: method,
  paymentStatus: paid,
  customerName: 'Chị Lan',
  customerPhone: '0909000003',
  items: const [
    OrderItem(
      productId: EntityRef('p1'),
      sku: 'SR-01',
      name: 'Serum',
      quantity: 1,
      unitPrice: 120000,
      lineTotal: 120000,
    ),
  ],
  subtotal: 120000,
  totalPrice: 120000,
);

class _FakeRepo implements ManagerRepository {
  _FakeRepo(this.order);

  Order order;
  List<Order> list = const [];
  final moves = <(OrderStatus, bool)>[];
  String? cancelReason;
  OrderStatus? lastListFilter;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Order> fetchOrder(String orderId) async => order;

  @override
  Future<List<Order>> fetchOnlineOrders({OrderStatus? status}) async {
    lastListFilter = status;
    return list;
  }

  @override
  Future<Order> updateOnlineStatus(
    String orderId,
    OrderStatus next, {
    bool collectedCash = false,
  }) async {
    moves.add((next, collectedCash));
    return order = order.copyWith(
      status: next,
      paymentStatus: next == OrderStatus.completed
          ? PaymentStatus.paid
          : order.paymentStatus,
      paymentMethod: collectedCash ? PaymentMethod.cash : order.paymentMethod,
      pointsEarned: next == OrderStatus.completed ? 12 : 0,
    );
  }

  @override
  Future<Order> cancelOrder(String orderId, {String reason = ''}) async {
    cancelReason = reason;
    return order = order.copyWith(
      status: OrderStatus.cancelled,
      cancellationReason: reason,
    );
  }
}

Future<_FakeRepo> _pumpDetail(WidgetTester tester, Order order) async {
  final repo = _FakeRepo(order);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        managerRepositoryProvider.overrideWithValue(repo),
        activeStoreProvider.overrideWithValue(const Store(id: 's1')),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: buildAppTheme(),
        home: const OnlineOrderScreen(orderId: 'o1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets(
    'Nhận tại CH, chưa chuyển khoản: chuẩn bị → sẵn sàng → thu tiền mặt khi nhận',
    (tester) async {
      final repo = await _pumpDetail(tester, _online());
      expect(find.text('Chưa chuyển khoản'), findsOneWidget);

      await tester.tap(find.text('Bắt đầu chuẩn bị hàng'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hàng đã sẵn sàng cho khách nhận'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Khách đã nhận – Hoàn tất'));
      await tester.pumpAndSettle();

      // Hỏi xác nhận đã thu tiền mặt vì khách chưa chuyển khoản
      expect(find.text('Khách chưa chuyển khoản'), findsWidgets);
      await tester.tap(find.text('Đã thu tiền'));
      await tester.pumpAndSettle();

      expect(repo.moves, [
        (OrderStatus.preparing, false),
        (OrderStatus.readyForPickup, false),
        (OrderStatus.completed, true),
      ]);
      expect(find.textContaining('Khách được cộng 12 điểm'), findsOneWidget);
      // Đơn hoàn tất: không còn thao tác
      expect(find.text('Hủy đơn'), findsNothing);
    },
  );

  testWidgets('Giao hàng COD: chuẩn bị rồi hoàn tất, không gửi collectedCash', (
    tester,
  ) async {
    final repo = await _pumpDetail(
      tester,
      _online(type: FulfillmentType.delivery, method: PaymentMethod.cod),
    );
    expect(find.text('Chưa chuyển khoản'), findsNothing);

    await tester.tap(find.text('Bắt đầu chuẩn bị hàng'));
    await tester.pumpAndSettle();
    // Giao hàng không có bước "sẵn sàng nhận"
    expect(find.text('Hàng đã sẵn sàng cho khách nhận'), findsNothing);
    await tester.tap(find.text('Đã giao xong – Hoàn tất'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đã thu tiền'));
    await tester.pumpAndSettle();

    expect(repo.moves, [
      (OrderStatus.preparing, false),
      (OrderStatus.completed, false),
    ]);
  });

  testWidgets('Đã chuyển khoản: hoàn tất không hỏi thu tiền', (tester) async {
    final repo = await _pumpDetail(
      tester,
      _online(status: OrderStatus.readyForPickup, paid: PaymentStatus.paid),
    );

    await tester.tap(find.text('Khách đã nhận – Hoàn tất'));
    await tester.pumpAndSettle();

    expect(find.text('Đã thu tiền'), findsNothing);
    expect(repo.moves.single, (OrderStatus.completed, false));
  });

  testWidgets('Hủy đơn online bắt buộc lý do từ 15 ký tự', (tester) async {
    final repo = await _pumpDetail(tester, _online());

    await tester.tap(find.text('Hủy đơn'));
    await tester.pumpAndSettle();
    FilledButton confirm() => tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Hủy đơn'),
    );

    await tester.enterText(find.byType(TextField), 'hết hàng');
    await tester.pump();
    expect(confirm().onPressed, isNull);

    await tester.enterText(
      find.byType(TextField),
      'Khách không đến nhận hàng sau 3 ngày',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Hủy đơn'));
    await tester.pumpAndSettle();

    expect(repo.cancelReason, 'Khách không đến nhận hàng sau 3 ngày');
    expect(find.textContaining('Lý do hủy:'), findsOneWidget);
  });

  testWidgets('Danh sách: mặc định lọc Chờ xử lý, đánh dấu đơn chưa trả', (
    tester,
  ) async {
    final repo = _FakeRepo(_online())
      ..list = [
        _online(),
        _online(
          id: 'o2',
          type: FulfillmentType.delivery,
          method: PaymentMethod.cod,
        ),
      ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          managerRepositoryProvider.overrideWithValue(repo),
          activeStoreProvider.overrideWithValue(const Store(id: 's1')),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const Scaffold(body: OnlineOrdersScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.lastListFilter, OrderStatus.pending);
    expect(find.text('GUTA-o1'), findsOneWidget);
    expect(find.text('GUTA-o2'), findsOneWidget);
    expect(find.text('Chuyển khoản • CHƯA TRẢ'), findsOneWidget);

    await tester.ensureVisible(find.text('Tất cả'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tất cả'));
    await tester.pumpAndSettle();
    expect(repo.lastListFilter, isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
