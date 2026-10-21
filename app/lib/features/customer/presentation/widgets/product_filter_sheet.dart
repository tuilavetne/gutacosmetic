import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../catalog/catalog_filter.dart';

/// Bottom sheet bộ lọc nâng cao: khoảng giá, thương hiệu, sắp xếp.
Future<void> showProductFilterSheet(
  BuildContext context, {
  required List<String> brands,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ProductFilterSheet(brands: brands),
  );
}

class _ProductFilterSheet extends ConsumerStatefulWidget {
  const _ProductFilterSheet({required this.brands});

  final List<String> brands;

  @override
  ConsumerState<_ProductFilterSheet> createState() =>
      _ProductFilterSheetState();
}

class _ProductFilterSheetState extends ConsumerState<_ProductFilterSheet> {
  late final TextEditingController _min;
  late final TextEditingController _max;
  String? _brand;
  ProductSort _sort = ProductSort.newest;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(catalogFilterProvider);
    _min = TextEditingController(text: filter.minPrice?.toString() ?? '');
    _max = TextEditingController(text: filter.maxPrice?.toString() ?? '');
    _brand = filter.brand;
    _sort = filter.sort;
  }

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  void _reset() => setState(() {
    _min.clear();
    _max.clear();
    _brand = null;
    _sort = ProductSort.newest;
    _priceError = null;
  });

  void _apply() {
    final min = int.tryParse(_min.text);
    final max = int.tryParse(_max.text);
    if (min != null && max != null && min > max) {
      setState(() => _priceError = 'Giá tối thiểu phải nhỏ hơn giá tối đa.');
      return;
    }
    ref
        .read(catalogFilterProvider.notifier)
        .applyAdvanced(
          minPrice: min,
          maxPrice: max,
          brand: _brand,
          sort: _sort,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Thương hiệu đang chọn có thể không còn trong kết quả hiện tại.
    final brands = [
      ...widget.brands,
      if (_brand != null && !widget.brands.contains(_brand)) _brand!,
    ];

    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Bộ lọc tìm kiếm',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(onPressed: _reset, child: const Text('Đặt lại')),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  section(
                    'Khoảng giá (đ)',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _PriceField(
                                controller: _min,
                                label: 'Tối thiểu',
                                hint: '0',
                                onChanged: () =>
                                    setState(() => _priceError = null),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('—'),
                            ),
                            Expanded(
                              child: _PriceField(
                                controller: _max,
                                label: 'Tối đa',
                                hint: 'Không giới hạn',
                                onChanged: () =>
                                    setState(() => _priceError = null),
                              ),
                            ),
                          ],
                        ),
                        if (_priceError != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _priceError!,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  section(
                    'Thương hiệu',
                    brands.isEmpty
                        ? const Text(
                            'Chưa có thương hiệu trong kết quả hiện tại.',
                            style: TextStyle(color: AppColors.muted),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final brand in brands)
                                FilterChip(
                                  label: Text(brand),
                                  selected: _brand == brand,
                                  onSelected: (on) => setState(
                                    () => _brand = on ? brand : null,
                                  ),
                                ),
                            ],
                          ),
                  ),
                  section(
                    'Sắp xếp',
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final sort in ProductSort.values)
                          ChoiceChip(
                            label: Text(sort.label),
                            selected: _sort == sort,
                            onSelected: (_) => setState(() => _sort = sort),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: FilledButton(
                onPressed: _apply,
                child: const Text('Áp dụng'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
      ],
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}

/// Nhãn khoảng giá cho chip bộ lọc đang bật: `100.000đ – 500.000đ`.
String priceRangeLabel(int? min, int? max) {
  final from = min == null ? null : formatVnd(min);
  final to = max == null ? null : formatVnd(max);
  if (from != null && to != null) return '$from – $to';
  return from != null ? 'Từ $from' : 'Đến $to';
}
