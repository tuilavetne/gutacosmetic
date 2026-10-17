import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/error_messages.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_messenger.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../session/session_controller.dart';
import '../../shared/models/models.dart';
import '../data/profile_repository.dart';
import 'widgets/member_avatar.dart';

/// Sửa ảnh đại diện, họ tên, SĐT, địa chỉ nhận hàng. Gmail chỉ xem (dùng để
/// đăng nhập).
///
/// Ảnh đại diện được lưu ngay khi chọn; các ô còn lại lưu bằng nút
/// "Lưu thay đổi".
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

enum _Field { fullName, phone, address }

/// Trạng thái kiểm tra trùng SĐT trong lúc gõ.
enum _PhoneCheck { idle, checking, available }

/// Chờ người dùng ngừng gõ bao lâu thì mới hỏi máy chủ.
const _phoneCheckDelay = Duration(milliseconds: 500);

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AppUser _original;
  late final _fullName = TextEditingController(text: _original.fullName);
  late final _phone = TextEditingController(
    text: Validators.localPhone(_original.phone),
  );
  late final _address = TextEditingController(text: _original.address ?? '');
  late final _email = TextEditingController(text: _original.email);

  /// Lỗi máy chủ gắn vào từng ô (SĐT đã được đăng ký...).
  final _serverErrors = <_Field, String>{};
  bool _saved = false;

  Timer? _phoneTimer;
  _PhoneCheck _phoneCheck = _PhoneCheck.idle;

  bool _avatarBusy = false;

  @override
  void initState() {
    super.initState();
    _original = ref.read(currentUserProvider)!;
  }

  @override
  void dispose() {
    _phoneTimer?.cancel();
    for (final c in [_fullName, _phone, _address, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  String? get _changedFullName {
    final v = _fullName.text.trim();
    return v == _original.fullName ? null : v;
  }

  String? get _changedPhone {
    final v = _phone.text.trim();
    final original = _original.phone ?? '';
    if (v.isEmpty && original.isEmpty) return null;
    return Validators.canonicalPhone(v) == Validators.canonicalPhone(original)
        ? null
        : v;
  }

  String? get _changedAddress {
    final v = _address.text.trim();
    return v == (_original.address ?? '').trim() ? null : v;
  }

  bool get _dirty =>
      _changedFullName != null ||
      _changedPhone != null ||
      _changedAddress != null;

  /// SĐT/địa chỉ chưa từng có (ví dụ tài khoản Google) thì được bỏ trống;
  /// đã có thì không xóa được — backend không cho lưu giá trị rỗng.
  FormFieldValidator<String> _optionalIfUnset(
    String? original,
    FormFieldValidator<String> validator,
  ) => (value) {
    final empty = value == null || value.trim().isEmpty;
    if (empty && (original ?? '').trim().isEmpty) return null;
    return validator(value);
  };

  void _onChanged(_Field field) => setState(() => _serverErrors.remove(field));

  /// Gõ xong SĐT mới (đúng định dạng) thì hỏi máy chủ xem đã có ai dùng chưa.
  void _onPhoneChanged(String value) {
    _phoneTimer?.cancel();
    final shouldCheck =
        _changedPhone != null && Validators.phone(value) == null;
    setState(() {
      _serverErrors.remove(_Field.phone);
      _phoneCheck = shouldCheck ? _PhoneCheck.checking : _PhoneCheck.idle;
    });
    if (!shouldCheck) return;
    _phoneTimer = Timer(_phoneCheckDelay, () => _checkPhone(value));
  }

  Future<void> _checkPhone(String phone) async {
    bool available;
    try {
      available = await ref
          .read(profileRepositoryProvider)
          .isPhoneAvailable(phone);
    } catch (_) {
      // Lỗi mạng: bỏ qua, khi bấm Lưu máy chủ vẫn kiểm tra lại.
      if (mounted) setState(() => _phoneCheck = _PhoneCheck.idle);
      return;
    }
    // Người dùng đã gõ tiếp trong lúc chờ → kết quả này không còn đúng.
    if (!mounted ||
        Validators.canonicalPhone(_phone.text) !=
            Validators.canonicalPhone(phone)) {
      return;
    }
    setState(() {
      _phoneCheck = available ? _PhoneCheck.available : _PhoneCheck.idle;
      if (!available) {
        _serverErrors[_Field.phone] = translateErrorCode('PHONE_EXISTS', null)!;
      }
    });
  }

  Widget? get _phoneSuffix => switch (_phoneCheck) {
    _PhoneCheck.checking => const Padding(
      padding: EdgeInsets.all(14),
      child: SizedBox.square(
        dimension: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
    _PhoneCheck.available => const Icon(
      Icons.check_circle,
      color: AppColors.success,
    ),
    _PhoneCheck.idle => null,
  };

  // ---- Ảnh đại diện ----

  Future<void> _showAvatarSheet(AppUser user) async {
    final hasAvatar = (user.avatarUrl ?? '').isNotEmpty;
    final action = await showModalBottomSheet<_AvatarAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Chọn ảnh từ thư viện'),
              onTap: () => Navigator.pop(context, _AvatarAction.gallery),
            ),
            // Trình duyệt không mở thẳng camera được — dùng thư viện.
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Chụp ảnh mới'),
                onTap: () => Navigator.pop(context, _AvatarAction.camera),
              ),
            if (hasAvatar)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.accent,
                ),
                title: const Text(
                  'Gỡ ảnh đại diện',
                  style: TextStyle(color: AppColors.accent),
                ),
                onTap: () => Navigator.pop(context, _AvatarAction.remove),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    switch (action) {
      case _AvatarAction.gallery:
        await _pickAvatar(ImageSource.gallery);
      case _AvatarAction.camera:
        await _pickAvatar(ImageSource.camera);
      case _AvatarAction.remove:
        await _removeAvatar();
      case null:
        break;
    }
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final XFile? file;
    try {
      file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (_) {
      showAppSnackBar(
        'Không mở được thư viện ảnh hoặc camera. Kiểm tra quyền truy cập.',
        isError: true,
      );
      return;
    }
    if (file == null) return; // Người dùng bỏ chọn.

    final mimeType = _avatarMimeType(file);
    if (mimeType == null) {
      showAppSnackBar(
        translateErrorCode('INVALID_IMAGE_TYPE', null)!,
        isError: true,
      );
      return;
    }
    final bytes = await file.readAsBytes();
    if (bytes.length > ProfileRepository.maxAvatarBytes) {
      showAppSnackBar(
        translateErrorCode('IMAGE_TOO_LARGE', null)!,
        isError: true,
      );
      return;
    }

    await _runAvatarTask(
      () => ref
          .read(profileRepositoryProvider)
          .uploadAvatar(bytes: bytes, fileName: file!.name, mimeType: mimeType),
      success: 'Đã cập nhật ảnh đại diện.',
    );
  }

  Future<void> _removeAvatar() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Gỡ ảnh đại diện?',
      message: 'Ảnh đại diện sẽ trở về chữ cái đầu của tên bạn.',
      confirmLabel: 'Gỡ ảnh',
      destructive: true,
    );
    if (!confirmed) return;
    await _runAvatarTask(
      () => ref.read(profileRepositoryProvider).removeAvatar(),
      success: 'Đã gỡ ảnh đại diện.',
    );
  }

  Future<void> _runAvatarTask(
    Future<AppUser> Function() task, {
    required String success,
  }) async {
    setState(() => _avatarBusy = true);
    try {
      final user = await task();
      await ref.read(sessionControllerProvider.notifier).updateUser(user);
      showAppSnackBar(success);
    } catch (e) {
      showAppSnackBar(errorMessageOf(e), isError: true);
    } finally {
      if (mounted) setState(() => _avatarBusy = false);
    }
  }

  /// MIME backend nhận; `null` nếu không phải JPG/PNG/WEBP.
  static String? _avatarMimeType(XFile file) {
    final fromPicker = file.mimeType?.toLowerCase();
    if (fromPicker != null && fromPicker.startsWith('image/')) {
      return const {
            'image/jpeg',
            'image/jpg',
            'image/png',
            'image/webp',
          }.contains(fromPicker)
          ? fromPicker
          : null;
    }
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
    // Ảnh đã nén lại (imageQuality) trên Android/iOS luôn là JPEG.
    return kIsWeb ? null : 'image/jpeg';
  }

  static _Field? _fieldOf(String? code) => switch (code) {
    'PHONE_EXISTS' || 'INVALID_PHONE' => _Field.phone,
    'INVALID_FULL_NAME' => _Field.fullName,
    'INVALID_ADDRESS' => _Field.address,
    _ => null,
  };

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    try {
      final user = await ref
          .read(profileRepositoryProvider)
          .updateProfile(
            fullName: _changedFullName,
            phone: _changedPhone,
            address: _changedAddress,
          );
      await ref.read(sessionControllerProvider.notifier).updateUser(user);
      if (!mounted) return;
      setState(() => _saved = true);
      showAppSnackBar('Đã cập nhật thông tin cá nhân.');
      _leave();
    } on ApiException catch (e) {
      final field = _fieldOf(e.code);
      // Lỗi khác (mạng, máy chủ...) để AppButton hiện SnackBar.
      if (field == null) rethrow;
      // Lỗi của một ô thì hiện ngay dưới ô đó — SnackBar sẽ che nút Lưu.
      if (mounted) setState(() => _serverErrors[field] = e.message);
    }
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.customerAccount);
    }
  }

  Future<void> _confirmDiscard() async {
    final discard = await showConfirmDialog(
      context,
      title: 'Bỏ thay đổi?',
      message: 'Các thay đổi chưa lưu sẽ bị mất.',
      confirmLabel: 'Bỏ thay đổi',
      cancelLabel: 'Tiếp tục sửa',
      destructive: true,
    );
    if (discard && mounted) {
      setState(() => _saved = true); // Cho phép pop.
      _leave();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = _saved || !_dirty;
    // Ảnh đại diện lưu ngay nên lấy từ session, không từ bản gốc.
    final user = ref.watch(currentUserProvider) ?? _original;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Thông tin cá nhân')),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  Center(
                    child: Tooltip(
                      message: 'Đổi ảnh đại diện',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: _avatarBusy
                            ? null
                            : () => _showAvatarSheet(user),
                        child: MemberAvatar(
                          user: user,
                          size: 96,
                          busy: _avatarBusy,
                          badge: const _CameraBadge(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhấn vào ảnh để thay đổi ảnh đại diện',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(child: MemberTierBadge(points: user.points)),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _SectionLabel('Thông tin cơ bản'),
                        AppTextField(
                          controller: _fullName,
                          label: 'Họ và tên',
                          prefixIcon: Icons.badge_outlined,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
                          validator: Validators.fullName,
                          forceErrorText: _serverErrors[_Field.fullName],
                          onChanged: (_) => _onChanged(_Field.fullName),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _email,
                          label: 'Gmail',
                          prefixIcon: Icons.mail_outline,
                          enabled: false,
                          helperText:
                              'Gmail dùng để đăng nhập, không thể thay đổi.',
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
                          validator: _optionalIfUnset(
                            _original.phone,
                            Validators.phone,
                          ),
                          forceErrorText: _serverErrors[_Field.phone],
                          helperText: _phoneCheck == _PhoneCheck.available
                              ? 'Số điện thoại có thể sử dụng.'
                              : null,
                          suffixIcon: _phoneSuffix,
                          onChanged: _onPhoneChanged,
                        ),
                        const SizedBox(height: 24),
                        const _SectionLabel('Địa chỉ giao hàng'),
                        AppTextField(
                          controller: _address,
                          label: 'Địa chỉ nhận hàng',
                          hint: 'Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành',
                          prefixIcon: Icons.location_on_outlined,
                          keyboardType: TextInputType.streetAddress,
                          maxLines: 3,
                          maxLength: 250,
                          autofillHints: const [
                            AutofillHints.fullStreetAddress,
                          ],
                          validator: _optionalIfUnset(
                            _original.address,
                            Validators.address,
                          ),
                          forceErrorText: _serverErrors[_Field.address],
                          onChanged: (_) => _onChanged(_Field.address),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        size: 16,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Thông tin của bạn được bảo mật theo chính sách '
                          'GUTA Cosmetic và không chia sẻ cho bên thứ ba.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Lưu thay đổi',
                    onPressed: _dirty ? _save : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.muted,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

enum _AvatarAction { gallery, camera, remove }

class _CameraBadge extends StatelessWidget {
  const _CameraBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3B39),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 2),
      ),
      child: const Icon(Icons.photo_camera, color: Colors.white, size: 16),
    );
  }
}
