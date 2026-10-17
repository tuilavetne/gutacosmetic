import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/features/customer/orders/order_display.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';

Order _order({
  OrderStatus status = OrderStatus.pending,
  FulfillmentType fulfillment = FulfillmentType.delivery,
  PaymentMethod method = PaymentMethod.cod,
  PaymentStatus payment = PaymentStatus.unpaid,
  List<StatusHistoryEntry> history = const [],
  String? cancellationReason,
}) => Order(
  id: 'o1',
  orderCode: 'GUTA-1',
  status: status,
  fulfillmentType: fulfillment,
  paymentMethod: method,
  paymentStatus: payment,
  totalPrice: 245000,
  statusHistory: history,
  cancellationReason: cancellationReason,
  createdAt: DateTime.utc(2026, 10, 17, 2),
  items: const [
    OrderItem(
      productId: EntityRef('p1'),
      name: 'Serum',
      quantity: 2,
      unitPrice: 110000,
    ),
  ],
);

void main() {
  test('mỗi đơn thuộc đúng một tab ngoài "Tất cả"', () {
    for (final status in OrderStatus.values) {
      final order = _order(status: status);
      final tabs = OrderTab.values
          .where((t) => t != OrderTab.all && t.matches(order))
          .toList();
      expect(tabs, hasLength(1), reason: '$status');
      expect(OrderTab.all.matches(order), isTrue);
    }
    expect(
      OrderTab.processing.matches(_order(status: OrderStatus.preparing)),
      isTrue,
    );
    expect(
      OrderTab.processing.matches(_order(status: OrderStatus.readyForPickup)),
      isTrue,
    );
  });

  test('nhãn trạng thái theo hình thức nhận và thanh toán', () {
    expect(_order().customerStatusLabel, 'Chờ xác nhận');
    expect(
      _order(method: PaymentMethod.bankTransfer).customerStatusLabel,
      'Chờ thanh toán',
    );
    expect(
      _order(
        method: PaymentMethod.bankTransfer,
        payment: PaymentStatus.paid,
      ).customerStatusLabel,
      'Chờ xác nhận',
    );
    expect(
      _order(status: OrderStatus.preparing).customerStatusLabel,
      'Đang giao hàng',
    );
    expect(
      _order(
        status: OrderStatus.completed,
        fulfillment: FulfillmentType.storePickup,
      ).customerStatusLabel,
      'Đã nhận hàng',
    );
  });

  test('chỉ hủy được đơn online chờ xác nhận chưa thanh toán', () {
    expect(_order().customerCanCancel, isTrue);
    expect(_order(status: OrderStatus.preparing).customerCanCancel, isFalse);
    expect(
      _order(
        method: PaymentMethod.bankTransfer,
        payment: PaymentStatus.paid,
      ).customerCanCancel,
      isFalse,
    );
  });

  test('tiến trình: giao hàng 3 bước, nhận tại cửa hàng 4 bước', () {
    final changedAt = DateTime.utc(2026, 10, 17, 3);
    final delivery = _order(
      status: OrderStatus.preparing,
      history: [
        const StatusHistoryEntry(status: OrderStatus.pending),
        StatusHistoryEntry(status: OrderStatus.preparing, changedAt: changedAt),
      ],
    );
    expect(delivery.progressSteps.map((s) => s.label), [
      'Đặt hàng',
      'Đang giao',
      'Đã giao',
    ]);
    expect(delivery.currentStepIndex, 1);
    expect(delivery.progressSteps[1].at, changedAt);

    final pickup = _order(
      status: OrderStatus.readyForPickup,
      fulfillment: FulfillmentType.storePickup,
    );
    expect(pickup.progressSteps, hasLength(4));
    expect(pickup.currentStepIndex, 2);

    expect(_order(status: OrderStatus.cancelled).progressSteps, isEmpty);
  });

  test('dịch lý do hủy tự động của PayOS, điểm dự kiến, mua lại', () {
    final expired = _order(
      status: OrderStatus.cancelled,
      cancellationReason: 'PayOS payment QR expired',
    );
    expect(expired.cancellationReasonLabel, contains('hết hạn'));
    expect(
      _order(cancellationReason: 'Đổi ý').cancellationReasonLabel,
      'Đổi ý',
    );
    expect(_order().expectedPoints, 24);
    expect(
      _order().reorderLines.map((e) => (e.productId, e.quantity, e.unitPrice)),
      [('p1', 2, 110000)],
    );
  });
}
