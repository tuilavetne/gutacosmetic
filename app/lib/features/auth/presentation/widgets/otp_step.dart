import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../../core/widgets/otp_input.dart';
import '../../data/auth_models.dart';
import 'auth_layout.dart';

/// Bước nhập OTP: 6 ô số, "Đã gửi tới …", gửi lại có đếm ngược 30 giây.
class OtpStep extends StatefulWidget {
  const OtpStep({
    super.key,
    required this.challenge,
    required this.sentAt,
    required this.onVerify,
    required this.onResend,
    required this.onEdit,
    this.editLabel = 'Sửa thông tin',
    this.verifyLabel = 'Xác thực',
  });

  final OtpChallenge challenge;
  final DateTime sentAt;
  final Future<void> Function(String otp) onVerify;
  final Future<void> Function() onResend;
  final VoidCallback onEdit;
  final String editLabel;
  final String verifyLabel;

  @override
  State<OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<OtpStep> {
  final _otp = TextEditingController();
  bool _verifying = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _otp.addListener(() {
      if (_hasError) setState(() => _hasError = false);
    });
  }

  @override
  void didUpdateWidget(covariant OtpStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Đã gửi mã mới → xóa mã cũ.
    if (oldWidget.challenge.challengeId != widget.challenge.challengeId) {
      _otp.clear();
    }
  }

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_verifying) return;
    final error = Validators.otp(_otp.text);
    if (error != null) {
      setState(() => _hasError = true);
      showAppSnackBar(error, isError: true);
      return;
    }
    setState(() => _verifying = true);
    try {
      await widget.onVerify(_otp.text);
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
      showAppSnackBar(errorMessageOf(e), isError: true);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    try {
      await widget.onResend();
      showAppSnackBar('Đã gửi lại mã OTP.');
    } catch (e) {
      showAppSnackBar(errorMessageOf(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (widget.challenge.expiresIn / 60).ceil();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 40,
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            text: 'Đã gửi mã 6 số tới ',
            children: [
              TextSpan(
                text: widget.challenge.deliveryTarget,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Mã có hiệu lực trong $minutes phút.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 20),
        DevOtpBanner(
          otp: widget.challenge.developmentOtp,
          onFill: () => _otp.text = widget.challenge.developmentOtp ?? '',
        ),
        OtpInput(
          controller: _otp,
          hasError: _hasError,
          enabled: !_verifying,
          onCompleted: (_) => _verify(),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: widget.verifyLabel,
          loading: _verifying,
          onPressed: _verify,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _verifying ? null : widget.onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(widget.editLabel),
            ),
            ResendOtpButton(sentAt: widget.sentAt, onResend: _resend),
          ],
        ),
      ],
    );
  }
}
