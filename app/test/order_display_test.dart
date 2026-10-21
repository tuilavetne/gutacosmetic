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
  test('mỗi đơn thuộc đúng một tab trạng thái ngoài "Tất cả"', () {
    // "Chờ đánh giá" là tập con của "Hoàn tất" nên không tính.
    const subsets = {OrderTab.all, OrderTab.toReview};
    for (final status in OrderStatus.values) {
      final order = _order(status: status);
      final tabs = OrderTab.values
          .where((t) => !subsets.contains(t) && t.matches(order))
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

  test('"Chờ đánh giá": đơn hoàn tất chưa đánh giá', () {
    final done = _order(status: OrderStatus.completed);
    expect(done.canReview, isTrue);
    expect(OrderTab.toReview.matches(done), isTrue);
    expect(done.reviewedProductId, 'p1');

    final reviewed = done.copyWith(isReviewed: true);
    expect(reviewed.canReview, isFalse);
    expect(OrderTab.toReview.matches(reviewed), isFalse);
    expect(OrderTab.completed.matches(reviewed), isTrue);

    expect(_order().canReview, isFalse);
    expect(_order(status: OrderStatus.cancelled).canReview, isFalse);
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

  test('hủy được đơn online chờ xác nhận, kể cả đã thanh toán', () {
    expect(_order().customerCanCancel, isTrue);
    expect(_order(status: OrderStatus.preparing).customerCanCancel, isFalse);
    expect(
      _order(
        method: PaymentMethod.bankTransfer,
        payment: PaymentStatus.paid,
      ).customerCanCancel,
      isTrue,
    );
    expect(
      _order().copyWith(channel: OrderChannel.offline).customerCanCancel,
      isFalse,
    );
  });

  test('đơn đã trả tiền bị hủy: chờ hoàn tiền rồi đã hoàn tiền', () {
    final cancelled = _order(
      status: OrderStatus.cancelled,
      method: PaymentMethod.bankTransfer,
      payment: PaymentStatus.paid,
    );
    expect(cancelled.refundNote, isNull);
    expect(cancelled.paymentStatusLabel, 'Đã thanh toán');

    final pending = cancelled.copyWith(
      refundStatus: RefundStatus.pendingRefund,
    );
    expect(pending.awaitsRefund, isTrue);
    expect(pending.paymentStatusLabel, contains('Chờ hoàn tiền'));
    expect(pending.refundNote, contains('ngày làm việc'));

    final refunded = cancelled.copyWith(refundStatus: RefundStatus.refunded);
    expect(refunded.paymentStatusLabel, 'Đã hoàn tiền');
    expect(refunded.refundNote, isNotNull);

    final json = Order.fromJson({
      '_id': 'o2',
      'status': 'CANCELLED',
      'refundStatus': 'PENDING_REFUND',
    });
    expect(json.refundStatus, RefundStatus.pendingRefund);
    expect(
      Order.fromJson({'_id': 'o3', 'status': 'PENDING'}).refundStatus,
      RefundStatus.none,
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
