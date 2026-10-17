import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/app/theme.dart';
import 'package:gutacosmetic/core/storage/local_storage.dart';
import 'package:gutacosmetic/core/widgets/app_messenger.dart';
import 'package:gutacosmetic/features/customer/cart/cart_controller.dart';
import 'package:gutacosmetic/features/customer/data/product_repository.dart';
import 'package:gutacosmetic/features/customer/data/review_repository.dart';
import 'package:gutacosmetic/features/customer/presentation/product_detail_screen.dart';
import 'package:gutacosmetic/features/customer/presentation/widgets/product_reviews_section.dart';
import 'package:gutacosmetic/features/customer/wishlist/wishlist_controller.dart';
import 'package:gutacosmetic/features/session/session_controller.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _product = Product(
  id: 'p1',
  sku: 'SRM-01',
  name: 'Serum Vitamin C',
  brand: 'Klairs',
  price: 320000,
  originalPrice: 400000,
  volume: '35ml',
  origin: 'Hàn Quốc',
  ingredients: [
    Ingredient(
      icon: 'water-outline',
      title: 'Vitamin C 5%',
      subtitle: 'Sáng da',
    ),
  ],
  rating: 4.5,
  reviewCount: 2,
  ratingBreakdown: {'1': 0, '2': 0, '3': 0, '4': 1, '5': 1},
);

const _branch = Store(id: 's1', name: 'GUTA Quận 1', address: '12 Lê Lợi');
const _central = Store(id: 's0', name: 'Kho Thủ Đức', type: StoreType.central);

class _NoWishlist extends WishlistController {
  @override
  Set<String> build() => const {};
}

/// Trả [reviews] theo trang như backend; đếm số lần gọi.
class _FakeReviews implements ReviewRepository {
  _FakeReviews(this.reviews);

  final List<Review> reviews;
  final requestedPages = <int>[];

  @override
  Future<ReviewPage> fetchProductReviews(
    String productId, {
    required int page,
    required int limit,
  }) async {
    requestedPages.add(page);
    final items = reviews.skip((page - 1) * limit).take(limit).toList();
    return ReviewPage(
      reviews: items,
      total: reviews.length,
      hasMore: page * limit < reviews.length,
    );
  }

  // Tạo/sửa/xóa đánh giá không dùng ở màn chi tiết sản phẩm.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required List<StoreStock> stocks,
  List<Review> reviews = const [],
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      currentUserProvider.overrideWithValue(
        const AppUser(id: 'u1', role: UserRole.customer),
      ),
      wishlistControllerProvider.overrideWith(_NoWishlist.new),
      productDetailProvider.overrideWith((ref, id) async => _product),
      productStockProvider.overrideWith((ref, id) async => stocks),
      reviewRepositoryProvider.overrideWithValue(_FakeReviews(reviews)),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildAppTheme(),
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        home: const ProductDetailScreen(productId: 'p1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('hiển thị giá, điểm TB, tồn kho availableStock từng cửa hàng', (
    tester,
  ) async {
    await _pump(
      tester,
      stocks: const [
        StoreStock(
          store: _branch,
          totalStock: 10,
          reservedStock: 2,
          availableStock: 8,
          lowStockThreshold: 5,
        ),
        StoreStock(store: _central, totalStock: 4, reservedStock: 4),
      ],
      reviews: [
        Review(
          id: 'r1',
          customerName: 'Lan',
          rating: 5,
          comment: 'Thấm nhanh',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        const Review(id: 'r2', customerName: 'Minh', rating: 4),
      ],
    );

    expect(find.text('Serum Vitamin C'), findsOneWidget);
    expect(find.text('320.000đ'), findsOneWidget);
    expect(find.text('-20%'), findsOneWidget);
    expect(find.text('4,5 (2 đánh giá)'), findsOneWidget);

    // Tồn kho hiển thị availableStock (8), không phải totalStock (10).
    expect(find.text('Còn 8'), findsOneWidget);
    expect(find.text('Hết hàng'), findsOneWidget);
    expect(find.text('Kho Thủ Đức (kho tổng)'), findsOneWidget);
    expect(find.textContaining('Còn hàng tại 1/2 cửa hàng'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Vitamin C 5%'), 300);
    expect(find.text('Sáng da'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Thấm nhanh'), 300);
    expect(find.text('Lan'), findsOneWidget);
    expect(find.text('2 ngày trước'), findsOneWidget);
    expect(find.text('Tuyệt vời'), findsOneWidget);
  });

  testWidgets('số lượng bị giới hạn theo cửa hàng còn nhiều nhất', (
    tester,
  ) async {
    final container = await _pump(
      tester,
      stocks: const [StoreStock(store: _branch, availableStock: 2)],
    );
    expect(find.text('Sắp hết · còn 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Tăng số lượng'));
    await tester.pump();
    await tester.tap(find.byTooltip('Tăng số lượng'));
    await tester.pump();
    expect(
      find.text('Mỗi cửa hàng hiện chỉ còn tối đa 2 sản phẩm.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Thêm vào giỏ'));
    await tester.pump();
    expect(container.read(cartCountProvider), 2);
    expect(container.read(cartControllerProvider).single.unitPrice, 320000);
  });

  testWidgets('hết hàng ở mọi cửa hàng → khóa nút mua', (tester) async {
    final container = await _pump(
      tester,
      stocks: const [
        StoreStock(store: _branch, totalStock: 3, reservedStock: 3),
      ],
    );
    expect(find.text('Tạm hết hàng'), findsOneWidget);
    expect(
      find.textContaining('tạm hết hàng ở tất cả cửa hàng'),
      findsOneWidget,
    );
    await tester.tap(find.text('Thêm vào giỏ'));
    await tester.pump();
    expect(container.read(cartCountProvider), 0);
  });

  testWidgets('đánh giá tải theo trang, bấm "Xem thêm" để tải tiếp', (
    tester,
  ) async {
    await _pump(
      tester,
      stocks: const [StoreStock(store: _branch, availableStock: 9)],
      reviews: [
        for (var i = 1; i <= 7; i++)
          Review(id: 'r$i', customerName: 'Khách $i', rating: 5),
      ],
    );
    // Phân bố sao lấy từ ratingBreakdown của backend (5★: 1, 4★: 1).
    await tester.ensureVisible(find.text('trên 5'));
    await tester.pumpAndSettle();
    expect(find.text('Khách 1'), findsOneWidget);

    final more = find.text('Xem thêm đánh giá (còn 2)');
    await tester.ensureVisible(more);
    await tester.pumpAndSettle();
    expect(find.byType(ReviewCard), findsNWidgets(5));
    expect(find.text('Khách 6'), findsNothing);

    await tester.tap(more);
    await tester.pumpAndSettle();
    expect(find.byType(ReviewCard), findsNWidgets(7));
    expect(find.text('Khách 7'), findsOneWidget);
    expect(find.textContaining('Xem thêm đánh giá'), findsNothing);
  });
}
