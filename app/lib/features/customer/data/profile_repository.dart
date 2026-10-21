import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/utils/validators.dart';
import '../../shared/models/models.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(apiClientProvider)),
);

/// `/users/profile*` — user tự sửa hồ sơ của mình.
class ProfileRepository {
  ProfileRepository(this._api);

  final ApiClient _api;

  /// Dung lượng ảnh đại diện tối đa backend nhận.
  static const maxAvatarBytes = 5 * 1024 * 1024;

  /// `PUT /users/profile` — chỉ gửi các trường khác `null`.
  ///
  /// Backend báo `PHONE_EXISTS` (409) nếu SĐT đã thuộc tài khoản khác.
  Future<AppUser> updateProfile({
    String? fullName,
    String? phone,
    String? address,
  }) async {
    final json = await _api.put(
      '/users/profile',
      data: {
        'fullName': ?fullName?.trim(),
        'phone': ?(phone == null ? null : Validators.normalizePhone(phone)),
        'address': ?address?.trim(),
      },
    );
    return AppUser.fromJson(requireObject(json, 'user'));
  }

  /// `GET /users/phone-available` — `true` nếu SĐT chưa thuộc tài khoản
  /// khác (SĐT của chính mình cũng tính là dùng được).
  Future<bool> isPhoneAvailable(String phone) async {
    final json = await _api.get(
      '/users/phone-available',
      query: {'phone': Validators.normalizePhone(phone)},
    );
    return json['available'] == true;
  }

  /// `PUT /users/profile/avatar` (multipart, field `avatar`) — JPG/PNG/WEBP.
  Future<AppUser> uploadAvatar({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
  }) async {
    final form = FormData.fromMap({
      'avatar': MultipartFile.fromBytes(
        bytes,
        filename: fileName,
        contentType: DioMediaType.parse(mimeType),
      ),
    });
    final json = await _api.putMultipart('/users/profile/avatar', form);
    return AppUser.fromJson(requireObject(json, 'user'));
  }

  /// `DELETE /users/profile/avatar` — quay về ảnh chữ cái đầu.
  Future<AppUser> removeAvatar() async {
    final json = await _api.delete('/users/profile/avatar');
    return AppUser.fromJson(requireObject(json, 'user'));
  }
}
