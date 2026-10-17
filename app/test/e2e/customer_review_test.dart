// Test end-to-end Viết / sửa / xóa đánh giá đơn hàng với BACKEND THẬT.
//
//   flutter test test/e2e/customer_review_test.dart --dart-define=E2E=true \
//     --dart-define=API_BASE_URL=http://localhost:5000/api --timeout 300s
//
// Cần một đơn đã hoàn tất của khách demo. Chưa có thì test tự tạo đơn nhận
// tại cửa hàng (COD, 1 sản phẩm rẻ nhất còn hàng) và dùng tài khoản Manager
// demo chuyển đơn sang Hoàn tất — lần đầu chạy sẽ bán thật 1 sản phẩm và cộng
// điểm cho khách demo. Các lần sau dùng lại đơn đó. Test xóa đánh giá ở
// cuối nên đơn quay về "Chờ đánh giá".
@Tags(['e2e'])
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/app/router.dart';
import 'package:gutacosmetic/core/config/env.dart';
import 'package:gutacosmetic/features/customer/data/review_repository.dart';
import 'package:gutacosmetic/features/customer/orders/order_display.dart';
import 'package:gutacosmetic/features/customer/presentation/order_detail_screen.dart';
import 'package:gutacosmetic/features/customer/presentation/orders_screen.dart';
import 'package:gutacosmetic/features/customer/presentation/write_review_screen.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';
import 'package:material_ui/material_ui.dart';

import 'e2e_helpers.dart';

const _customer = 'customer.guta.demo@gmail.com';
const _manager = 'manager.guta.demo@gmail.com';

final _verticalScroll = find.byWidgetPredicate(
  (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
);

/// Gọi API bằng Dio riêng, tạo trong zone thật của `runAsync` (Dio của app
/// mở kết nối trong zone fake-async nên dùng lại sẽ treo).
class _Api {
  _Api() : _dio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));

  final Dio _dio;

  Future<String> login(String identifier) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'identifier': identifier, 'password': demoPassword},
    );
    return res.data!['token'] as String;
  }

  Future<Map<String, dynamic>> send(
    String method,
    String path,
    String token, {
    Object? data,
    String? storeId,
  }) async {
    final res = await _dio.request<Map<String, dynamic>>(
      path,
      data: data,
      options: Options(
        method: method,
        headers: {
          'Authorization': 'Bearer $token',
          'X-Active-Store-Id': ?storeId,
        },
      ),
    );
    return res.data!;
  }
}

/// Id + mã của một đơn hoàn tất, chưa đánh giá của khách demo.
Future<({String id, String code})> _ensureCompletedOrder() async {
  final api = _Api();
  final token = await api.login(_customer);
  final orders = [
    for (final o in (await api.send('GET', '/orders', token))['orders'] as List)
      Order.fromJson(Map<String, dynamic>.from(o as Map)),
  ];

  final completed = orders.where((o) => o.status == OrderStatus.completed);
  for (final order in completed) {
    if (!order.isReviewed) return (id: order.id, code: order.orderCode);
  }
  // Lần chạy trước dừng giữa chừng → xóa đánh giá cũ để dùng lại đơn.
  if (completed.isNotEmpty) {
    final order = completed.first;
    final review = await api.send('GET', '/reviews/order/${order.id}', token);
    final id = (review['review'] as Map?)?['_id'];
    if (id != null) await api.send('DELETE', '/reviews/$id', token);
    return (id: order.id, code: order.orderCode);
  }

  // Tạo đơn nhận tại cửa hàng cho sản phẩm rẻ nhất còn hàng.
  final inventory = [
    for (final p
        in (await api.send('GET', '/inventory/products', token))['products']
            as List)
      ProductInventory.fromJson(Map<String, dynamic>.from(p as Map)),
  ]..sort((a, b) => a.product.price.compareTo(b.product.price));
  late final ProductInventory item;
  late final StoreStock stock;
  outer:
  for (final p in inventory) {
    for (final s in p.inventories) {
      if (s.availableStock > 0) {
        item = p;
        stock = s;
        break outer;
      }
    }
  }
  final placed = await api.send(
    'POST',
    '/orders/online',
    token,
    data: {
      'storeId': stock.store.id,
      'fulfillmentType': 'STORE_PICKUP',
      'paymentMethod': 'COD',
      'items': [
        {'productId': item.product.id, 'quantity': 1},
      ],
    },
  );
  final order = Order.fromJson(placed['order'] as Map<String, dynamic>);

  final managerToken = await api.login(_manager);
  for (final status in ['READY_FOR_PICKUP', 'COMPLETED']) {
    await api.send(
      'PATCH',
      '/orders/${order.id}/online-status',
      managerToken,
      data: {'status': status},
      storeId: stock.store.id,
    );
  }
  return (id: order.id, code: order.orderCode);
}

/// Giữ [provider] sống và chờ tải xong.
Future<T> _read<T>(
  WidgetTester tester,
  ProviderContainer container,
  ProviderListenable<AsyncValue<T>> provider,
) async {
  final sub = container.listen(provider, (_, _) {});
  addTearDown(sub.close);
  await waitUntil(
    tester,
    () => sub.read().hasValue || sub.read().hasError,
    description: '$provider',
  );
  return sub.read().requireValue;
}

Future<Review?> _fetchReview(
  WidgetTester tester,
  ProviderContainer container,
  String orderId,
) {
  container.invalidate(orderReviewProvider(orderId));
  return _read(tester, container, orderReviewProvider(orderId));
}

void main() {
  testWidgets(
    'Khách hàng: tab Chờ đánh giá → viết → xem, sửa, xóa đánh giá',
    skip: !runE2E,
    (tester) async {
      // flutter_test chặn HTTP thật — bỏ chặn trước khi gọi API chuẩn bị.
      HttpOverrides.global = null;
      final order = (await tester.runAsync(_ensureCompletedOrder))!;

      final container = await startApp(tester);
      await login(tester, _customer, demoPassword);
      await waitFor(tester, find.textContaining('Xin chào'));

      // 1. Tab Đơn hàng → "Chờ đánh giá" có đơn hoàn tất.
      await tapCustomerTab(tester, 'Đơn hàng');
      await waitFor(tester, find.byType(CustomerOrdersScreen));
      final reviewTab = find.textContaining('Chờ đánh giá (');
      await waitFor(tester, reviewTab);
      await tester.ensureVisible(reviewTab);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(reviewTab);
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        DefaultTabController.of(tester.element(find.byType(TabBar))).index,
        OrderTab.toReview.index,
      );
      await waitFor(tester, find.text(order.code));
      final card = find.ancestor(
        of: find.text(order.code),
        matching: find.byType(OrderCard),
      );
      await tester.ensureVisible(card);
      await tester.pump();

      // 2. Viết đánh giá 4 sao.
      await tester.tap(
        find.descendant(of: card, matching: find.text('Đánh giá')),
      );
      await waitFor(tester, find.byType(WriteReviewScreen));
      await waitFor(tester, find.text('Viết đánh giá'));
      await tester.tap(find.byTooltip('4 sao'));
      await tester.enterText(find.byType(TextField), 'E2E: dùng tốt');
      await tester.tap(find.text('Giao hàng nhanh'));
      await tester.pump();
      clearSnackBars();
      await tester.tap(find.text('Gửi đánh giá'));
      await waitUntil(
        tester,
        () => find.byType(WriteReviewScreen).evaluate().isEmpty,
        description: 'gửi đánh giá',
      );
      var review = await _fetchReview(tester, container, order.id);
      expect(review?.rating, 4);
      expect(review?.comment, 'E2E: dùng tốt. Giao hàng nhanh');

      // Đơn rời tab "Chờ đánh giá" sau khi tải lại.
      await waitUntil(
        tester,
        () => find.text(order.code).evaluate().isEmpty,
        description: 'đơn rời tab Chờ đánh giá',
      );

      // 3. Chi tiết đơn hiện đánh giá; sửa thành 5 sao.
      container.read(routerProvider).push('/customer/orders/${order.id}');
      await waitFor(tester, find.byType(OrderDetailScreen));
      await waitFor(tester, find.text(order.code));
      final editButton = find.widgetWithText(TextButton, 'Sửa');
      await tester.scrollUntilVisible(
        editButton,
        150,
        scrollable: _verticalScroll.first,
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Đánh giá của bạn'), findsOneWidget);
      expect(find.text('E2E: dùng tốt. Giao hàng nhanh'), findsOneWidget);
      await tester.tap(editButton);
      await waitFor(tester, find.text('Sửa đánh giá'));
      expect(find.text('Tốt'), findsOneWidget); // 4 sao đã chọn
      await tester.tap(find.byTooltip('5 sao'));
      await tester.pump();
      clearSnackBars();
      await tester.tap(find.text('Lưu thay đổi'));
      await waitUntil(
        tester,
        () => find.byType(WriteReviewScreen).evaluate().isEmpty,
        description: 'lưu đánh giá',
      );
      review = await _fetchReview(tester, container, order.id);
      expect(review?.rating, 5);
      await waitFor(tester, find.text('Tuyệt vời'));

      // 4. Xóa → đơn quay về chưa đánh giá.
      await tester.scrollUntilVisible(
        find.widgetWithText(TextButton, 'Xóa'),
        200,
        scrollable: _verticalScroll.first,
      );
      await tester.pump();
      clearSnackBars();
      await tester.tap(find.widgetWithText(TextButton, 'Xóa'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
      await waitFor(tester, find.text('Viết đánh giá'));
      expect(await _fetchReview(tester, container, order.id), isNull);
      expect(find.widgetWithText(FilledButton, 'Đánh giá'), findsOneWidget);

      await finish(tester);
    },
  );
}
