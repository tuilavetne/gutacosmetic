import 'package:intl/intl.dart';

final _vndFormat = NumberFormat.decimalPattern('vi_VN');

/// `320000` → `320.000đ`.
String formatVnd(num? value) => '${_vndFormat.format((value ?? 0).round())}đ';

/// `1234` → `1.234`.
String formatNumber(num? value) => _vndFormat.format((value ?? 0).round());

/// `dd/MM HH:mm` theo giờ máy.
String formatDateTime(DateTime? value) =>
    value == null ? '—' : DateFormat('dd/MM HH:mm').format(value.toLocal());

/// `dd/MM/yyyy HH:mm` theo giờ máy.
String formatFullDateTime(DateTime? value) => value == null
    ? '—'
    : DateFormat('dd/MM/yyyy HH:mm').format(value.toLocal());

/// `dd/MM/yyyy` theo giờ máy.
String formatDate(DateTime? value) =>
    value == null ? '—' : DateFormat('dd/MM/yyyy').format(value.toLocal());

/// Ví dụ: `Thứ Ba, 13/10/2026`.
String formatLongDate(DateTime value) => toBeginningOfSentenceCase(
  DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(value.toLocal()),
);

/// Định dạng gửi lên API cho ngày hết hạn: `YYYY-MM-DD` (theo ngày local).
String toApiDate(DateTime value) {
  final local = value.isUtc ? value.toLocal() : value;
  return DateFormat('yyyy-MM-dd').format(local);
}

/// `mm:ss` cho đồng hồ đếm ngược.
String formatCountdown(Duration remaining) {
  if (remaining.isNegative) return '00:00';
  final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
  final hours = remaining.inHours;
  return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
}

/// Thời gian tương đối: "Vừa xong", "5 phút trước", "3 ngày trước"...
String formatRelativeTime(DateTime? value, {DateTime? now}) {
  if (value == null) return '';
  final diff = (now ?? DateTime.now()).difference(value.toLocal());
  if (diff.inSeconds < 60) return 'Vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  if (diff.inDays < 30) return '${diff.inDays} ngày trước';
  if (diff.inDays < 365) return '${diff.inDays ~/ 30} tháng trước';
  return formatDate(value);
}

/// "Còn N ngày · HSD yyyy-mm-dd" hoặc "Đã quá hạn N ngày · HSD …".
String formatExpiry({int? daysUntilExpiry, String? expiryDateLabel}) {
  final label = expiryDateLabel == null || expiryDateLabel.isEmpty
      ? ''
      : ' · HSD $expiryDateLabel';
  if (daysUntilExpiry == null) {
    return label.isEmpty ? 'Chưa có HSD' : 'HSD $expiryDateLabel';
  }
  if (daysUntilExpiry < 0) return 'Đã quá hạn ${-daysUntilExpiry} ngày$label';
  if (daysUntilExpiry == 0) return 'Hết hạn hôm nay$label';
  return 'Còn $daysUntilExpiry ngày$label';
}

/// Phần trăm giảm từ giá gốc, làm tròn; `null` nếu không giảm.
int? discountPercentOf({required num price, num? originalPrice}) {
  if (originalPrice == null || originalPrice <= 0 || originalPrice <= price) {
    return null;
  }
  return ((1 - price / originalPrice) * 100).round();
}
