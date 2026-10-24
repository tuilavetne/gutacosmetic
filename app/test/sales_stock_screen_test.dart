import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/app/theme.dart';
import 'package:gutacosmetic/core/widgets/app_messenger.dart';
import 'package:gutacosmetic/features/sales/data/sales_repository.dart';
import 'package:gutacosmetic/features/sales/presentation/sales_stock_screen.dart';
import 'package:gutacosmetic/features/session/session_controller.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';
import 'package:material_ui/material_ui.dart';

const _serum = Product(id: 'p1', name: 'Serum B5', sku: 'B5-01', price: 250000);
const _toner = Product(
  id: 'p2',
  name: 'Toner Klairs',
  sku: 'KL-02',
  price: 300000,
);
const _cream = Product(
  id: 'p3',
  name: 'Kem chống nắng',
  sku: 'SUN-03',
  price: 400000,
);

class _FakeSalesRepository implements SalesRepository {
  _FakeSalesRepository({this.requests = const []});

  List<RestockRequest> requests;
  final created = <({String productId, int quantity, String reason})>[];
  RestockStatus? lastStatusFilter;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<InventoryAlert>> fetchInventoryAlerts() async => const [
    InventoryAlert(
      type: InventoryAlertType.lowStock,
      severity: 'CRITICAL',
      message: 'Sản phẩm đã hết hàng tại chi nhánh',
      inventoryId: 'inv1',
      product: EntityRef('p1', _serum),
      availableStock: 0,
      totalStock: 2,
      reservedStock: 2,
    ),
    InventoryAlert(
      type: InventoryAlertType.lowStock,
      severity: 'WARNING',
      message: 'Sản phẩm còn dưới 10 sản phẩm khả dụng',
      inventoryId: 'inv2',
      product: EntityRef('p2', _toner),
      availableStock: 4,
      totalStock: 4,
    ),
    InventoryAlert(
      type: InventoryAlertType.expiringSoon,
      severity: 'WARNING',
      message: 'Sản phẩm sắp hết hạn trong 60 ngày',
      inventoryId: 'inv3',
      product: EntityRef('p3', _cream),
      availableStock: 30,
      totalStock: 30,
    ),
  ];

  @override
  Future<List<RestockRequest>> fetchRestockRequests({
    RestockStatus? status,
  }) async {
    lastStatusFilter = status;
    return requests.where((r) => status == null || r.status == status).toList();
  }

  @override
  Future<RestockRequest> createRestockRequest({
    required String productId,
    required int quantity,
    String reason = '',
  }) async {
    created.add((productId: productId, quantity: quantity, reason: reason));
    final request = RestockRequest(
      id: 'req_${created.length}',
      productId: EntityRef(productId),
      requestedQuantity: quantity,
    );
    requests = [...requests, request];
    return request;
  }
}

Future<void> _pump(WidgetTester tester, _FakeSalesRepository repo) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        activeStoreProvider.overrideWithValue(const Store(id: 's1')),
        salesRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: buildAppTheme(),
        home: const Scaffold(body: SalesStockScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Cảnh báo: chỉ hàng tồn thấp mới có nút đề xuất bổ sung', (
    tester,
  ) async {
    await _pump(tester, _FakeSalesRepository());

    expect(find.text('Serum B5'), findsOneWidget);
    expect(find.text('Toner Klairs'), findsOneWidget);
    expect(find.text('Kem chống nắng'), findsOneWidget);
    // 2 cảnh báo tồn thấp có nút, cảnh báo hạn dùng thì không
    expect(find.text('Đề xuất bổ sung'), findsNWidgets(2));

    // Lọc theo hạn sử dụng
    await tester.tap(find.text('Hạn sử dụng'));
    await tester.pumpAndSettle();
    expect(find.text('Serum B5'), findsNothing);
    expect(find.text('Kem chống nắng'), findsOneWidget);
    expect(find.text('Đề xuất bổ sung'), findsNothing);
  });

  testWidgets('Gửi đề xuất bổ sung từ cảnh báo hết hàng', (tester) async {
    final repo = _FakeSalesRepository();
    await _pump(tester, repo);

    await tester.tap(find.text('Đề xuất bổ sung').first);
    await tester.pumpAndSettle();
    expect(find.text('Đề xuất bổ sung hàng'), findsOneWidget);
    expect(find.text('Còn 0 sp khả dụng tại chi nhánh'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('restock-quantity')),
      '25',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Lý do (không bắt buộc)'),
      'Khách hỏi nhiều',
    );
    await tester.tap(find.text('Gửi đề xuất'));
    await tester.pumpAndSettle();

    expect(repo.created.single.productId, 'p1');
    expect(repo.created.single.quantity, 25);
    expect(repo.created.single.reason, 'Khách hỏi nhiều');
    // Danh sách tải lại: cảnh báo hiện "đã đề xuất" thay cho nút
    expect(find.text('Đã đề xuất 25 sp • chờ Quản lý xử lý'), findsOneWidget);
    expect(find.text('Đề xuất bổ sung'), findsOneWidget);
  });

  testWidgets('Số lượng ngoài 1–1000 thì không gửi được', (tester) async {
    final repo = _FakeSalesRepository();
    await _pump(tester, repo);

    await tester.tap(find.text('Đề xuất bổ sung').first);
    await tester.pumpAndSettle();

    final quantity = find.byKey(const ValueKey('restock-quantity'));
    for (final invalid in ['0', '1001', '']) {
      await tester.enterText(quantity, invalid);
      await tester.pump();
      final send = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Gửi đề xuất'),
      );
      expect(send.onPressed, isNull, reason: 'số lượng "$invalid"');
    }
    expect(repo.created, isEmpty);
  });

  testWidgets('Tab đề xuất: Sales chỉ xem trạng thái và ghi chú của Quản lý', (
    tester,
  ) async {
    final repo = _FakeSalesRepository(
      requests: [
        RestockRequest(
          id: 'r1',
          productId: const EntityRef('p2', _toner),
          requestedQuantity: 20,
          currentAvailableStock: 4,
          reason: 'Sắp hết',
          acknowledgedAt: DateTime(2026, 10, 24, 9),
        ),
        const RestockRequest(
          id: 'r2',
          productId: EntityRef('p1', _serum),
          requestedQuantity: 10,
          status: RestockStatus.resolved,
          managerNote: 'Đã nhận 10 sp vào kho',
        ),
      ],
    );
    await _pump(tester, repo);

    await tester.tap(find.text('Đề xuất của chi nhánh'));
    await tester.pumpAndSettle();

    // Mặc định lọc đề xuất đang mở
    expect(repo.lastStatusFilter, RestockStatus.open);
    expect(find.text('Đề xuất: 20 sp • Tồn lúc đề xuất: 4'), findsOneWidget);
    expect(find.textContaining('Quản lý đã tiếp nhận'), findsOneWidget);
    expect(find.textContaining('Đã nhận 10 sp'), findsNothing);

    await tester.tap(find.text('Tất cả'));
    await tester.pumpAndSettle();
    expect(repo.lastStatusFilter, isNull);
    expect(find.text('Quản lý: Đã nhận 10 sp vào kho'), findsOneWidget);
    // Sales không có thao tác nhận hàng / hủy đề xuất
    expect(find.text('Nhận hàng'), findsNothing);
    expect(find.text('Hủy đề xuất'), findsNothing);
  });
}
