import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../shared/models/models.dart';
import '../../shared/presentation/restock_request_details.dart';
import '../data/sales_repository.dart';
import 'widgets/restock_request_dialog.dart';

/// Tab "Kho" của Sales: xem cảnh báo tồn kho và đề xuất bổ sung hàng.
/// Sales chỉ xem và đề xuất — việc nhận hàng/hủy đề xuất do Manager quyết định.
class SalesStockScreen extends StatelessWidget {
  const SalesStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ColoredBox(
        color: AppColors.background,
        child: Column(
          children: [
            const ColoredBox(
              color: Colors.white,
              child: TabBar(
                labelColor: AppColors.primary,
                indicatorColor: AppColors.primary,
                unselectedLabelColor: AppColors.muted,
                tabs: [
                  Tab(text: 'Cảnh báo tồn kho'),
                  Tab(text: 'Đề xuất của chi nhánh'),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: const TabBarView(
                    children: [_AlertsTab(), _RestockRequestsTab()],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cảnh báo tồn kho
// ---------------------------------------------------------------------------

enum _AlertFilter {
  all('Tất cả'),
  stock('Tồn thấp / hết hàng'),
  expiry('Hạn sử dụng');

  const _AlertFilter(this.label);
  final String label;

  bool matches(InventoryAlert alert) => switch (this) {
    all => true,
    stock => !alert.type.isExpiry,
    expiry => alert.type.isExpiry,
  };
}

class _AlertsTab extends ConsumerStatefulWidget {
  const _AlertsTab();

  @override
  ConsumerState<_AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends ConsumerState<_AlertsTab> {
  _AlertFilter _filter = _AlertFilter.all;

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(salesInventoryAlertsProvider);
    // Đề xuất đang xử lý theo sản phẩm (chờ Manager / chờ Owner / đang chuyển
    // hàng), để hiện "đã đề xuất" trên từng cảnh báo.
    final openRequests = <String, RestockRequest>{};
    for (final request
        in ref.watch(salesRestockRequestsProvider(null)).value ??
            const <RestockRequest>[]) {
      final productId = request.productId?.id;
      if (productId != null && request.status.isActive) {
        openRequests.putIfAbsent(productId, () => request);
      }
    }

    return Column(
      children: [
        _FilterChips<_AlertFilter>(
          values: _AlertFilter.values,
          selected: _filter,
          labelOf: (f) => f.label,
          onSelected: (f) => setState(() => _filter = f),
        ),
        Expanded(
          child: AsyncValueView<List<InventoryAlert>>(
            value: alertsAsync,
            onRetry: () => ref.invalidate(salesInventoryAlertsProvider),
            data: (alerts) {
              final visible = alerts.where(_filter.matches).toList();
              return RefreshIndicator(
                onRefresh: () {
                  ref.invalidate(salesRestockRequestsProvider);
                  return ref.refresh(salesInventoryAlertsProvider.future);
                },
                child: visible.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 80),
                          EmptyState(
                            icon: Icons.verified_outlined,
                            message: 'Không có cảnh báo tồn kho',
                            hint: 'Hàng tại chi nhánh đang ở mức an toàn.',
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final alert = visible[index];
                          return _AlertCard(
                            alert: alert,
                            openRequest: openRequests[alert.product?.id],
                          );
                        },
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert, this.openRequest});

  final InventoryAlert alert;
  final RestockRequest? openRequest;

  @override
  Widget build(BuildContext context) {
    final product = alert.product?.data;
    final productName = product?.name ?? 'Sản phẩm';
    final color = alert.isCritical ? AppColors.accent : AppColors.warning;
    final canRequestRestock =
        alert.type == InventoryAlertType.lowStock && alert.product != null;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  alert.type.isExpiry
                      ? Icons.event_busy_outlined
                      : Icons.inventory_2_outlined,
                  color: color,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((product?.sku ?? '').isNotEmpty)
                        Text(
                          'SKU: ${product!.sku}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusChip(label: alert.type.label, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(alert.message, style: TextStyle(color: color, fontSize: 13)),
            const SizedBox(height: 6),
            Text(
              'Khả dụng: ${alert.availableStock} • Đang giữ: '
              '${alert.reservedStock} • Tổng: ${alert.totalStock}'
              '${alert.expiryDate != null ? ' • HSD: ${formatDate(alert.expiryDate)}' : ''}',
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            if (canRequestRestock) ...[
              const Divider(height: 20),
              Row(
                children: [
                  if (openRequest != null)
                    Expanded(
                      child: Text(
                        'Đã đề xuất ${openRequest!.requestedQuantity} sp • '
                        '${openRequest!.status.label}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 8),
                  // Chỉ sửa được khi Manager chưa chuyển lên Owner.
                  if (openRequest?.status == RestockStatus.open)
                    TextButton(
                      onPressed: () => _requestRestock(context),
                      child: const Text('Cập nhật đề xuất'),
                    )
                  else if (openRequest == null)
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.add_box_outlined, size: 18),
                      label: const Text('Đề xuất bổ sung'),
                      onPressed: () => _requestRestock(context),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _requestRestock(BuildContext context) {
    RestockRequestDialog.show(
      context,
      productId: alert.product!.id,
      productName: alert.product?.data?.name ?? 'Sản phẩm',
      availableStock: alert.availableStock,
      pendingQuantity: openRequest?.requestedQuantity,
    );
  }
}

// ---------------------------------------------------------------------------
// Đề xuất bổ sung hàng
// ---------------------------------------------------------------------------

class _RestockRequestsTab extends ConsumerStatefulWidget {
  const _RestockRequestsTab();

  @override
  ConsumerState<_RestockRequestsTab> createState() =>
      _RestockRequestsTabState();
}

class _RestockRequestsTabState extends ConsumerState<_RestockRequestsTab> {
  /// `null` = tất cả trạng thái.
  RestockStatus? _status;

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(salesRestockRequestsProvider(_status));

    return Column(
      children: [
        _FilterChips<RestockStatus?>(
          values: const [null, ...RestockStatus.values],
          selected: _status,
          labelOf: (s) => s?.label ?? 'Tất cả',
          onSelected: (s) => setState(() => _status = s),
        ),
        Expanded(
          child: AsyncValueView<List<RestockRequest>>(
            value: requestsAsync,
            onRetry: () =>
                ref.invalidate(salesRestockRequestsProvider(_status)),
            data: (requests) => RefreshIndicator(
              onRefresh: () =>
                  ref.refresh(salesRestockRequestsProvider(_status).future),
              child: requests.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 80),
                        EmptyState(
                          icon: Icons.assignment_outlined,
                          message: 'Chưa có đề xuất bổ sung nào',
                          hint: 'Đề xuất từ tab "Cảnh báo tồn kho" khi hàng sắp hết.',
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          RestockRequestCard(request: requests[index]),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _FilterChips<T> extends StatelessWidget {
  const _FilterChips({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          for (final value in values) ...[
            ChoiceChip(
              label: Text(labelOf(value)),
              selected: value == selected,
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: value == selected ? Colors.white : AppColors.ink,
                fontWeight: value == selected
                    ? FontWeight.bold
                    : FontWeight.w500,
                fontSize: 13,
              ),
              onSelected: (_) => onSelected(value),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
