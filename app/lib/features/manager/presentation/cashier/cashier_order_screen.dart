import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../customer/presentation/widgets/order_widgets.dart';
import '../../../shared/models/models.dart';
import '../../data/manager_repository.dart';
import 'cashier_payos_screen.dart';

/// Thu ngân xử lý một đơn tại quầy: thu tiền mặt / thẻ / QR PayOS, hoặc hủy
/// khi khách đổi ý. Không có chiết khấu thủ công — thu đúng tổng tiền.
class CashierOrderScreen extends ConsumerStatefulWidget {
  const CashierOrderScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<CashierOrderScreen> createState() => _CashierOrderScreenState();
}

class _CashierOrderScreenState extends ConsumerState<CashierOrderScreen> {
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

  void _onPaid(Order order) {
    setState(() => _order = order);
    ref.invalidate(cashierOrdersProvider);
    final method = order.paymentMethod?.label ?? '';
    showAppSnackBar(
      'Đã thu ${formatVnd(order.totalPrice)} ($method).'
      '${order.pointsEarned > 0 ? ' Khách được cộng ${order.pointsEarned} điểm.' : ''}',
    );
  }

  Future<void> _payAtCounter(PaymentMethod method) async {
    final order = _order!;
    final confirmed = method == PaymentMethod.cash
        ? await _CashPaymentDialog.show(context, total: order.totalPrice)
        : await showConfirmDialog(
            context,
            title: 'Thu bằng thẻ?',
            message:
                'Xác nhận đã quẹt thẻ thành công ${formatVnd(order.totalPrice)} '
                'cho đơn ${order.orderCode}.',
            confirmLabel: 'Đã quẹt thẻ',
          );
    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    try {
      _onPaid(await _repo.payAtCounter(order.id, method));
    } catch (e) {
      showAppSnackBar(
        'Không thu được tiền: ${errorMessageOf(e)}',
        isError: true,
      );
      // Có thể khách đã chuyển khoản PayOS trước đó: tải lại trạng thái thật.
      await _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _payByPayos() async {
    final paid = await CashierPayosScreen.open(context, _order!);
    if (!mounted) return;
    if (paid != null) {
      _onPaid(paid);
    } else {
      await _load();
    }
  }

  Future<void> _cancel() async {
    final order = _order!;
    final reason = await showReasonDialog(
      context,
      title: 'Hủy đơn ${order.orderCode}?',
      message: 'Khách không mua nữa. Hàng đang giữ sẽ được trả lại kho.',
      confirmLabel: 'Hủy đơn',
      hint: 'Lý do (không bắt buộc), ví dụ: khách đổi ý',
      maxLength: 255,
    );
    if (reason == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final cancelled = await _repo.cancelOrder(order.id, reason: reason);
      if (!mounted) return;
      setState(() => _order = cancelled);
      ref.invalidate(cashierOrdersProvider);
      showAppSnackBar('Đã hủy đơn và trả hàng về kho.');
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
        title: Text(order?.orderCode ?? 'Đơn tại quầy'),
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
    final member = order.customerId;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tạo lúc ${formatDateTime(order.createdAt)}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
                SalesOrderStatusBadge(order: order),
              ],
            ),
            const SizedBox(height: 12),
            _Section(
              child: Row(
                children: [
                  Icon(
                    member != null ? Icons.star_rounded : Icons.person_outline,
                    color: member != null
                        ? const Color(0xFFD97706)
                        : AppColors.muted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (order.customerName ?? '').isNotEmpty
                              ? order.customerName!
                              : 'Khách vãng lai',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          [
                            if ((order.customerPhone ?? '').isNotEmpty)
                              order.customerPhone!,
                            member != null
                                ? 'Thành viên • ${formatNumber(member.data?.points ?? 0)} điểm'
                                : 'Không tích điểm',
                          ].join(' • '),
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tổng cần thu',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        formatVnd(order.totalPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (member != null &&
                      order.status == OrderStatus.pendingPayment)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Khách sẽ được cộng ${order.totalPrice ~/ 10000} điểm '
                        '(10.000đ = 1 điểm).',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
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
    final Widget content;
    switch (order.status) {
      case OrderStatus.pendingPayment:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _PayButton(
                    icon: Icons.payments_outlined,
                    label: 'Tiền mặt',
                    onPressed: _busy
                        ? null
                        : () => _payAtCounter(PaymentMethod.cash),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PayButton(
                    icon: Icons.credit_card,
                    label: 'Quẹt thẻ',
                    onPressed: _busy
                        ? null
                        : () => _payAtCounter(PaymentMethod.card),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PayButton(
                    icon: Icons.qr_code_2,
                    label: 'QR PayOS',
                    onPressed: _busy ? null : _payByPayos,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: AppColors.accent),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Hủy đơn (khách không mua)'),
              onPressed: _busy ? null : _cancel,
            ),
          ],
        );
      case OrderStatus.completed:
        content = Text(
          'Đã thu ${formatVnd(order.totalPrice)}'
          '${order.paymentMethod != null ? ' • ${order.paymentMethod!.label}' : ''}'
          '${order.paidAt != null ? ' • ${formatDateTime(order.paidAt)}' : ''}'
          '${order.pointsEarned > 0 ? '\nKhách được cộng ${order.pointsEarned} điểm' : ''}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.success,
            fontWeight: FontWeight.bold,
          ),
        );
      case OrderStatus.cancelled:
        content = const Text(
          'Đơn đã hủy, hàng đã trả về kho.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted),
        );
      default:
        return null;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        // heightFactor: 1 — để thanh dưới chỉ cao bằng nội dung.
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: content,
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon), const SizedBox(height: 4), Text(label)],
      ),
    );
  }
}

/// Xác nhận thu tiền mặt; nhập tiền khách đưa (không bắt buộc) để tính tiền
/// thối lại.
class _CashPaymentDialog extends StatefulWidget {
  const _CashPaymentDialog({required this.total});

  final int total;

  static Future<bool> show(BuildContext context, {required int total}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _CashPaymentDialog(total: total),
    );
    return result ?? false;
  }

  @override
  State<_CashPaymentDialog> createState() => _CashPaymentDialogState();
}

class _CashPaymentDialogState extends State<_CashPaymentDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? get _received => int.tryParse(_controller.text.trim());

  /// Gợi ý tờ tiền khách hay đưa: đúng số tiền và các mức làm tròn lên.
  List<int> get _suggestions {
    final total = widget.total;
    final rounded = <int>{total};
    for (final step in const [50000, 100000, 200000, 500000]) {
      rounded.add(((total + step - 1) ~/ step) * step);
    }
    return rounded.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final received = _received;
    final short = received != null && received < widget.total;

    return AlertDialog(
      title: const Text('Thu tiền mặt'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cần thu: ${formatVnd(widget.total)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('cash-received'),
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Tiền khách đưa (không bắt buộc)',
                border: const OutlineInputBorder(),
                errorText: short ? 'Khách đưa chưa đủ tiền' : null,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final amount in _suggestions)
                  ActionChip(
                    label: Text(formatVnd(amount)),
                    onPressed: () =>
                        setState(() => _controller.text = '$amount'),
                  ),
              ],
            ),
            if (received != null && !short) ...[
              const SizedBox(height: 12),
              Text(
                'Tiền thối lại: ${formatVnd(received - widget.total)}',
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Quay lại'),
        ),
        FilledButton(
          onPressed: short ? null : () => Navigator.of(context).pop(true),
          child: const Text('Đã nhận tiền'),
        ),
      ],
    );
  }
}
