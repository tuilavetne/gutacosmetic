// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RevenueSummary _$RevenueSummaryFromJson(Map<String, dynamic> json) =>
    _RevenueSummary(
      paidRevenue: json['paidRevenue'] as num? ?? 0,
      monthlyRevenue: json['monthlyRevenue'] as num? ?? 0,
      grossProfit: json['grossProfit'] as num? ?? 0,
      monthlyGrossProfit: json['monthlyGrossProfit'] as num? ?? 0,
      estimatedNetProfit: json['estimatedNetProfit'] as num? ?? 0,
      soldCost: json['soldCost'] as num? ?? 0,
      writeOffCost: json['writeOffCost'] as num? ?? 0,
      stockInCost: json['stockInCost'] as num? ?? 0,
      inventoryValue: json['inventoryValue'] as num? ?? 0,
      paidOrders: (json['paidOrders'] as num?)?.toInt() ?? 0,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      averageOrderValue: json['averageOrderValue'] as num? ?? 0,
      missingCostProductCount:
          (json['missingCostProductCount'] as num?)?.toInt() ?? 0,
      missingCostProducts:
          (json['missingCostProducts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$RevenueSummaryToJson(_RevenueSummary instance) =>
    <String, dynamic>{
      'paidRevenue': instance.paidRevenue,
      'monthlyRevenue': instance.monthlyRevenue,
      'grossProfit': instance.grossProfit,
      'monthlyGrossProfit': instance.monthlyGrossProfit,
      'estimatedNetProfit': instance.estimatedNetProfit,
      'soldCost': instance.soldCost,
      'writeOffCost': instance.writeOffCost,
      'stockInCost': instance.stockInCost,
      'inventoryValue': instance.inventoryValue,
      'paidOrders': instance.paidOrders,
      'totalOrders': instance.totalOrders,
      'averageOrderValue': instance.averageOrderValue,
      'missingCostProductCount': instance.missingCostProductCount,
      'missingCostProducts': instance.missingCostProducts,
    };

_StoreRevenue _$StoreRevenueFromJson(Map<String, dynamic> json) =>
    _StoreRevenue(
      store: _$JsonConverterFromJson<Object, EntityRef<Store>>(
        json['store'],
        const StoreRefConverter().fromJson,
      ),
      orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
      paidOrderCount: (json['paidOrderCount'] as num?)?.toInt() ?? 0,
      revenue: json['revenue'] as num? ?? 0,
      onlineRevenue: json['onlineRevenue'] as num? ?? 0,
      offlineRevenue: json['offlineRevenue'] as num? ?? 0,
      soldCost: json['soldCost'] as num? ?? 0,
      grossProfit: json['grossProfit'] as num? ?? 0,
      writeOffCost: json['writeOffCost'] as num? ?? 0,
      stockInCost: json['stockInCost'] as num? ?? 0,
      estimatedNetProfit: json['estimatedNetProfit'] as num? ?? 0,
      inventoryValue: json['inventoryValue'] as num? ?? 0,
      totalStockUnits: (json['totalStockUnits'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$StoreRevenueToJson(_StoreRevenue instance) =>
    <String, dynamic>{
      'store': ?_$JsonConverterToJson<Object, EntityRef<Store>>(
        instance.store,
        const StoreRefConverter().toJson,
      ),
      'orderCount': instance.orderCount,
      'paidOrderCount': instance.paidOrderCount,
      'revenue': instance.revenue,
      'onlineRevenue': instance.onlineRevenue,
      'offlineRevenue': instance.offlineRevenue,
      'soldCost': instance.soldCost,
      'grossProfit': instance.grossProfit,
      'writeOffCost': instance.writeOffCost,
      'stockInCost': instance.stockInCost,
      'estimatedNetProfit': instance.estimatedNetProfit,
      'inventoryValue': instance.inventoryValue,
      'totalStockUnits': instance.totalStockUnits,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_RevenueAnalytics _$RevenueAnalyticsFromJson(Map<String, dynamic> json) =>
    _RevenueAnalytics(
      summary: json['summary'] == null
          ? const RevenueSummary()
          : RevenueSummary.fromJson(json['summary'] as Map<String, dynamic>),
      stores:
          (json['stores'] as List<dynamic>?)
              ?.map((e) => StoreRevenue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <StoreRevenue>[],
    );

Map<String, dynamic> _$RevenueAnalyticsToJson(_RevenueAnalytics instance) =>
    <String, dynamic>{
      'summary': instance.summary.toJson(),
      'stores': instance.stores.map((e) => e.toJson()).toList(),
    };
