import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_messenger.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../session/session_controller.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';
import 'widgets/auth_layout.dart';
import 'widgets/otp_step.dart';

/// Đăng ký 2 bước: điền thông tin → xác thực OTP Gmail.
/// Xác thực xong tự đăng nhập; router chuyển tới `/customer/home`.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _address = TextEditingController();

  OtpChallenge? _challenge;
  DateTime _sentAt = DateTime.now();
  bool _sending = false;

  bool get _onOtpStep => _challenge != null;

  @override
  void dispose() {
    for (final c in [
      _fullName,
      _email,
      _phone,
      _password,
      _confirm,
      _address,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<OtpChallenge> _requestOtp() => ref
      .read(authRepositoryProvider)
      .requestRegisterOtp(
        fullName: _fullName.text,
        email: _email.text,
        phone: _phone.text,
        password: _password.text,
        confirmPassword: _confirm.text,
        address: _address.text,
      );

  Future<void> _sendOtp() async {
    if (_sending) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      final challenge = await _requestOtp();
      if (!mounted) return;
      setState(() {
        _challenge = challenge;
        _sentAt = DateTime.now();
      });
    } catch (e) {
      showAppSnackBar(errorMessageOf(e), isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _resend() async {
    final challenge = await _requestOtp();
    if (!mounted) return;
    setState(() {
      _challenge = challenge;
      _sentAt = DateTime.now();
    });
  }

  Future<void> _verify(String otp) async {
    final result = await ref
        .read(authRepositoryProvider)
        .verifyRegisterOtp(challengeId: _challenge!.challengeId, otp: otp);
    await ref.read(sessionControllerProvider.notifier).startSession(result);
    showAppSnackBar('Tạo tài khoản thành công. Chào mừng bạn đến GUTA!');
  }

  void _backToForm() => setState(() => _challenge = null);

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Ở bước OTP, nút Back quay về form thay vì thoát màn.
      canPop: !_onOtpStep,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _onOtpStep) _backToForm();
      },
      child: AuthLayout(
        title: _onOtpStep ? 'Xác thực Gmail' : 'Tạo tài khoản',
        subtitle: _onOtpStep
            ? 'Nhập mã OTP để hoàn tất đăng ký'
            : 'Tích điểm thành viên và đặt hàng online dễ dàng',
        onBack: _onOtpStep ? _backToForm : _leave,
        footer: _onOtpStep
            ? null
            : Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Đã có tài khoản?'),
                  TextButton(onPressed: _leave, child: const Text('Đăng nhập')),
                ],
              ),
        // Giữ form trong cây (Offstage) để không mất dữ liệu khi quay lại.
        child: Stack(
          children: [
            Offstage(offstage: _onOtpStep, child: _buildForm()),
            if (_onOtpStep)
              OtpStep(
                challenge: _challenge!,
                sentAt: _sentAt,
                onVerify: _verify,
                onResend: _resend,
                onEdit: _backToForm,
                verifyLabel: 'Xác thực & tạo tài khoản',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _fullName,
            label: 'Họ và tên',
            prefixIcon: Icons.badge_outlined,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            validator: Validators.fullName,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _email,
            label: 'Gmail',
            hint: 'ten@gmail.com',
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: Validators.gmail,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _phone,
            label: 'Số điện thoại',
            hint: '09xx xxx xxx',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumber],
            validator: Validators.phone,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _password,
            label: 'Mật khẩu',
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
            label: 'Xác nhận mật khẩu',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            textInputAction: TextInputAction.next,
            validator: Validators.confirmPassword(() => _password.text),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _address,
            label: 'Địa chỉ',
            prefixIcon: Icons.home_outlined,
            maxLines: 2,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.fullStreetAddress],
            validator: Validators.address,
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Gửi OTP Gmail',
            icon: Icons.send_outlined,
            loading: _sending,
            onPressed: _sendOtp,
          ),
        ],
      ),
    );
  }
}
