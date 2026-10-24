import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/app/theme.dart';
import 'package:gutacosmetic/core/utils/formatters.dart';
import 'package:gutacosmetic/core/widgets/app_messenger.dart';
import 'package:gutacosmetic/features/customer/data/order_repository.dart';
import 'package:gutacosmetic/features/sales/data/sales_repository.dart';
import 'package:gutacosmetic/features/sales/presentation/pos_screen.dart';
import 'package:gutacosmetic/features/session/session_controller.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';
import 'package:material_ui/material_ui.dart';

class _FakeSalesRepository implements SalesRepository {
  OfflineOrderRequest? lastSubmittedRequest;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Order> submitOfflineOrder(OfflineOrderRequest request) async {
    lastSubmittedRequest = request;
    return Order(
      id: 'ord_pos_1',
      orderCode: 'ORD-POS-1',
      storeId: EntityRef(request.storeId),
      customerName: request.customerName,
      status: OrderStatus.pendingPayment,
    );
  }
}

void main() {
  const store = Store(id: 's1', name: 'Chi nhánh Quận 1');
  const p1 = Product(
    id: 'p1',
    sku: 'KLAIRS-01',
    name: 'Kem dưỡng ẩm Klairs',
    brand: 'Klairs',
    price: 300000,
  );
  const p2 = Product(
    id: 'p2',
    sku: 'TO-02',
    name: 'Serum B5 The Ordinary',
    brand: 'The Ordinary',
    price: 250000,
  );

  final items = <ProductInventory>[
    const ProductInventory(
      product: p1,
      inventories: [
        StoreStock(
          store: store,
          totalStock: 10,
          availableStock: 10,
          reservedStock: 0,
        ),
      ],
    ),
    const ProductInventory(
      product: p2,
      inventories: [
        StoreStock(
          store: store,
          totalStock: 5,
          availableStock: 5,
          reservedStock: 0,
        ),
      ],
    ),
  ];

  testWidgets('POS: thêm nhiều sản phẩm vào giỏ, điều chỉnh số lượng và duyệt gửi thu ngân', (tester) async {
    final fakeRepo = _FakeSalesRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeStoreProvider.overrideWithValue(store),
          salesRepositoryProvider.overrideWithValue(fakeRepo),
          salesProductsProvider(defaultSalesProductQuery).overrideWith(
            (ref) => Future.value(items),
          ),
        ],
        child: MaterialApp(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          theme: buildAppTheme(),
          home: const Scaffold(body: PosScreen()),
        ),
      ),
    );

    // Chờ danh sách sản phẩm load xong
    await tester.pumpAndSettle();

    expect(find.text('Kem dưỡng ẩm Klairs'), findsOneWidget);
    expect(find.text('Serum B5 The Ordinary'), findsOneWidget);

    // Ban đầu giỏ hàng trống, chưa có thanh tổng kết giỏ
    expect(find.text('Xem giỏ & Gửi duyệt'), findsNothing);

    // 1. Thêm sản phẩm 1 vào giỏ
    final addButtons = find.text('+ Giỏ POS');
    expect(addButtons, findsNWidgets(2));
    await tester.tap(addButtons.first);
    await tester.pumpAndSettle();

    // Thanh giỏ xuất hiện và hiển thị 1 sản phẩm
    expect(find.text('Xem giỏ & Gửi duyệt'), findsOneWidget);
    expect(find.text('Đã chọn 1 sp (1 món)'), findsOneWidget);

    // 2. Thêm sản phẩm 2 vào giỏ
    final remainingAddBtn = find.text('+ Giỏ POS');
    expect(remainingAddBtn, findsOneWidget);
    await tester.tap(remainingAddBtn);
    await tester.pumpAndSettle();

    // Cả 2 sản phẩm đã trong giỏ
    expect(find.text('Đã chọn 2 sp (2 món)'), findsOneWidget);
    expect(find.text(formatVnd(550000)), findsWidgets);

    // 3. Tăng số lượng sản phẩm 1 lên 2 bằng nút '+' ngay trên thẻ
    final addIcons = find.byIcon(Icons.add_circle);
    expect(addIcons, findsNWidgets(2));
    await tester.tap(addIcons.first);
    await tester.pumpAndSettle();

    // Tổng số món tăng lên 3 (2 món sp1 + 1 món sp2 = 850.000 đ)
    expect(find.text('Đã chọn 2 sp (3 món)'), findsOneWidget);
    expect(find.text(formatVnd(850000)), findsWidgets);

    // 4. Đóng SnackBar nếu có rồi bấm 'Xem giỏ & Gửi duyệt' để mở PosCartBottomSheet
    rootScaffoldMessengerKey.currentState?.clearSnackBars();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Xem giỏ & Gửi duyệt'));
    await tester.pumpAndSettle();

    // Kiểm tra bottom sheet mở ra với đầy đủ thông tin
    expect(find.text('Giỏ hàng POS (3)'), findsOneWidget);
    expect(find.text('Duyệt gửi thu ngân'), findsOneWidget);

    // 5. Bấm 'Duyệt gửi thu ngân'
    await tester.tap(find.text('Duyệt gửi thu ngân'));
    await tester.pumpAndSettle();

    // Xác nhận đã tạo và gửi thu ngân đơn với đủ 2 loại sản phẩm
    final request = fakeRepo.lastSubmittedRequest;
    expect(request, isNotNull);
    expect(request!.storeId, 's1');
    expect(request.items.length, 2);
    expect(request.items[0].productId, 'p1');
    expect(request.items[0].quantity, 2);
    expect(request.items[1].productId, 'p2');
    expect(request.items[1].quantity, 1);

    // Bottom sheet đóng lại và giỏ được reset
    expect(find.text('Xem giỏ & Gửi duyệt'), findsNothing);
  });
}
