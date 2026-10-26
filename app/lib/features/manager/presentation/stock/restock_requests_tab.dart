import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../session/session_controller.dart';
import '../../../shared/models/models.dart';
import '../../data/manager_repository.dart';
import 'stock_dialogs.dart';

/// Manager xử lý đề xuất nhập hàng của Sales: tiếp nhận, nhận hàng vào kho
/// hoặc hủy kèm lý do.
class RestockRequestsTab extends ConsumerStatefulWidget {
  const RestockRequestsTab({super.key});

  @override
  ConsumerState<RestockRequestsTab> createState() => _RestockRequestsTabState();
}

class _RestockRequestsTabState extends ConsumerState<RestockRequestsTab> {
  RestockStatus? _status = RestockStatus.open;

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(managerRestockRequestsProvider(_status));
    final storeId = ref.watch(activeStoreProvider)?.id ?? '';
    // Tồn khả dụng hiện tại để so với lúc Sales đề xuất.
    final available = {
      for (final item in ref.watch(managerStockProvider).value ?? const [])
        item.product.id: item.availableAt(storeId),
    };

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              for (final status in [...RestockStatus.values, null])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status?.label ?? 'Tất cả'),
                    selected: status == _status,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: status == _status ? Colors.white : AppColors.ink,
                    ),
                    onSelected: (_) => setState(() => _status = status),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: AsyncValueView<List<RestockRequest>>(
            value: requestsAsync,
            onRetry: () =>
                ref.invalidate(managerRestockRequestsProvider(_status)),
            data: (requests) => RefreshIndicator(
              onRefresh: () =>
                  ref.refresh(managerRestockRequestsProvider(_status).future),
              child: requests.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 60),
                        EmptyState(
                          icon: Icons.assignment_outlined,
                          message: 'Không có đề xuất nhập nào',
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, index) {
                        final request = requests[index];
                        return _RestockCard(
                          request: request,
                          availableNow: available[request.productId?.id],
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RestockCard extends ConsumerStatefulWidget {
  const _RestockCard({required this.request, this.availableNow});

  final RestockRequest request;
  final int? availableNow;

  @override
  ConsumerState<_RestockCard> createState() => _RestockCardState();
}

class _RestockCardState extends ConsumerState<_RestockCard> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action, String done) async {
    setState(() => _busy = true);
    try {
      await action();
      invalidateStock(ref);
      showAppSnackBar(done);
    } catch (e) {
      showAppSnackBar(errorMessageOf(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final note = await showReasonDialog(
      context,
      title: 'Hủy đề xuất nhập?',
      message: 'Lý do sẽ hiển thị cho Sales.',
      confirmLabel: 'Hủy đề xuất',
      hint: 'Ví dụ: kho tổng đang hết hàng',
      minLength: 3,
      maxLength: 300,
    );
    if (note == null || !mounted) return;
    await _run(
      () => ref
          .read(managerRepositoryProvider)
          .cancelRestock(widget.request.id, note),
      'Đã hủy đề xuất.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final isOpen = request.status == RestockStatus.open;
    final statusColor = switch (request.status) {
      RestockStatus.open => AppColors.warning,
      RestockStatus.resolved => AppColors.success,
      RestockStatus.cancelled => AppColors.muted,
    };
    final note = request.managerNote?.trim() ?? '';
    final reason = request.reason?.trim() ?? '';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.productId?.data?.name ?? 'Sản phẩm',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                StatusChip(label: request.status.label, color: statusColor),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Đề xuất ${request.requestedQuantity} sp • tồn lúc đề xuất '
              '${request.currentAvailableStock}'
              '${widget.availableNow != null ? ' • hiện còn ${widget.availableNow}' : ''}',
            ),
            if (reason.isNotEmpty)
              Text(
                'Lý do: $reason',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            Text(
              [
                ?request.requestedBy?.data?.displayName,
                formatDateTime(request.createdAt),
              ].join(' • '),
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            if (request.acknowledgedAt != null && isOpen)
              Text(
                'Đã tiếp nhận lúc ${formatDateTime(request.acknowledgedAt)}',
                style: const TextStyle(fontSize: 12, color: AppColors.info),
              ),
            if (note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Ghi chú: $note', style: const TextStyle(fontSize: 12)),
            ],
            if (isOpen) ...[
              const Divider(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                    ),
                    onPressed: _busy ? null : _cancel,
                    child: const Text('Hủy'),
                  ),
                  if (request.acknowledgedAt == null)
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _run(
                              () => ref
                                  .read(managerRepositoryProvider)
                                  .acknowledgeRestock(request.id),
                              'Đã tiếp nhận đề xuất.',
                            ),
                      child: const Text('Tiếp nhận'),
                    ),
                  FilledButton.icon(
                    icon: const Icon(Icons.move_to_inbox_outlined, size: 18),
                    label: const Text('Nhận hàng'),
                    onPressed: _busy
                        ? null
                        : () => RestockReceiveDialog.show(context, request),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
