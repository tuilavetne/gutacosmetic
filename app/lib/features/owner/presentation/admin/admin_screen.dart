import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../shared/models/models.dart';
import '../../data/owner_repository.dart';

/// Tab Quản trị của Owner: cửa hàng và nhân viên (Manager / Sales).
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ColoredBox(
        color: AppColors.background,
        child: Column(
          children: [
            const ColoredBox(
              color: Colors.white,
              child: TabBar(
                labelColor: AppColors.primary,
                indicatorColor: AppColors.primary,
                unselectedLabelColor: AppColors.muted,
                tabs: [
                  Tab(text: 'Cửa hàng'),
                  Tab(text: 'Nhân viên'),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: const TabBarView(
                    children: [_StoresTab(), _StaffTab()],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.text,
    required this.onAdd,
    required this.addLabel,
  });

  final String text;
  final VoidCallback onAdd;
  final String addLabel;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Row(
      children: [
        Expanded(
          child: Text(text, style: const TextStyle(color: AppColors.muted)),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.add),
          label: Text(addLabel),
          onPressed: onAdd,
        ),
      ],
    ),
  );
}

Widget _card({required Widget child, VoidCallback? onTap}) => Card(
  elevation: 0,
  margin: EdgeInsets.zero,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    side: const BorderSide(color: AppColors.border),
  ),
  child: InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Padding(padding: const EdgeInsets.all(14), child: child),
  ),
);

// ---------------------------------------------------------------------------
// Cửa hàng
// ---------------------------------------------------------------------------

class _StoresTab extends ConsumerWidget {
  const _StoresTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(ownerStoresProvider);
    final stores = storesAsync.value ?? const <Store>[];
    void openForm([Store? store]) => showDialog<void>(
      context: context,
      builder: (_) => StoreFormDialog(
        store: store,
        hasCentral: stores.any((s) => s.isCentral),
      ),
    );

    return Column(
      children: [
        _Header(
          text:
              'Chỉ có một kho tổng. Loại cửa hàng không đổi được sau khi tạo.',
          addLabel: 'Thêm cửa hàng',
          onAdd: openForm,
        ),
        Expanded(
          child: AsyncValueView<List<Store>>(
            value: storesAsync,
            onRetry: () => ref.invalidate(ownerStoresProvider),
            data: (stores) => RefreshIndicator(
              onRefresh: () => ref.refresh(ownerStoresProvider.future),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: stores.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final store = stores[index];
                  return _card(
                    onTap: () => openForm(store),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                store.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${store.address} • ${Validators.localPhone(store.phone)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusChip(
                          label: store.type.label,
                          color: store.isCentral
                              ? AppColors.primary
                              : AppColors.info,
                        ),
                        if (!store.isActive) ...[
                          const SizedBox(width: 6),
                          const StatusChip(
                            label: 'Ngừng hoạt động',
                            color: AppColors.muted,
                          ),
                        ],
                        const Icon(Icons.chevron_right, color: AppColors.muted),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Thêm / sửa cửa hàng. Ngừng hoạt động bị backend chặn nếu còn đơn đang xử
/// lý, nhân viên hoặc phiếu chuyển chưa nhận; kho tổng không ngừng được.
class StoreFormDialog extends ConsumerStatefulWidget {
  const StoreFormDialog({super.key, this.store, required this.hasCentral});

  final Store? store;
  final bool hasCentral;

  @override
  ConsumerState<StoreFormDialog> createState() => _StoreFormDialogState();
}

class _StoreFormDialogState extends ConsumerState<StoreFormDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.store?.name);
  late final _address = TextEditingController(text: widget.store?.address);
  late final _phone = TextEditingController(
    text: Validators.localPhone(widget.store?.phone),
  );
  late StoreType _type = widget.store?.type ?? StoreType.branch;
  late bool _isActive = widget.store?.isActive ?? true;
  bool _saving = false;

  bool get _isEdit => widget.store != null;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final store = widget.store;
    if (store != null && store.isActive && !_isActive) {
      final ok = await showConfirmDialog(
        context,
        title: 'Ngừng hoạt động cửa hàng?',
        message: 'Cửa hàng sẽ không nhận đơn mới. Chỉ ngừng được khi không còn đơn đang xử lý, nhân viên đang gán và phiếu chuyển chưa nhận.',
        confirmLabel: 'Ngừng hoạt động',
        destructive: true,
      );
      if (!ok || !mounted) return;
    }
    setState(() => _saving = true);
    final repo = ref.read(ownerRepositoryProvider);
    final data = <String, Object?>{
      'name': _name.text.trim(),
      'address': _address.text.trim(),
      'phone': Validators.normalizePhone(_phone.text.trim()),
      if (!_isEdit) 'type': _type.apiValue,
      if (_isEdit) 'isActive': _isActive,
    };
    try {
      if (store == null) {
        await repo.createStore(data);
      } else {
        await repo.updateStore(store.id, data);
      }
      ref
        ..invalidate(ownerStoresProvider)
        ..invalidate(ownerDashboardProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      showAppSnackBar(_isEdit ? 'Đã lưu cửa hàng.' : 'Đã thêm cửa hàng.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar('Không lưu được: ${errorMessageOf(e)}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    const gap = SizedBox(height: 12);
    return AlertDialog(
      title: Text(_isEdit ? 'Sửa cửa hàng' : 'Thêm cửa hàng'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const ValueKey('store-name'),
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Tên cửa hàng',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => Validators.required(v, 'Tên cửa hàng'),
                ),
                gap,
                TextFormField(
                  key: const ValueKey('store-address'),
                  controller: _address,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => Validators.required(v, 'Địa chỉ'),
                ),
                gap,
                TextFormField(
                  key: const ValueKey('store-phone'),
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => Validators.required(v, 'Số điện thoại'),
                ),
                gap,
                if (_isEdit)
                  Text(
                    'Loại: ${store!.type.label} (không đổi được)',
                    style: const TextStyle(color: AppColors.muted),
                  )
                else
                  SegmentedButton<StoreType>(
                    segments: [
                      const ButtonSegment(
                        value: StoreType.branch,
                        label: Text('Chi nhánh'),
                      ),
                      ButtonSegment(
                        value: StoreType.central,
                        label: const Text('Kho tổng'),
                        enabled: !widget.hasCentral,
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (v) => setState(() => _type = v.first),
                  ),
                if (!_isEdit && widget.hasCentral)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Chuỗi đã có kho tổng.',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ),
                if (_isEdit)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Đang hoạt động'),
                    subtitle: store!.isCentral
                        ? const Text('Kho tổng luôn phải hoạt động')
                        : null,
                    value: _isActive,
                    onChanged: store.isCentral && store.isActive
                        ? null
                        : (v) => setState(() => _isActive = v),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
        FilledButton(
          key: const ValueKey('store-save'),
          onPressed: _saving ? null : _save,
          child: Text(_isEdit ? 'Lưu' : 'Thêm'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Nhân viên
// ---------------------------------------------------------------------------

class _StaffTab extends ConsumerStatefulWidget {
  const _StaffTab();

  @override
  ConsumerState<_StaffTab> createState() => _StaffTabState();
}

class _StaffTabState extends ConsumerState<_StaffTab> {
  String _query = '';

  void _openForm([AppUser? staff]) => showDialog<void>(
    context: context,
    builder: (_) => StaffFormDialog(staff: staff),
  );

  Future<void> _toggleLock(AppUser staff) async {
    final repo = ref.read(ownerRepositoryProvider);
    Map<String, Object?> data;
    if (staff.isActive) {
      final reason = await showReasonDialog(
        context,
        title: 'Khóa tài khoản ${staff.displayName}?',
        message: 'Nhân viên sẽ bị đăng xuất và không đăng nhập được nữa.',
        confirmLabel: 'Khóa',
        hint: 'Lý do khóa',
        minLength: 3,
        maxLength: 200,
      );
      if (reason == null) return;
      data = {'isActive': false, 'disabledReason': reason};
    } else {
      final ok = await showConfirmDialog(
        context,
        title: 'Mở khóa ${staff.displayName}?',
        message: 'Nhân viên đăng nhập lại được với mật khẩu hiện tại.',
        confirmLabel: 'Mở khóa',
      );
      if (!ok) return;
      data = {'isActive': true};
    }
    try {
      await repo.updateStaff(staff.id, data);
      ref
        ..invalidate(ownerStaffProvider)
        ..invalidate(ownerDashboardProvider);
      showAppSnackBar(
        staff.isActive ? 'Đã khóa tài khoản.' : 'Đã mở khóa tài khoản.',
      );
    } catch (e) {
      showAppSnackBar(errorMessageOf(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Tìm theo tên, email, SĐT',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Thêm nhân viên'),
                onPressed: _openForm,
              ),
            ],
          ),
        ),
        Expanded(
          child: AsyncValueView<List<AppUser>>(
            value: ref.watch(ownerStaffProvider),
            onRetry: () => ref.invalidate(ownerStaffProvider),
            data: (staff) {
              final visible = staff
                  .where(
                    (u) =>
                        q.isEmpty ||
                        u.fullName.toLowerCase().contains(q) ||
                        u.email.toLowerCase().contains(q) ||
                        Validators.localPhone(u.phone).contains(q),
                  )
                  .toList();
              return RefreshIndicator(
                onRefresh: () => ref.refresh(ownerStaffProvider.future),
                child: visible.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 60),
                          EmptyState(
                            icon: Icons.badge_outlined,
                            message: 'Không có nhân viên phù hợp',
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, index) {
                          final u = visible[index];
                          return _card(
                            onTap: () => _openForm(u),
                            child: Row(
                              children: [
                                CircleAvatar(child: Text(u.initials)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        u.displayName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${u.role.label} • ${u.assignedStoreName ?? 'Chưa gán cửa hàng'}',
                                      ),
                                      Text(
                                        [
                                              u.email,
                                              Validators.localPhone(u.phone),
                                            ]
                                            .where((e) => e.isNotEmpty)
                                            .join(' • '),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                      if (!u.isActive &&
                                          (u.disabledReason ?? '').isNotEmpty)
                                        Text(
                                          'Lý do khóa: ${u.disabledReason}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (!u.isActive)
                                  const StatusChip(
                                    label: 'Đã khóa',
                                    color: AppColors.accent,
                                  ),
                                IconButton(
                                  tooltip: u.isActive
                                      ? 'Khóa tài khoản'
                                      : 'Mở khóa',
                                  icon: Icon(
                                    u.isActive
                                        ? Icons.lock_outline
                                        : Icons.lock_open,
                                  ),
                                  onPressed: () => _toggleLock(u),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Thêm / sửa nhân viên. Chỉ tạo Manager hoặc Sales; cửa hàng bắt buộc.
/// Khi sửa, nhập mật khẩu mới để đặt lại (để trống thì giữ nguyên).
class StaffFormDialog extends ConsumerStatefulWidget {
  const StaffFormDialog({super.key, this.staff});

  final AppUser? staff;

  @override
  ConsumerState<StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends ConsumerState<StaffFormDialog> {
  final _form = GlobalKey<FormState>();
  late final AppUser? _u = widget.staff;
  late final _name = TextEditingController(text: _u?.fullName);
  late final _email = TextEditingController(text: _u?.email);
  late final _phone = TextEditingController(
    text: Validators.localPhone(_u?.phone),
  );
  late final _address = TextEditingController(text: _u?.address);
  final _password = TextEditingController();
  late UserRole _role = _u?.role ?? UserRole.sales;
  late String? _storeId = _u?.storeId?.id;
  bool _saving = false;
  bool _showPassword = false;

  bool get _isEdit => _u != null;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _address, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(ownerRepositoryProvider);
    final password = _password.text;
    final data = <String, Object?>{
      'fullName': _name.text.trim(),
      'email': Validators.normalizeEmail(_email.text),
      'phone': Validators.normalizePhone(_phone.text.trim()),
      'address': _address.text.trim(),
      'role': _role.apiValue,
      'storeId': _storeId,
      if (password.isNotEmpty) 'password': password,
    };
    try {
      if (_u == null) {
        await repo.createStaff(data);
      } else {
        await repo.updateStaff(_u.id, data);
      }
      ref
        ..invalidate(ownerStaffProvider)
        ..invalidate(ownerDashboardProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      showAppSnackBar(
        !_isEdit
            ? 'Đã tạo tài khoản nhân viên.'
            : password.isNotEmpty
            ? 'Đã lưu và đặt lại mật khẩu.'
            : 'Đã lưu nhân viên.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar('Không lưu được: ${errorMessageOf(e)}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allStores = ref.watch(ownerStoresProvider).value ?? const <Store>[];
    // Chỉ gán vào cửa hàng đang hoạt động (giữ cửa hàng cũ để hiện đúng).
    final stores = allStores
        .where((s) => s.isActive || s.id == _storeId)
        .toList();
    const gap = SizedBox(height: 12);
    InputDecoration deco(String label, {String? helper, Widget? suffix}) =>
        InputDecoration(
          labelText: label,
          helperText: helper,
          suffixIcon: suffix,
          border: const OutlineInputBorder(),
        );

    return AlertDialog(
      title: Text(_isEdit ? 'Sửa nhân viên' : 'Thêm nhân viên'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const ValueKey('staff-name'),
                  controller: _name,
                  decoration: deco('Họ tên'),
                  validator: Validators.fullName,
                ),
                gap,
                TextFormField(
                  key: const ValueKey('staff-email'),
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: deco('Gmail đăng nhập'),
                  validator: Validators.gmail,
                ),
                gap,
                TextFormField(
                  key: const ValueKey('staff-phone'),
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: deco('Số điện thoại'),
                  validator: Validators.phone,
                ),
                gap,
                TextFormField(
                  key: const ValueKey('staff-address'),
                  controller: _address,
                  decoration: deco('Địa chỉ'),
                  validator: Validators.address,
                ),
                gap,
                SegmentedButton<UserRole>(
                  segments: const [
                    ButtonSegment(value: UserRole.sales, label: Text('Sales')),
                    ButtonSegment(
                      value: UserRole.manager,
                      label: Text('Manager / Thu ngân'),
                    ),
                  ],
                  selected: {_role},
                  onSelectionChanged: (v) => setState(() => _role = v.first),
                ),
                gap,
                DropdownButtonFormField<String>(
                  key: const ValueKey('staff-store'),
                  initialValue: _storeId,
                  decoration: deco('Cửa hàng làm việc'),
                  items: [
                    for (final s in stores)
                      DropdownMenuItem(
                        value: s.id,
                        child: Text(
                          '${s.name}${s.isCentral ? ' (kho tổng)' : ''}${s.isActive ? '' : ' — ngừng hoạt động'}',
                        ),
                      ),
                  ],
                  validator: (v) => v == null ? 'Vui lòng chọn cửa hàng' : null,
                  onChanged: (v) => setState(() => _storeId = v),
                ),
                gap,
                TextFormField(
                  key: const ValueKey('staff-password'),
                  controller: _password,
                  obscureText: !_showPassword,
                  decoration: deco(
                    _isEdit ? 'Đặt lại mật khẩu' : 'Mật khẩu',
                    helper: _isEdit
                        ? 'Để trống nếu giữ mật khẩu cũ'
                        : '8–72 ký tự, có chữ hoa, chữ thường, chữ số',
                    suffix: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  validator: (v) => _isEdit && (v ?? '').isEmpty
                      ? null
                      : Validators.password(v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
        FilledButton(
          key: const ValueKey('staff-save'),
          onPressed: _saving ? null : _save,
          child: Text(_isEdit ? 'Lưu' : 'Tạo tài khoản'),
        ),
      ],
    );
  }
}
