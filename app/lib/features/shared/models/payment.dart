import 'dart:convert';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';
import 'order.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

/// Link thanh toán PayOS.
@freezed
abstract class PayosPayment with _$PayosPayment {
  const PayosPayment._();

  const factory PayosPayment({
    String? checkoutUrl,
    @FlexibleDateTimeConverter() DateTime? expiredAt,
    String? paymentLinkId,

    /// Data URL: `data:image/png;base64,...`.
    String? qrImage,

    /// Chuỗi VietQR thô.
    String? qrCode,
  }) = _PayosPayment;

  factory PayosPayment.fromJson(Map<String, dynamic> json) =>
      _$PayosPaymentFromJson(json);

  /// Giải mã `qrImage` để hiển thị bằng `Image.memory`.
  Uint8List? get qrImageBytes {
    final raw = qrImage;
    if (raw == null || raw.isEmpty) return null;
    final comma = raw.indexOf(',');
    final base64Part = comma >= 0 ? raw.substring(comma + 1) : raw;
    try {
      return base64Decode(base64Part.trim());
    } catch (_) {
      return null;
    }
  }

  Duration remaining([DateTime? now]) {
    final expiry = expiredAt;
    if (expiry == null) return Duration.zero;
    return expiry.difference(now ?? DateTime.now());
  }
}

/// Response của `POST .../sync`.
@freezed
abstract class PayosSyncResult with _$PayosSyncResult {
  const factory PayosSyncResult({required Order order, String? payosStatus}) =
      _PayosSyncResult;

  factory PayosSyncResult.fromJson(Map<String, dynamic> json) =>
      _$PayosSyncResultFromJson(json);
}

/// Response của `POST /orders/online`.
@freezed
abstract class PlacedOrder with _$PlacedOrder {
  const factory PlacedOrder({required Order order, PayosPayment? payment}) =
      _PlacedOrder;

  factory PlacedOrder.fromJson(Map<String, dynamic> json) =>
      _$PlacedOrderFromJson(json);
}
