import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gutacosmetic/app/theme.dart';
import 'package:gutacosmetic/core/widgets/app_messenger.dart';
import 'package:gutacosmetic/features/customer/data/order_repository.dart';
import 'package:gutacosmetic/features/customer/data/review_repository.dart';
import 'package:gutacosmetic/features/customer/presentation/write_review_screen.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';
import 'package:material_ui/material_ui.dart';

const _order = Order(
  id: 'o1',
  orderCode: 'GUTA-1',
  status: OrderStatus.completed,
  items: [
    OrderItem(productId: EntityRef('p1'), name: 'Serum B5', unitPrice: 1000),
    OrderItem(productId: EntityRef('p2'), name: 'Toner', unitPrice: 1000),
  ],
);

/// Ghi lại các lần tạo/sửa đánh giá.
class _FakeReviews implements ReviewRepository {
  final created = <({String orderId, int rating, String comment})>[];
  final updated =
      <({String id, int rating, String comment, List<String> kept})>[];

  @override
  Future<Review> createReview({
    required String orderId,
    required int rating,
    required String comment,
    List<ReviewImageUpload> images = const [],
  }) async {
    created.add((orderId: orderId, rating: rating, comment: comment));
    return Review(id: 'r-new', rating: rating, comment: comment);
  }

  @override
  Future<Review> updateReview(
    String id, {
    required int rating,
    required String comment,
    required List<String> keptImages,
    List<ReviewImageUpload> newImages = const [],
  }) async {
    updated.add((id: id, rating: rating, comment: comment, kept: keptImages));
    return Review(id: id, rating: rating, comment: comment);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<_FakeReviews> _pump(
  WidgetTester tester, {
  Order order = _order,
  Review? review,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final repo = _FakeReviews();
  final router = GoRouter(
    initialLocation: '/review',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('Chi tiết đơn')),
        routes: [
          GoRoute(
            path: 'review',
            builder: (_, _) => const WriteReviewScreen(orderId: 'o1'),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        reviewRepositoryProvider.overrideWithValue(repo),
        customerOrderProvider.overrideWith((ref, id) async => order),
        orderReviewProvider.overrideWith((ref, id) async => review),
      ],
      child: MaterialApp.router(
        theme: buildAppTheme(),
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  test('form gửi lên backend: trường văn bản và ảnh cũ dạng JSON', () {
    final create = ReviewRepository.reviewFormData(
      orderId: 'o1',
      rating: 4,
      comment: '  Tốt  ',
      newImages: [
        (bytes: [1, 2, 3], fileName: 'a.png', mimeType: 'image/png'),
      ],
    );
    expect(Map.fromEntries(create.fields), {
      'orderId': 'o1',
      'rating': '4',
      'comment': 'Tốt',
    });
    expect(create.files.single.key, 'images');
    expect(create.files.single.value.filename, 'a.png');

    final update = ReviewRepository.reviewFormData(
      rating: 5,
      comment: 'Ok',
      keptImages: ['https://x/1.jpg'],
    );
    final fields = Map.fromEntries(update.fields);
    expect(fields.containsKey('orderId'), isFalse);
    expect(jsonDecode(fields['existingImages']!), ['https://x/1.jpg']);
    expect(update.files, isEmpty);
  });

  test('chỉ nhận ảnh JPG/PNG', () {
    expect(
      reviewImageMimeType(mimeType: 'image/png', fileName: 'x'),
      'image/png',
    );
    expect(
      reviewImageMimeType(mimeType: 'image/jpg', fileName: 'x'),
      'image/jpeg',
    );
    expect(
      reviewImageMimeType(mimeType: 'image/webp', fileName: 'a.png'),
      isNull,
    );
    expect(reviewImageMimeType(fileName: 'A.JPEG'), 'image/jpeg');
    expect(reviewImageMimeType(fileName: 'a.heic'), isNull);
  });

  testWidgets('viết mới: bắt buộc nội dung, chọn sao, chèn gợi ý rồi gửi', (
    tester,
  ) async {
    final repo = await _pump(tester);

    expect(find.text('Viết đánh giá'), findsOneWidget);
    expect(find.text('Serum B5'), findsOneWidget);
    expect(find.textContaining('sản phẩm đầu tiên'), findsOneWidget);
    expect(find.text('Tuyệt vời'), findsOneWidget); // mặc định 5 sao

    await tester.tap(find.text('Gửi đánh giá'));
    await tester.pump();
    expect(find.text('Vui lòng chia sẻ cảm nhận của bạn'), findsOneWidget);
    expect(repo.created, isEmpty);

    await tester.tap(find.byTooltip('4 sao'));
    await tester.pump();
    expect(find.text('Tốt'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Dùng thích');
    await tester.tap(find.text('Đóng gói cẩn thận'));
    await tester.pump();

    await tester.tap(find.text('Gửi đánh giá'));
    await tester.pumpAndSettle();
    expect(repo.created.single, (
      orderId: 'o1',
      rating: 4,
      comment: 'Dùng thích. Đóng gói cẩn thận',
    ));
    // Đã quay về màn trước.
    expect(find.text('Chi tiết đơn'), findsOneWidget);
    expect(find.text('Cảm ơn bạn đã đánh giá!'), findsOneWidget);
  });

  testWidgets('sửa: điền sẵn, chỉ lưu khi có thay đổi, giữ ảnh còn lại', (
    tester,
  ) async {
    final repo = await _pump(
      tester,
      order: _order.copyWith(isReviewed: true),
      review: const Review(
        id: 'r1',
        rating: 3,
        comment: 'Tạm ổn',
        images: ['https://x/1.jpg', 'https://x/2.jpg'],
      ),
    );

    expect(find.text('Sửa đánh giá'), findsOneWidget);
    expect(find.text('Bình thường'), findsOneWidget);
    expect(find.text('Tạm ổn'), findsOneWidget);
    final save = find.widgetWithText(FilledButton, 'Lưu thay đổi');
    expect(tester.widget<FilledButton>(save).onPressed, isNull);

    await tester.tap(find.byTooltip('5 sao'));
    await tester.pump();
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);

    await tester.scrollUntilVisible(
      find.text('Hình ảnh (2/5)'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Xóa ảnh').first);
    await tester.pump();
    expect(find.text('Hình ảnh (1/5)'), findsOneWidget);

    await tester.tap(save);
    await tester.pumpAndSettle();
    final update = repo.updated.single;
    expect((update.id, update.rating, update.comment), ('r1', 5, 'Tạm ổn'));
    expect(update.kept, ['https://x/2.jpg']);
  });

  testWidgets('đơn chưa hoàn tất thì không cho đánh giá', (tester) async {
    await _pump(tester, order: _order.copyWith(status: OrderStatus.preparing));
    expect(find.text('Chỉ đánh giá được đơn đã hoàn tất'), findsOneWidget);
  });
}
