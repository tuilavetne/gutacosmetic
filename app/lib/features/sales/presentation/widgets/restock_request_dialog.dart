import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../shared/models/models.dart';
import '../../data/sales_repository.dart';

/// Sales đề xuất bổ sung hàng cho chi nhánh. Sales chỉ đề xuất — Manager mới
/// quyết định nhận hàng hay hủy đề xuất.
class RestockRequestDialog extends ConsumerStatefulWidget {
  const RestockRequestDialog({
    super.key,
    required this.productId,
    required this.productName,
    required this.availableStock,
    this.pendingQuantity,
  });

  final String productId;
  final String productName;
  final int availableStock;

  /// Số lượng của đề xuất đang mở (nếu có) — backend gộp vào đề xuất đó.
  final int? pendingQuantity;

  /// Trả về đề xuất vừa gửi, hoặc `null` nếu đóng hộp thoại.
  static Future<RestockRequest?> show(
    BuildContext context, {
    required String productId,
    required String productName,
    required int availableStock,
    int? pendingQuantity,
  }) {
    return showDialog<RestockRequest>(
      context: context,
      builder: (_) => RestockRequestDialog(
        productId: productId,
        productName: productName,
        availableStock: availableStock,
        pendingQuantity: pendingQuantity,
      ),
    );
  }

  @override
  ConsumerState<RestockRequestDialog> createState() =>
      _RestockRequestDialogState();
}

class _RestockRequestDialogState extends ConsumerState<RestockRequestDialog> {
  static const _min = 1;
  static const _max = AppConstants.maxReceiveQuantity;

  late final _quantityController = TextEditingController(
    text: '${widget.pendingQuantity ?? AppConstants.defaultRestockQuantity}',
  );
  final _reasonController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  int? get _quantity {
    final value = int.tryParse(_quantityController.text.trim());
    if (value == null || value < _min || value > _max) return null;
    return value;
  }

  void _step(int delta) {
    final current = int.tryParse(_quantityController.text.trim()) ?? 0;
    final next = (current + delta).clamp(_min, _max);
    setState(() => _quantityController.text = '$next');
  }

  Future<void> _submit() async {
    final quantity = _quantity;
    if (quantity == null || _submitting) return;

    setState(() => _submitting = true);
    try {
      final request = await ref
          .read(salesRepositoryProvider)
          .createRestockRequest(
            productId: widget.productId,
            quantity: quantity,
            reason: _reasonController.text,
          );
      ref
        ..invalidate(salesRestockRequestsProvider)
        ..invalidate(salesInventoryAlertsProvider);
      if (!mounted) return;
      Navigator.of(context).pop(request);
      showAppSnackBar(
        'Đã gửi đề xuất bổ sung ${request.requestedQuantity} sp. '
        'Chờ Quản lý xử lý.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      showAppSnackBar(
        'Không gửi được đề xuất: ${errorMessageOf(e)}',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = widget.pendingQuantity;

    return AlertDialog(
      title: const Text('Đề xuất bổ sung hàng'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.productName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Còn ${widget.availableStock} sp khả dụng tại chi nhánh',
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            if (pending != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Đã có đề xuất $pending sp đang chờ Quản lý. '
                  'Gửi lại sẽ cập nhật đề xuất đó (lấy số lượng lớn hơn).',
                  style: const TextStyle(fontSize: 12, color: AppColors.info),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Số lượng đề xuất',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                IconButton(
                  tooltip: 'Giảm',
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _submitting ? null : () => _step(-1),
                ),
                Expanded(
                  child: TextField(
                    key: const ValueKey('restock-quantity'),
                    controller: _quantityController,
                    enabled: !_submitting,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      isDense: true,
                      errorText: _quantity == null
                          ? 'Từ $_min đến $_max'
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Tăng',
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _submitting ? null : () => _step(1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              enabled: !_submitting,
              maxLines: 2,
              maxLength: 255,
              decoration: const InputDecoration(
                labelText: 'Lý do (không bắt buộc)',
                hintText: 'Ví dụ: khách hỏi nhiều, sắp hết hàng',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
        FilledButton(
          onPressed: _quantity == null || _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Gửi đề xuất'),
        ),
      ],
    );
  }
}
