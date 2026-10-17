/// Validation phía client — khớp quy tắc của backend.
abstract final class Validators {
  static final _gmail = RegExp(
    r'^[a-z0-9._%+-]+@gmail\.com$',
    caseSensitive: false,
  );
  static final _vnPhone = RegExp(r'^(?:\+84|0)(3|5|7|8|9)\d{8}$');
  static final _phoneNoise = RegExp(r'[\s().-]');
  static final _otp = RegExp(r'^\d{6}$');
  static final _upper = RegExp(r'[A-Z]');
  static final _lower = RegExp(r'[a-z]');
  static final _digit = RegExp(r'\d');

  /// Bỏ khoảng trắng và các ký tự `().-` trước khi kiểm tra/gửi.
  static String normalizePhone(String value) =>
      value.replaceAll(_phoneNoise, '');

  /// Dạng backend lưu: `0912 345 678` → `+84912345678` (giống
  /// `normalizePhone` của backend). Dùng để so sánh SĐT đã đổi hay chưa.
  static String canonicalPhone(String value) {
    final phone = normalizePhone(value.trim());
    return phone.startsWith('0') ? '+84${phone.substring(1)}' : phone;
  }

  /// Dạng quen thuộc để hiện trong ô nhập: `+84912345678` → `0912345678`.
  static String localPhone(String? value) {
    final phone = normalizePhone(value?.trim() ?? '');
    return phone.startsWith('+84') ? '0${phone.substring(3)}' : phone;
  }

  static String normalizeEmail(String value) => value.trim().toLowerCase();

  static bool isGmail(String value) => _gmail.hasMatch(value.trim());
  static bool isVnPhone(String value) =>
      _vnPhone.hasMatch(normalizePhone(value));

  /// Đăng nhập nhận Gmail hoặc SĐT: chứa `@` thì coi là email.
  static bool looksLikeEmail(String value) => value.contains('@');

  /// Chuẩn hóa định danh đăng nhập trước khi gửi.
  static String normalizeIdentifier(String value) => looksLikeEmail(value)
      ? normalizeEmail(value)
      : normalizePhone(value.trim());

  static String? required(String? value, [String field = 'Trường này']) =>
      (value == null || value.trim().isEmpty)
      ? '$field không được để trống'
      : null;

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Vui lòng nhập họ tên';
    if (v.length < 2 || v.length > 80) return 'Họ tên dài từ 2 đến 80 ký tự';
    return null;
  }

  static String? gmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Vui lòng nhập Gmail';
    if (!isGmail(v)) return 'Chỉ chấp nhận địa chỉ @gmail.com';
    return null;
  }

  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Vui lòng nhập số điện thoại';
    if (!isVnPhone(v)) return 'Số điện thoại Việt Nam không hợp lệ';
    return null;
  }

  static String? identifier(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Vui lòng nhập Gmail hoặc số điện thoại';
    return looksLikeEmail(v) ? gmail(v) : phone(v);
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (v.length < 8 || v.length > 72) return 'Mật khẩu dài từ 8 đến 72 ký tự';
    if (!_upper.hasMatch(v) || !_lower.hasMatch(v) || !_digit.hasMatch(v)) {
      return 'Mật khẩu cần có chữ hoa, chữ thường và chữ số';
    }
    return null;
  }

  /// Chỉ kiểm tra không rỗng — dùng ở màn Login (không lộ quy tắc mật khẩu).
  static String? loginPassword(String? value) =>
      (value == null || value.isEmpty) ? 'Vui lòng nhập mật khẩu' : null;

  static String? Function(String?) confirmPassword(
    String Function() original,
  ) => (value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập lại mật khẩu';
    if (value != original()) return 'Mật khẩu xác nhận không khớp';
    return null;
  };

  static String? address(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Vui lòng nhập địa chỉ';
    if (v.length < 5 || v.length > 250) return 'Địa chỉ dài từ 5 đến 250 ký tự';
    return null;
  }

  static String? otp(String? value) {
    final v = value?.trim() ?? '';
    if (!_otp.hasMatch(v)) return 'Mã OTP gồm đúng 6 chữ số';
    return null;
  }

  /// Số nguyên trong khoảng [min, max].
  static String? intInRange(
    String? value, {
    required int min,
    required int max,
    String field = 'Số lượng',
  }) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null) return '$field phải là số nguyên';
    if (parsed < min || parsed > max) return '$field từ $min đến $max';
    return null;
  }

  /// Số tiền không âm (giá bán, giá vốn).
  static String? nonNegativeMoney(
    String? value, {
    bool allowEmpty = false,
    String field = 'Giá',
  }) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return allowEmpty ? null : '$field không được để trống';
    final parsed = int.tryParse(v.replaceAll('.', '').replaceAll(',', ''));
    if (parsed == null) return '$field phải là số nguyên';
    if (parsed < 0) return '$field không được âm';
    return null;
  }
}
