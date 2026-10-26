import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../shared/models/models.dart';
import '../../data/manager_repository.dart';

/// Khách quét QR PayOS để chuyển khoản tại quầy. Trả về đơn đã hoàn tất khi
/// PayOS xác nhận tiền đã về, hoặc `null` nếu thu ngân đóng màn (QR vẫn còn
/// hiệu lực tới khi hết hạn hoặc thu bằng cách khác).
///
/// Ở máy local PayOS không gọi webhook về được, nên màn tự hỏi PayOS định kỳ
/// và có nút "Kiểm tra thanh toán".
class CashierPayosScreen extends ConsumerStatefulWidget {
  const CashierPayosScreen({super.key, required this.order});

  final Order order;

  static Future<Order?> open(BuildContext context, Order order) {
    return Navigator.of(context).push<Order>(
      MaterialPageRoute(builder: (_) => CashierPayosScreen(order: order)),
    );
  }

  @override
  ConsumerState<CashierPayosScreen> createState() => _CashierPayosScreenState();
}

class _CashierPayosScreenState extends ConsumerState<CashierPayosScreen> {
  PayosPayment? _payment;
  Object? _error;
  bool _loading = true;
  bool _checking = false;
  Duration _remaining = Duration.zero;
  Timer? _pollTimer;
  Timer? _clockTimer;

  bool get _expired => _payment != null && _remaining <= Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadLink();
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }

  Future<void> _loadLink() async {
    _stopTimers();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final payment = await ref
          .read(managerRepositoryProvider)
          .fetchPosPayment(widget.order.id);
      if (!mounted) return;
      setState(() {
        _payment = payment;
        _loading = false;
        _remaining = _timeLeft(payment);
      });
      _startTimers();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Duration _timeLeft(PayosPayment payment) {
    final expiredAt = payment.expiredAt;
    if (expiredAt == null) return const Duration(minutes: 15);
    final left = expiredAt.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  void _startTimers() {
    _pollTimer = Timer.periodic(
      AppConstants.payosPollInterval,
      (_) => _check(silent: true),
    );
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final payment = _payment;
      if (!mounted || payment == null) return;
      setState(() => _remaining = _timeLeft(payment));
      if (_expired) {
        // Kiểm tra lần cuối: khách có thể vừa chuyển khoản sát giờ hết hạn.
        _stopTimers();
        _check(silent: true);
      }
    });
  }

  void _stopTimers() {
    _pollTimer?.cancel();
    _clockTimer?.cancel();
    _pollTimer = null;
    _clockTimer = null;
  }

  Future<void> _check({bool silent = false}) async {
    if (_checking) return;
    _checking = true;
    if (!silent) setState(() {});
    try {
      final result = await ref
          .read(managerRepositoryProvider)
          .syncPosPayment(widget.order.id);
      if (!mounted) return;
      if (result.order.status == OrderStatus.completed) {
        _stopTimers();
        Navigator.of(context).pop(result.order);
        return;
      }
      if (!silent) {
        showAppSnackBar(
          'Chưa nhận được tiền. Nhờ khách kiểm tra lại giao dịch.',
        );
      }
    } catch (e) {
      if (!silent && mounted) {
        showAppSnackBar(
          'Không kiểm tra được thanh toán: ${errorMessageOf(e)}',
          isError: true,
        );
      }
    } finally {
      _checking = false;
      if (mounted && !silent) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR PayOS • ${widget.order.orderCode}')),
      body: _loading
          ? const LoadingView(message: 'Đang tạo mã QR...')
          : _error != null
          ? ErrorState(error: _error!, onRetry: _loadLink)
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final payment = _payment!;
    final qr = payment.qrImageBytes;
    final minutes = _remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Số tiền khách cần chuyển',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 4),
              Text(
                formatVnd(widget.order.totalPrice),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SizedBox.square(
                    dimension: 240,
                    child: _expired
                        ? const Center(
                            child: Text(
                              'Mã QR đã hết hạn',
                              style: TextStyle(color: AppColors.accent),
                            ),
                          )
                        : qr == null
                        ? const Center(
                            child: Text(
                              'Không hiển thị được mã QR',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.muted),
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
              ),
              const SizedBox(height: 12),
              Text(
                _expired
                    ? 'Tạo mã mới nếu khách vẫn muốn chuyển khoản.'
                    : 'Mã hết hạn sau $minutes:$seconds • tự kiểm tra mỗi '
                          '${AppConstants.payosPollInterval.inSeconds} giây',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _expired ? AppColors.accent : AppColors.muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              if (_expired)
                FilledButton.icon(
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Tạo mã QR mới'),
                  onPressed: _loadLink,
                )
              else
                FilledButton.icon(
                  icon: _checking
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: const Text('Kiểm tra thanh toán'),
                  onPressed: _checking ? null : () => _check(),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng (thu bằng cách khác)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
