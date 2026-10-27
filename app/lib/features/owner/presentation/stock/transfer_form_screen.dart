import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../shared/models/models.dart';
import '../../data/owner_repository.dart';
import 'owner_stock_screen.dart';

/// Owner tạo phiếu chuyển hàng giữa hai cửa hàng bất kỳ: kho gửi bị trừ
/// ngay, nơi nhận được cộng khi Manager xác nhận đã nhận.
class TransferFormScreen extends ConsumerStatefulWidget {
  const TransferFormScreen({super.key});

  @override
  ConsumerState<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _Line {
  _Line(this.product) : quantity = TextEditingController(text: '1');

  final Product product;
  final TextEditingController quantity;

  int? get qty {
    final v = int.tryParse(quantity.text.trim());
    return v == null || v < 1 || v > AppConstants.maxReceiveQuantity ? null : v;
  }
}

class _TransferFormScreenState extends ConsumerState<TransferFormScreen> {
  String? _fromStoreId;
  String? _toStoreId;
  final _lines = <_Line>[];
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    for (final line in _lines) {
      line.quantity.dispose();
    }
    _note.dispose();
    super.dispose();
  }

  Future<void> _addProduct(
    List<ProductInventory> stock,
    String fromStoreId,
  ) async {
    final taken = {for (final line in _lines) line.product.id};
    final candidates = stock
        .where(
          (item) =>
              item.product.isActive &&
              !taken.contains(item.product.id) &&
              item.availableAt(fromStoreId) > 0,
        )
        .toList();
    final picked = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _ProductPicker(candidates: candidates, fromStoreId: fromStoreId),
    );
    if (picked == null) return;
    setState(() => _lines.add(_Line(picked)));
  }

  void _removeLine(_Line line) {
    setState(() => _lines.remove(line));
    line.quantity.dispose();
  }

  Future<void> _save() async {
    final from = _fromStoreId;
    final to = _toStoreId;
    if (from == null || to == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(ownerRepositoryProvider)
          .createTransfer(
            fromStoreId: from,
            toStoreId: to,
            items: [
              for (final line in _lines)
                (productId: line.product.id, quantity: line.qty!),
            ],
            note: _note.text,
          );
      invalidateOwnerStock(ref);
      if (!mounted) return;
      Navigator.of(context).pop();
      showAppSnackBar('Đã tạo phiếu chuyển hàng.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar(
        'Không tạo được phiếu: ${errorMessageOf(e)}',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(ownerStoresProvider);
    final stockAsync = ref.watch(ownerStockProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo phiếu chuyển hàng')),
      body: AsyncValueView<List<Store>>(
        value: storesAsync,
        onRetry: () => ref.invalidate(ownerStoresProvider),
        data: (allStores) {
          final stores = allStores.where((s) => s.isActive).toList();
          final stock = stockAsync.value ?? const <ProductInventory>[];
          final from = _fromStoreId;
          int availableOf(Product product) {
            if (from == null) return 0;
            for (final item in stock) {
              if (item.product.id == product.id) return item.availableAt(from);
            }
            return 0;
          }

          String? lineError(_Line line) {
            final qty = line.qty;
            if (qty == null) {
              return 'Từ 1 đến ${AppConstants.maxReceiveQuantity}';
            }
            final available = availableOf(line.product);
            return qty > available ? 'Kho gửi chỉ còn $available' : null;
          }

          final valid =
              from != null &&
              _toStoreId != null &&
              from != _toStoreId &&
              _lines.isNotEmpty &&
              _lines.every((line) => lineError(line) == null);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DropdownButtonFormField<String>(
                    key: const ValueKey('transfer-from'),
                    initialValue: _fromStoreId,
                    decoration: const InputDecoration(
                      labelText: 'Kho gửi',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final store in stores)
                        DropdownMenuItem(
                          value: store.id,
                          child: Text(_storeLabel(store)),
                        ),
                    ],
                    // Đổi kho gửi thì tồn khả dụng khác — chọn lại sản phẩm.
                    onChanged: (v) => setState(() {
                      _fromStoreId = v;
                      if (_toStoreId == v) _toStoreId = null;
                      for (final line in _lines) {
                        line.quantity.dispose();
                      }
                      _lines.clear();
                    }),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey('transfer-to-$_fromStoreId'),
                    initialValue: _toStoreId,
                    decoration: const InputDecoration(
                      labelText: 'Nơi nhận',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final store in stores)
                        if (store.id != _fromStoreId)
                          DropdownMenuItem(
                            value: store.id,
                            child: Text(_storeLabel(store)),
                          ),
                    ],
                    onChanged: (v) => setState(() => _toStoreId = v),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Sản phẩm chuyển',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm sản phẩm'),
                        onPressed: from == null || _saving
                            ? null
                            : () => _addProduct(stock, from),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (from == null)
                    const Text(
                      'Chọn kho gửi trước để thêm sản phẩm.',
                      style: TextStyle(color: AppColors.muted),
                    )
                  else if (_lines.isEmpty)
                    const Text(
                      'Chưa có sản phẩm nào.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  for (final line in _lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(line.product.name),
                                  Text(
                                    'SKU ${line.product.sku} • khả dụng ${availableOf(line.product)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 130,
                            child: TextField(
                              key: ValueKey('transfer-qty-${line.product.id}'),
                              controller: line.quantity,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: 'Số lượng',
                                isDense: true,
                                border: const OutlineInputBorder(),
                                errorText: lineError(line),
                                errorMaxLines: 2,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Bỏ sản phẩm',
                            icon: const Icon(Icons.close),
                            onPressed: _saving ? null : () => _removeLine(line),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _note,
                    maxLength: 300,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú (không bắt buộc)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.local_shipping_outlined),
                    label: Text(
                      _lines.isEmpty
                          ? 'Tạo phiếu chuyển'
                          : 'Tạo phiếu chuyển (${_lines.fold<int>(0, (s, l) => s + (l.qty ?? 0))} sp)',
                    ),
                    onPressed: valid && !_saving ? _save : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

String _storeLabel(Store store) =>
    '${store.name}${store.isCentral ? ' (kho tổng)' : ''}';

class _ProductPicker extends StatefulWidget {
  const _ProductPicker({required this.candidates, required this.fromStoreId});

  final List<ProductInventory> candidates;
  final String fromStoreId;

  @override
  State<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends State<_ProductPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final items = widget.candidates
        .where(
          (item) =>
              q.isEmpty ||
              item.product.name.toLowerCase().contains(q) ||
              item.product.sku.toLowerCase().contains(q),
        )
        .toList();
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Tìm theo tên hoặc SKU',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const EmptyState(
                      icon: Icons.inventory_2_outlined,
                      message: 'Không có sản phẩm còn hàng ở kho gửi',
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(item.product.name),
                          subtitle: Text('SKU ${item.product.sku}'),
                          trailing: Text(
                            'Còn ${item.availableAt(widget.fromStoreId)}',
                          ),
                          onTap: () => Navigator.of(context).pop(item.product),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
