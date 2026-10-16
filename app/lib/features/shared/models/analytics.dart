import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';
import 'store.dart';

part 'analytics.freezed.dart';
part 'analytics.g.dart';

// Khớp `getRevenueAnalytics` trong backend/modules/owner/services/ownerService.js.
// Số liệu tài chính có thể là số thực (ví dụ averageOrderValue) → dùng `num`.

@freezed
abstract class RevenueSummary with _$RevenueSummary {
  const factory RevenueSummary({
    @Default(0) num paidRevenue,
    @Default(0) num monthlyRevenue,
    @Default(0) num grossProfit,
    @Default(0) num monthlyGrossProfit,
    @Default(0) num estimatedNetProfit,
    @Default(0) num soldCost,
    @Default(0) num writeOffCost,
    @Default(0) num stockInCost,
    @Default(0) num inventoryValue,
    @Default(0) int paidOrders,
    @Default(0) int totalOrders,
    @Default(0) num averageOrderValue,
    @Default(0) int missingCostProductCount,

    /// Tên (tối đa 5) sản phẩm chưa có giá vốn.
    @Default(<String>[]) List<String> missingCostProducts,
  }) = _RevenueSummary;

  factory RevenueSummary.fromJson(Map<String, dynamic> json) =>
      _$RevenueSummaryFromJson(json);
}

/// Một dòng trong bảng doanh thu theo cửa hàng.
@freezed
abstract class StoreRevenue with _$StoreRevenue {
  const StoreRevenue._();

  const factory StoreRevenue({
    @StoreRefConverter() EntityRef<Store>? store,
    @Default(0) int orderCount,
    @Default(0) int paidOrderCount,

    /// Doanh thu đã thu (tổng online + offline).
    @Default(0) num revenue,
    @Default(0) num onlineRevenue,
    @Default(0) num offlineRevenue,
    @Default(0) num soldCost,
    @Default(0) num grossProfit,
    @Default(0) num writeOffCost,
    @Default(0) num stockInCost,
    @Default(0) num estimatedNetProfit,
    @Default(0) num inventoryValue,
    @Default(0) int totalStockUnits,
  }) = _StoreRevenue;

  factory StoreRevenue.fromJson(Map<String, dynamic> json) =>
      _$StoreRevenueFromJson(json);

  String get displayName => store?.data?.name ?? 'Cửa hàng';
}

@freezed
abstract class RevenueAnalytics with _$RevenueAnalytics {
  const factory RevenueAnalytics({
    @Default(RevenueSummary()) RevenueSummary summary,
    @Default(<StoreRevenue>[]) List<StoreRevenue> stores,
  }) = _RevenueAnalytics;

  factory RevenueAnalytics.fromJson(Map<String, dynamic> json) =>
      _$RevenueAnalyticsFromJson(json);
}
