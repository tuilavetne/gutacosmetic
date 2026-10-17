import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_messenger.dart';
import '../../../core/widgets/state_views.dart';
import '../../shared/models/models.dart';
import '../cart/cart_controller.dart';
import '../data/order_repository.dart';
import '../orders/order_display.dart';
import 'widgets/order_widgets.dart';

enum _PaymentView { awaiting, paid, expired, notBankTransfer }

/// Quét mã VietQR PayOS cho đơn chuyển khoản. Tự hỏi PayOS mỗi
/// [AppConstants.payosPollInterval] (không phụ thuộc webhook) và đếm ngược
/// tới lúc mã hết hạn.
class PayosPaymentScreen extends ConsumerStatefulWidget {
  const PayosPaymentScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<PayosPaymentScreen> createState() => _PayosPaymentScreenState();
}

class _PayosPaymentScreenState extends ConsumerState<PayosPaymentScreen> {
  Order? _order;
  PayosPayment? _payment;
  Object? _error;
  bool _checking = false;
  Timer? _pollTimer;
  Timer? _clockTimer;

  OrderRepository get _repo => ref.read(orderRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }

  Duration get _remaining => _payment?.remaining() ?? Duration.zero;

  _PaymentView get _view {
    final order = _order!;
    if (order.isPaid) return _PaymentView.paid;
    if (!order.isBankTransfer) return _PaymentView.notBankTransfer;
    if (order.awaitsBankTransfer &&
        _payment != null &&
        _remaining > Duration.zero) {
      return _PaymentView.awaiting;
    }
    return _PaymentView.expired;
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      var order = await _repo.fetchOrder(widget.orderId);
      PayosPayment? payment;
      if (order.awaitsBankTransfer) {
        try {
          payment = await _repo.fetchPaymentLink(order.id);
        } on ApiException catch (e) {
          // Hết hạn đúng lúc mở — tải lại để thấy đơn đã hủy.
          if (e.code != 'PAYMENT_QR_EXPIRED') rethrow;
          order = await _repo.fetchOrder(widget.orderId);
        }
      }
      if (!mounted) return;
      setState(() {
        _order = order;
        _payment = payment;
      });
      if (_view == _PaymentView.awaiting) _startTimers();
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _startTimers() {
    _stopTimers();
    _pollTimer = Timer.periodic(AppConstants.payosPollInterval, (_) => _sync());
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining <= Duration.zero) {
        _stopTimers();
        // Hỏi lần cuối: có thể tiền vừa về sát giờ hết hạn.
        _sync();
      }
      setState(() {});
    });
  }

  void _stopTimers() {
    _pollTimer?.cancel();
    _clockTimer?.cancel();
    _pollTimer = null;
    _clockTimer = null;
  }

  /// Hỏi PayOS. [manual] = khách bấm "Tôi đã thanh toán" (báo kết quả).
  Future<void> _sync({bool manual = false}) async {
    if (_checking || !mounted) return;
    _checking = true;
    try {
      Order order;
      try {
        order = (await _repo.syncPayment(widget.orderId)).order;
      } on ApiException catch (e) {
        // Webhook đã ghi nhận trước → sync báo "đã thanh toán".
        if (e.code != 'ORDER_ALREADY_PAID') rethrow;
        order = await _repo.fetchOrder(widget.orderId);
      }
      if (!mounted) return;
      setState(() => _order = order);
      if (order.isPaid || !order.awaitsBankTransfer) {
        _stopTimers();
        ref
          ..invalidate(customerOrdersProvider)
          ..invalidate(customerOrderProvider(widget.orderId));
      } else if (manual) {
        showAppSnackBar(
          'Chưa nhận được thanh toán. Nếu bạn vừa chuyển khoản, vui lòng đợi '
          'vài giây rồi thử lại.',
        );
      }
    } catch (e) {
      if (manual) rethrow;
      // Lỗi khi tự kiểm tra thì bỏ qua — lần sau hỏi lại.
    } finally {
      _checking = false;
    }
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.customerOrder(widget.orderId));
    }
  }

  Future<void> _openCheckout() async {
    final url = Uri.tryParse(_payment?.checkoutUrl ?? '');
    if (url == null ||
        !await launchUrl(url, mode: LaunchMode.externalApplication)) {
      showAppSnackBar('Không mở được trang thanh toán PayOS.', isError: true);
    }
  }

  void _reorder(Order order) {
    final added = ref
        .read(cartControllerProvider.notifier)
        .addItems(order.reorderLines);
    if (added == 0) {
      showAppSnackBar('Giỏ hàng đã có đủ các sản phẩm này.');
    }
    context.pushReplacement(AppRoutes.customerCart);
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán chuyển khoản'),
        leading: IconButton(
          tooltip: 'Đóng',
          onPressed: _close,
          icon: const Icon(Icons.close),
        ),
      ),
      body: order == null
          ? (_error == null
                ? const LoadingView(message: 'Đang tạo mã QR...')
                : ErrorState(error: _error!, onRetry: _load))
          : OrderContentWidth(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  switch (_view) {
                    _PaymentView.awaiting => _AwaitingView(
                      order: order,
                      payment: _payment!,
                      remaining: _remaining,
                      onOpenCheckout: _openCheckout,
                      onCheck: () => _sync(manual: true),
                    ),
                    _PaymentView.paid => _ResultView(
                      icon: Icons.check_circle,
                      color: AppColors.success,
                      title: 'Thanh toán thành công',
                      message:
                          'Đơn ${order.orderCode} đã được thanh toán '
                          '${formatVnd(order.totalPrice)}. Cửa hàng sẽ sớm '
                          'xác nhận và chuẩn bị hàng cho bạn.',
                      primaryLabel: 'Xem đơn hàng',
                      onPrimary: _close,
                      secondaryLabel: 'Tiếp tục mua sắm',
                      onSecondary: () => context.go(AppRoutes.customerHome),
                    ),
                    _PaymentView.expired => _ResultView(
                      icon: Icons.timer_off_outlined,
                      color: AppColors.accent,
                      title: 'Mã QR đã hết hạn',
                      message:
                          'Đơn ${order.orderCode} đã tự động hủy vì chưa nhận '
                          'được thanh toán trong 15 phút. Bạn có thể đặt lại '
                          'các sản phẩm này.',
                      primaryLabel: 'Mua lại',
                      onPrimary: () => _reorder(order),
                      secondaryLabel: 'Xem đơn hàng',
                      onSecondary: _close,
                    ),
                    _PaymentView.notBankTransfer => _ResultView(
                      icon: Icons.info_outline,
                      color: AppColors.info,
                      title: 'Đơn không dùng chuyển khoản',
                      message:
                          'Đơn ${order.orderCode} thanh toán bằng '
                          '"${order.paymentMethodLabel}".',
                      primaryLabel: 'Xem đơn hàng',
                      onPrimary: _close,
                    ),
                  },
                ],
              ),
            ),
    );
  }
}

class _AwaitingView extends StatelessWidget {
  const _AwaitingView({
    required this.order,
    required this.payment,
    required this.remaining,
    required this.onOpenCheckout,
    required this.onCheck,
  });

  final Order order;
  final PayosPayment payment;
  final Duration remaining;
  final Future<void> Function() onOpenCheckout;
  final Future<void> Function() onCheck;

  @override
  Widget build(BuildContext context) {
    final qr = payment.qrImageBytes;
    final urgent = remaining < const Duration(minutes: 2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Số tiền cần thanh toán',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  formatVnd(order.totalPrice),
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mã đơn ${order.orderCode}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SizedBox.square(
                    dimension: 240,
                    child: qr == null
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Không hiển thị được mã QR. Vui lòng mở '
                                'trang thanh toán PayOS.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ),
                          )
                        : Image.memory(
                            qr,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                            semanticLabel: 'Mã QR thanh toán',
                          ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (urgent ? AppColors.accent : AppColors.warning)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: urgent ? AppColors.accent : AppColors.warning,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Mã hết hạn sau ${formatCountdown(remaining)}',
                          style: TextStyle(
                            color: urgent
                                ? AppColors.accent
                                : AppColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const TitledCard(
          title: 'Hướng dẫn',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Step(1, 'Mở ứng dụng ngân hàng và chọn quét mã QR.'),
              _Step(
                2,
                'Kiểm tra số tiền và nội dung chuyển khoản đã điền sẵn — '
                'không sửa nội dung.',
              ),
              _Step(
                3,
                'Xác nhận chuyển khoản. Đơn hàng tự cập nhật sau vài giây.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'Tôi đã thanh toán',
          icon: Icons.verified_outlined,
          onPressed: onCheck,
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'Mở trang thanh toán PayOS',
          icon: Icons.open_in_new,
          variant: AppButtonVariant.outlined,
          onPressed: (payment.checkoutUrl ?? '').isEmpty
              ? null
              : onOpenCheckout,
        ),
        const SizedBox(height: 12),
        const Text(
          'Hệ thống tự kiểm tra giao dịch mỗi 5 giây.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.index, this.text);

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              '$index',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: color),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPrimary,
              child: Text(primaryLabel),
            ),
          ),
          if (secondaryLabel != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSecondary,
                child: Text(secondaryLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
