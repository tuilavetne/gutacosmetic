import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../customer/presentation/widgets/product_image.dart';
import '../../../shared/models/models.dart';
import '../../data/owner_repository.dart';
import 'product_form_screen.dart';

enum _ActiveFilter {
  active('Đang bán'),
  hidden('Đã ẩn'),
  all('Tất cả');

  const _ActiveFilter(this.label);
  final String label;

  bool matches(Product p) => switch (this) {
    active => p.isActive,
    hidden => !p.isActive,
    all => true,
  };
}

/// Owner quản lý danh mục sản phẩm: tìm, thêm, sửa, ẩn/hiện (không xóa).
class OwnerProductsScreen extends ConsumerStatefulWidget {
  const OwnerProductsScreen({super.key});

  @override
  ConsumerState<OwnerProductsScreen> createState() =>
      _OwnerProductsScreenState();
}

class _OwnerProductsScreenState extends ConsumerState<OwnerProductsScreen> {
  String _query = '';
  _ActiveFilter _filter = _ActiveFilter.active;

  void _openForm([Product? product]) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ProductFormScreen(product: product),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    return ColoredBox(
      color: AppColors.background,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Tìm theo tên, SKU, thương hiệu',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm'),
                      onPressed: () => _openForm(),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (final filter in _ActiveFilter.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter.label),
                          selected: filter == _filter,
                          onSelected: (_) => setState(() => _filter = filter),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: AsyncValueView<List<Product>>(
                  value: ref.watch(ownerProductsProvider),
                  onRetry: () => ref.invalidate(ownerProductsProvider),
                  data: (products) {
                    final visible = products
                        .where(_filter.matches)
                        .where(
                          (p) =>
                              q.isEmpty ||
                              p.name.toLowerCase().contains(q) ||
                              p.sku.toLowerCase().contains(q) ||
                              p.brand.toLowerCase().contains(q),
                        )
                        .toList();
                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.refresh(ownerProductsProvider.future),
                      child: visible.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 60),
                                EmptyState(
                                  icon: Icons.inventory_2_outlined,
                                  message: 'Không có sản phẩm phù hợp',
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: visible.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, index) => _ProductRow(
                                product: visible[index],
                                onEdit: () => _openForm(visible[index]),
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductRow extends ConsumerStatefulWidget {
  const _ProductRow({required this.product, required this.onEdit});

  final Product product;
  final VoidCallback onEdit;

  @override
  ConsumerState<_ProductRow> createState() => _ProductRowState();
}

class _ProductRowState extends ConsumerState<_ProductRow> {
  bool _busy = false;

  Future<void> _toggleActive() async {
    final p = widget.product;
    final hide = p.isActive;
    final ok = await showConfirmDialog(
      context,
      title: hide ? 'Ẩn sản phẩm?' : 'Hiện lại sản phẩm?',
      message: hide
          ? '"${p.name}" sẽ không còn hiển thị cho khách và không bán được tại quầy. Dữ liệu đơn cũ vẫn giữ nguyên.'
          : '"${p.name}" sẽ được bán trở lại.',
      confirmLabel: hide ? 'Ẩn' : 'Hiện lại',
      destructive: hide,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(ownerRepositoryProvider).updateProduct(p.id, {
        'isActive': !hide,
      });
      ref.invalidate(ownerProductsProvider);
      showAppSnackBar(hide ? 'Đã ẩn sản phẩm.' : 'Đã hiện lại sản phẩm.');
    } catch (e) {
      showAppSnackBar(errorMessageOf(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: widget.onEdit,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: ProductImage(url: p.coverImage, iconSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'SKU ${p.sku} • ${p.brand}${p.category == null ? '' : ' • ${p.category}'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          formatVnd(p.price),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (p.costPrice == null)
                          const StatusChip(
                            label: 'Chưa có giá vốn',
                            color: AppColors.warning,
                          )
                        else
                          Text(
                            'vốn ${formatVnd(p.costPrice!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        if (!p.isActive)
                          const StatusChip(
                            label: 'Đã ẩn',
                            color: AppColors.muted,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: p.isActive ? 'Ẩn sản phẩm' : 'Hiện lại',
                icon: Icon(
                  p.isActive
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: _busy ? null : _toggleActive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
