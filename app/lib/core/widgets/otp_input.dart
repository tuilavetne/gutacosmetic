import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../utils/constants.dart';

/// 6 ô số OTP. Dùng một TextField ẩn phía sau để hỗ trợ dán mã và
/// tự điền OTP của hệ điều hành.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.controller,
    this.onCompleted,
    this.enabled = true,
    this.autofocus = true,
    this.hasError = false,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final bool autofocus;
  final bool hasError;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final _focusNode = FocusNode();
  static const _length = AppConstants.otpLength;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant OtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focusNode.dispose();
    super.dispose();
  }

  String? _lastCompleted;

  void _onChanged() {
    final text = widget.controller.text;
    // Listener cũng chạy khi đổi vị trí con trỏ → chỉ báo khi nội dung đổi.
    if (text.length == _length && text != _lastCompleted) {
      _lastCompleted = text;
      _focusNode.unfocus();
      widget.onCompleted?.call(text);
    } else if (text.length < _length) {
      _lastCompleted = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled ? _focusNode.requestFocus : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // TextField thật — trong suốt, nằm dưới các ô hiển thị.
          Opacity(
            opacity: 0,
            child: SizedBox(
              height: 56,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                maxLength: _length,
                showCursor: false,
                enableInteractiveSelection: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: ListenableBuilder(
              listenable: Listenable.merge([widget.controller, _focusNode]),
              builder: (context, _) {
                final text = widget.controller.text;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_length, (i) {
                    final char = i < text.length ? text[i] : '';
                    final isCurrent =
                        _focusNode.hasFocus &&
                        (i == text.length ||
                            (text.length == _length && i == _length - 1));
                    final borderColor = widget.hasError
                        ? scheme.error
                        : isCurrent
                        ? AppColors.primary
                        : AppColors.border;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 46,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: widget.enabled
                            ? AppColors.surface
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: borderColor,
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        char,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Nút "Gửi lại" khóa trong [AppConstants.otpResendCooldown] sau mỗi lần gửi.
class ResendOtpButton extends StatefulWidget {
  const ResendOtpButton({
    super.key,
    required this.sentAt,
    required this.onResend,
  });

  /// Thời điểm gửi gần nhất — đổi giá trị để bắt đầu đếm lại.
  final DateTime sentAt;
  final Future<void> Function() onResend;

  @override
  State<ResendOtpButton> createState() => _ResendOtpButtonState();
}

class _ResendOtpButtonState extends State<ResendOtpButton> {
  Timer? _timer;
  int _secondsLeft = 0;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant ResendOtpButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sentAt != widget.sentAt) _start();
  }

  void _start() {
    _timer?.cancel();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final elapsed = DateTime.now().difference(widget.sentAt);
    final left = AppConstants.otpResendCooldown.inSeconds - elapsed.inSeconds;
    if (!mounted) return;
    setState(() => _secondsLeft = left > 0 ? left : 0);
    if (left <= 0) _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resend() async {
    setState(() => _sending = true);
    try {
      await widget.onResend();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sending) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return TextButton(
      onPressed: _secondsLeft > 0 ? null : _resend,
      child: Text(
        _secondsLeft > 0 ? 'Gửi lại sau ${_secondsLeft}s' : 'Gửi lại mã',
      ),
    );
  }
}
