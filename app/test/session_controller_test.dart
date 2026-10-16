import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/core/storage/local_storage.dart';
import 'package:gutacosmetic/core/storage/token_storage.dart';
import 'package:gutacosmetic/features/session/session_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryTokenStorage implements TokenStorage {
  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String value) async => token = value;

  @override
  Future<void> clear() async => token = null;
}

void main() {
  test('Không có token → phiên ở trạng thái đã đăng xuất', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        tokenStorageProvider.overrideWithValue(_MemoryTokenStorage()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(sessionControllerProvider).isRestoring, isTrue);
    await Future<void>.delayed(Duration.zero);
    final state = container.read(sessionControllerProvider);
    expect(state.isRestoring, isFalse);
    expect(state.isAuthenticated, isFalse);
  });
}
