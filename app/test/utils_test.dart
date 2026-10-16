import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/core/utils/formatters.dart';
import 'package:gutacosmetic/core/utils/validators.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('vi_VN'));

  group('Validators', () {
    test('gmail', () {
      expect(Validators.gmail('An.Nguyen@Gmail.com'), isNull);
      expect(Validators.gmail('a@yahoo.com'), isNotNull);
    });

    test('số điện thoại VN, bỏ ký tự ().- và khoảng trắng', () {
      expect(Validators.phone('0912 345 678'), isNull);
      expect(Validators.phone('+84 (912) 345-678'), isNull);
      expect(Validators.phone('0212345678'), isNotNull);
      expect(Validators.phone('091234567'), isNotNull);
      expect(Validators.normalizePhone('(091) 234.5678'), '0912345678');
    });

    test('mật khẩu', () {
      expect(Validators.password('Abcdefg1'), isNull);
      expect(Validators.password('abcdefg1'), isNotNull);
      expect(Validators.password('Abc1'), isNotNull);
      expect(Validators.password('A1${'a' * 71}'), isNotNull);
    });

    test('định danh đăng nhập', () {
      expect(Validators.identifier('abc@gmail.com'), isNull);
      expect(Validators.identifier('0987654321'), isNull);
      expect(
        Validators.normalizeIdentifier(' ABC@gmail.com '),
        'abc@gmail.com',
      );
      expect(Validators.normalizeIdentifier('098 765 4321'), '0987654321');
    });

    test('otp, họ tên, địa chỉ', () {
      expect(Validators.otp('123456'), isNull);
      expect(Validators.otp('12345a'), isNotNull);
      expect(Validators.fullName('A'), isNotNull);
      expect(Validators.address('Q1'), isNotNull);
    });
  });

  group('Formatters', () {
    test('tiền VND', () {
      expect(formatVnd(320000), '320.000đ');
      expect(formatVnd(0), '0đ');
    });

    test('HSD', () {
      expect(
        formatExpiry(daysUntilExpiry: 12, expiryDateLabel: '2026-10-25'),
        'Còn 12 ngày · HSD 2026-10-25',
      );
      expect(
        formatExpiry(daysUntilExpiry: -3, expiryDateLabel: '2026-10-10'),
        'Đã quá hạn 3 ngày · HSD 2026-10-10',
      );
    });

    test('ngày gửi API', () {
      expect(toApiDate(DateTime(2027, 1, 5)), '2027-01-05');
    });

    test('đếm ngược', () {
      expect(formatCountdown(const Duration(minutes: 14, seconds: 5)), '14:05');
    });

    test('% giảm giá', () {
      expect(discountPercentOf(price: 80000, originalPrice: 100000), 20);
      expect(discountPercentOf(price: 80000), isNull);
    });
  });
}
