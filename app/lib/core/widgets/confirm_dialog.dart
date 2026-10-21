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
  final controller = TextEditingController();
  final isRequired = minLength > 0;
  return showDialog<String>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final length = value.text.trim().length;
          final valid = length >= minLength;
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  minLines: 2,
                  maxLength: maxLength,
                  decoration: InputDecoration(
                    hintText:
                        hint ??
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
                style: destructive
                    ? FilledButton.styleFrom(
                        backgroundColor: scheme.error,
                        foregroundColor: scheme.onError,
                      )
                    : null,
                onPressed: valid
                    ? () => Navigator.of(context).pop(value.text.trim())
                    : null,
                child: Text(confirmLabel),
              ),
            ],
          );
        },
      );
    },
  ).whenComplete(controller.dispose);
}
