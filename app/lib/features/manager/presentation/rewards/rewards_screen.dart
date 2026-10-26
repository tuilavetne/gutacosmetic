import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../shared/models/models.dart';
import '../../data/manager_repository.dart';

/// Tab Đổi quà: tìm khách thành viên, đổi quà bằng điểm tại quầy (trừ điểm,
/// lưu lịch sử). Điểm chỉ dùng để đổi quà, không trừ thành tiền.
class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<CustomerSearchResult> _results = const [];
  bool _searching = false;
  CustomerSearchResult? _customer;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(AppConstants.searchDebounce, () => _runSearch(value));
  }

  Future<void> _runSearch(String value) async {
    if (value.trim().length < AppConstants.customerSearchMinLength) {
      setState(() => _results = const []);
      return;
    }
    setState(() => _searching = true);
    try {
      final results = await ref
          .read(managerRepositoryProvider)
          .searchMembers(value);
      if (mounted) setState(() => _results = results);
    } catch (e) {
      showAppSnackBar(errorMessageOf(e), isError: true);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _select(CustomerSearchResult customer) {
    FocusScope.of(context).unfocus();
    setState(() {
      _customer = customer;
      _results = const [];
      _search.clear();
    });
  }

  Future<void> _redeem() async {
    final customer = _customer!;
    final remaining = await _RedeemDialog.show(context, customer);
    if (remaining == null || !mounted) return;
    setState(() => _customer = customer.copyWith(points: remaining));
    ref.invalidate(managerRedemptionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final customer = _customer;

    return ColoredBox(
      color: AppColors.background,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _search,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_search_outlined),
                  hintText: 'Tìm khách thành viên theo tên, SĐT hoặc email',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: _searching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
              ),
              for (final result in _results)
                Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(top: 6),
                  child: ListTile(
                    leading: const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFD97706),
                    ),
                    title: Text(result.fullName),
                    subtitle: Text(result.phone ?? result.email ?? ''),
                    trailing: Text(
                      '${formatNumber(result.points)} điểm',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () => _select(result),
                  ),
                ),
              if (_search.text.trim().length >=
                      AppConstants.customerSearchMinLength &&
                  !_searching &&
                  _results.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Không tìm thấy khách thành viên. Khách vãng lai chưa có '
                    'tài khoản nên không có điểm.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              if (customer != null) ...[
                _CustomerPanel(
                  customer: customer,
                  onRedeem: customer.points > 0 ? _redeem : null,
                  onClose: () => setState(() => _customer = null),
                ),
                const SizedBox(height: 16),
                Text(
                  'Lịch sử đổi quà của ${customer.fullName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ] else
                const Text(
                  'Đổi quà gần đây tại chi nhánh',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 8),
              _RedemptionList(customerId: customer?.id),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerPanel extends StatelessWidget {
  const _CustomerPanel({
    required this.customer,
    required this.onRedeem,
    required this.onClose,
  });

  final CustomerSearchResult customer;
  final VoidCallback? onRedeem;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: AppColors.primary.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if ((customer.phone ?? '').isNotEmpty) Text(customer.phone!),
                  const SizedBox(height: 8),
                  Text(
                    '${formatNumber(customer.points)} điểm',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text(
                    'Tích 1 điểm cho mỗi 10.000đ mua hàng',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Chọn khách khác',
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.card_giftcard),
                  label: const Text('Đổi quà'),
                  onPressed: onRedeem,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RedemptionList extends ConsumerWidget {
  const _RedemptionList({this.customerId});

  final String? customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final redemptions = ref.watch(managerRedemptionsProvider(customerId));
    return redemptions.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ErrorState(
        error: e,
        onRetry: () => ref.invalidate(managerRedemptionsProvider(customerId)),
      ),
      data: (items) => items.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Chưa có lần đổi quà nào',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
            )
          : Column(
              children: [
                for (final r in items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.card_giftcard,
                      color: AppColors.primary,
                    ),
                    title: Text(r.rewardName),
                    subtitle: Text(
                      [
                        if (customerId == null) ?r.customerId?.data?.fullName,
                        formatDateTime(r.createdAt),
                        ?r.storeId?.data?.name,
                        if (r.redeemedBy?.data != null)
                          'bởi ${r.redeemedBy!.data!.displayName}',
                        if ((r.note ?? '').isNotEmpty) r.note!,
                      ].join(' • '),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Text(
                      '-${formatNumber(r.pointsUsed)} điểm',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Đổi quà: tên quà (gợi ý quà đã đổi ở chi nhánh) và số điểm ≤ điểm hiện có.
/// Trả về số điểm còn lại sau khi đổi, `null` nếu đóng.
class _RedeemDialog extends ConsumerStatefulWidget {
  const _RedeemDialog({required this.customer});

  final CustomerSearchResult customer;

  static Future<int?> show(
    BuildContext context,
    CustomerSearchResult customer,
  ) => showDialog<int>(
    context: context,
    builder: (_) => _RedeemDialog(customer: customer),
  );

  @override
  ConsumerState<_RedeemDialog> createState() => _RedeemDialogState();
}

class _RedeemDialogState extends ConsumerState<_RedeemDialog> {
  final _reward = TextEditingController();
  final _points = TextEditingController();
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _reward.dispose();
    _points.dispose();
    _note.dispose();
    super.dispose();
  }

  int? get _pointsValue {
    final v = int.tryParse(_points.text.trim());
    return v == null || v < 1 || v > widget.customer.points ? null : v;
  }

  bool get _valid => _reward.text.trim().isNotEmpty && _pointsValue != null;

  Future<void> _save() async {
    final points = _pointsValue;
    if (!_valid || points == null) return;
    setState(() => _saving = true);
    try {
      final remaining = await ref
          .read(managerRepositoryProvider)
          .redeemPoints(
            widget.customer.id,
            points: points,
            rewardName: _reward.text,
            note: _note.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop(remaining);
      showAppSnackBar(
        'Đã đổi "${_reward.text.trim()}" (-$points điểm). Còn '
        '${formatNumber(remaining)} điểm.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar(
        'Không đổi quà được: ${errorMessageOf(e)}',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gợi ý các quà đã đổi ở chi nhánh (kèm số điểm lần gần nhất).
    final recent = <String, int>{};
    for (final r
        in ref.watch(managerRedemptionsProvider(null)).value ?? const []) {
      recent.putIfAbsent(r.rewardName, () => r.pointsUsed);
    }
    final pointsText = _points.text.trim();

    return AlertDialog(
      title: Text('Đổi quà cho ${widget.customer.fullName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Hiện có ${formatNumber(widget.customer.points)} điểm'),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('reward-name'),
              controller: _reward,
              maxLength: 120,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Tên quà',
                border: OutlineInputBorder(),
              ),
            ),
            if (recent.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final MapEntry(key: name, value: points)
                      in recent.entries.take(6))
                    ActionChip(
                      label: Text('$name • $points điểm'),
                      onPressed: () => setState(() {
                        _reward.text = name;
                        _points.text = '$points';
                      }),
                    ),
                ],
              ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('reward-points'),
              controller: _points,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Số điểm trừ',
                border: const OutlineInputBorder(),
                errorText: pointsText.isNotEmpty && _pointsValue == null
                    ? 'Từ 1 đến ${formatNumber(widget.customer.points)} điểm'
                    : null,
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
        FilledButton(
          onPressed: _valid && !_saving ? _save : null,
          child: const Text('Xác nhận đổi quà'),
        ),
      ],
    );
  }
}
