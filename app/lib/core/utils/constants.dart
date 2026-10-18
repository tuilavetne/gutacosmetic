import 'package:material_ui/material_ui.dart';

/// Hằng số nghiệp vụ, khớp với backend.
abstract final class AppConstants {
  static const int deliveryFee = 25000;

  /// 1 điểm cho mỗi 10.000đ.
  static const int vndPerPoint = 10000;

  static const int otpLength = 6;
  static const Duration otpResendCooldown = Duration(seconds: 30);

  static const int minCartQuantity = 1;
  static const int maxCartQuantity = 50;

  /// Giới hạn mỗi lần nhập kho.
  static const int maxReceiveQuantity = 1000;

  /// Ngưỡng tối thiểu để cảnh báo tồn thấp (`max(lowStockThreshold, 10)`).
  static const int minLowStockAlert = 10;
  static const int expiringSoonDays = 60;

  /// Số lượng mặc định khi Sales yêu cầu bổ sung.
  static const int defaultRestockQuantity = 10;

  static const int maxReviewImages = 5;
  static const int maxReviewImageBytes = 5 * 1024 * 1024;

  static const int customerSearchMinLength = 2;
  static const Duration searchDebounce = Duration(milliseconds: 400);
  static const Duration customerSearchDebounce = Duration(milliseconds: 350);

  /// Lý do hủy đơn của khách (backend kiểm tra cùng giới hạn).
  static const int cancellationReasonMinLength = 15;
  static const int cancellationReasonMaxLength = 255;

  /// Thời hạn cửa hàng hoàn tiền đơn đã thanh toán bị hủy.
  static const int refundBusinessDays = 7;

  /// PayOS QR có hiệu lực 15 phút.
  static const Duration payosLinkLifetime = Duration(minutes: 15);

  /// Chu kỳ tự hỏi PayOS khi đang mở màn quét QR.
  static const Duration payosPollInterval = Duration(seconds: 5);
}

class ProductCategory {
  const ProductCategory(this.name, this.icon);

  final String name;
  final IconData icon;
}

const productCategories = <ProductCategory>[
  ProductCategory('Chăm Sóc Da Mặt', Icons.face_retouching_natural_outlined),
  ProductCategory('Trang Điểm', Icons.brush_outlined),
  ProductCategory('Chăm Sóc Cơ Thể', Icons.spa_outlined),
  ProductCategory('Chăm Sóc Tóc', Icons.content_cut_outlined),
  ProductCategory('Nước Hoa', Icons.local_florist_outlined),
  ProductCategory('Dụng Cụ Làm Đẹp', Icons.auto_fix_high_outlined),
];

/// Chip loại da ở màn Danh mục; `null` là "Tất cả".
const skinTypeOptions = <String>[
  'Da dầu',
  'Da khô',
  'Da nhạy cảm',
  'Da mụn',
  'Da lão hóa',
  'Da thường',
];
