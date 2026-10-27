import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/owner_models.dart';

/// Màu theo thứ tự cố định của bảng màu chuẩn (đã kiểm tra tương phản và
/// mù màu trên nền trắng): tại quầy = slot 1, online = slot 2.
const offlineColor = Color(0xFF2A78D6);
const onlineColor = Color(0xFFEB6834);

/// `1.250.000` -> `1,3tr`; `850.000` -> `850k`.
String compactVnd(int value) {
  if (value >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(1).replaceAll('.', ',')} tỷ';
  }
  if (value >= 1000000) {
    final text = (value / 1000000).toStringAsFixed(value >= 10000000 ? 0 : 1);
    return '${text.replaceAll('.', ',').replaceAll(',0', '')}tr';
  }
  if (value >= 1000) return '${(value / 1000).round()}k';
  return '$value';
}

/// Mức trần trục tung "tròn" (1/2/5 × 10^n) để vạch lưới dễ đọc.
int _niceMax(int value) {
  if (value <= 0) return 1;
  final magnitude = math.pow(10, (math.log(value) / math.ln10).floor()).toInt();
  for (final step in [1, 2, 5, 10]) {
    if (step * magnitude >= value) return step * magnitude;
  }
  return 10 * magnitude;
}

/// Biểu đồ cột chồng doanh thu theo ngày/tháng: tại quầy (dưới) + online
/// (trên). Chạm/rê chuột lên cột để xem chi tiết; có chế độ xem dạng bảng.
class RevenueChart extends StatefulWidget {
  const RevenueChart({super.key, required this.series});

  final List<RevenueBucket> series;

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  int? _selected;
  bool _table = false;

  static const _chartHeight = 200.0;
  static const _axisWidth = 44.0;

  @override
  void didUpdateWidget(covariant RevenueChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.series != widget.series) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final series = widget.series;
    final selected = _selected == null ? null : series[_selected!];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const _LegendItem(color: offlineColor, label: 'Tại quầy'),
            const SizedBox(width: 16),
            const _LegendItem(color: onlineColor, label: 'Online'),
            const Spacer(),
            TextButton.icon(
              icon: Icon(
                _table ? Icons.bar_chart : Icons.table_rows_outlined,
                size: 18,
              ),
              label: Text(_table ? 'Xem biểu đồ' : 'Xem dạng bảng'),
              onPressed: () => setState(() => _table = !_table),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_table)
          _RevenueTable(series: series)
        else ...[
          SizedBox(
            height: 44,
            child: selected == null
                ? const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Chạm vào một cột để xem chi tiết',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  )
                : _Tooltip(bucket: selected),
          ),
          _buildChart(series),
        ],
      ],
    );
  }

  Widget _buildChart(List<RevenueBucket> series) {
    final maxRevenue = series.fold<int>(
      0,
      (m, b) => math.max(m, b.totals.revenue),
    );
    final top = _niceMax(maxRevenue);
    // Giãn nhãn trục hoành để không chồng nhau (tối đa ~8 nhãn).
    final labelEvery = math.max(1, (series.length / 8).ceil());

    return SizedBox(
      height: _chartHeight + 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _axisWidth,
            height: _chartHeight,
            child: Stack(
              children: [
                for (var i = 0; i <= 4; i++)
                  Positioned(
                    right: 6,
                    top: _chartHeight * (1 - i / 4) - 7,
                    child: Text(
                      compactVnd((top * i / 4).round()),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final slot = constraints.maxWidth / math.max(1, series.length);
                final barWidth = (slot * 0.62).clamp(3.0, 28.0);
                return Column(
                  children: [
                    SizedBox(
                      height: _chartHeight,
                      child: Stack(
                        children: [
                          // Lưới ngang mờ
                          for (var i = 0; i <= 4; i++)
                            Positioned(
                              left: 0,
                              right: 0,
                              top: _chartHeight * (1 - i / 4),
                              child: Container(
                                height: 1,
                                color: i == 0
                                    ? AppColors.border
                                    : AppColors.border.withValues(alpha: 0.5),
                              ),
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (var i = 0; i < series.length; i++)
                                SizedBox(
                                  width: slot,
                                  height: _chartHeight,
                                  child: MouseRegion(
                                    onEnter: (_) =>
                                        setState(() => _selected = i),
                                    child: GestureDetector(
                                      key: ValueKey('bar-${series[i].key}'),
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () =>
                                          setState(() => _selected = i),
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: _Bar(
                                          totals: series[i].totals,
                                          top: top,
                                          width: barWidth,
                                          highlighted:
                                              _selected == null ||
                                              _selected == i,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 24,
                      child: Row(
                        children: [
                          for (var i = 0; i < series.length; i++)
                            SizedBox(
                              width: slot,
                              child: i % labelEvery == 0
                                  ? OverflowBox(
                                      // Ít cột thì ô rộng hơn 60 — giữ ràng buộc hợp lệ.
                                      minWidth: 0,
                                      maxWidth: math.max(60, slot),
                                      child: Text(
                                        series[i].shortLabel,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.totals,
    required this.top,
    required this.width,
    required this.highlighted,
  });

  final RevenueTotals totals;
  final int top;
  final double width;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    double h(int value) => value <= 0
        ? 0
        : math.max(2, _RevenueChartState._chartHeight * value / top);
    final offline = h(totals.offlineRevenue);
    final online = h(totals.onlineRevenue);
    final opacity = highlighted ? 1.0 : 0.45;
    const radius = Radius.circular(4);

    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (online > 0)
            Container(
              width: width,
              height: online,
              decoration: const BoxDecoration(
                color: onlineColor,
                borderRadius: BorderRadius.vertical(top: radius),
              ),
            ),
          // Khe 2px giữa hai phần của cột chồng.
          if (online > 0 && offline > 0) const SizedBox(height: 2),
          if (offline > 0)
            Container(
              width: width,
              height: offline,
              decoration: BoxDecoration(
                color: offlineColor,
                borderRadius: online > 0
                    ? null
                    : const BorderRadius.vertical(top: radius),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tooltip extends StatelessWidget {
  const _Tooltip({required this.bucket});

  final RevenueBucket bucket;

  @override
  Widget build(BuildContext context) {
    final t = bucket.totals;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 12, color: AppColors.ink),
          children: [
            TextSpan(
              text:
                  '${bucket.longLabel}: ${formatVnd(t.revenue)} (${t.orders} đơn)\n',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const WidgetSpan(child: _Swatch(offlineColor)),
            TextSpan(text: ' Tại quầy ${formatVnd(t.offlineRevenue)}   '),
            const WidgetSpan(child: _Swatch(onlineColor)),
            TextSpan(text: ' Online ${formatVnd(t.onlineRevenue)}'),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _Swatch(color),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}

/// Bảng số liệu thay cho biểu đồ (đọc chính xác, không phụ thuộc màu).
class _RevenueTable extends StatelessWidget {
  const _RevenueTable({required this.series});

  final List<RevenueBucket> series;

  @override
  Widget build(BuildContext context) {
    const head = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    const cell = TextStyle(fontSize: 12);
    final rows = series.where((b) => b.totals.orders > 0).toList();
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Không có doanh thu trong khoảng này',
          textAlign: TextAlign.center,
        ),
      );
    }
    return Table(
      columnWidths: const {0: FlexColumnWidth(1.2)},
      children: [
        const TableRow(
          children: [
            Text('Thời gian', style: head),
            Text('Tại quầy', style: head, textAlign: TextAlign.right),
            Text('Online', style: head, textAlign: TextAlign.right),
            Text('Tổng', style: head, textAlign: TextAlign.right),
            Text('Đơn', style: head, textAlign: TextAlign.right),
          ],
        ),
        for (final b in rows)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(b.longLabel, style: cell),
              ),
              Text(
                formatVnd(b.totals.offlineRevenue),
                style: cell,
                textAlign: TextAlign.right,
              ),
              Text(
                formatVnd(b.totals.onlineRevenue),
                style: cell,
                textAlign: TextAlign.right,
              ),
              Text(
                formatVnd(b.totals.revenue),
                style: cell,
                textAlign: TextAlign.right,
              ),
              Text(
                '${b.totals.orders}',
                style: cell,
                textAlign: TextAlign.right,
              ),
            ],
          ),
      ],
    );
  }
}
