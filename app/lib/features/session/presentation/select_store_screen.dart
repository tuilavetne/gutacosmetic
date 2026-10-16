import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/state_views.dart';
import '../../shared/data/store_repository.dart';
import '../../shared/models/models.dart';
import '../session_controller.dart';

/// MANAGER/SALES chọn chi nhánh làm việc. Từ đó mọi request gửi kèm
/// `X-Active-Store-Id`.
class SelectStoreScreen extends ConsumerStatefulWidget {
  const SelectStoreScreen({super.key});

  @override
  ConsumerState<SelectStoreScreen> createState() => _SelectStoreScreenState();
}

class _SelectStoreScreenState extends ConsumerState<SelectStoreScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    final session = ref.read(sessionControllerProvider);
    // Mặc định: chi nhánh đang làm, nếu chưa có thì chi nhánh được phân công.
    _selectedId = session.activeStore?.id ?? session.user?.storeId?.id;
  }

  Future<void> _confirm(List<Store> stores) async {
    final store = stores.where((s) => s.id == _selectedId).firstOrNull;
    if (store == null) return;
    final role = ref.read(sessionControllerProvider).role;
    await ref.read(sessionControllerProvider.notifier).setActiveStore(store);
    if (mounted && role != null) context.go(AppRoutes.homeFor(role));
  }

  Future<void> _logout() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Đăng xuất',
      message: 'Bạn có chắc muốn đăng xuất?',
      confirmLabel: 'Đăng xuất',
    );
    if (ok) await ref.read(sessionControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final user = session.user;
    final storesAsync = ref.watch(activeStoresProvider);
    final hasActiveStore = session.activeStore != null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: hasActiveStore && user != null
            ? IconButton(
                tooltip: 'Quay lại',
                icon: const Icon(Icons.close),
                onPressed: () => context.go(AppRoutes.homeFor(user.role)),
              )
            : null,
        title: const Text('Chọn chi nhánh'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                'Xin chào ${user.displayName} (${user.role.label}). '
                'Chọn chi nhánh bạn đang làm việc hôm nay.',
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
          Expanded(
            child: AsyncValueView<List<Store>>(
              value: storesAsync,
              onRetry: () => ref.invalidate(activeStoresProvider),
              data: (stores) {
                if (stores.isEmpty) {
                  return RefreshableFill(
                    onRefresh: () => ref.refresh(activeStoresProvider.future),
                    child: const EmptyState(
                      icon: Icons.store_mall_directory_outlined,
                      message: 'Chưa có chi nhánh nào đang hoạt động',
                      hint: 'Liên hệ Owner để mở chi nhánh.',
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(activeStoresProvider.future),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: stores.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final store = stores[i];
                      return _StoreCard(
                        store: store,
                        selected: store.id == _selectedId,
                        isAssigned: store.id == user?.storeId?.id,
                        isCurrent: store.id == session.activeStore?.id,
                        onTap: () => setState(() => _selectedId = store.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: AppButton(
                label: 'Xác nhận',
                icon: Icons.check,
                onPressed:
                    _selectedId == null ||
                        !(storesAsync.value ?? const <Store>[]).any(
                          (s) => s.id == _selectedId,
                        )
                    ? null
                    : () => _confirm(storesAsync.value!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.store,
    required this.selected,
    required this.isAssigned,
    required this.isCurrent,
    required this.onTap,
  });

  final Store store;
  final bool selected;
  final bool isAssigned;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.06)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  store.isCentral ? Icons.warehouse_outlined : Icons.storefront,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _Tag(store.type.label, AppColors.muted),
                        if (isAssigned)
                          const _Tag('Được phân công', AppColors.info),
                        if (isCurrent)
                          const _Tag('Đang làm việc', AppColors.success),
                      ],
                    ),
                    if (store.address.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _InfoLine(Icons.place_outlined, store.address),
                    ],
                    if (store.phone.isNotEmpty)
                      _InfoLine(Icons.call_outlined, store.phone),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.muted),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
