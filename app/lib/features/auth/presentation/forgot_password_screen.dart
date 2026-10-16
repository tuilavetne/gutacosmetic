import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_messenger.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';
import 'widgets/auth_layout.dart';
import 'widgets/otp_step.dart';

enum _Step { identifier, otp, reset }

/// Quên mật khẩu 3 bước: Gmail/SĐT → OTP (luôn gửi về Gmail) → mật khẩu mới.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _identifierForm = GlobalKey<FormState>();
  final _resetForm = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  _Step _step = _Step.identifier;
  OtpChallenge? _challenge;
  DateTime _sentAt = DateTime.now();
  String? _resetToken;
  bool _busy = false;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      showAppSnackBar(errorMessageOf(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _requestOtp() async {
    if (!_identifierForm.currentState!.validate()) return;
    await _run(() async {
      final challenge = await ref
          .read(authRepositoryProvider)
          .requestPasswordResetOtp(_identifier.text);
      if (!mounted) return;
      setState(() {
        _challenge = challenge;
        _sentAt = DateTime.now();
        _step = _Step.otp;
      });
    });
  }

  Future<void> _resend() async {
    final challenge = await ref
        .read(authRepositoryProvider)
        .requestPasswordResetOtp(_identifier.text);
    if (!mounted) return;
    setState(() {
      _challenge = challenge;
      _sentAt = DateTime.now();
    });
  }

  Future<void> _verify(String otp) async {
    final token = await ref
        .read(authRepositoryProvider)
        .verifyPasswordResetOtp(challengeId: _challenge!.challengeId, otp: otp);
    if (!mounted) return;
    setState(() {
      _resetToken = token.resetToken;
      _step = _Step.reset;
    });
  }

  Future<void> _resetPassword() async {
    if (!_resetForm.currentState!.validate()) return;
    await _run(() async {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(
            resetToken: _resetToken!,
            password: _password.text,
            confirmPassword: _confirm.text,
          );
      showAppSnackBar('Đổi mật khẩu thành công. Vui lòng đăng nhập lại.');
      if (mounted) context.go(AppRoutes.login);
    });
  }

  void _back() {
    switch (_step) {
      case _Step.identifier:
        context.canPop() ? context.pop() : context.go(AppRoutes.login);
      case _Step.otp:
        setState(() => _step = _Step.identifier);
      case _Step.reset:
        // Reset token chỉ dùng một lần — quay lại thì bắt đầu lại từ đầu.
        setState(() {
          _resetToken = null;
          _step = _Step.identifier;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = switch (_step) {
      _Step.identifier => (
        'Quên mật khẩu',
        'Nhập Gmail hoặc số điện thoại đã đăng ký. '
            'Mã OTP sẽ được gửi về Gmail của tài khoản.',
      ),
      _Step.otp => ('Nhập mã OTP', 'Xác thực để đặt lại mật khẩu'),
      _Step.reset => ('Mật khẩu mới', 'Tạo mật khẩu mới cho tài khoản của bạn'),
    };

    return PopScope(
      canPop: _step == _Step.identifier,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: AuthLayout(
        title: title,
        subtitle: subtitle,
        onBack: _back,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepIndicator(current: _step.index),
            const SizedBox(height: 20),
            switch (_step) {
              _Step.identifier => _buildIdentifier(),
              _Step.otp => OtpStep(
                challenge: _challenge!,
                sentAt: _sentAt,
                onVerify: _verify,
                onResend: _resend,
                onEdit: _back,
                editLabel: 'Đổi Gmail/SĐT',
              ),
              _Step.reset => _buildReset(),
            },
          ],
        ),
      ),
    );
  }

  Widget _buildIdentifier() {
    return Form(
      key: _identifierForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _identifier,
            label: 'Gmail hoặc số điện thoại',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.identifier,
            onFieldSubmitted: (_) => _requestOtp(),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Gửi mã OTP',
            icon: Icons.send_outlined,
            loading: _busy,
            onPressed: _requestOtp,
          ),
        ],
      ),
    );
  }

  Widget _buildReset() {
    return Form(
      key: _resetForm,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _password,
            label: 'Mật khẩu mới',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            helperText: '8–72 ký tự, gồm chữ hoa, chữ thường và chữ số',
            validator: Validators.password,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _confirm,
            label: 'Xác nhận mật khẩu mới',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: Validators.confirmPassword(() => _password.text),
            onFieldSubmitted: (_) => _resetPassword(),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Đổi mật khẩu',
            loading: _busy,
            onPressed: _resetPassword,
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
            decoration: BoxDecoration(
              color: i <= current ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
