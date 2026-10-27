import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../session/session_controller.dart';
import '../../../shared/presentation/restock_request_details.dart';
import '../../../shared/models/models.dart';
import '../../data/manager_repository.dart';
import 'stock_dialogs.dart';

/// Manager xử lý đề xuất nhập hàng của Sales: chuyển lên Owner (được sửa số
/// lượng) hoặc hủy kèm lý do. Hàng về qua "Hàng chuyển đến".
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

  Future<void> _cancel() async {
    final note = await showReasonDialog(
      context,
      title: 'Hủy đề xuất nhập?',
      message: 'Lý do sẽ hiển thị cho Sales.',
      confirmLabel: 'Hủy đề xuất',
      hint: 'Ví dụ: chi nhánh còn đủ hàng',
      minLength: 3,
      maxLength: 300,
    );
    if (note == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(managerRepositoryProvider)
          .cancelRestock(widget.request.id, note);
      invalidateStock(ref);
      showAppSnackBar('Đã hủy đề xuất.');
    } catch (e) {
      showAppSnackBar(errorMessageOf(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final canCancel =
        request.status == RestockStatus.open ||
        request.status == RestockStatus.forwarded;

    return RestockRequestCard(
      request: request,
      availableNow: widget.availableNow,
      actions: [
        if (canCancel)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            onPressed: _busy ? null : _cancel,
            child: const Text('Hủy'),
          ),
        if (request.status == RestockStatus.open)
          FilledButton.icon(
            icon: const Icon(Icons.upload_outlined, size: 18),
            label: const Text('Chuyển lên Owner'),
            onPressed: _busy
                ? null
                : () => RestockForwardDialog.show(context, request),
          ),
      ],
    );
  }
}
