import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../session/session_controller.dart';
import '../../shared/models/models.dart';
import 'home_screen.dart' show customerContentMaxWidth;
import 'widgets/member_avatar.dart';

/// Tab Tài khoản: xem hồ sơ, lối tắt và đăng xuất.
class CustomerAccountScreen extends ConsumerStatefulWidget {
  const CustomerAccountScreen({super.key});

  @override
  ConsumerState<CustomerAccountScreen> createState() =>
      _CustomerAccountScreenState();
}

class _CustomerAccountScreenState extends ConsumerState<CustomerAccountScreen> {
  @override
  void initState() {
    super.initState();
    // Làm mới điểm/hồ sơ khi mở tab; lỗi mạng thì giữ dữ liệu đang có.
    unawaited(_refresh().then<void>((_) {}, onError: (_) {}));
  }

  Future<void> _refresh() =>
      ref.read(sessionControllerProvider.notifier).refreshUser();

  Future<void> _logout() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Đăng xuất',
      message: 'Bạn có chắc muốn đăng xuất khỏi tài khoản này?',
      confirmLabel: 'Đăng xuất',
      destructive: true,
    );
    if (!confirmed) return;
    // Router tự chuyển về màn Đăng nhập khi phiên bị xóa.
    await ref.read(sessionControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: customerContentMaxWidth),
          child: RefreshIndicator(
            onRefresh: () => _refresh().then<void>((_) {}, onError: (_) {}),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                _ProfileHeader(user: user),
                const SizedBox(height: 20),
                const _QuickActions(),
                const SizedBox(height: 24),
                _ProfileCard(
                  user: user,
                  onEdit: () => context.push(AppRoutes.customerEditProfile),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.lock_outline,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      user.authProvider == AuthProvider.google
                          ? 'Mật khẩu đăng nhập'
                          : 'Đổi mật khẩu',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: user.authProvider == AuthProvider.google
                        ? const Text(
                            'Đặt hoặc đổi mật khẩu cho tài khoản Google',
                          )
                        : null,
                    trailing: const Icon(Icons.chevron_right),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    onTap: () => context.push(AppRoutes.customerChangePassword),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: Color(0xFFF3C4CC)),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Đăng xuất'),
                  ),
                ),
                if (user.createdAt != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Thành viên từ ${formatDate(user.createdAt)}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        MemberAvatar(user: user),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chào bạn!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              MemberTierBadge(points: user.points),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = <(IconData, String, VoidCallback)>[
      (
        Icons.favorite_border,
        'Yêu thích',
        () => context.push(AppRoutes.customerWishlist),
      ),
      (
        Icons.receipt_long_outlined,
        'Đơn hàng',
        () => context.go(AppRoutes.customerOrders),
      ),
      (
        Icons.shopping_bag_outlined,
        'Giỏ hàng',
        () => context.push(AppRoutes.customerCart),
      ),
    ];
    return Row(
      children: [
        for (final (i, (icon, label, onTap)) in actions.indexed) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    boxShadow: appSoftShadow,
                  ),
                  child: Column(
                    children: [
                      Icon(icon, color: const Color(0xFFD9475C)),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Thẻ "Hồ sơ cá nhân" chỉ xem; bấm Chỉnh sửa để sang màn sửa.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user, required this.onEdit});

  final AppUser user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = [
      _InfoRow(
        icon: Icons.badge_outlined,
        label: 'Họ và tên',
        value: user.fullName,
      ),
      _InfoRow(
        icon: Icons.mail_outline,
        label: 'Gmail',
        value: user.email,
        trailing: user.emailVerified ? const _VerifiedBadge() : null,
      ),
      _InfoRow(
        icon: Icons.phone_outlined,
        label: 'Số điện thoại',
        value: formatPhone(user.phone),
      ),
      _InfoRow(
        icon: Icons.location_on_outlined,
        label: 'Địa chỉ nhận hàng',
        value: user.address ?? '',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Hồ sơ cá nhân',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Chỉnh sửa'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Card(
          child: Column(
            children: [
              for (final (i, row) in rows.indexed) ...[
                if (i > 0) const Divider(indent: 56),
                row,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final missing = value.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.muted),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  missing ? 'Chưa cập nhật' : value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: missing ? FontWeight.w400 : FontWeight.w600,
                    color: missing ? AppColors.muted : null,
                    fontStyle: missing ? FontStyle.italic : null,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Đã xác thực',
        style: TextStyle(
          color: AppColors.success,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
