import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../customer/orders/order_display.dart';
import '../../../shared/models/models.dart';
import '../../data/manager_repository.dart';
import 'online_order_display.dart';

/// Manager xử lý một đơn online: chuyển bước, hoàn tất (thu tiền mặt nếu khách
/// chưa chuyển khoản) hoặc hủy kèm lý do.
class OnlineOrderScreen extends ConsumerStatefulWidget {
  const OnlineOrderScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OnlineOrderScreen> createState() => _OnlineOrderScreenState();
}

class _OnlineOrderScreenState extends ConsumerState<OnlineOrderScreen> {
  Order? _order;
  Object? _error;
  bool _loading = true;
  bool _busy = false;

  ManagerRepository get _repo => ref.read(managerRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final order = await _repo.fetchOrder(widget.orderId);
      if (mounted) {
        setState(() {
          _order = order;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  void _updated(Order order, String message) {
    setState(() => _order = order);
    ref.invalidate(managerOnlineOrdersProvider);
    showAppSnackBar(message);
  }

  Future<void> _advance() async {
    final order = _order!;
    final step = order.nextStep;
    if (step == null) return;

    var collectedCash = false;
    if (step.next == OrderStatus.completed && !order.isPaid) {
      final ok = await showConfirmDialog(
        context,
        title: order.unpaidTransfer
            ? 'Khách chưa chuyển khoản'
            : 'Thu tiền khi ${order.isDelivery ? 'giao' : 'nhận'} hàng',
        message: order.unpaidTransfer
            ? 'PayOS chưa ghi nhận tiền của đơn ${order.orderCode}. Xác nhận '
                  'đã thu ${formatVnd(order.totalPrice)} tiền mặt '
                  '${order.isDelivery ? 'khi giao hàng (COD)' : 'tại cửa hàng'}?\n'
                  'Mã QR của khách sẽ bị hủy để tránh trả hai lần.'
            : 'Xác nhận đã thu ${formatVnd(order.totalPrice)} '
                  '(${order.paymentMethodLabel}).',
        confirmLabel: 'Đã thu tiền',
      );
      if (!ok || !mounted) return;
      collectedCash = order.unpaidTransfer;
    }

    setState(() => _busy = true);
    try {
      final updated = await _repo.updateOnlineStatus(
        order.id,
        step.next,
        collectedCash: collectedCash,
      );
      if (!mounted) return;
      _updated(
        updated,
        updated.status == OrderStatus.completed && updated.pointsEarned > 0
            ? 'Đơn đã hoàn tất. Khách được cộng ${updated.pointsEarned} điểm.'
            : 'Đã chuyển đơn sang "${updated.managerStatusLabel}".',
      );
    } catch (e) {
      showAppSnackBar(errorMessageOf(e), isError: true);
      // Có thể khách vừa chuyển khoản: tải lại trạng thái thật.
      await _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final order = _order!;
    final reason = await showReasonDialog(
      context,
      title: 'Hủy đơn ${order.orderCode}?',
      message:
          'Lý do sẽ hiển thị cho khách. Hàng đang giữ được trả về kho'
          '${order.isPaid ? '; đơn đã thanh toán sẽ chuyển sang chờ hoàn tiền' : ''}.',
      confirmLabel: 'Hủy đơn',
      hint: 'Ví dụ: khách không đến nhận hàng sau 3 ngày',
      minLength: AppConstants.cancellationReasonMinLength,
      maxLength: 255,
    );
    if (reason == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final cancelled = await _repo.cancelOrder(order.id, reason: reason);
      if (mounted) _updated(cancelled, 'Đã hủy đơn ${order.orderCode}.');
    } catch (e) {
      showAppSnackBar(
        'Không hủy được đơn: ${errorMessageOf(e)}',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    return Scaffold(
      appBar: AppBar(
        title: Text(order?.orderCode ?? 'Đơn online'),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            icon: const Icon(Icons.refresh),
            onPressed: _busy ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
          ? ErrorState(error: _error!, onRetry: _load)
          : _buildBody(order!),
      bottomNavigationBar: order == null || _loading ? null : _actionBar(order),
    );
  }

  Widget _buildBody(Order order) {
    final address = order.shippingAddress;
    final cancelReason = order.cancellationReasonLabel;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusChip(
                  label: order.managerStatusLabel,
                  color: order.managerStatusColor,
                ),
                StatusChip(
                  label: order.fulfillmentType?.label ?? 'Online',
                  color: AppColors.info,
                ),
                if (order.unpaidTransfer)
                  const StatusChip(
                    label: 'Chưa chuyển khoản',
                    color: AppColors.accent,
                  ),
                if (order.awaitsRefund)
                  const StatusChip(
                    label: 'Chờ hoàn tiền',
                    color: AppColors.accent,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Đặt lúc ${formatDateTime(order.createdAt)}',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            if (cancelReason != null) ...[
              const SizedBox(height: 12),
              _Section(
                color: AppColors.accent.withValues(alpha: 0.06),
                child: Text('Lý do hủy: $cancelReason'),
              ),
            ],
            const SizedBox(height: 12),
            _Section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Khách hàng',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(order.customerName ?? 'Khách hàng'),
                  if ((order.customerDisplayPhone ?? '').isNotEmpty)
                    Text('SĐT: ${order.customerDisplayPhone}'),
                  if (order.isDelivery && address != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Giao đến: ${address.recipientName.isNotEmpty ? '${address.recipientName} • ' : ''}'
                      '${address.phone.isNotEmpty ? '${address.phone} • ' : ''}${address.addressLine}',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sản phẩm (${order.itemCount})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 20),
                  for (final item in order.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.name} × ${item.quantity}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(formatVnd(item.lineTotal)),
                        ],
                      ),
                    ),
                  const Divider(height: 20),
                  _AmountRow('Tiền hàng', order.subtotal),
                  if (order.shippingFee > 0)
                    _AmountRow('Phí giao hàng', order.shippingFee),
                  const SizedBox(height: 4),
                  _AmountRow('Tổng cộng', order.totalPrice, bold: true),
                  const SizedBox(height: 8),
                  Text(
                    '${order.paymentMethodLabel} • ${order.paymentStatusLabel}',
                    style: TextStyle(
                      color: order.isPaid ? AppColors.success : AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (order.statusHistory.isNotEmpty) ...[
              const SizedBox(height: 12),
              _Section(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tiến trình',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    for (final step in order.statusHistory)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text(
                          '${formatDateTime(step.changedAt)} • ${step.status.label}'
                          '${(step.note ?? '').isNotEmpty ? ' — ${step.note}' : ''}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget? _actionBar(Order order) {
    final step = order.nextStep;
    if (step == null && !order.managerCanCancel) return null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (step != null)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(0, 48),
                    ),
                    icon: _busy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(step.icon),
                    label: Text(step.label),
                    onPressed: _busy ? null : _advance,
                  ),
                if (order.managerCanCancel)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Hủy đơn'),
                    onPressed: _busy ? null : _cancel,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.child, this.color});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow(this.label, this.amount, {this.bold = false});

  final String label;
  final int amount;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 16 : 14,
      color: bold ? AppColors.primary : null,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(formatVnd(amount), style: style),
      ],
    );
  }
}
