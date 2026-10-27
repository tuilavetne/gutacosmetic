import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../shared/models/models.dart';
import '../../data/owner_models.dart';
import '../../data/owner_repository.dart';
import 'revenue_chart.dart';

enum RangePreset {
  today('Hôm nay'),
  last7('7 ngày'),
  last30('30 ngày'),
  thisMonth('Tháng này'),
  custom('Tùy chọn');

  const RangePreset(this.label);
  final String label;
}

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Khoảng ngày (giờ máy) của một mốc chọn nhanh.
DateTimeRange rangeFor(RangePreset preset, DateTime now) {
  final today = DateUtils.dateOnly(now);
  return switch (preset) {
    RangePreset.today => DateTimeRange(start: today, end: today),
    RangePreset.last7 => DateTimeRange(
      start: today.subtract(const Duration(days: 6)),
      end: today,
    ),
    RangePreset.thisMonth => DateTimeRange(
      start: DateTime(today.year, today.month),
      end: today,
    ),
    _ => DateTimeRange(
      start: today.subtract(const Duration(days: 29)),
      end: today,
    ),
  };
}

/// Báo cáo doanh thu: chỉ đơn hoàn tất (theo ngày hoàn tất), lọc theo thời
/// gian và cửa hàng; biểu đồ, so sánh chi nhánh, top sản phẩm, lợi nhuận gộp.
class RevenueScreen extends ConsumerStatefulWidget {
  const RevenueScreen({super.key});

  @override
  ConsumerState<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends ConsumerState<RevenueScreen> {
  RangePreset _preset = RangePreset.last30;
  late DateTimeRange _range = rangeFor(RangePreset.last30, DateTime.now());
  String? _storeId;

  RevenueQuery get _query =>
      (from: dateKey(_range.start), to: dateKey(_range.end), storeId: _storeId);

  Future<void> _selectPreset(RangePreset preset) async {
    if (preset == RangePreset.custom) {
      final today = DateUtils.dateOnly(DateTime.now());
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(today.year - 3),
        lastDate: today,
        initialDateRange: _range,
        helpText: 'Chọn khoảng ngày',
      );
      if (picked == null) return;
      setState(() {
        _preset = preset;
        _range = picked;
      });
      return;
    }
    setState(() {
      _preset = preset;
      _range = rangeFor(preset, DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final stores = ref.watch(ownerStoresProvider).value ?? const <Store>[];
    final reportAsync = ref.watch(ownerRevenueProvider(_query));

    return ColoredBox(
      color: AppColors.background,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Bộ lọc gom một hàng phía trên biểu đồ.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final preset in RangePreset.values)
                    ChoiceChip(
                      label: Text(preset.label),
                      selected: preset == _preset,
                      onSelected: (_) => _selectPreset(preset),
                    ),
                  DropdownButton<String?>(
                    value: _storeId,
                    hint: const Text('Tất cả cửa hàng'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tất cả cửa hàng'),
                      ),
                      for (final store in stores)
                        DropdownMenuItem(
                          value: store.id,
                          child: Text(store.name),
                        ),
                    ],
                    onChanged: (value) => setState(() => _storeId = value),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Từ ${formatDate(_range.start)} đến ${formatDate(_range.end)} • '
                'chỉ tính đơn đã hoàn tất',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              AsyncValueView<RevenueReport>(
                value: reportAsync,
                onRetry: () => ref.invalidate(ownerRevenueProvider(_query)),
                data: (report) => _ReportBody(report: report),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report});

  final RevenueReport report;

  @override
  Widget build(BuildContext context) {
    final s = report.summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _Kpi(label: 'Doanh thu', value: formatVnd(s.revenue)),
            _Kpi(label: 'Đơn hoàn tất', value: '${s.orders}'),
            _Kpi(
              label: 'TB mỗi đơn',
              value: formatVnd(report.averageOrderValue),
            ),
            _Kpi(
              label: 'Lợi nhuận gộp',
              value: report.costedRevenue > 0
                  ? formatVnd(report.grossProfit)
                  : '—',
              hint: report.costedRevenue > 0
                  ? 'trên ${formatVnd(report.costedRevenue)} có giá vốn'
                  : 'chưa có giá vốn',
            ),
          ],
        ),
        if (report.missingCostProductCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '⚠ ${report.missingCostProductCount} sản phẩm đã bán chưa có giá vốn'
              '${report.missingCostProducts.isEmpty ? '' : ' (${report.missingCostProducts.join(', ')})'}'
              ' — lợi nhuận chỉ tính phần có giá vốn. Cập nhật ở tab Sản phẩm.',
              style: const TextStyle(color: AppColors.warning, fontSize: 12),
            ),
          ),
        const SizedBox(height: 16),
        _Panel(
          title: report.granularity == 'month'
              ? 'Doanh thu theo tháng'
              : 'Doanh thu theo ngày',
          child: RevenueChart(series: report.series),
        ),
        const SizedBox(height: 12),
        _Panel(
          title: 'So sánh chi nhánh',
          child: Column(
            children: [
              for (final entry in report.stores)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.store.name),
                  subtitle: Text(
                    '${entry.totals.orders} đơn • tại quầy ${formatVnd(entry.totals.offlineRevenue)}'
                    ' • online ${formatVnd(entry.totals.onlineRevenue)}',
                  ),
                  trailing: Text(
                    formatVnd(entry.totals.revenue),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Panel(
          title: 'Top sản phẩm bán chạy',
          child: report.topProducts.isEmpty
              ? const Text(
                  'Chưa có sản phẩm bán ra trong khoảng này',
                  style: TextStyle(color: AppColors.muted),
                )
              : Column(
                  children: [
                    for (final (index, p) in report.topProducts.indexed)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 13,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(p.name),
                        subtitle: Text('SKU ${p.sku} • ${p.quantity} sp'),
                        trailing: Text(
                          formatVnd(p.revenue),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, this.hint});

  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          if (hint != null)
            Text(
              hint!,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
