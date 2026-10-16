import 'package:flutter/services.dart';
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
import '../../session/session_controller.dart';
import '../data/auth_repository.dart';
import '../data/google_auth_service.dart';
import 'widgets/auth_layout.dart';

/// Đăng nhập bằng Gmail hoặc SĐT + mật khẩu, hoặc Google.
/// Sau khi lưu phiên, router tự chuyển: staff → chọn chi nhánh, còn lại →
/// trang chủ của role.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || _googleLoading) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final result = await ref
          .read(authRepositoryProvider)
          .login(identifier: _identifier.text, password: _password.text);
      TextInput.finishAutofillContext();
      await ref.read(sessionControllerProvider.notifier).startSession(result);
    } catch (e) {
      showAppSnackBar(errorMessageOf(e), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_submitting || _googleLoading) return;
    setState(() => _googleLoading = true);
    try {
      final idToken = await ref
          .read(googleAuthServiceProvider)
          .requestIdToken();
      if (idToken == null) return; // Người dùng đóng hộp chọn tài khoản.
      final result = await ref
          .read(authRepositoryProvider)
          .loginWithGoogle(idToken);
      await ref.read(sessionControllerProvider.notifier).startSession(result);
    } catch (e) {
      showAppSnackBar(errorMessageOf(e), isError: true);
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Chào mừng trở lại',
      subtitle: 'Đăng nhập để mua sắm và quản lý cửa hàng',
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Chưa có tài khoản?'),
          TextButton(
            onPressed: () => context.push(AppRoutes.register),
            child: const Text('Tạo tài khoản'),
          ),
        ],
      ),
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _identifier,
                label: 'Gmail hoặc số điện thoại',
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [
                  AutofillHints.email,
                  AutofillHints.telephoneNumber,
                ],
                validator: Validators.identifier,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _password,
                label: 'Mật khẩu',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: Validators.loginPassword,
                onFieldSubmitted: (_) => _submit(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                  child: const Text('Quên mật khẩu?'),
                ),
              ),
              const SizedBox(height: 4),
              AppButton(
                label: 'Đăng nhập',
                loading: _submitting,
                onPressed: _submit,
              ),
              const OrDivider(),
              GoogleSignInButton(
                loading: _googleLoading,
                onPressed: _signInWithGoogle,
              ),
              const SizedBox(height: 8),
              const Text(
                'Đăng nhập Google sẽ tự tạo tài khoản khách hàng nếu Gmail chưa đăng ký.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
