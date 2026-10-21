// Test end-to-end Giỏ hàng → Thanh toán → Đơn hàng với BACKEND THẬT.
//
//   flutter test test/e2e/customer_checkout_test.dart --dart-define=E2E=true \
//     --dart-define=API_BASE_URL=http://localhost:5000/api --timeout 300s
//
// Mỗi test tự hủy đơn vừa tạo (trả hàng về kho). Đơn chuyển khoản gọi PayOS
// thật để tạo mã QR — hủy ngay để không bị tính là đơn hết hạn chưa trả.
@Tags(['e2e'])
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/app/router.dart';
import 'package:gutacosmetic/core/utils/constants.dart';
import 'package:gutacosmetic/core/utils/formatters.dart';
import 'package:gutacosmetic/features/customer/cart/cart_controller.dart';
import 'package:gutacosmetic/features/customer/data/order_repository.dart';
import 'package:gutacosmetic/features/customer/data/product_repository.dart';
import 'package:gutacosmetic/features/customer/orders/order_display.dart';
import 'package:gutacosmetic/features/customer/presentation/cart_screen.dart';
import 'package:gutacosmetic/features/customer/presentation/checkout_screen.dart';
import 'package:gutacosmetic/features/customer/presentation/order_detail_screen.dart';
import 'package:gutacosmetic/features/customer/presentation/orders_screen.dart';
import 'package:gutacosmetic/features/customer/presentation/payos_payment_screen.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';
import 'package:material_ui/material_ui.dart';

import 'e2e_helpers.dart';

const _cancelReason = 'Test e2e: khách đổi ý không mua nữa';

final _verticalScroll = find.byWidgetPredicate(
  (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
);

/// Đăng nhập khách demo, làm trống giỏ, chọn một sản phẩm còn ≥ 2 ở ít nhất
/// một cửa hàng và cho vào giỏ [quantity] cái.
Future<(ProviderContainer, Product)> _startWithCart(
  WidgetTester tester, {
  required int quantity,
}) async {
  final container = await startApp(tester);
  await login(tester, 'customer.guta.demo@gmail.com', demoPassword);
  await waitFor(tester, find.textContaining('Xin chào'));

  // Đọc qua provider (không gọi API trong `runAsync`: kết nối keep-alive mở
  // trong zone fake-async sẽ treo).
  final products = await _read(
    tester,
    container,
    productsProvider(allProductsQuery),
  );
  final inventories = await _read(
    tester,
    container,
    productsStockProvider(products.map((e) => e.id).join(',')),
  );
  final product = inventories
      .firstWhere((p) => p.inventories.any((s) => s.availableStock >= 2))
      .product;
  container.read(cartControllerProvider.notifier)
    ..clear()
    ..add(product, quantity: quantity);
  await tester.pump();

  await tester.tap(find.byTooltip('Giỏ hàng').first);
  await waitFor(tester, find.byType(CartScreen));
  expect(find.text(product.name), findsOneWidget);
  expect(find.text(formatVnd(product.price * quantity)), findsWidgets);

  await tester.tap(find.text('Thanh toán'));
  await waitFor(tester, find.byType(CheckoutScreen));
  return (container, product);
}

/// Id đơn trong đường dẫn hiện tại `/customer/orders/:id[/payment]`.
String _orderIdFromLocation(ProviderContainer container) {
  final path = container
      .read(routerProvider)
      .routerDelegate
      .currentConfiguration
      .uri
      .path;
  final match = RegExp(r'^/customer/orders/([^/]+)').firstMatch(path);
  expect(match, isNotNull, reason: path);
  return match!.group(1)!;
}

/// Giữ [provider] sống và chờ có dữ liệu.
Future<T> _read<T>(
  WidgetTester tester,
  ProviderContainer container,
  ProviderListenable<AsyncValue<T>> provider,
) async {
  final sub = container.listen(provider, (_, _) {});
  addTearDown(sub.close);
  await waitUntil(
    tester,
    () => sub.read().value != null || sub.read().hasError,
    description: '$provider',
  );
  return sub.read().requireValue;
}

/// Tải lại đơn từ server rồi đọc.
Future<Order> _fetchOrder(
  WidgetTester tester,
  ProviderContainer container,
  String id,
) {
  container.invalidate(customerOrderProvider(id));
  return _read(tester, container, customerOrderProvider(id));
}

Future<void> _cancelFromDetail(WidgetTester tester) async {
  clearSnackBars();
  await tester.pump();
  await tester.tap(find.widgetWithText(OutlinedButton, 'Hủy đơn'));
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.text('Hủy đơn hàng'), findsOneWidget);
  // Lý do dưới 15 ký tự: nút xác nhận bị khóa.
  await tester.enterText(find.byType(TextField).last, 'Test e2e');
  await tester.pump();
  expect(find.text('8/15 ký tự'), findsOneWidget);
  final confirm = find.widgetWithText(FilledButton, 'Xác nhận hủy');
  expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
  await tester.enterText(find.byType(TextField).last, _cancelReason);
  await tester.pump();
  await tester.tap(confirm);
  await waitFor(tester, find.textContaining('Đơn đã hủy lúc'));
}

void main() {
  testWidgets(
    'Khách hàng: giao tận nơi + COD → chi tiết đơn → hủy đơn',
    skip: !runE2E,
    (tester) async {
      final (container, product) = await _startWithCart(tester, quantity: 2);

      // Mặc định giao tận nơi, thông tin nhận hàng lấy từ hồ sơ.
      await waitFor(
        tester,
        find.text('Đơn được chuẩn bị và giao từ cửa hàng này.'),
      );
      expect(find.text('Customer Demo'), findsOneWidget);
      final total = product.price * 2 + AppConstants.deliveryFee;
      expect(find.text(formatVnd(total)), findsWidgets);

      await tester.tap(find.text('Đặt hàng'));
      await waitFor(tester, find.byType(OrderDetailScreen));
      await waitFor(tester, find.text('Chờ xác nhận'));
      expect(container.read(cartControllerProvider), isEmpty);

      final id = _orderIdFromLocation(container);
      final order = await _fetchOrder(tester, container, id);
      expect(order.fulfillmentType, FulfillmentType.delivery);
      expect(order.paymentMethod, PaymentMethod.cod);
      expect(order.shippingFee, AppConstants.deliveryFee);
      expect(order.totalPrice, total);
      expect(order.shippingAddress?.recipientName, 'Customer Demo');
      expect(order.items.single.quantity, 2);
      expect(order.inventoryReserved, isTrue);
      expect(find.text(order.orderCode), findsOneWidget);

      await _cancelFromDetail(tester);
      final cancelled = await _fetchOrder(tester, container, id);
      expect(cancelled.status, OrderStatus.cancelled);
      expect(cancelled.inventoryReserved, isFalse);
      expect(cancelled.cancellationReason, _cancelReason);

      await finish(tester);
    },
  );

  testWidgets(
    'Khách hàng: nhận tại cửa hàng + QR PayOS → màn QR → hủy, xem ở tab Đã hủy',
    skip: !runE2E,
    (tester) async {
      final (container, product) = await _startWithCart(tester, quantity: 1);

      await tester.tap(find.text('Nhận tại cửa hàng'));
      await tester.pump();
      await waitFor(tester, find.text('Còn đủ hàng cho giỏ của bạn'));

      final qrOption = find.text('Chuyển khoản qua QR PayOS');
      await tester.scrollUntilVisible(
        qrOption,
        200,
        scrollable: _verticalScroll.first,
      );
      await tester.pump();
      await tester.tap(qrOption);
      await tester.pump();
      // Nhận tại cửa hàng thì miễn phí ship.
      expect(find.text(formatVnd(product.price)), findsWidgets);

      await tester.tap(find.text('Đặt hàng'));
      await waitFor(tester, find.byType(PayosPaymentScreen));
      await waitFor(
        tester,
        find.textContaining('Mã hết hạn sau'),
        timeout: const Duration(seconds: 40),
      );
      expect(find.bySemanticsLabel('Mã QR thanh toán'), findsOneWidget);

      final id = _orderIdFromLocation(container);
      final order = await _fetchOrder(tester, container, id);
      expect(order.fulfillmentType, FulfillmentType.storePickup);
      expect(order.paymentMethod, PaymentMethod.bankTransfer);
      expect(order.shippingFee, 0);
      expect(order.totalPrice, product.price);
      expect(order.awaitsBankTransfer, isTrue);
      expect(order.paymentOrderCode, isNotNull);
      expect(find.text(formatVnd(order.totalPrice)), findsOneWidget);

      // Chưa chuyển khoản → PayOS báo chưa nhận tiền.
      final checkButton = find.text('Tôi đã thanh toán');
      await tester.scrollUntilVisible(
        checkButton,
        200,
        scrollable: _verticalScroll.first,
      );
      await tester.pump(const Duration(milliseconds: 300));
      clearSnackBars();
      await tester.tap(checkButton);
      await waitFor(
        tester,
        find.textContaining('Chưa nhận được thanh toán'),
        timeout: const Duration(seconds: 30),
      );

      // Đóng màn QR → chi tiết đơn (chờ thanh toán) → hủy.
      clearSnackBars();
      await tester.tap(find.byTooltip('Đóng'));
      await waitFor(tester, find.byType(OrderDetailScreen));
      await waitFor(tester, find.text('Chờ thanh toán'));
      expect(find.text('Thanh toán ngay'), findsOneWidget);
      await _cancelFromDetail(tester);
      expect(
        (await _fetchOrder(tester, container, id)).status,
        OrderStatus.cancelled,
      );

      // Tab Đơn hàng → "Đã hủy" có đơn vừa hủy.
      await tapCustomerTab(tester, 'Đơn hàng');
      await waitFor(tester, find.byType(CustomerOrdersScreen));
      final cancelledTab = find.textContaining('Đã hủy (');
      await tester.ensureVisible(cancelledTab);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(cancelledTab);
      await tester.pump(const Duration(milliseconds: 600));
      final tabController = DefaultTabController.of(
        tester.element(find.byType(TabBar)),
      );
      expect(tabController.index, OrderTab.cancelled.index);
      await waitFor(tester, find.text(order.orderCode));
      final card = find.ancestor(
        of: find.text(order.orderCode),
        matching: find.byType(OrderCard),
      );
      expect(
        find.descendant(of: card, matching: find.text('Mua lại')),
        findsOneWidget,
      );

      await finish(tester);
    },
  );
}
