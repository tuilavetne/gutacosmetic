import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../shared/models/models.dart';
import '../../orders/order_display.dart';
import 'product_image.dart';

/// Bề rộng tối đa của các màn giỏ hàng / thanh toán / đơn hàng.
const orderContentMaxWidth = 720.0;

/// Nhãn trạng thái đơn theo cách gọi của khách.
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) => StatusChip(
    label: order.customerStatusLabel,
    color: order.customerStatusColor,
  );
}

/// Nhãn trạng thái đơn dành cho nhân viên Sales / Quầy POS
class SalesOrderStatusBadge extends StatelessWidget {
  const SalesOrderStatusBadge({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (order.status) {
      OrderStatus.draft => ('Nháp', AppColors.muted),
      OrderStatus.pendingApproval => ('Chờ duyệt', const Color(0xFFF59E0B)),
      OrderStatus.pendingPayment => ('Chờ thu ngân', const Color(0xFF2563EB)),
      OrderStatus.pending => ('Chờ xác nhận', const Color(0xFFD97706)),
      OrderStatus.paid => ('Đã thanh toán', const Color(0xFF059669)),
      OrderStatus.preparing => ('Đang xử lý', const Color(0xFF0D9488)),
      OrderStatus.readyForPickup => ('Sẵn sàng nhận', const Color(0xFF0284C7)),
      OrderStatus.completed => ('Hoàn tất', const Color(0xFF16A34A)),
      OrderStatus.cancelled => ('Đã hủy', const Color(0xFFDC2626)),
    };
    return StatusChip(label: label, color: color);
  }
}

/// Tiêu đề nhỏ + thẻ nội dung.
class TitledCard extends StatelessWidget {
  const TitledCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(14),
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        Card(
          child: Padding(padding: padding, child: child),
        ),
      ],
    );
  }
}

/// Ảnh vuông bo góc của một dòng sản phẩm.
class ItemThumbnail extends StatelessWidget {
  const ItemThumbnail({super.key, required this.url, this.size = 56});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox.square(
        dimension: size,
        child: ProductImage(url: url, iconSize: size * 0.4),
      ),
    );
  }
}

/// Dòng sản phẩm trong đơn: ảnh, tên, `SL × đơn giá`, thành tiền.
class OrderLineTile extends StatelessWidget {
  const OrderLineTile({
    super.key,
    required this.name,
    required this.image,
    required this.quantity,
    required this.unitPrice,
    this.subtitle,
    this.onTap,
  });

  final String name;
  final String? image;
  final int quantity;
  final int unitPrice;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            ItemThumbnail(url: image),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle ?? '$quantity × ${formatVnd(unitPrice)}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatVnd(unitPrice * quantity),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dòng "nhãn ....... số tiền" trong bảng tổng tiền.
class MoneyRow extends StatelessWidget {
  const MoneyRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: emphasize ? AppColors.ink : AppColors.muted,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
                fontSize: emphasize ? 15 : 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color:
                  valueColor ?? (emphasize ? AppColors.accent : AppColors.ink),
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
              fontSize: emphasize ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thanh cố định phía dưới (tổng tiền + nút hành động).
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: orderContentMaxWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Căn giữa nội dung và giới hạn bề rộng trên màn hình rộng.
class OrderContentWidth extends StatelessWidget {
  const OrderContentWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: orderContentMaxWidth),
        child: child,
      ),
    );
  }
}
