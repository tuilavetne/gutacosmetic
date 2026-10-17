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
import '../../../core/widgets/confirm_dialog.dart';
import '../../auth/data/auth_repository.dart';
import '../../session/session_controller.dart';
import '../../shared/models/models.dart';
import 'widgets/order_widgets.dart';

/// Điều kiện mật khẩu mạnh (khớp `Validators.password` / backend).
typedef PasswordRule = ({String label, bool Function(String) test});

final passwordRules = <PasswordRule>[
  (label: '8–72 ký tự', test: (v) => v.length >= 8 && v.length <= 72),
  (label: 'Có chữ hoa', test: (v) => v.contains(RegExp('[A-Z]'))),
  (label: 'Có chữ thường', test: (v) => v.contains(RegExp('[a-z]'))),
  (label: 'Có chữ số', test: (v) => v.contains(RegExp(r'\d'))),
];

/// Đổi mật khẩu khi đã đăng nhập. Tài khoản tạo bằng Google chưa có mật khẩu
/// thì "Đặt mật khẩu" (không cần mật khẩu hiện tại).
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  /// Tài khoản Google có thể chưa có mật khẩu; backend báo
  /// `CURRENT_PASSWORD_REQUIRED` nếu thật ra đã có thì hiện thêm ô này.
  late bool _needsCurrent =
      ref.read(currentUserProvider)?.authProvider != AuthProvider.google;

  /// Lỗi từ máy chủ, hiện dưới đúng ô nhập.
  String? _currentError;
  String? _nextError;
  String? _confirmError;

  @override
  void initState() {
    super.initState();
    _next.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _clearServerErrors() {
    if (_currentError == null && _nextError == null && _confirmError == null) {
      return;
    }
    setState(() => _currentError = _nextError = _confirmError = null);
  }

  Future<void> _submit() async {
    _clearServerErrors();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final session = ref.read(sessionControllerProvider.notifier);
    try {
      final result = await ref
          .read(authRepositoryProvider)
          .changePassword(
            currentPassword: _needsCurrent ? _current.text : null,
            newPassword: _next.text,
            confirmPassword: _confirm.text,
          );
      await session.renewSession(result);
    } on ApiException catch (e) {
      final message = errorMessageOf(e);
      switch (e.code) {
        case 'CURRENT_PASSWORD_REQUIRED':
          setState(() {
            _needsCurrent = true;
            _currentError = 'Tài khoản đã có mật khẩu — nhập mật khẩu hiện tại';
          });
        case 'INVALID_CURRENT_PASSWORD':
          setState(() => _currentError = message);
        case 'SAME_PASSWORD' || 'WEAK_PASSWORD':
          setState(() => _nextError = message);
        case 'PASSWORD_MISMATCH':
          setState(() => _confirmError = message);
        default:
          rethrow;
      }
      return;
    }
    if (!mounted) return;
    showAppSnackBar('Đã đổi mật khẩu. Các thiết bị khác cần đăng nhập lại.');
    context.pop();
  }

  Future<void> _forgotPassword() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Quên mật khẩu hiện tại?',
      message:
          'Bạn sẽ được đăng xuất để đặt lại mật khẩu bằng mã OTP gửi về '
          'Gmail. Giỏ hàng vẫn được giữ nguyên.',
      confirmLabel: 'Đăng xuất & đặt lại',
    );
    if (!ok || !mounted) return;
    final router = GoRouter.of(context);
    await ref.read(sessionControllerProvider.notifier).signOut();
    router.go(AppRoutes.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    final isSetup = !_needsCurrent;
    final value = _next.text;

    return Scaffold(
      appBar: AppBar(title: Text(isSetup ? 'Đặt mật khẩu' : 'Đổi mật khẩu')),
      body: OrderContentWidth(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _Notice(
                icon: isSetup ? Icons.key_outlined : Icons.shield_outlined,
                text: isSetup
                    ? 'Tài khoản đăng nhập bằng Google chưa có mật khẩu. Đặt '
                          'mật khẩu để có thể đăng nhập bằng Gmail và mật khẩu.'
                    : 'Sau khi đổi, các thiết bị khác đang đăng nhập tài khoản '
                          'này sẽ phải đăng nhập lại.',
              ),
              const SizedBox(height: 20),
              if (_needsCurrent) ...[
                AppTextField(
                  label: 'Mật khẩu hiện tại',
                  controller: _current,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.next,
                  forceErrorText: _currentError,
                  onChanged: (_) => _clearServerErrors(),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Vui lòng nhập mật khẩu hiện tại'
                      : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text('Quên mật khẩu hiện tại?'),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              AppTextField(
                label: 'Mật khẩu mới',
                controller: _next,
                isPassword: true,
                prefixIcon: Icons.lock_reset,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                forceErrorText: _nextError,
                onChanged: (_) => _clearServerErrors(),
                validator: (v) {
                  final error = Validators.password(v);
                  if (error != null) return error;
                  if (_needsCurrent && v == _current.text) {
                    return 'Mật khẩu mới phải khác mật khẩu hiện tại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  for (final rule in passwordRules)
                    _RuleChip(label: rule.label, ok: rule.test(value)),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Nhập lại mật khẩu mới',
                controller: _confirm,
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                forceErrorText: _confirmError,
                onChanged: (_) => _clearServerErrors(),
                onFieldSubmitted: (_) => _submit(),
                validator: Validators.confirmPassword(() => _next.text),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        child: AppButton(
          label: isSetup ? 'Đặt mật khẩu' : 'Đổi mật khẩu',
          icon: Icons.check,
          onPressed: _submit,
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}

class _RuleChip extends StatelessWidget {
  const _RuleChip({required this.label, required this.ok});

  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.success : AppColors.muted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }
}
