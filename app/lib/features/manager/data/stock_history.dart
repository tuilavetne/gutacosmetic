import '../../shared/models/models.dart';

/// Loại dòng lịch sử kho (`GET /inventory/history?type=`).
enum StockHistoryType {
  receipt('Nhập kho'),
  adjustment('Ghi giảm'),
  returnRequest('Trả hàng lỗi');

  const StockHistoryType(this.label);
  final String label;

  String get apiValue => switch (this) {
    receipt => 'RECEIPT',
    adjustment => 'ADJUSTMENT',
    returnRequest => 'RETURN',
  };

  static StockHistoryType? fromApi(Object? value) => switch (value) {
    'RECEIPT' => receipt,
    'ADJUSTMENT' => adjustment,
    'RETURN' => returnRequest,
    _ => null,
  };
}

/// Một dòng trong lịch sử kho của chi nhánh. [totalChange] là thay đổi
/// totalStock; [lockedChange] là số hàng bị khóa/mở khóa do trả hàng lỗi.
class StockHistoryEntry {
  const StockHistoryEntry({
    required this.id,
    required this.type,
    required this.event,
    required this.at,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.totalChange,
    required this.lockedChange,
    this.expiryDate,
    this.note = '',
    this.actorName,
  });

  final String id;
  final StockHistoryType type;
  final String event;
  final DateTime? at;
  final String productId;
  final String productName;
  final int quantity;
  final int totalChange;
  final int lockedChange;
  final DateTime? expiryDate;
  final String note;
  final String? actorName;

  /// `null` nếu dòng không đọc được (bỏ qua thay vì làm hỏng cả danh sách).
  static StockHistoryEntry? tryParse(Map<String, dynamic> json) {
    final type = StockHistoryType.fromApi(json['type']);
    if (type == null) return null;
    final product = json['product'];
    final actor = json['actor'];
    int asInt(Object? v) => v is num ? v.toInt() : 0;
    return StockHistoryEntry(
      id: '${json['id']}',
      type: type,
      event: '${json['event'] ?? ''}',
      at: DateTime.tryParse('${json['at']}')?.toLocal(),
      productId: product is Map ? '${product['_id']}' : '',
      productName: product is Map
          ? '${product['name'] ?? 'Sản phẩm'}'
          : 'Sản phẩm',
      quantity: asInt(json['quantity']),
      totalChange: asInt(json['totalChange']),
      lockedChange: asInt(json['lockedChange']),
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.tryParse('${json['expiryDate']}')?.toLocal(),
      note: '${json['note'] ?? ''}',
      actorName: actor is Map ? actor['fullName'] as String? : null,
    );
  }

  /// Mô tả sự kiện bằng tiếng Việt.
  String get eventLabel => switch (event) {
    'DIRECT' => ReceiptSource.direct.label,
    'SALES_REQUEST' => ReceiptSource.salesRequest.label,
    'TRANSFER' => ReceiptSource.transfer.label,
    'RETURN_REJECTED' when type == StockHistoryType.receipt =>
      ReceiptSource.returnRejected.label,
    'DAMAGED' => AdjustmentType.damaged.label,
    'DEFECTIVE' => AdjustmentType.defective.label,
    'LOST' => AdjustmentType.lost.label,
    'EXPIRED' => AdjustmentType.expired.label,
    'OTHER' => AdjustmentType.other.label,
    'RETURN_REQUESTED' => 'Gửi trả hàng lỗi (khóa hàng)',
    'RETURN_APPROVED' => 'Owner duyệt trả hàng',
    'RETURN_REJECTED' => 'Owner từ chối trả hàng (mở khóa)',
    _ => type.label,
  };
}
