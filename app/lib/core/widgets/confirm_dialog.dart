import 'package:material_ui/material_ui.dart';

/// Hỏi xác nhận trước hành động có hậu quả (hủy đơn, trừ kho, khóa tài khoản...).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Xác nhận',
  String cancelLabel = 'Quay lại',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// Hỏi xác nhận kèm ô nhập lý do. Trả về `null` nếu hủy.
///
/// [minLength] > 0 thì lý do bắt buộc: nút xác nhận bị khóa tới khi lý do
/// (đã bỏ khoảng trắng hai đầu) đủ dài, kèm bộ đếm `8/15 ký tự`.
Future<String?> showReasonDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Xác nhận',
  String? hint,
  int minLength = 0,
  int? maxLength,
  bool destructive = true,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _ReasonDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      hint: hint,
      minLength: minLength,
      maxLength: maxLength,
      destructive: destructive,
    ),
  );
}

/// Hộp thoại tự giữ controller: chỉ dispose khi widget rời cây, sau hiệu ứng
/// đóng — dispose ngay khi `pop` làm TextField dùng controller đã hủy.
class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.hint,
    required this.minLength,
    required this.maxLength,
    required this.destructive,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String? hint;
  final int minLength;
  final int? maxLength;
  final bool destructive;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final minLength = widget.minLength;
    final maxLength = widget.maxLength;
    final isRequired = minLength > 0;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        final length = value.text.trim().length;
        final valid = length >= minLength;
        return AlertDialog(
          title: Text(widget.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.message),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                maxLines: 3,
                minLines: 2,
                maxLength: maxLength,
                decoration: InputDecoration(
                  hintText:
                      widget.hint ??
                      (isRequired
                          ? 'Lý do (bắt buộc, ít nhất $minLength ký tự)'
                          : 'Lý do (không bắt buộc)'),
                  counterText: isRequired && !valid
                      ? '$length/$minLength ký tự'
                      : (maxLength == null ? '' : null),
                  counterStyle: isRequired && !valid
                      ? TextStyle(color: scheme.error)
                      : null,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Quay lại'),
            ),
            FilledButton(
              style: widget.destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: scheme.error,
                      foregroundColor: scheme.onError,
                    )
                  : null,
              onPressed: valid
                  ? () => Navigator.of(context).pop(value.text.trim())
                  : null,
              child: Text(widget.confirmLabel),
            ),
          ],
        );
      },
    );
  }
}
