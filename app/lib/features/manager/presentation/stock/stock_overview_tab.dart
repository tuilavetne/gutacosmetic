import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../session/session_controller.dart';
import '../../../shared/models/models.dart';
import '../../data/manager_repository.dart';
import 'stock_dialogs.dart';
import 'stock_health.dart';

/// Tồn kho chi nhánh: 3 chỉ số, HSD, cảnh báo; nhập / ghi giảm / sửa HSD.
class StockOverviewTab extends ConsumerStatefulWidget {
  const StockOverviewTab({super.key});

  @override
  ConsumerState<StockOverviewTab> createState() => _StockOverviewTabState();
}

class _StockOverviewTabState extends ConsumerState<StockOverviewTab> {
  /// `null` = tất cả.
  StockFlag? _flag;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final storeId = ref.watch(activeStoreProvider)?.id ?? '';
    final stockAsync = ref.watch(managerStockProvider);

    return AsyncValueView<List<ProductInventory>>(
      value: stockAsync,
      onRetry: () => ref.invalidate(managerStockProvider),
      data: (items) {
        final rows = stockRowsFor(items, storeId);
        final now = DateTime.now();
        final counts = {
          for (final flag in StockFlag.values)
            flag: rows.where((r) => r.stock.flags(now).contains(flag)).length,
        };
        final q = _query.toLowerCase();
        final visible =
            rows
                .where(
                  (r) =>
                      (_flag == null || r.stock.flags(now).contains(_flag)) &&
                      (q.isEmpty ||
                          r.product.name.toLowerCase().contains(q) ||
                          r.product.sku.toLowerCase().contains(q)),
                )
                .toList()
              // Có cảnh báo lên trước, rồi khả dụng tăng dần.
              ..sort((a, b) {
                final byFlag = (b.stock.flags(now).isNotEmpty ? 1 : 0)
                    .compareTo(a.stock.flags(now).isNotEmpty ? 1 : 0);
                return byFlag != 0
                    ? byFlag
                    : a.stock.availableStock.compareTo(b.stock.availableStock);
              });

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Tìm sản phẩm theo tên hoặc SKU',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setState(() => _query = v.trim()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Nhập kho'),
                    onPressed: () => ReceiptDialog.show(context, rows: rows),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                children: [
                  _chip('Tất cả (${rows.length})', _flag == null, () {
                    setState(() => _flag = null);
                  }),
                  for (final flag in StockFlag.values)
                    _chip(
                      '${flag.label} (${counts[flag]})',
                      _flag == flag,
                      () => setState(() => _flag = flag),
                      color: counts[flag]! > 0 ? flag.color : null,
                    ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.refresh(managerStockProvider.future),
                child: visible.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 60),
                          EmptyState(
                            icon: Icons.inventory_2_outlined,
                            message: 'Không có sản phẩm phù hợp',
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) => _StockCard(
                          row: visible[index],
                          rows: rows,
                          now: now,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _chip(
    String label,
    bool selected,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : (color ?? AppColors.ink),
          fontWeight: selected || color != null
              ? FontWeight.bold
              : FontWeight.w500,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

enum _StockAction { receive, adjust, expiry }

class _StockCard extends StatelessWidget {
  const _StockCard({required this.row, required this.rows, required this.now});

  final StockRow row;
  final List<StockRow> rows;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final stock = row.stock;
    final flags = stock.flags(now);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: flags.isEmpty
              ? AppColors.border
              : flags.first.color.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'SKU ${row.product.sku}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _Metric('Tổng', stock.totalStock),
                      _Metric('Đang giữ', stock.reservedStock),
                      _Metric(
                        'Khả dụng',
                        stock.availableStock,
                        color:
                            flags.contains(StockFlag.outOfStock) ||
                                flags.contains(StockFlag.lowStock)
                            ? flags.first.color
                            : AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        stock.expiryDate == null
                            ? 'HSD: chưa theo dõi'
                            : 'HSD: ${formatDate(stock.expiryDate)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      for (final flag in flags)
                        StatusChip(label: flag.label, color: flag.color),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<_StockAction>(
              tooltip: 'Thao tác',
              onSelected: (action) => switch (action) {
                _StockAction.receive => ReceiptDialog.show(
                  context,
                  rows: rows,
                  initial: row,
                ),
                _StockAction.adjust => AdjustmentDialog.show(
                  context,
                  rows: rows,
                  initial: row,
                ),
                _StockAction.expiry => ExpiryDialog.show(context, row),
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: _StockAction.receive,
                  child: Text('Nhập hàng'),
                ),
                PopupMenuItem(
                  value: _StockAction.adjust,
                  child: Text('Ghi giảm (hỏng/lỗi/hết hạn)'),
                ),
                PopupMenuItem(
                  value: _StockAction.expiry,
                  child: Text('Sửa hạn sử dụng'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, {this.color});

  final String label;
  final int value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          TextSpan(
            text: '$value',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
