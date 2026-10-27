import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/app/theme.dart';
import 'package:gutacosmetic/core/widgets/app_messenger.dart';
import 'package:gutacosmetic/features/owner/data/owner_models.dart';
import 'package:gutacosmetic/features/owner/data/owner_repository.dart';
import 'package:gutacosmetic/features/owner/presentation/admin/admin_screen.dart';
import 'package:gutacosmetic/features/owner/presentation/owner_shell.dart';
import 'package:gutacosmetic/features/owner/presentation/products/product_form_screen.dart';
import 'package:gutacosmetic/features/owner/presentation/revenue/revenue_chart.dart';
import 'package:gutacosmetic/features/owner/presentation/revenue/revenue_screen.dart';
import 'package:gutacosmetic/features/owner/presentation/stock/owner_stock_screen.dart';
import 'package:gutacosmetic/features/owner/presentation/stock/transfer_form_screen.dart';
import 'package:gutacosmetic/features/session/session_controller.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';
import 'package:material_ui/material_ui.dart';

const _central = Store(id: 'c', name: 'Kho tổng', type: StoreType.central);
const _branchA = Store(
  id: 'a',
  name: 'Chi nhánh A',
  address: '1 Lê Duẩn',
  phone: '+84912345678',
);
const _branchB = Store(id: 'b', name: 'Chi nhánh B');
const _serum = Product(id: 'p1', sku: 'SR01', name: 'Serum B5', price: 300000);
const _toner = Product(id: 'p2', sku: 'TN01', name: 'Toner', price: 150000);

const _owner = AppUser(id: 'o', fullName: 'Chủ chuỗi', role: UserRole.owner);

ProductInventory _inv(Product product, Map<Store, int> available) =>
    ProductInventory(
      product: product,
      inventories: [
        for (final e in available.entries)
          StoreStock(
            store: e.key,
            totalStock: e.value,
            availableStock: e.value,
          ),
      ],
    );

final _dashboardJson = <String, dynamic>{
  'today': {'revenue': 1200000, 'orders': 3},
  'month': {'revenue': 25000000, 'orders': 40},
  'pending': {
    'restockRequests': 2,
    'returnRequests': 1,
    'transfersInTransit': 4,
  },
  'alerts': {'lowStock': 3, 'outOfStock': 1, 'expiringSoon': 2, 'expired': 0},
  'stores': [
    {
      'store': {'_id': 'a', 'name': 'Chi nhánh A', 'type': 'BRANCH'},
      'today': {'revenue': 1200000, 'orders': 3},
      'month': {'revenue': 25000000, 'orders': 40},
      'ordersInProgress': 5,
      'activeStaff': 2,
      'alerts': {'lowStock': 3, 'outOfStock': 1},
    },
    // Thiếu thông tin cửa hàng → bỏ qua, không làm hỏng trang
    {'store': null},
  ],
};

final _reportJson = <String, dynamic>{
  'range': {'from': '2026-10-01', 'to': '2026-10-03', 'granularity': 'day'},
  'summary': {
    'revenue': 900000,
    'onlineRevenue': 300000,
    'offlineRevenue': 600000,
    'orders': 3,
    'averageOrderValue': 300000,
    'costedRevenue': 600000,
    'grossProfit': 250000,
    'missingCostProductCount': 1,
    'missingCostProducts': ['Toner'],
  },
  'series': [
    {
      'key': '2026-10-01',
      'revenue': 600000,
      'onlineRevenue': 200000,
      'offlineRevenue': 400000,
      'orders': 2,
    },
    {'key': '2026-10-02', 'revenue': 0, 'orders': 0},
    {
      'key': '2026-10-03',
      'revenue': 300000,
      'onlineRevenue': 100000,
      'offlineRevenue': 200000,
      'orders': 1,
    },
  ],
  'stores': [
    {
      'store': {'_id': 'a', 'name': 'Chi nhánh A', 'type': 'BRANCH'},
      'revenue': 900000,
      'onlineRevenue': 300000,
      'offlineRevenue': 600000,
      'orders': 3,
    },
  ],
  'topProducts': [
    {'name': 'Serum B5', 'sku': 'SR01', 'quantity': 3, 'revenue': 900000},
  ],
};

class _FakeOwnerRepo implements OwnerRepository {
  List<Store> stores = const [_central, _branchA, _branchB];
  List<ProductInventory> stock = const [];
  List<RestockRequest> restock = const [];
  List<InventoryReturnRequest> returns = const [];
  List<StockTransfer> transfers = const [];
  List<AppUser> staff = const [];
  final revenueQueries = <RevenueQuery>[];
  final approved = <(String, String?, int?, String)>[];
  final rejected = <(String, String)>[];
  final reviewed = <(String, bool, String)>[];
  final createdTransfers = <Map<String, Object?>>[];
  final cancelledTransfers = <String>[];
  final productWrites = <(String?, Map<String, Object?>)>[];
  final storeWrites = <(String?, Map<String, Object?>)>[];
  final staffWrites = <(String?, Map<String, Object?>)>[];

  @override
  Future<OwnerDashboard> fetchDashboard() async =>
      OwnerDashboard.fromJson(_dashboardJson);

  @override
  Future<RevenueReport> fetchRevenue(RevenueQuery query) async {
    revenueQueries.add(query);
    return RevenueReport.fromJson(_reportJson);
  }

  @override
  Future<List<Store>> fetchStores() async => stores;

  @override
  Future<List<ProductInventory>> fetchStock() async => stock;

  @override
  Future<List<AppUser>> fetchStaff() async => staff;

  @override
  Future<List<RestockRequest>> fetchRestockRequests({
    RestockStatus? status,
  }) async =>
      restock.where((r) => status == null || r.status == status).toList();

  @override
  Future<void> approveRestock(
    String requestId, {
    String? fromStoreId,
    int? quantity,
    String note = '',
  }) async => approved.add((requestId, fromStoreId, quantity, note));

  @override
  Future<void> rejectRestock(String requestId, String note) async =>
      rejected.add((requestId, note));

  @override
  Future<List<InventoryReturnRequest>> fetchReturnRequests({
    ReturnRequestStatus? status,
  }) async =>
      returns.where((r) => status == null || r.status == status).toList();

  @override
  Future<void> reviewReturn(
    String requestId, {
    required bool approve,
    String note = '',
  }) async => reviewed.add((requestId, approve, note));

  @override
  Future<List<StockTransfer>> fetchTransfers({TransferStatus? status}) async =>
      transfers.where((t) => status == null || t.status == status).toList();

  @override
  Future<void> createTransfer({
    required String fromStoreId,
    required String toStoreId,
    required List<({String productId, int quantity})> items,
    String note = '',
  }) async => createdTransfers.add({
    'from': fromStoreId,
    'to': toStoreId,
    'items': items,
    'note': note,
  });

  @override
  Future<void> cancelTransfer(String transferId) async =>
      cancelledTransfers.add(transferId);

  @override
  Future<Product> createProduct(Map<String, Object?> data) async {
    productWrites.add((null, data));
    return const Product(id: 'new');
  }

  @override
  Future<Product> updateProduct(String id, Map<String, Object?> data) async {
    productWrites.add((id, data));
    return Product(id: id);
  }

  @override
  Future<Store> createStore(Map<String, Object?> data) async {
    storeWrites.add((null, data));
    return const Store(id: 'new');
  }

  @override
  Future<Store> updateStore(String id, Map<String, Object?> data) async {
    storeWrites.add((id, data));
    return Store(id: id);
  }

  @override
  Future<AppUser> createStaff(Map<String, Object?> data) async {
    staffWrites.add((null, data));
    return const AppUser(id: 'new', role: UserRole.sales);
  }

  @override
  Future<AppUser> updateStaff(String id, Map<String, Object?> data) async {
    staffWrites.add((id, data));
    return AppUser(id: id, role: UserRole.sales);
  }

  List<Product> products = const [_serum, _toner];
  List<InventoryReceipt> receipts = const [];
  final createdReceipts = <(String, String, int, DateTime?, String)>[];

  /// Sản phẩm nhập lỗi (giả lập backend từ chối giữa chừng).
  String? failReceiptFor;

  @override
  Future<List<Product>> fetchProducts() async => products;

  @override
  Future<List<InventoryReceipt>> fetchReceipts(String storeId) async =>
      receipts;

  @override
  Future<void> createReceipt({
    required String storeId,
    required String productId,
    required int quantity,
    DateTime? expiryDate,
    String note = '',
  }) async {
    if (productId == failReceiptFor) {
      throw Exception('Lỗi nhập $productId');
    }
    createdReceipts.add((storeId, productId, quantity, expiryDate, note));
    // Tồn kho tăng như backend để màn hình tải lại thấy số mới.
    stock = [
      for (final item in stock)
        item.product.id == productId
            ? item.copyWith(
                inventories: [
                  for (final s in item.inventories)
                    s.store.id == storeId
                        ? s.copyWith(
                            totalStock: s.totalStock + quantity,
                            availableStock: s.availableStock + quantity,
                          )
                        : s,
                ],
              )
            : item,
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  _FakeOwnerRepo repo,
  Widget home,
) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1.5;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: [
      ownerRepositoryProvider.overrideWithValue(repo),
      currentUserProvider.overrideWithValue(_owner),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: buildAppTheme(),
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  group('Báo cáo doanh thu', () {
    test('đọc báo cáo, bỏ qua dòng cửa hàng lỗi', () {
      final report = RevenueReport.fromJson(_reportJson);
      expect(report.summary.revenue, 900000);
      expect(report.series, hasLength(3));
      expect(report.series.first.shortLabel, '01/10');
      expect(report.series.first.longLabel, '01/10/2026');
      expect(
        const RevenueBucket(key: '2026-10', totals: RevenueTotals()).shortLabel,
        'T10/26',
      );
      expect(report.stores.single.store.name, 'Chi nhánh A');
      expect(report.missingCostProducts, ['Toner']);

      final dashboard = OwnerDashboard.fromJson(_dashboardJson);
      expect(dashboard.stores, hasLength(1));
      expect(dashboard.stores.single.alerts.total, 4);
    });

    test('mốc thời gian và định dạng gọn', () {
      final now = DateTime(2026, 10, 27, 15);
      expect(dateKey(rangeFor(RangePreset.today, now).start), '2026-10-27');
      expect(dateKey(rangeFor(RangePreset.last7, now).start), '2026-10-21');
      expect(dateKey(rangeFor(RangePreset.last30, now).start), '2026-09-28');
      expect(dateKey(rangeFor(RangePreset.thisMonth, now).start), '2026-10-01');
      expect(compactVnd(850000), '850k');
      expect(compactVnd(1250000), '1,3tr');
      expect(compactVnd(25000000), '25tr');
      expect(compactVnd(2000000), '2tr');
    });

    testWidgets('lọc theo mốc + cửa hàng, chạm cột xem chi tiết, xem bảng', (
      tester,
    ) async {
      final repo = _FakeOwnerRepo();
      await _pump(tester, repo, const Scaffold(body: RevenueScreen()));

      expect(repo.revenueQueries.last.storeId, isNull);
      expect(find.text('Lợi nhuận gộp'), findsOneWidget);
      expect(
        find.textContaining('1 sản phẩm đã bán chưa có giá vốn (Toner)'),
        findsOneWidget,
      );
      expect(find.text('Tại quầy'), findsOneWidget); // chú thích
      expect(find.text('Online'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('bar-2026-10-01')));
      await tester.pump();
      expect(find.textContaining('01/10/2026: 600.000'), findsOneWidget);

      await tester.tap(find.text('Xem dạng bảng'));
      await tester.pump();
      expect(find.text('02/10/2026'), findsNothing); // ngày không có đơn
      expect(find.text('03/10/2026'), findsOneWidget);

      await tester.tap(find.text('7 ngày'));
      await tester.pumpAndSettle();
      final q7 = repo.revenueQueries.last;
      expect(
        DateTime.parse(q7.to).difference(DateTime.parse(q7.from)).inDays,
        6,
      );

      await tester.tap(find.text('Tất cả cửa hàng').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chi nhánh B').last);
      await tester.pumpAndSettle();
      expect(repo.revenueQueries.last.storeId, 'b');
    });
  });

  testWidgets('Trang chủ: số liệu toàn chuỗi, chạm việc chờ → mở tab Kho', (
    tester,
  ) async {
    final repo = _FakeOwnerRepo();
    final container = await _pump(tester, repo, const OwnerShell());

    expect(find.text('Doanh thu hôm nay'), findsOneWidget);
    expect(find.text('Đề xuất nhập chờ duyệt: 2'), findsOneWidget);
    expect(
      find.textContaining('5 đơn đang xử lý • 2 nhân viên • 4 cảnh báo kho'),
      findsOneWidget,
    );

    await tester.tap(find.text('Trả hàng lỗi chờ duyệt: 1'));
    await tester.pumpAndSettle();
    expect(container.read(ownerTabProvider), OwnerTab.stock);
    expect(
      container.read(ownerStockSectionProvider),
      OwnerStockSection.returns,
    );
    expect(find.text('Không có yêu cầu trả hàng nào'), findsOneWidget);
  });

  group('Duyệt kho', () {
    final forwarded = RestockRequest(
      id: 'rq1',
      storeId: const EntityRef('a', _branchA),
      productId: const EntityRef('p1', _serum),
      requestedQuantity: 20,
      forwardedQuantity: 30,
      forwardedAt: DateTime(2026, 10, 26),
      managerNote: 'Bán chạy',
      status: RestockStatus.forwarded,
    );

    testWidgets(
      'duyệt đề xuất: mặc định kho tổng, số lượng Manager chuyển lên',
      (tester) async {
        final repo = _FakeOwnerRepo()
          ..restock = [forwarded]
          ..stock = [
            _inv(_serum, {_central: 25, _branchB: 50}),
          ];
        await _pump(tester, repo, const Scaffold(body: OwnerStockScreen()));

        expect(find.text('Chi nhánh A'), findsOneWidget);
        expect(find.text('Manager: Bán chạy'), findsOneWidget);

        await tester.tap(find.text('Duyệt & chuyển hàng'));
        await tester.pumpAndSettle();
        final qty = find.byKey(const ValueKey('approve-quantity'));
        expect(tester.widget<TextField>(qty).controller!.text, '30');
        // Kho tổng chỉ còn 25 → không duyệt được 30
        expect(find.text('Kho gửi không đủ hàng'), findsOneWidget);
        final approve = find.widgetWithText(
          FilledButton,
          'Duyệt & tạo phiếu chuyển',
        );
        expect(tester.widget<FilledButton>(approve).onPressed, isNull);

        await tester.enterText(qty, '25');
        await tester.pump();
        await tester.tap(approve);
        await tester.pumpAndSettle();
        expect(repo.approved, [('rq1', 'c', 25, '')]);
      },
    );

    testWidgets(
      'kho tổng hết hàng: thấy tồn mọi cửa hàng, nhập hàng về kho tổng rồi duyệt',
      (tester) async {
        final repo = _FakeOwnerRepo()
          ..restock = [forwarded]
          ..stock = [
            _inv(_serum, {_central: 0, _branchA: 1, _branchB: 12}),
          ];
        await _pump(tester, repo, const Scaffold(body: OwnerStockScreen()));

        await tester.tap(find.text('Duyệt & chuyển hàng'));
        await tester.pumpAndSettle();
        // Hiện tồn các cửa hàng (trừ chi nhánh nhận)
        expect(find.text('Kho tổng: 0'), findsOneWidget);
        expect(find.text('Chi nhánh B: 12'), findsOneWidget);
        expect(find.text('Chi nhánh A: 1'), findsNothing);

        // Chọn chi nhánh B làm kho gửi: không đủ nhưng không có nút nhập hàng
        await tester.tap(find.byKey(const ValueKey('source-b')));
        await tester.pumpAndSettle();
        expect(find.text('Kho gửi còn 12 sp khả dụng'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('receive-into-central')),
          findsNothing,
        );

        await tester.tap(find.byKey(const ValueKey('source-c')));
        await tester.pumpAndSettle();
        expect(find.text('Nhập hàng về kho tổng (thiếu 30)'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('receive-into-central')));
        await tester.pumpAndSettle();

        // Form nhập hàng điền sẵn sản phẩm + số còn thiếu
        expect(find.text('Nhập hàng về kho tổng'), findsOneWidget);
        final qty = find.byKey(const ValueKey('receipt-qty-p1'));
        expect(tester.widget<TextField>(qty).controller!.text, '30');
        await tester.enterText(qty, '40');
        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Ghi chú (nhà cung cấp, số hóa đơn...)',
          ),
          'NCC ABC - HĐ 123',
        );
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('receipt-save')));
        await tester.pumpAndSettle();
        expect(repo.createdReceipts, [
          ('c', 'p1', 40, null, 'NCC ABC - HĐ 123'),
        ]);

        // Quay lại hộp duyệt: kho tổng đã có 40 → duyệt được 30
        expect(find.text('Kho tổng: 40'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('receive-into-central')),
          findsNothing,
        );
        await tester.tap(
          find.widgetWithText(FilledButton, 'Duyệt & tạo phiếu chuyển'),
        );
        await tester.pumpAndSettle();
        expect(repo.approved, [('rq1', 'c', 30, '')]);
      },
    );

    testWidgets('từ chối đề xuất bắt buộc lý do', (tester) async {
      final repo = _FakeOwnerRepo()..restock = [forwarded];
      await _pump(tester, repo, const Scaffold(body: OwnerStockScreen()));

      await tester.tap(find.widgetWithText(TextButton, 'Từ chối'));
      await tester.pumpAndSettle();
      final confirm = find.widgetWithText(FilledButton, 'Từ chối');
      expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
      await tester.enterText(find.byType(TextField).last, 'Hết hàng kho tổng');
      await tester.pump();
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(repo.rejected, [('rq1', 'Hết hàng kho tổng')]);
    });

    testWidgets('trả hàng lỗi: duyệt và từ chối có lý do', (tester) async {
      final repo = _FakeOwnerRepo()
        ..returns = [
          const InventoryReturnRequest(
            id: 'rt1',
            storeId: EntityRef('a', _branchA),
            productId: EntityRef('p1', _serum),
            quantity: 2,
            reasonType: ReturnReasonType.damaged,
            managerNote: 'Vỡ nắp',
          ),
        ];
      final container = await _pump(
        tester,
        repo,
        const Scaffold(body: OwnerStockScreen()),
      );
      container
          .read(ownerStockSectionProvider.notifier)
          .show(OwnerStockSection.returns);
      await tester.pumpAndSettle();

      expect(find.text('Chi nhánh A • trả 2 sp • Hàng hỏng'), findsOneWidget);
      await tester.tap(find.text('Duyệt trả hàng'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Duyệt'));
      await tester.pumpAndSettle();
      expect(repo.reviewed, [('rt1', true, '')]);

      await tester.tap(find.widgetWithText(TextButton, 'Từ chối'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Không phải lỗi NSX');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Từ chối'));
      await tester.pumpAndSettle();
      expect(repo.reviewed.last, ('rt1', false, 'Không phải lỗi NSX'));
    });

    testWidgets('chuyển hàng: hủy phiếu đang chờ nhận', (tester) async {
      final repo = _FakeOwnerRepo()
        ..transfers = [
          const StockTransfer(
            id: 't1',
            fromStoreId: EntityRef('c', _central),
            toStoreId: EntityRef('a', _branchA),
            items: [
              TransferItem(productId: EntityRef('p1', _serum), quantity: 5),
            ],
            restockRequestId: 'rq1',
          ),
        ];
      final container = await _pump(
        tester,
        repo,
        const Scaffold(body: OwnerStockScreen()),
      );
      container
          .read(ownerStockSectionProvider.notifier)
          .show(OwnerStockSection.transfers);
      await tester.pumpAndSettle();

      expect(find.text('Kho tổng → Chi nhánh A'), findsOneWidget);
      expect(find.text('• Serum B5 × 5'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Hủy phiếu'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Đề xuất nhập liên quan quay về chờ duyệt'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Hủy phiếu'));
      await tester.pumpAndSettle();
      expect(repo.cancelledTransfers, ['t1']);
    });
  });

  testWidgets(
    'Nhập hàng kho tổng: nhiều sản phẩm, lỗi giữa chừng không nhập trùng',
    (tester) async {
      final repo = _FakeOwnerRepo()
        ..stock = [
          _inv(_serum, {_central: 5}),
          _inv(_toner, {_central: 0}),
        ]
        ..receipts = [
          InventoryReceipt(
            id: 'r0',
            storeId: const EntityRef('c', _central),
            productId: const EntityRef('p1', _serum),
            quantity: 100,
            note: 'Lô tháng 9',
            createdAt: DateTime(2026, 9, 1),
          ),
        ]
        ..failReceiptFor = 'p2';
      final container = await _pump(
        tester,
        repo,
        const Scaffold(body: OwnerStockScreen()),
      );
      container
          .read(ownerStockSectionProvider.notifier)
          .show(OwnerStockSection.receipts);
      await tester.pumpAndSettle();

      expect(find.text('+100'), findsOneWidget);
      expect(find.textContaining('Lô tháng 9'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Nhập hàng'));
      await tester.pumpAndSettle();
      for (final name in ['Serum B5', 'Toner']) {
        await tester.tap(find.text('Thêm sản phẩm'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(name));
        await tester.pumpAndSettle();
      }
      expect(
        find.text('SKU SR01 • kho tổng đang có 5 → sau khi nhập 6'),
        findsOneWidget,
      );
      await tester.enterText(find.byKey(const ValueKey('receipt-qty-p1')), '0');
      await tester.pump();
      expect(find.text('Từ 1 đến 1000'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('receipt-qty-p1')),
        '20',
      );
      await tester.enterText(
        find.byKey(const ValueKey('receipt-qty-p2')),
        '15',
      );
      await tester.pump();
      expect(find.text('Nhập kho (35 sp)'), findsOneWidget);

      // Toner lỗi: Serum đã nhập bị bỏ khỏi form, chỉ còn dòng lỗi
      await tester.tap(find.byKey(const ValueKey('receipt-save')));
      await tester.pumpAndSettle();
      expect(repo.createdReceipts.map((r) => (r.$2, r.$3)), [('p1', 20)]);
      expect(find.byKey(const ValueKey('receipt-qty-p1')), findsNothing);
      expect(find.byKey(const ValueKey('receipt-qty-p2')), findsOneWidget);

      repo.failReceiptFor = null;
      await tester.tap(find.byKey(const ValueKey('receipt-save')));
      await tester.pumpAndSettle();
      expect(repo.createdReceipts.map((r) => (r.$2, r.$3)), [
        ('p1', 20),
        ('p2', 15),
      ]);
      // Quay về danh sách phiếu nhập
      expect(
        find.text('Phiếu nhập hàng nhà cung cấp vào Kho tổng'),
        findsOneWidget,
      );
    },
  );

  testWidgets('Tạo phiếu chuyển: nhiều sản phẩm, không vượt tồn kho gửi', (
    tester,
  ) async {
    final repo = _FakeOwnerRepo()
      ..stock = [
        _inv(_serum, {_branchA: 10}),
        _inv(_toner, {_branchA: 4}),
      ];
    await _pump(tester, repo, const TransferFormScreen());

    await tester.tap(find.byKey(const ValueKey('transfer-from')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chi nhánh A').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('transfer-to-a')));
    await tester.pumpAndSettle();
    // Nơi nhận không có kho gửi
    expect(find.text('Chi nhánh A'), findsOneWidget);
    await tester.tap(find.text('Chi nhánh B').last);
    await tester.pumpAndSettle();

    for (final name in ['Serum B5', 'Toner']) {
      await tester.tap(find.text('Thêm sản phẩm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
    }
    await tester.enterText(find.byKey(const ValueKey('transfer-qty-p2')), '5');
    await tester.pump();
    expect(find.text('Kho gửi chỉ còn 4'), findsOneWidget);
    final submit = find.byType(FilledButton);
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);

    await tester.enterText(find.byKey(const ValueKey('transfer-qty-p1')), '7');
    await tester.enterText(find.byKey(const ValueKey('transfer-qty-p2')), '4');
    await tester.pump();
    expect(find.text('Tạo phiếu chuyển (11 sp)'), findsOneWidget);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    final created = repo.createdTransfers.single;
    expect(created['from'], 'a');
    expect(created['to'], 'b');
    expect(created['items'], [
      (productId: 'p1', quantity: 7),
      (productId: 'p2', quantity: 4),
    ]);
  });

  group('Sản phẩm', () {
    testWidgets('sửa: SKU bị khóa và không gửi lên, giá vốn để trống = null', (
      tester,
    ) async {
      final repo = _FakeOwnerRepo();
      await _pump(
        tester,
        repo,
        const ProductFormScreen(
          product: Product(
            id: 'p1',
            sku: 'SR01',
            name: 'Serum B5',
            brand: 'GUTA',
            category: 'Chăm Sóc Da Mặt',
            price: 300000,
            costPrice: 120000,
            image: 'https://img/main.jpg',
            images: ['https://img/2.jpg'],
          ),
        ),
      );

      final sku = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const ValueKey('product-sku')),
          matching: find.byType(TextField),
        ),
      );
      expect(sku.enabled, isFalse);
      expect(find.text('Ảnh sản phẩm (2/6)'), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('product-cost')), '');
      await tester.enterText(
        find.byKey(const ValueKey('product-price')),
        '320000',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('product-save')));
      await tester.tap(find.byKey(const ValueKey('product-save')));
      await tester.pumpAndSettle();

      final (id, data) = repo.productWrites.single;
      expect(id, 'p1');
      expect(data.containsKey('sku'), isFalse);
      expect(data['price'], 320000);
      expect(data['costPrice'], isNull);
      expect(data['image'], 'https://img/main.jpg');
      expect(data['images'], ['https://img/2.jpg']);
    });

    testWidgets('thêm: bắt buộc SKU, tên, thương hiệu, danh mục, giá', (
      tester,
    ) async {
      final repo = _FakeOwnerRepo();
      await _pump(tester, repo, const ProductFormScreen());

      await tester.ensureVisible(find.byKey(const ValueKey('product-save')));
      await tester.tap(find.byKey(const ValueKey('product-save')));
      await tester.pumpAndSettle();
      expect(find.text('SKU không được để trống'), findsOneWidget);
      expect(find.text('Vui lòng chọn danh mục'), findsOneWidget);
      expect(repo.productWrites, isEmpty);

      await tester.enterText(find.byKey(const ValueKey('product-sku')), 'nw01');
      await tester.enterText(find.byKey(const ValueKey('product-name')), 'Kem');
      await tester.enterText(
        find.byKey(const ValueKey('product-brand')),
        'GUTA',
      );
      await tester.enterText(
        find.byKey(const ValueKey('product-price')),
        '99000',
      );
      await tester.tap(find.byKey(const ValueKey('product-category')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trang Điểm').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('product-save')));
      await tester.tap(find.byKey(const ValueKey('product-save')));
      await tester.pumpAndSettle();

      final (id, data) = repo.productWrites.single;
      expect(id, isNull);
      expect(data['sku'], 'NW01');
      expect(data['category'], 'Trang Điểm');
      expect(data['price'], 99000);
      expect(data['image'], '');
    });

    test('nhận định dạng ảnh JPG/PNG/WEBP', () {
      expect(
        productImageMimeType(mimeType: 'image/webp', fileName: 'a'),
        'image/webp',
      );
      expect(
        productImageMimeType(mimeType: 'image/jpg', fileName: 'a'),
        'image/jpeg',
      );
      expect(
        productImageMimeType(mimeType: 'image/gif', fileName: 'a.gif'),
        isNull,
      );
      expect(productImageMimeType(fileName: 'a.PNG'), 'image/png');
    });
  });

  group('Quản trị', () {
    testWidgets(
      'cửa hàng: đã có kho tổng thì chỉ tạo chi nhánh; sửa không gửi loại',
      (tester) async {
        final repo = _FakeOwnerRepo();
        await _pump(tester, repo, const Scaffold(body: AdminScreen()));

        await tester.tap(find.text('Thêm cửa hàng'));
        await tester.pumpAndSettle();
        expect(find.text('Chuỗi đã có kho tổng.'), findsOneWidget);
        await tester.enterText(
          find.byKey(const ValueKey('store-name')),
          'Chi nhánh C',
        );
        await tester.enterText(
          find.byKey(const ValueKey('store-address')),
          '12 Lê Lợi',
        );
        await tester.enterText(
          find.byKey(const ValueKey('store-phone')),
          '0912 000 111',
        );
        await tester.tap(find.byKey(const ValueKey('store-save')));
        await tester.pumpAndSettle();
        expect(repo.storeWrites.single.$2, {
          'name': 'Chi nhánh C',
          'address': '12 Lê Lợi',
          'phone': '0912000111',
          'type': 'BRANCH',
        });

        await tester.tap(find.text('Chi nhánh A'));
        await tester.pumpAndSettle();
        expect(find.text('Loại: Chi nhánh (không đổi được)'), findsOneWidget);
        expect(
          tester
              .widget<TextField>(
                find.descendant(
                  of: find.byKey(const ValueKey('store-phone')),
                  matching: find.byType(TextField),
                ),
              )
              .controller!
              .text,
          '0912345678',
        );
        await tester.tap(find.text('Đang hoạt động'));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('store-save')));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Ngừng hoạt động'));
        await tester.pumpAndSettle();
        final (id, data) = repo.storeWrites.last;
        expect(id, 'a');
        expect(data.containsKey('type'), isFalse);
        expect(data['isActive'], isFalse);
      },
    );

    testWidgets('nhân viên: cửa hàng bắt buộc; sửa để trống mật khẩu thì giữ', (
      tester,
    ) async {
      final repo = _FakeOwnerRepo()
        ..staff = [
          const AppUser(
            id: 'u1',
            fullName: 'Sales Demo',
            email: 'sales@gmail.com',
            phone: '+84987654321',
            address: '1 Nguyễn Huệ',
            role: UserRole.sales,
            storeId: EntityRef('a', _branchA),
          ),
        ];
      await _pump(tester, repo, const Scaffold(body: AdminScreen()));
      await tester.tap(find.text('Nhân viên'));
      await tester.pumpAndSettle();

      expect(find.text('Tư vấn viên • Chi nhánh A'), findsOneWidget);
      await tester.tap(find.text('Thêm nhân viên'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('staff-name')),
        'Quản lý B',
      );
      await tester.enterText(
        find.byKey(const ValueKey('staff-email')),
        'qlb@gmail.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('staff-phone')),
        '0901234567',
      );
      await tester.enterText(
        find.byKey(const ValueKey('staff-address')),
        '5 Hai Bà Trưng',
      );
      await tester.enterText(
        find.byKey(const ValueKey('staff-password')),
        'Matkhau123',
      );
      await tester.tap(find.text('Manager / Thu ngân'));
      await tester.tap(find.byKey(const ValueKey('staff-save')));
      await tester.pumpAndSettle();
      expect(find.text('Vui lòng chọn cửa hàng'), findsOneWidget);
      expect(repo.staffWrites, isEmpty);

      await tester.tap(find.byKey(const ValueKey('staff-store')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chi nhánh B').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('staff-save')));
      await tester.pumpAndSettle();
      final created = repo.staffWrites.single.$2;
      expect(created['role'], 'MANAGER');
      expect(created['storeId'], 'b');
      expect(created['password'], 'Matkhau123');

      await tester.tap(find.text('Sales Demo'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('staff-save')));
      await tester.pumpAndSettle();
      final (id, updated) = repo.staffWrites.last;
      expect(id, 'u1');
      expect(updated.containsKey('password'), isFalse);
      expect(updated['storeId'], 'a');
      expect(updated['phone'], '0987654321');
    });

    testWidgets('khóa nhân viên cần lý do', (tester) async {
      final repo = _FakeOwnerRepo()
        ..staff = [
          const AppUser(id: 'u1', fullName: 'Sales Demo', role: UserRole.sales),
        ];
      await _pump(tester, repo, const Scaffold(body: AdminScreen()));
      await tester.tap(find.text('Nhân viên'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Khóa tài khoản'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Nghỉ việc');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Khóa'));
      await tester.pumpAndSettle();
      expect(repo.staffWrites.single.$2, {
        'isActive': false,
        'disabledReason': 'Nghỉ việc',
      });
    });
  });
}
