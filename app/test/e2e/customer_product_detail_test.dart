// Test end-to-end màn Chi tiết sản phẩm với BACKEND THẬT.
//
//   flutter test test/e2e --dart-define=E2E=true \
//     --dart-define=API_BASE_URL=http://localhost:5000/api
//
// So khớp số liệu trên màn hình với chính API: tồn kho là `availableStock`
// từng cửa hàng, điểm trung bình là `rating` của `GET /products/:id`.
@Tags(['e2e'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/core/utils/formatters.dart';
import 'package:gutacosmetic/features/customer/cart/cart_controller.dart';
import 'package:gutacosmetic/features/customer/catalog/product_reviews_controller.dart';
import 'package:gutacosmetic/features/customer/catalog/rating_summary.dart';
import 'package:gutacosmetic/features/customer/data/product_repository.dart';
import 'package:gutacosmetic/features/customer/presentation/product_detail_screen.dart';
import 'package:gutacosmetic/features/customer/presentation/widgets/product_card.dart';
import 'package:gutacosmetic/features/customer/presentation/widgets/product_reviews_section.dart';
import 'package:material_ui/material_ui.dart';

import 'e2e_helpers.dart';

final _verticalScroll = find.byWidgetPredicate(
  (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
);

void main() {
  testWidgets(
    'Khách hàng: mở chi tiết sản phẩm → tồn kho, đánh giá, thêm giỏ',
    skip: !runE2E,
    (tester) async {
      final container = await startApp(tester);
      await login(tester, 'customer.guta.demo@gmail.com', demoPassword);
      await waitFor(tester, find.textContaining('Xin chào'));

      // 1. Mở sản phẩm đầu tiên ở Trang chủ.
      await tester.scrollUntilVisible(
        find.text('Gợi ý cho bạn'),
        300,
        scrollable: _verticalScroll.first,
      );
      await waitFor(tester, find.byType(ProductCard));
      final card = find.byType(ProductCard).first;
      await tester.ensureVisible(card);
      await tester.pump();
      final listed = tester.widget<ProductCard>(card).product;
      await tester.tap(
        find.descendant(of: card, matching: find.text(listed.name)),
      );
      await waitFor(tester, find.byType(ProductDetailScreen));
      await waitFor(tester, find.text('Tồn kho tại cửa hàng'));

      // Số liệu thật mà màn hình vừa tải — dùng để đối chiếu. Không `await`
      // future của provider trong `runAsync` (future thuộc zone fake-async
      // nên sẽ treo); chờ tới khi cả 3 request xong rồi đọc `.value`.
      final stockAsync = productStockProvider(listed.id);
      final reviewsAsync = productReviewsProvider(listed.id);
      await waitUntil(
        tester,
        () =>
            container.read(stockAsync).value != null &&
            container.read(reviewsAsync).value != null,
        description: 'tải tồn kho + đánh giá',
      );
      final product = container.read(productDetailProvider(listed.id)).value;
      final stocks = container.read(stockAsync).value;
      final reviews = container.read(reviewsAsync).value;

      // 2. Đầu trang: tên, giá, điểm trung bình.
      expect(find.text(product!.name), findsWidgets);
      expect(find.text(formatVnd(product.price)), findsWidgets);
      final summary = RatingSummary.of(product);
      // Phân bố sao của backend khớp tổng số đánh giá.
      expect(summary.starCounts.values.fold(0, (s, e) => s + e), summary.count);
      expect(reviews!.total, summary.count);
      expect(
        find.text(
          summary.hasReviews
              ? '${summary.averageLabel} (${formatNumber(summary.count)} đánh giá)'
              : 'Chưa có đánh giá',
        ),
        findsOneWidget,
      );

      // 3. Tồn kho từng cửa hàng = availableStock.
      expect(stocks, isNotEmpty);
      for (final s in stocks!) {
        final name = s.store.isCentral
            ? '${s.store.name} (kho tổng)'
            : s.store.name;
        await tester.scrollUntilVisible(
          find.text(name),
          200,
          scrollable: _verticalScroll.first,
        );
        final label = s.isOutOfStock
            ? 'Hết hàng'
            : s.isLowStock
            ? 'Sắp hết · còn ${formatNumber(s.availableStock)}'
            : 'Còn ${formatNumber(s.availableStock)}';
        final row = find.ancestor(
          of: find.text(name),
          matching: find.byType(Row),
        );
        expect(
          find.descendant(of: row.first, matching: find.text(label)),
          findsOneWidget,
          reason: '${s.store.name}: availableStock=${s.availableStock}',
        );
      }

      // 4. Thành phần + đánh giá.
      await tester.scrollUntilVisible(
        find.text('Thành phần nổi bật'),
        300,
        scrollable: _verticalScroll.first,
      );
      await tester.scrollUntilVisible(
        find.text('Đánh giá sản phẩm'),
        300,
        scrollable: _verticalScroll.first,
      );
      if (reviews.reviews.isEmpty) {
        await tester.scrollUntilVisible(
          find.textContaining('Chưa có đánh giá nào'),
          200,
          scrollable: _verticalScroll.first,
        );
      } else {
        await tester.scrollUntilVisible(
          find.byType(ReviewCard).first,
          200,
          scrollable: _verticalScroll.first,
        );
        expect(
          find.byType(ReviewCard).evaluate().length,
          lessThanOrEqualTo(ProductReviewsController.pageSize),
        );
      }

      // 5. Thêm vào giỏ (nếu còn hàng).
      final soldOut = stocks.every((s) => s.isOutOfStock);
      clearSnackBars();
      await tester.tap(find.text('Thêm vào giỏ'));
      await tester.pump();
      expect(container.read(cartCountProvider), soldOut ? 0 : 1);

      // 6. Quay lại Trang chủ.
      await tester.tap(find.byTooltip('Quay lại'));
      // Về lại shell khách hàng (Trang chủ giữ nguyên vị trí cuộn).
      await waitUntil(
        tester,
        () => find.byType(ProductDetailScreen).evaluate().isEmpty,
        description: 'đóng màn chi tiết',
      );
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(ProductCard), findsWidgets);

      await finish(tester);
    },
  );
}
