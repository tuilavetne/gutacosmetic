import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../session/session_controller.dart';
import '../../data/manager_repository.dart';
import '../../data/stock_history.dart';
import 'stock_dialogs.dart';
import 'stock_health.dart';

/// Lịch sử kho: nhập, ghi giảm, trả hàng lỗi gộp một dòng thời gian; lọc
/// theo loại và theo sản phẩm. Hàng bán ra theo đơn không nằm ở đây.
class StockHistoryTab extends ConsumerStatefulWidget {
  const StockHistoryTab({super.key});

  @override
  ConsumerState<StockHistoryTab> createState() => _StockHistoryTabState();
}

class _StockHistoryTabState extends ConsumerState<StockHistoryTab> {
  StockHistoryType? _type;
  StockRow? _product;

  StockHistoryQuery get _query =>
      (type: _type, productId: _product?.product.id);

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(managerStockHistoryProvider(_query));
    final rows = stockRowsFor(
      ref.watch(managerStockProvider).value ?? const [],
      ref.watch(activeStoreProvider)?.id ?? '',
    );

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              for (final type in [null, ...StockHistoryType.values])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type?.label ?? 'Tất cả'),
                    selected: type == _type,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: type == _type ? Colors.white : AppColors.ink,
                    ),
                    onSelected: (_) => setState(() => _type = type),
                  ),
                ),
              _product == null
                  ? ActionChip(
                      avatar: const Icon(Icons.filter_alt_outlined, size: 18),
                      label: const Text('Lọc theo sản phẩm'),
                      onPressed: () async {
                        final picked = await pickStockRow(context, rows);
                        if (picked != null) setState(() => _product = picked);
                      },
                    )
                  : InputChip(
                      label: Text(_product!.product.name),
                      onDeleted: () => setState(() => _product = null),
                    ),
            ],
          ),
        ),
        Expanded(
          child: AsyncValueView<List<StockHistoryEntry>>(
            value: historyAsync,
            onRetry: () => ref.invalidate(managerStockHistoryProvider(_query)),
            data: (entries) => RefreshIndicator(
              onRefresh: () =>
                  ref.refresh(managerStockHistoryProvider(_query).future),
              child: entries.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 60),
                        EmptyState(
                          icon: Icons.history,
                          message: 'Chưa có lịch sử kho phù hợp',
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: entries.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, index) =>
                          _HistoryTile(entry: entries[index]),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final StockHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (entry.type) {
      StockHistoryType.receipt => (
        Icons.move_to_inbox_outlined,
        AppColors.success,
      ),
      StockHistoryType.adjustment => (
        Icons.remove_circle_outline,
        AppColors.accent,
      ),
      StockHistoryType.returnRequest => (
        Icons.assignment_return_outlined,
        AppColors.warning,
      ),
    };
    final change = entry.totalChange != 0
        ? '${entry.totalChange > 0 ? '+' : ''}${entry.totalChange}'
        : entry.lockedChange > 0
        ? 'khóa ${entry.lockedChange}'
        : entry.lockedChange < 0
        ? 'mở ${-entry.lockedChange}'
        : '0';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        entry.productName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        [
          entry.eventLabel,
          if (entry.expiryDate != null) 'HSD ${formatDate(entry.expiryDate)}',
          if (entry.note.isNotEmpty) entry.note,
          [formatDateTime(entry.at), ?entry.actorName].join(' • '),
        ].join('\n'),
        style: const TextStyle(fontSize: 12),
      ),
      isThreeLine: true,
      trailing: Text(
        change,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: color,
        ),
      ),
    );
  }
}
