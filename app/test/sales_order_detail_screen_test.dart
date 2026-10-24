import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/app/theme.dart';
import 'package:gutacosmetic/core/widgets/app_messenger.dart';
import 'package:gutacosmetic/features/sales/data/sales_repository.dart';
import 'package:gutacosmetic/features/sales/presentation/sales_order_detail_screen.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';
import 'package:material_ui/material_ui.dart';

class _FakeSalesRepository implements SalesRepository {
  _FakeSalesRepository(this.order);

  Order order;
  String? cancelledOrderId;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Order> fetchOrderDetail(String orderId) async => order;

  @override
  Future<Order> cancelOfflineOrder(String orderId, {String reason = ''}) async {
    cancelledOrderId = orderId;
    return order = order.copyWith(status: OrderStatus.cancelled);
  }
}

Order _order(OrderStatus status) => Order(
  id: 'ord_1',
  orderCode: 'GUTA-POS-1',
  channel: OrderChannel.offline,
  customerName: 'Khách lẻ',
  status: status,
  items: const [
    OrderItem(
      productId: EntityRef('p1'),
      sku: 'B5-01',
      name: 'Serum B5',
      quantity: 2,
      unitPrice: 250000,
      lineTotal: 500000,
    ),
  ],
  subtotal: 500000,
  totalPrice: 500000,
);

Future<_FakeSalesRepository> _pump(
  WidgetTester tester,
  OrderStatus status,
) async {
  final repo = _FakeSalesRepository(_order(status));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [salesRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: buildAppTheme(),
        home: const SalesOrderDetailScreen(orderId: 'ord_1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('Chờ duyệt: thanh thao tác không che nội dung đơn', (
    tester,
  ) async {
    await _pump(tester, OrderStatus.pendingApproval);

    // Nội dung đơn vẫn hiển thị (trước đây bị thanh dưới chiếm hết màn hình)
    expect(find.text('Serum B5'), findsOneWidget);
    expect(find.text('Hủy giỏ'), findsOneWidget);
    expect(find.text('Duyệt giỏ gửi sang thu ngân (Giữ kho)'), findsOneWidget);

    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final barHeight = tester
        .getSize(
          find.ancestor(
            of: find.text('Hủy giỏ'),
            matching: find.byType(SafeArea),
          ),
        )
        .height;
    expect(barHeight, lessThan(screenHeight / 3));
  });

  testWidgets('Chờ thu ngân: Sales không có nút thu tiền, chỉ được hủy đơn', (
    tester,
  ) async {
    final repo = await _pump(tester, OrderStatus.pendingPayment);

    expect(find.textContaining('Thu tiền'), findsNothing);
    expect(
      find.text('Đã gửi sang thu ngân, chờ Quản lý thu tiền.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Hủy đơn'));
    await tester.pumpAndSettle();
    // Hộp thoại lý do: lý do không bắt buộc với nhân viên
    await tester.tap(find.widgetWithText(FilledButton, 'Hủy đơn'));
    await tester.pumpAndSettle();

    expect(repo.cancelledOrderId, 'ord_1');
    // Đơn đã hủy: không còn thanh thao tác
    expect(find.text('Hủy đơn'), findsNothing);
  });
}
