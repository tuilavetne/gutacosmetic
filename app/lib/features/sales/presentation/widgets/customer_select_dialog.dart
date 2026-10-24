import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../shared/models/models.dart';
import '../../data/sales_repository.dart';

class CustomerSelectDialog extends ConsumerStatefulWidget {
  const CustomerSelectDialog({super.key, this.selectedCustomer});

  final CustomerSearchResult? selectedCustomer;

  static Future<CustomerSearchResult?> show(
    BuildContext context, {
    CustomerSearchResult? current,
  }) {
    return showDialog<CustomerSearchResult>(
      context: context,
      builder: (_) => CustomerSelectDialog(selectedCustomer: current),
    );
  }

  @override
  ConsumerState<CustomerSelectDialog> createState() =>
      _CustomerSelectDialogState();
}

class _CustomerSelectDialogState extends ConsumerState<CustomerSelectDialog> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  Timer? _debounce;
  bool _searching = false;
  List<CustomerSearchResult> _results = const [];
  bool _isManualMode = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _results = const [];
        _searching = false;
      });
      return;
    }

    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final list = await ref
            .read(salesRepositoryProvider)
            .searchCustomers(query);
        if (mounted) {
          setState(() {
            _results = list;
            _searching = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _searching = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chọn khách hàng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('Tìm thành viên/SĐT'),
                    icon: Icon(Icons.search),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Khách lẻ nhập tay'),
                    icon: Icon(Icons.person_add_alt_1_outlined),
                  ),
                ],
                selected: {_isManualMode},
                onSelectionChanged: (val) {
                  setState(() => _isManualMode = val.first);
                },
              ),
              const SizedBox(height: 16),
              if (!_isManualMode) ...[
                AppTextField(
                  controller: _searchController,
                  label: 'Tìm theo Tên, Số điện thoại hoặc Email',
                  prefixIcon: Icons.search,
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.background,
                    child: Icon(Icons.person_outline, color: AppColors.muted),
                  ),
                  title: const Text('Khách vãng lai tại quầy'),
                  subtitle: const Text('Không tích điểm'),
                  trailing: const Icon(Icons.check_circle_outline),
                  onTap: () {
                    Navigator.pop(
                      context,
                      const CustomerSearchResult(
                        id: 'guest:anonymous',
                        fullName: 'Khách vãng lai',
                        isGuest: true,
                      ),
                    );
                  },
                ),
                const Divider(),
                Expanded(
                  child: _searching
                      ? const LoadingView(message: 'Đang tìm khách hàng...')
                      : _results.isEmpty
                          ? Center(
                              child: Text(
                                _searchController.text.trim().length >= 2
                                    ? 'Không tìm thấy khách hàng nào'
                                    : 'Nhập ít nhất 2 ký tự để tìm kiếm',
                                style: const TextStyle(color: AppColors.muted),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _results.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final cust = _results[index];
                                final isSelected =
                                    widget.selectedCustomer?.id == cust.id;
                                return ListTile(
                                  selected: isSelected,
                                  leading: CircleAvatar(
                                    backgroundColor: cust.isMember
                                        ? AppColors.primary.withValues(alpha: 0.15)
                                        : AppColors.background,
                                    child: Icon(
                                      cust.isMember
                                          ? Icons.star_rounded
                                          : Icons.person_outline,
                                      color: cust.isMember
                                          ? AppColors.primary
                                          : AppColors.muted,
                                    ),
                                  ),
                                  title: Text(
                                    cust.fullName.isNotEmpty
                                        ? cust.fullName
                                        : 'Khách vãng lai',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    [
                                      if (cust.phone != null &&
                                          cust.phone!.isNotEmpty)
                                        cust.phone,
                                      if (cust.email != null &&
                                          cust.email!.isNotEmpty)
                                        cust.email,
                                    ].join(' • '),
                                  ),
                                  trailing: cust.isMember
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${formatNumber(cust.points)} điểm',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        )
                                      : const Chip(
                                          label: Text('Vãng lai',
                                              style: TextStyle(fontSize: 11)),
                                        ),
                                  onTap: () => Navigator.pop(context, cust),
                                );
                              },
                            ),
                ),
              ] else ...[
                AppTextField(
                  controller: _nameController,
                  label: 'Tên khách hàng',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _phoneController,
                  label: 'Số điện thoại',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const Spacer(),
                AppButton(
                  label: 'Sử dụng thông tin này',
                  icon: Icons.check,
                  onPressed: () async {
                    final name = _nameController.text.trim();
                    final phone = _phoneController.text.trim();
                    Navigator.pop(
                      context,
                      CustomerSearchResult(
                        id: phone.isNotEmpty ? 'guest:$phone' : 'guest:custom',
                        fullName: name.isNotEmpty ? name : 'Khách vãng lai',
                        phone: phone.isNotEmpty ? phone : null,
                        isGuest: true,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
