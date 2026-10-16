import 'package:material_ui/material_ui.dart';

/// Messenger toàn cục để hiện SnackBar từ nơi không có BuildContext
/// (ví dụ interceptor khi phiên hết hạn).
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void showAppSnackBar(String message, {bool isError = false}) {
  final messenger = rootScaffoldMessengerKey.currentState;
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? const Color(0xFFC33E53) : null,
      ),
    );
}
