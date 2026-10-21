import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/models.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => PaymentRepository(ref.watch(apiClientProvider)),
);

/// Repository quản lý thanh toán trực tuyến và POS PayOS.
class PaymentRepository {
  PaymentRepository(this._api);

  final ApiClient _api;

  /// Lấy hoặc tạo link QR PayOS cho đơn hàng online của khách (`GET /payments/payos/orders/:id/link`).
  Future<PayosPayment> fetchPaymentLink(String orderId) async {
    final json = await _api.get('/payments/payos/orders/$orderId/link');
    return PayosPayment.fromJson(requireObject(json, 'payment'));
  }

  /// Đồng bộ trạng thái thanh toán từ PayOS (`POST /payments/payos/orders/:id/sync`).
  Future<PayosSyncResult> syncPayment(String orderId) async {
    final json = await _api.post('/payments/payos/orders/$orderId/sync');
    return PayosSyncResult.fromJson(json);
  }

  /// Lấy hoặc tạo link QR PayOS cho đơn tại quầy (dành cho Thu ngân / Manager).
  Future<PayosPayment> fetchPosPaymentLink(String orderId) async {
    final json = await _api.get('/payments/payos/pos-orders/$orderId/link');
    return PayosPayment.fromJson(requireObject(json, 'payment'));
  }

  /// Đồng bộ trạng thái thanh toán đơn POS từ PayOS.
  Future<PayosSyncResult> syncPosPayment(String orderId) async {
    final json = await _api.post('/payments/payos/pos-orders/$orderId/sync');
    return PayosSyncResult.fromJson(json);
  }
}
