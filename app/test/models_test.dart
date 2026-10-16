import 'package:flutter_test/flutter_test.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';

void main() {
  const storeId = '64b000000000000000000001';

  Map<String, dynamic> orderJson(Object storeRef) => {
    '_id': '64b0000000000000000000aa',
    'orderCode': 'GUTA-20261013-ABC123',
    'channel': 'OFFLINE',
    'fulfillmentType': 'IN_STORE',
    'storeId': storeRef,
    'customerId': null,
    'items': [
      {
        'productId': '64b0000000000000000000p1',
        'sku': 'SKU1',
        'name': 'Serum',
        'quantity': 2,
        'unitPrice': 150000,
        'lineTotal': 300000,
      },
    ],
    'subtotal': 300000,
    'totalPrice': 300000.0,
    'status': 'PENDING_APPROVAL',
    'paymentStatus': 'UNPAID',
    'paymentOrderCode': 123456789,
    'statusHistory': [
      {'status': 'PENDING_APPROVAL', 'changedAt': '2026-10-13T08:00:00.000Z'},
    ],
    'createdAt': '2026-10-13T08:00:00.000Z',
  };

  test('Order parse storeId dạng chuỗi', () {
    final order = Order.fromJson(orderJson(storeId));
    expect(order.storeId?.id, storeId);
    expect(order.storeId?.isPopulated, isFalse);
    expect(order.status, OrderStatus.pendingApproval);
    expect(order.totalPrice, 300000);
    expect(order.paymentOrderCode, '123456789');
    expect(order.hasMemberCustomer, isFalse);
  });

  test('Order parse storeId đã populate', () {
    final order = Order.fromJson(
      orderJson({'_id': storeId, 'name': 'GUTA Q1', 'type': 'BRANCH'}),
    );
    expect(order.storeId?.id, storeId);
    expect(order.storeName, 'GUTA Q1');
    expect(order.storeId?.data?.type, StoreType.branch);
  });

  test('AppUser round-trip qua JSON (lưu shared_preferences)', () {
    final user = AppUser.fromJson({
      '_id': 'u1',
      'fullName': 'Nguyễn An',
      'email': 'an@gmail.com',
      'role': 'MANAGER',
      'storeId': {'_id': storeId, 'name': 'CN 1', 'type': 'BRANCH'},
      'points': 12,
      'wishlist': [
        'p1',
        {'_id': 'p2'},
      ],
    });
    expect(user.wishlist, ['p1', 'p2']);
    final again = AppUser.fromJson(user.toJson());
    expect(again, user);
    expect(again.assignedStoreName, 'CN 1');
    expect(again.initials, 'A');
  });

  test('RestockRequest chấp nhận cả `store` và `storeId`', () {
    final a = RestockRequest.fromJson({
      '_id': 'r1',
      'store': {'_id': storeId, 'name': 'CN 1'},
      'productId': {'_id': 'p1', 'name': 'Toner'},
      'requestedQuantity': 10,
      'status': 'OPEN',
    });
    expect(a.storeId?.data?.name, 'CN 1');
    expect(a.productId?.data?.name, 'Toner');
    expect(a.status, RestockStatus.open);
  });

  test('PayOS qrImage data URL và expiredAt epoch giây', () {
    final payment = PayosPayment.fromJson({
      'checkoutUrl': 'https://pay.payos.vn/web/abc',
      'expiredAt': 1792000000,
      'qrImage': 'data:image/png;base64,iVBORw0KGgo=',
    });
    expect(payment.qrImageBytes, isNotNull);
    expect(payment.expiredAt!.year, greaterThanOrEqualTo(2026));
  });

  test('Cảnh báo kho với loại không xác định không làm hỏng parse', () {
    final alert = InventoryAlert.fromJson({
      'type': 'SOMETHING_NEW',
      'severity': 'CRITICAL',
      'availableStock': 0,
    });
    expect(alert.type, InventoryAlertType.unknown);
    expect(alert.isCritical, isTrue);
  });

  test('apiValue của enum', () {
    expect(OrderStatus.readyForPickup.apiValue, 'READY_FOR_PICKUP');
    expect(PaymentMethod.bankTransfer.apiValue, 'BANK_TRANSFER');
    expect(UserRole.manager.apiValue, 'MANAGER');
  });
}
