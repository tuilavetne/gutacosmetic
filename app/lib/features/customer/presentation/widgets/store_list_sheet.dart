import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../shared/data/store_repository.dart';
import '../../../shared/models/models.dart';

/// Danh sách chi nhánh đang mở cửa (không gồm kho tổng); bấm số để gọi.
Future<void> showStoreListSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _StoreListSheet(),
  );
}

class _StoreListSheet extends ConsumerWidget {
  const _StoreListSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final storesAsync = ref.watch(activeStoresProvider);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Hệ thống cửa hàng',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: AsyncValueView<List<Store>>(
              value: storesAsync,
              onRetry: () => ref.invalidate(activeStoresProvider),
              data: (stores) {
                final branches = stores.where((s) => !s.isCentral).toList();
                if (branches.isEmpty) {
                  return const EmptyState(
                    icon: Icons.storefront_outlined,
                    message: 'Chưa có cửa hàng nào đang mở',
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: branches.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _StoreTile(branches[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreTile extends StatelessWidget {
  const _StoreTile(this.store);

  final Store store;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.storefront, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (store.address.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      store.address,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (store.phone.isNotEmpty)
              IconButton(
                tooltip: 'Gọi ${store.phone}',
                onPressed: () =>
                    launchUrl(Uri(scheme: 'tel', path: store.phone)),
                icon: const Icon(Icons.call_outlined, color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
