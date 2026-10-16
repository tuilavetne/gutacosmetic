import 'package:material_ui/material_ui.dart';

import '../network/api_exception.dart';
import 'app_messenger.dart';

enum AppButtonVariant { filled, outlined, text, danger }

/// Nút tự chuyển sang loading và khóa trong lúc `onPressed` (async) chạy,
/// tránh gửi request hai lần. Lỗi được hiện bằng SnackBar.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.filled,
    this.expand = true,
    this.loading = false,
  });

  final String label;
  final Future<void> Function()? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool expand;

  /// Loading do bên ngoài điều khiển (ví dụ khi submit form).
  final bool loading;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _busy = false;

  bool get _loading => _busy || widget.loading;

  Future<void> _handlePressed() async {
    if (_loading || widget.onPressed == null) return;
    setState(() => _busy = true);
    try {
      await widget.onPressed!();
    } catch (e) {
      showAppSnackBar(errorMessageOf(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onPressed = widget.onPressed == null || _loading
        ? null
        : _handlePressed;
    final spinnerColor =
        widget.variant == AppButtonVariant.filled ||
            widget.variant == AppButtonVariant.danger
        ? scheme.onPrimary
        : scheme.primary;

    final Widget child = _loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: spinnerColor,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(widget.label, overflow: TextOverflow.ellipsis),
              ),
            ],
          );

    final Widget button = switch (widget.variant) {
      AppButtonVariant.filled => FilledButton(
        onPressed: onPressed,
        child: child,
      ),
      AppButtonVariant.danger => FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.error,
          foregroundColor: scheme.onError,
        ),
        onPressed: onPressed,
        child: child,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: onPressed,
        child: child,
      ),
      AppButtonVariant.text => TextButton(onPressed: onPressed, child: child),
    };

    return widget.expand
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
