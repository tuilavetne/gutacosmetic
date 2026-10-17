// Test end-to-end Trang chủ + Danh mục của khách hàng với BACKEND THẬT.
//
//   flutter test test/e2e --dart-define=E2E=true \
//     --dart-define=API_BASE_URL=http://localhost:5000/api
//
// Bấm thích 2 lần nên wishlist của customer demo được trả về như cũ.
@Tags(['e2e'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/features/customer/cart/cart_controller.dart';
import 'package:gutacosmetic/features/customer/catalog/catalog_filter.dart';
import 'package:gutacosmetic/features/customer/presentation/widgets/product_card.dart';
import 'package:gutacosmetic/features/customer/wishlist/wishlist_controller.dart';
import 'package:material_ui/material_ui.dart';

import 'e2e_helpers.dart';

/// Scrollable dọc chính của màn hiện tại (bỏ qua các hàng cuộn ngang).
final _verticalScroll = find.byWidgetPredicate(
  (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
);

void main() {
  testWidgets(
    'Khách hàng: Trang chủ → thêm giỏ, thích, chọn danh mục, tìm kiếm, lọc',
    skip: !runE2E,
    (tester) async {
      final container = await startApp(tester);
      await login(tester, 'customer.guta.demo@gmail.com', demoPassword);

      // 1. Trang chủ: chào khách, giỏ trống, có sản phẩm gợi ý (tối đa 6).
      await waitFor(tester, find.textContaining('Xin chào'));
      expect(find.text('Giỏ hàng của bạn đang trống'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Gợi ý cho bạn'),
        300,
        scrollable: _verticalScroll.first,
      );
      await waitFor(tester, find.byType(ProductCard));
      final firstCard = find.byType(ProductCard).first;
      await tester.ensureVisible(firstCard);
      await tester.pump();
      expect(find.byType(ProductCard).evaluate().length, lessThanOrEqualTo(6));
      final product = tester.widget<ProductCard>(firstCard).product;

      // 2. Thêm nhanh vào giỏ → badge + tạm tính.
      await tester.tap(
        find.descendant(
          of: firstCard,
          matching: find.byTooltip('Thêm vào giỏ hàng'),
        ),
      );
      await tester.pump();
      expect(find.text('Đã thêm "${product.name}" vào giỏ hàng.'), findsOne);
      expect(container.read(cartCountProvider), 1);
      expect(container.read(cartSubtotalProvider), product.price);

      // 3. Thích rồi bỏ thích (gọi API thật, trả wishlist về như cũ).
      bool liked() =>
          container.read(wishlistControllerProvider).contains(product.id);
      final wasLiked = liked();
      Future<void> tapHeart() async {
        clearSnackBars();
        await tester.tap(
          find.descendant(
            of: firstCard,
            matching: find.byTooltip(liked() ? 'Bỏ thích' : 'Yêu thích'),
          ),
        );
        await tester.pump();
      }

      await tapHeart();
      expect(liked(), !wasLiked); // Cập nhật lạc quan ngay.
      await waitUntil(
        tester,
        () => find
            .descendant(
              of: firstCard,
              matching: find.byTooltip(wasLiked ? 'Yêu thích' : 'Bỏ thích'),
            )
            .evaluate()
            .isNotEmpty,
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 1)),
      );
      await tapHeart();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 1)),
      );
      await tester.pump();
      expect(liked(), wasLiked);

      // 4. Chọn danh mục "Trang Điểm" ở Trang chủ → sang tab Danh mục đã lọc.
      await tester.scrollUntilVisible(
        find.text('Mua theo danh mục'),
        -300,
        scrollable: _verticalScroll.first,
      );
      await tester.tap(find.text('Trang Điểm').first);
      await tester.pump();
      expect(container.read(catalogFilterProvider).category, 'Trang Điểm');
      await waitFor(tester, find.textContaining(RegExp(r'^\d+ sản phẩm$')));
      final makeupCount = find
          .byType(ProductCard)
          .evaluate()
          .map((e) => (e.widget as ProductCard).product)
          .where((p) => p.category == 'Trang Điểm')
          .length;
      expect(makeupCount, greaterThan(0));
      expect(
        find.byType(ProductCard).evaluate().length,
        makeupCount,
        reason: 'Mọi sản phẩm hiển thị phải thuộc danh mục đã chọn',
      );

      // 5. Tìm "Bioderma" trong "Trang Điểm" → không có; bỏ danh mục → có.
      await tester.enterText(
        find.widgetWithText(TextField, 'Tìm sản phẩm chăm sóc da...'),
        'Bioderma',
      );
      await waitFor(tester, find.text('Không tìm thấy sản phẩm'));
      expect(container.read(catalogFilterProvider).search, 'Bioderma');
      await tester.tap(find.text('Tất cả danh mục'));
      await waitFor(tester, find.textContaining('cho "Bioderma"'));
      final bioderma = find
          .byType(ProductCard)
          .evaluate()
          .map((e) => (e.widget as ProductCard).product)
          .toList();
      expect(bioderma, isNotEmpty);
      expect(bioderma.every((p) => p.name.contains('Bioderma')), isTrue);

      // 6. Bộ lọc nâng cao: giá tối đa thấp hơn mọi kết quả → trống → xóa lọc.
      final cheapest = bioderma
          .map((p) => p.price)
          .reduce((a, b) => a < b ? a : b);
      await tester.tap(find.byTooltip('Bộ lọc nâng cao'));
      await waitFor(tester, find.text('Bộ lọc tìm kiếm'));
      await tester.enterText(
        find.widgetWithText(TextField, 'Tối đa'),
        '${cheapest - 1}',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Áp dụng'));
      await waitFor(tester, find.text('Không có sản phẩm phù hợp với bộ lọc'));
      expect(container.read(catalogFilterProvider).advancedCount, 1);
      await tester.tap(find.text('Xóa bộ lọc nâng cao'));
      await waitFor(tester, find.byType(ProductCard));
      expect(find.byType(ProductCard).evaluate().length, bioderma.length);

      // 7. Tìm từ Trang chủ → tab Danh mục nhận từ khóa mới, bỏ lọc cũ.
      await tapCustomerTab(tester, 'Trang chủ');
      final homeSearch = find.widgetWithText(TextField, 'Tìm sản phẩm...');
      await tester.scrollUntilVisible(
        homeSearch,
        -200,
        scrollable: _verticalScroll.first,
      );
      await tester.ensureVisible(homeSearch);
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(homeSearch, 'Niacinamide');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await waitFor(tester, find.textContaining('cho "Niacinamide"'));
      final filter = container.read(catalogFilterProvider);
      expect(filter.search, 'Niacinamide');
      expect(filter.category, isNull);
      expect(
        find.widgetWithText(TextField, 'Niacinamide'),
        findsOneWidget,
        reason: 'Ô tìm kiếm ở Danh mục phải đồng bộ từ khóa',
      );

      // 8. Giỏ hàng vẫn còn sau khi chuyển tab; đăng xuất ở tab Tài khoản.
      expect(container.read(cartCountProvider), 1);
      await logoutCustomer(tester);
      await finish(tester);
    },
  );
}
