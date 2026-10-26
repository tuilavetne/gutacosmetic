import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/app/theme.dart';
import 'package:gutacosmetic/core/widgets/app_messenger.dart';
import 'package:gutacosmetic/features/manager/data/manager_repository.dart';
import 'package:gutacosmetic/features/manager/presentation/rewards/rewards_screen.dart';
import 'package:gutacosmetic/features/session/session_controller.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';
import 'package:material_ui/material_ui.dart';

class _FakeRepo implements ManagerRepository {
  int points = 120;
  final redeemed = <(String, int, String)>[];
  final searches = <String>[];
  List<RewardRedemption> storeHistory = [
    const RewardRedemption(
      id: 'h1',
      rewardName: 'Son dưỡng mini',
      pointsUsed: 50,
      customerId: EntityRef(
        'c9',
        AppUser(id: 'c9', fullName: 'Anh Minh', role: UserRole.customer),
      ),
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<CustomerSearchResult>> searchMembers(String query) async {
    searches.add(query);
    return [
      CustomerSearchResult(
        id: 'c1',
        fullName: 'Chị Lan',
        phone: '0909000003',
        points: points,
      ),
    ];
  }

  @override
  Future<int> redeemPoints(
    String customerId, {
    required int points,
    required String rewardName,
    String note = '',
  }) async {
    redeemed.add((customerId, points, rewardName));
    return this.points -= points;
  }

  @override
  Future<List<RewardRedemption>> fetchRedemptions({String? customerId}) async =>
      customerId == null ? storeHistory : const [];
}

void main() {
  testWidgets('Đổi quà: tìm khách, chọn quà gợi ý, trừ điểm', (tester) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          managerRepositoryProvider.overrideWithValue(repo),
          activeStoreProvider.overrideWithValue(const Store(id: 's1')),
        ],
        child: MaterialApp(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          theme: buildAppTheme(),
          home: const Scaffold(body: RewardsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Chưa chọn khách: lịch sử đổi quà gần đây của chi nhánh
    expect(find.text('Đổi quà gần đây tại chi nhánh'), findsOneWidget);
    expect(find.text('Son dưỡng mini'), findsOneWidget);
    expect(find.textContaining('Anh Minh'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '0909');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(repo.searches, ['0909']);
    await tester.tap(find.text('Chị Lan'));
    await tester.pumpAndSettle();
    expect(find.text('120 điểm'), findsOneWidget);

    await tester.tap(find.text('Đổi quà'));
    await tester.pumpAndSettle();

    // Gợi ý quà đã đổi ở chi nhánh điền sẵn tên và điểm
    await tester.tap(find.text('Son dưỡng mini • 50 điểm'));
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('reward-name')))
          .controller!
          .text,
      'Son dưỡng mini',
    );

    // Không cho trừ quá số điểm hiện có
    await tester.enterText(find.byKey(const ValueKey('reward-points')), '121');
    await tester.pump();
    expect(find.text('Từ 1 đến 120 điểm'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Xác nhận đổi quà'),
          )
          .onPressed,
      isNull,
    );

    await tester.enterText(find.byKey(const ValueKey('reward-points')), '50');
    await tester.pump();
    await tester.tap(find.text('Xác nhận đổi quà'));
    await tester.pumpAndSettle();

    expect(repo.redeemed.single, ('c1', 50, 'Son dưỡng mini'));
    expect(find.text('70 điểm'), findsOneWidget);
    expect(find.text('Lịch sử đổi quà của Chị Lan'), findsOneWidget);
  });
}
