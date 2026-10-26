import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/app/theme.dart';
import 'package:gutacosmetic/core/widgets/app_messenger.dart';
import 'package:gutacosmetic/features/manager/data/manager_repository.dart';
import 'package:gutacosmetic/features/manager/data/stock_history.dart';
import 'package:gutacosmetic/features/manager/presentation/stock/manager_stock_screen.dart';
import 'package:gutacosmetic/features/manager/presentation/stock/stock_health.dart';
import 'package:gutacosmetic/features/session/session_controller.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';
import 'package:material_ui/material_ui.dart';

const _store = Store(id: 's1', name: 'Chi nhánh 2');
final _now = DateTime(2026, 10, 25);

ProductInventory _item(
  String id,
  String name, {
  int total = 30,
  int reserved = 0,
  int? available,
  DateTime? expiry,
}) => ProductInventory(
  product: Product(id: id, name: name, sku: 'SKU-$id', price: 100000),
  inventories: [
    StoreStock(
      store: _store,
      totalStock: total,
      reservedStock: reserved,
      availableStock: available ?? total - reserved,
      expiryDate: expiry,
    ),
    // Tồn ở chi nhánh khác không được tính vào màn Kho của chi nhánh này.
    const StoreStock(store: Store(id: 's2'), totalStock: 0, availableStock: 0),
  ],
);

class _FakeRepo implements ManagerRepository {
  List<ProductInventory> stock = [];
  final receipts = <(String, int, DateTime?, String)>[];
  final adjustments = <(String, AdjustmentType, int)>[];
  final expiryUpdates = <(String, DateTime?)>[];
  List<InventoryReceipt> receiptLog = const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<ProductInventory>> fetchStock() async => stock;

  @override
  Future<List<InventoryReceipt>> fetchReceipts() async => receiptLog;

  @override
  Future<List<InventoryAdjustment>> fetchAdjustments() async => const [];

  @override
  Future<void> createReceipt({
    required String productId,
    required int quantity,
    DateTime? expiryDate,
    String note = '',
  }) async => receipts.add((productId, quantity, expiryDate, note));

  @override
  Future<void> createAdjustment({
    required String productId,
    required AdjustmentType type,
    required int quantity,
    String note = '',
  }) async => adjustments.add((productId, type, quantity));

  @override
  Future<void> updateExpiry(String productId, DateTime? expiryDate) async =>
      expiryUpdates.add((productId, expiryDate));

  // --- Đề xuất nhập ---
  List<RestockRequest> restockRequests = const [];
  final acknowledged = <String>[];
  final received = <(String, int)>[];
  final cancelledRestock = <(String, String)>[];

  @override
  Future<List<RestockRequest>> fetchRestockRequests({
    RestockStatus? status,
  }) async => restockRequests
      .where((r) => status == null || r.status == status)
      .toList();

  @override
  Future<void> acknowledgeRestock(String requestId) async =>
      acknowledged.add(requestId);

  @override
  Future<void> receiveRestock(
    String requestId, {
    required int quantity,
    DateTime? expiryDate,
    String note = '',
  }) async => received.add((requestId, quantity));

  @override
  Future<void> cancelRestock(String requestId, String note) async =>
      cancelledRestock.add((requestId, note));

  // --- Trả hàng lỗi + hàng chuyển đến ---
  List<InventoryReturnRequest> returns = const [];
  final createdReturns = <(String, int, ReturnReasonType)>[];
  List<StockTransfer> transfers = const [];
  final confirmedTransfers = <String>[];

  @override
  Future<List<InventoryReturnRequest>> fetchReturnRequests({
    ReturnRequestStatus? status,
  }) async =>
      returns.where((r) => status == null || r.status == status).toList();

  @override
  Future<void> createReturnRequest({
    required String productId,
    required int quantity,
    required ReturnReasonType reason,
    String note = '',
  }) async => createdReturns.add((productId, quantity, reason));

  @override
  Future<List<StockTransfer>> fetchIncomingTransfers({
    TransferStatus? status,
  }) async =>
      transfers.where((t) => status == null || t.status == status).toList();

  @override
  Future<void> confirmTransfer(String transferId) async =>
      confirmedTransfers.add(transferId);

  // --- Lịch sử kho ---
  List<StockHistoryEntry> history = const [];
  final historyQueries = <(StockHistoryType?, String?)>[];

  @override
  Future<List<StockHistoryEntry>> fetchStockHistory({
    StockHistoryType? type,
    String? productId,
  }) async {
    historyQueries.add((type, productId));
    return history
        .where((e) => type == null || e.type == type)
        .where((e) => productId == null || e.productId == productId)
        .toList();
  }
}

Future<_FakeRepo> _pump(
  WidgetTester tester,
  List<ProductInventory> stock,
) async {
  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1.5;
  addTearDown(tester.view.reset);
  final repo = _FakeRepo()..stock = stock;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        managerRepositoryProvider.overrideWithValue(repo),
        activeStoreProvider.overrideWithValue(_store),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: buildAppTheme(),
        home: const Scaffold(body: ManagerStockScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

Future<void> _openAction(
  WidgetTester tester,
  String product,
  String action,
) async {
  final card = find.ancestor(
    of: find.text(product),
    matching: find.byType(Card),
  );
  await tester.tap(
    find.descendant(of: card, matching: find.byTooltip('Thao tác')),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(action).last);
  await tester.pumpAndSettle();
}

void main() {
  group('Quy tắc cảnh báo', () {
    StoreStock s({int available = 50, int threshold = 5, DateTime? expiry}) =>
        StoreStock(
          store: _store,
          totalStock: available,
          availableStock: available,
          lowStockThreshold: threshold,
          expiryDate: expiry,
        );

    test('dưới 10 khả dụng là sắp hết, 0 là hết hàng', () {
      expect(s(available: 10).flags(_now), isEmpty);
      expect(s(available: 9).flags(_now), [StockFlag.lowStock]);
      expect(s(available: 0).flags(_now), [StockFlag.outOfStock]);
      // Ngưỡng riêng lớn hơn 10 thì dùng ngưỡng riêng
      expect(s(available: 12, threshold: 15).flags(_now), [StockFlag.lowStock]);
    });

    test('HSD trong 60 ngày là sắp hết hạn, đã qua là hết hạn', () {
      expect(
        s(expiry: _now.add(const Duration(days: 61))).flags(_now),
        isEmpty,
      );
      expect(s(expiry: _now.add(const Duration(days: 59))).flags(_now), [
        StockFlag.expiringSoon,
      ]);
      expect(s(expiry: _now.subtract(const Duration(days: 1))).flags(_now), [
        StockFlag.expired,
      ]);
      expect(
        s(
          available: 3,
          expiry: _now.subtract(const Duration(days: 1)),
        ).flags(_now),
        [StockFlag.lowStock, StockFlag.expired],
      );
    });
  });

  testWidgets('Tồn kho: 3 chỉ số, đếm cảnh báo, lọc sắp hết', (tester) async {
    await _pump(tester, [
      _item('p1', 'Serum B5', total: 30, reserved: 4),
      _item('p2', 'Toner', total: 5),
      _item('p3', 'Kem chống nắng', total: 0),
    ]);

    expect(find.text('Tất cả (3)'), findsOneWidget);
    expect(find.text('Sắp hết (1)'), findsOneWidget);
    expect(find.text('Hết hàng (1)'), findsOneWidget);
    // Serum: tổng 30, giữ 4, khả dụng 26
    final serum = find.ancestor(
      of: find.text('Serum B5'),
      matching: find.byType(Card),
    );
    expect(
      find.descendant(
        of: serum,
        matching: find.text('Tổng 30', findRichText: true),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: serum,
        matching: find.text('Đang giữ 4', findRichText: true),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: serum,
        matching: find.text('Khả dụng 26', findRichText: true),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Sắp hết (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Toner'), findsOneWidget);
    expect(find.text('Serum B5'), findsNothing);
  });

  testWidgets('Nhập hàng từ một sản phẩm, có chọn HSD', (tester) async {
    final repo = await _pump(tester, [_item('p1', 'Serum B5')]);

    await _openAction(tester, 'Serum B5', 'Nhập hàng');
    expect(find.text('Phiếu nhập kho'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('receipt-quantity')),
      '1001',
    );
    await tester.pump();
    expect(find.text('Số lượng phải từ 1 đến 1000'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('receipt-quantity')),
      '40',
    );
    await tester.pump();

    await tester.tap(find.text('Hạn sử dụng (không bắt buộc)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.textContaining('HSD:'), findsWidgets);

    await tester.tap(find.text('Nhập kho').last);
    await tester.pumpAndSettle();

    final (productId, qty, expiry, _) = repo.receipts.single;
    expect(productId, 'p1');
    expect(qty, 40);
    expect(expiry, isNotNull);
  });

  testWidgets('Ghi giảm không vượt số khả dụng', (tester) async {
    final repo = await _pump(tester, [
      _item('p1', 'Serum B5', total: 10, reserved: 7),
    ]);

    await _openAction(tester, 'Serum B5', 'Ghi giảm (hỏng/lỗi/hết hạn)');
    await tester.tap(find.text('Hết hạn').last);
    await tester.pump();

    final qty = find.byKey(const ValueKey('adjustment-quantity'));
    await tester.enterText(qty, '4'); // chỉ còn 3 khả dụng
    await tester.pump();
    expect(find.text('Số lượng phải từ 1 đến 3'), findsOneWidget);

    await tester.enterText(qty, '3');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Ghi giảm'));
    await tester.pumpAndSettle();

    expect(repo.adjustments.single, ('p1', AdjustmentType.expired, 3));
  });

  testWidgets('Sửa HSD: bỏ theo dõi HSD', (tester) async {
    final repo = await _pump(tester, [
      _item(
        'p1',
        'Serum B5',
        expiry: DateTime.now().add(const Duration(days: 20)),
      ),
    ]);
    expect(find.text('Sắp hết hạn'), findsOneWidget);

    await _openAction(tester, 'Serum B5', 'Sửa hạn sử dụng');
    await tester.tap(find.text('Bỏ theo dõi HSD'));
    await tester.pump();
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(repo.expiryUpdates.single, ('p1', null));
  });

  testWidgets('Phiếu nhập: hiện nguồn, HSD lô và người nhập', (tester) async {
    final repo = await _pump(tester, [_item('p1', 'Serum B5')]);
    repo.receiptLog = [
      InventoryReceipt(
        id: 'r1',
        productId: const EntityRef('p1', Product(id: 'p1', name: 'Serum B5')),
        quantity: 40,
        source: ReceiptSource.salesRequest,
        expiryDate: DateTime(2027, 6, 1),
        receivedBy: const EntityRef(
          'm1',
          AppUser(id: 'm1', fullName: 'Quản lý A', role: UserRole.manager),
        ),
      ),
    ];

    await tester.tap(find.text('Phiếu nhập'));
    await tester.pumpAndSettle();

    expect(find.text('+40'), findsOneWidget);
    expect(find.text('Theo đề xuất Sales'), findsOneWidget);
    expect(find.text('HSD lô: 01/06/2027'), findsOneWidget);
    expect(find.textContaining('Quản lý A'), findsOneWidget);
  });

  test('Phiếu nhập RETURN_REJECTED đọc được (không làm hỏng danh sách)', () {
    final receipt = InventoryReceipt.fromJson({
      '_id': 'r1',
      'quantity': 2,
      'source': 'RETURN_REJECTED',
    });
    expect(receipt.source, ReceiptSource.returnRejected);
  });

  testWidgets('Đề xuất nhập: tiếp nhận, nhận hàng ≤ số đề xuất, hủy có lý do', (
    tester,
  ) async {
    final repo = await _pump(tester, [_item('p1', 'Serum B5', total: 3)]);
    repo.restockRequests = [
      RestockRequest(
        id: 'rq1',
        productId: const EntityRef('p1', Product(id: 'p1', name: 'Serum B5')),
        requestedQuantity: 20,
        currentAvailableStock: 2,
        reason: 'Khách hỏi nhiều',
        requestedBy: const EntityRef(
          's1',
          AppUser(id: 's1', fullName: 'Sales Demo', role: UserRole.sales),
        ),
      ),
    ];

    await tester.tap(find.text('Đề xuất nhập'));
    await tester.pumpAndSettle();
    expect(
      find.text('Đề xuất 20 sp • tồn lúc đề xuất 2 • hiện còn 3'),
      findsOneWidget,
    );
    expect(find.textContaining('Sales Demo'), findsOneWidget);

    await tester.tap(find.text('Tiếp nhận'));
    await tester.pumpAndSettle();
    expect(repo.acknowledged, ['rq1']);

    await tester.tap(find.text('Nhận hàng'));
    await tester.pumpAndSettle();
    final qty = find.byKey(const ValueKey('restock-receive-quantity'));
    expect(tester.widget<TextField>(qty).controller!.text, '20');
    await tester.enterText(qty, '21');
    await tester.pump();
    expect(find.text('Số lượng phải từ 1 đến 20'), findsOneWidget);
    await tester.enterText(qty, '15');
    await tester.pump();
    await tester.tap(find.text('Nhận vào kho'));
    await tester.pumpAndSettle();
    expect(repo.received, [('rq1', 15)]);

    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Kho tổng hết hàng');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Hủy đề xuất'));
    await tester.pumpAndSettle();
    expect(repo.cancelledRestock, [('rq1', 'Kho tổng hết hàng')]);
  });

  testWidgets(
    'Trả hàng lỗi: tạo yêu cầu, hiện trạng thái khóa và kết quả duyệt',
    (tester) async {
      final repo = await _pump(tester, [
        _item('p1', 'Serum B5', total: 10, reserved: 4),
      ]);
      repo.returns = [
        const InventoryReturnRequest(
          id: 'rt1',
          productId: EntityRef('p1', Product(id: 'p1', name: 'Serum B5')),
          quantity: 2,
          reasonType: ReturnReasonType.damaged,
          status: ReturnRequestStatus.rejected,
          reviewNote: 'Hàng vẫn bán được',
        ),
      ];

      await tester.ensureVisible(find.text('Trả hàng lỗi'));
      await tester.tap(find.text('Trả hàng lỗi'));
      await tester.pumpAndSettle();
      // Mặc định lọc chờ duyệt
      expect(find.text('Không có yêu cầu trả hàng nào'), findsOneWidget);
      await tester.tap(find.text('Bị từ chối').first);
      await tester.pumpAndSettle();
      expect(find.text('Owner từ chối: Hàng vẫn bán được'), findsOneWidget);

      await tester.tap(find.text('Trả hàng'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chọn sản phẩm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Serum B5').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hết hạn').last);
      await tester.pump();
      await tester.enterText(
        find.byKey(const ValueKey('return-quantity')),
        '7',
      );
      await tester.pump();
      expect(find.text('Số lượng phải từ 1 đến 6'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('return-quantity')),
        '6',
      );
      await tester.pump();
      await tester.tap(find.text('Gửi yêu cầu'));
      await tester.pumpAndSettle();

      expect(repo.createdReturns.single, ('p1', 6, ReturnReasonType.expired));
    },
  );

  testWidgets('Hàng chuyển đến: xác nhận đã nhận', (tester) async {
    final repo = await _pump(tester, [_item('p1', 'Serum B5')]);
    repo.transfers = [
      const StockTransfer(
        id: 't1',
        fromStoreId: EntityRef('c1', Store(id: 'c1', name: 'Kho tổng Quận 1')),
        items: [
          TransferItem(
            productId: EntityRef('p1', Product(id: 'p1', name: 'Serum B5')),
            quantity: 10,
          ),
        ],
      ),
    ];

    await tester.ensureVisible(find.text('Hàng chuyển đến'));
    await tester.tap(find.text('Hàng chuyển đến'));
    await tester.pumpAndSettle();
    expect(find.text('Từ Kho tổng Quận 1'), findsOneWidget);
    expect(find.text('• Serum B5 × 10'), findsOneWidget);

    await tester.tap(find.text('Xác nhận đã nhận hàng'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đã nhận đủ'));
    await tester.pumpAndSettle();
    expect(repo.confirmedTransfers, ['t1']);
  });

  test('Lịch sử: đọc dòng từ API, bỏ qua dòng lạ', () {
    final entry = StockHistoryEntry.tryParse({
      'id': 'return:1:reviewed',
      'type': 'RETURN',
      'event': 'RETURN_APPROVED',
      'at': '2026-10-25T03:00:00.000Z',
      'product': {'_id': 'p1', 'name': 'Serum B5'},
      'quantity': 2,
      'totalChange': -2,
      'lockedChange': -2,
      'actor': {'fullName': 'Owner A'},
    })!;
    expect(entry.type, StockHistoryType.returnRequest);
    expect(entry.eventLabel, 'Owner duyệt trả hàng');
    expect(entry.totalChange, -2);
    expect(entry.actorName, 'Owner A');
    expect(StockHistoryEntry.tryParse({'type': 'SALE'}), isNull);
  });

  testWidgets('Lịch sử kho: dòng thời gian, lọc theo loại và sản phẩm', (
    tester,
  ) async {
    final repo = await _pump(tester, [
      _item('p1', 'Serum B5'),
      _item('p2', 'Toner'),
    ]);
    StockHistoryEntry entry(
      String id,
      StockHistoryType type,
      String event,
      String productId,
      String name,
      int total, {
      int locked = 0,
    }) => StockHistoryEntry(
      id: id,
      type: type,
      event: event,
      at: DateTime(2026, 10, 25, 9),
      productId: productId,
      productName: name,
      quantity: total.abs(),
      totalChange: total,
      lockedChange: locked,
    );
    repo.history = [
      entry('a', StockHistoryType.receipt, 'TRANSFER', 'p1', 'Serum B5', 10),
      entry('b', StockHistoryType.adjustment, 'DAMAGED', 'p2', 'Toner', -2),
      entry(
        'c',
        StockHistoryType.returnRequest,
        'RETURN_REQUESTED',
        'p1',
        'Serum B5',
        0,
        locked: 3,
      ),
    ];

    await tester.ensureVisible(find.text('Lịch sử'));
    await tester.tap(find.text('Lịch sử'));
    await tester.pumpAndSettle();

    expect(find.text('+10'), findsOneWidget);
    expect(find.text('-2'), findsOneWidget);
    expect(find.text('khóa 3'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.textContaining('Hàng chuyển đến'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Ghi giảm').last);
    await tester.pumpAndSettle();
    expect(find.text('+10'), findsNothing);
    expect(find.text('-2'), findsOneWidget);

    await tester.tap(find.text('Tất cả').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Lọc theo sản phẩm'));
    await tester.tap(find.text('Lọc theo sản phẩm'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Serum B5').last);
    await tester.pumpAndSettle();

    expect(repo.historyQueries.last, (null, 'p1'));
    expect(find.text('-2'), findsNothing);
    expect(find.text('+10'), findsOneWidget);
  });
}
