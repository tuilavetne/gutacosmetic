import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../features/shared/models/enums.dart';

/// Nhãn trạng thái dạng viên thuốc.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});

  factory StatusChip.order(OrderStatus status) =>
      StatusChip(label: status.label, color: orderStatusColor(status));

  factory StatusChip.payment(PaymentStatus status) =>
      StatusChip(label: status.label, color: paymentStatusColor(status));

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

Color orderStatusColor(OrderStatus status) => switch (status) {
  OrderStatus.draft || OrderStatus.pendingApproval => AppColors.muted,
  OrderStatus.pending || OrderStatus.pendingPayment => AppColors.warning,
  OrderStatus.paid || OrderStatus.preparing => AppColors.info,
  OrderStatus.readyForPickup => AppColors.primary,
  OrderStatus.completed => AppColors.success,
  OrderStatus.cancelled => AppColors.accent,
};

Color paymentStatusColor(PaymentStatus status) => switch (status) {
  PaymentStatus.unpaid => AppColors.warning,
  PaymentStatus.paid => AppColors.success,
  PaymentStatus.failed => AppColors.accent,
  PaymentStatus.refunded => AppColors.info,
};
