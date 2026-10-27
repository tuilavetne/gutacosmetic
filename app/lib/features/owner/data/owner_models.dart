import '../../shared/models/models.dart';

int _int(Object? v) => v is num ? v.toInt() : 0;

Store? _store(Object? v) {
  if (v is! Map) return null;
  try {
    return Store.fromJson(Map<String, dynamic>.from(v));
  } catch (_) {
    return null;
  }
}

/// Doanh thu + số đơn hoàn tất (tách online / tại quầy).
class RevenueTotals {
  const RevenueTotals({
    this.revenue = 0,
    this.onlineRevenue = 0,
    this.offlineRevenue = 0,
    this.orders = 0,
  });

  factory RevenueTotals.fromJson(Object? json) {
    final map = json is Map ? json : const {};
    return RevenueTotals(
      revenue: _int(map['revenue']),
      onlineRevenue: _int(map['onlineRevenue']),
      offlineRevenue: _int(map['offlineRevenue']),
      orders: _int(map['orders']),
    );
  }

  final int revenue;
  final int onlineRevenue;
  final int offlineRevenue;
  final int orders;
}

/// Số cảnh báo kho theo loại.
class StockAlertCounts {
  const StockAlertCounts({
    this.lowStock = 0,
    this.outOfStock = 0,
    this.expiringSoon = 0,
    this.expired = 0,
  });

  factory StockAlertCounts.fromJson(Object? json) {
    final map = json is Map ? json : const {};
    return StockAlertCounts(
      lowStock: _int(map['lowStock']),
      outOfStock: _int(map['outOfStock']),
      expiringSoon: _int(map['expiringSoon']),
      expired: _int(map['expired']),
    );
  }

  final int lowStock;
  final int outOfStock;
  final int expiringSoon;
  final int expired;

  int get total => lowStock + outOfStock + expiringSoon + expired;
}

class DashboardStore {
  const DashboardStore({
    required this.store,
    required this.today,
    required this.month,
    required this.ordersInProgress,
    required this.activeStaff,
    required this.alerts,
  });

  final Store store;
  final RevenueTotals today;
  final RevenueTotals month;
  final int ordersInProgress;
  final int activeStaff;
  final StockAlertCounts alerts;
}

/// `GET /owner/dashboard` — toàn chuỗi.
class OwnerDashboard {
  const OwnerDashboard({
    required this.today,
    required this.month,
    required this.pendingRestock,
    required this.pendingReturns,
    required this.transfersInTransit,
    required this.alerts,
    required this.stores,
  });

  factory OwnerDashboard.fromJson(Map<String, dynamic> json) {
    final pending = json['pending'] is Map ? json['pending'] as Map : const {};
    return OwnerDashboard(
      today: RevenueTotals.fromJson(json['today']),
      month: RevenueTotals.fromJson(json['month']),
      pendingRestock: _int(pending['restockRequests']),
      pendingReturns: _int(pending['returnRequests']),
      transfersInTransit: _int(pending['transfersInTransit']),
      alerts: StockAlertCounts.fromJson(json['alerts']),
      stores: [
        for (final raw
            in (json['stores'] as List? ?? const []).whereType<Map>())
          if (_store(raw['store']) case final store?)
            DashboardStore(
              store: store,
              today: RevenueTotals.fromJson(raw['today']),
              month: RevenueTotals.fromJson(raw['month']),
              ordersInProgress: _int(raw['ordersInProgress']),
              activeStaff: _int(raw['activeStaff']),
              alerts: StockAlertCounts.fromJson(raw['alerts']),
            ),
      ],
    );
  }

  final RevenueTotals today;
  final RevenueTotals month;
  final int pendingRestock;
  final int pendingReturns;
  final int transfersInTransit;
  final StockAlertCounts alerts;
  final List<DashboardStore> stores;
}

/// Một cột của biểu đồ (ngày `yyyy-mm-dd` hoặc tháng `yyyy-mm`).
class RevenueBucket {
  const RevenueBucket({required this.key, required this.totals});

  final String key;
  final RevenueTotals totals;

  bool get isMonth => key.length == 7;

  /// Nhãn ngắn trên trục: `25/10` hoặc `T10/26`.
  String get shortLabel {
    final parts = key.split('-');
    return isMonth
        ? 'T${int.parse(parts[1])}/${parts[0].substring(2)}'
        : '${parts[2]}/${parts[1]}';
  }

  String get longLabel {
    final parts = key.split('-');
    return isMonth
        ? 'Tháng ${int.parse(parts[1])}/${parts[0]}'
        : '${parts[2]}/${parts[1]}/${parts[0]}';
  }
}

class TopProduct {
  const TopProduct({
    required this.name,
    required this.sku,
    required this.quantity,
    required this.revenue,
  });

  final String name;
  final String sku;
  final int quantity;
  final int revenue;
}

/// `GET /owner/analytics/revenue` — chỉ đơn hoàn tất, theo ngày hoàn tất.
class RevenueReport {
  const RevenueReport({
    required this.from,
    required this.to,
    required this.granularity,
    required this.summary,
    required this.averageOrderValue,
    required this.costedRevenue,
    required this.grossProfit,
    required this.missingCostProductCount,
    required this.missingCostProducts,
    required this.series,
    required this.stores,
    required this.topProducts,
  });

  factory RevenueReport.fromJson(Map<String, dynamic> json) {
    final range = json['range'] is Map ? json['range'] as Map : const {};
    final summary = json['summary'] is Map ? json['summary'] as Map : const {};
    return RevenueReport(
      from: '${range['from'] ?? ''}',
      to: '${range['to'] ?? ''}',
      granularity: '${range['granularity'] ?? 'day'}',
      summary: RevenueTotals.fromJson(summary),
      averageOrderValue: _int(summary['averageOrderValue']),
      costedRevenue: _int(summary['costedRevenue']),
      grossProfit: _int(summary['grossProfit']),
      missingCostProductCount: _int(summary['missingCostProductCount']),
      missingCostProducts: [
        for (final name
            in (summary['missingCostProducts'] as List? ?? const []))
          '$name',
      ],
      series: [
        for (final raw
            in (json['series'] as List? ?? const []).whereType<Map>())
          RevenueBucket(
            key: '${raw['key']}',
            totals: RevenueTotals.fromJson(raw),
          ),
      ],
      stores: [
        for (final raw
            in (json['stores'] as List? ?? const []).whereType<Map>())
          if (_store(raw['store']) case final store?)
            (store: store, totals: RevenueTotals.fromJson(raw)),
      ],
      topProducts: [
        for (final raw
            in (json['topProducts'] as List? ?? const []).whereType<Map>())
          TopProduct(
            name: '${raw['name'] ?? ''}',
            sku: '${raw['sku'] ?? ''}',
            quantity: _int(raw['quantity']),
            revenue: _int(raw['revenue']),
          ),
      ],
    );
  }

  final String from;
  final String to;

  /// `day` hoặc `month`.
  final String granularity;
  final RevenueTotals summary;
  final int averageOrderValue;

  /// Doanh thu của các sản phẩm đã có giá vốn (cơ sở tính lợi nhuận gộp).
  final int costedRevenue;
  final int grossProfit;
  final int missingCostProductCount;
  final List<String> missingCostProducts;
  final List<RevenueBucket> series;
  final List<({Store store, RevenueTotals totals})> stores;
  final List<TopProduct> topProducts;
}
