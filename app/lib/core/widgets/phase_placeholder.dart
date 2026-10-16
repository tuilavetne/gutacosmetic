import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/routes.dart';
import '../../features/session/session_controller.dart';
import 'state_views.dart';

/// Màn tạm cho các route sẽ hoàn thiện ở giai đoạn sau. Vẫn có Đăng xuất và
/// Đổi chi nhánh để kiểm tra router.
class PhasePlaceholder extends ConsumerWidget {
  const PhasePlaceholder({
    super.key,
    required this.title,
    this.phase,
    this.message,
  });

  final String title;
  final int? phase;
  final String? message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final user = session.user;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (session.isStaff)
            IconButton(
              tooltip: 'Đổi chi nhánh',
              icon: const Icon(Icons.storefront_outlined),
              onPressed: () => context.go(AppRoutes.selectStore),
            ),
          if (user != null)
            IconButton(
              tooltip: 'Đăng xuất',
              icon: const Icon(Icons.logout),
              onPressed: () =>
                  ref.read(sessionControllerProvider.notifier).signOut(),
            ),
        ],
      ),
      body: EmptyState(
        icon: Icons.construction_outlined,
        message:
            message ??
            'Màn hình "$title" sẽ được hoàn thiện ở giai đoạn $phase.',
        hint: user == null
            ? null
            : '${user.displayName} · ${user.role.label}'
                  '${session.activeStore == null ? '' : ' · ${session.activeStore!.name}'}',
      ),
    );
  }
}
