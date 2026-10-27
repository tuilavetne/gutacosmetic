import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/models.dart';

Color restockStatusColor(RestockStatus status) => switch (status) {
  RestockStatus.open => AppColors.warning,
  RestockStatus.forwarded => AppColors.info,
  RestockStatus.inTransit => AppColors.primary,
  RestockStatus.resolved => AppColors.success,
  RestockStatus.cancelled => AppColors.muted,
};

/// Thẻ đề xuất nhập hàng dùng chung cho Sales / Manager / Owner: số lượng,
/// lý do và tiến trình (Sales đề xuất → Manager chuyển lên → Owner duyệt →
/// nhận hàng), kèm ghi chú của Manager / Owner. [actions] hiện dưới cùng.
class RestockRequestCard extends StatelessWidget {
  const RestockRequestCard({
    super.key,
    required this.request,
    this.showStore = false,
    this.availableNow,
    this.actions = const [],
  });

  final RestockRequest request;

  /// Owner xem nhiều chi nhánh nên hiện tên chi nhánh đề xuất.
  final bool showStore;

  /// Tồn khả dụng hiện tại để so với lúc đề xuất (nếu có).
  final int? availableNow;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final managerNote = request.managerNote?.trim() ?? '';
    final ownerNote = request.ownerNote?.trim() ?? '';
    final reason = request.reason?.trim() ?? '';
    const muted = TextStyle(fontSize: 12, color: AppColors.muted);

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.productId?.data?.name ?? 'Sản phẩm',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (showStore && request.storeId?.data != null)
                        Text(request.storeId!.data!.name, style: muted),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusChip(
                  label: request.status.label,
                  color: restockStatusColor(request.status),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Sales đề xuất ${request.requestedQuantity} sp • tồn lúc đề xuất '
              '${request.currentAvailableStock}'
              '${availableNow != null ? ' • hiện còn $availableNow' : ''}',
            ),
            if (reason.isNotEmpty) Text('Lý do: $reason', style: muted),
            Text(
              [
                ?request.requestedBy?.data?.displayName,
                formatDateTime(request.createdAt),
              ].join(' • '),
              style: muted,
            ),
            if (request.forwardedAt != null)
              _Step(
                icon: Icons.upload_outlined,
                text:
                    'Manager chuyển lên Owner ${request.forwardedQuantity ?? request.requestedQuantity} sp'
                    '${request.forwardedBy?.data != null ? ' (${request.forwardedBy!.data!.displayName})' : ''}'
                    ' • ${formatDateTime(request.forwardedAt)}',
              ),
            if (managerNote.isNotEmpty) _Note('Manager: $managerNote'),
            if (request.approvedAt != null)
              _Step(
                icon: Icons.local_shipping_outlined,
                text:
                    'Owner duyệt ${request.approvedQuantity ?? ''} sp, đã tạo phiếu chuyển hàng'
                    ' • ${formatDateTime(request.approvedAt)}',
              ),
            if (ownerNote.isNotEmpty) _Note('Owner: $ownerNote'),
            if (request.status == RestockStatus.resolved &&
                request.resolvedAt != null)
              _Step(
                icon: Icons.check_circle_outline,
                text:
                    'Chi nhánh đã nhận hàng • ${formatDateTime(request.resolvedAt)}',
              ),
            if (actions.isNotEmpty) ...[
              const Divider(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.info),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.info),
            ),
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
