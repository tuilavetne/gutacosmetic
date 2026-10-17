import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_messenger.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../../session/session_controller.dart';
import '../../shared/models/models.dart';
import '../cart/cart_controller.dart';
import '../cart/cart_item.dart';
import '../checkout/checkout_stock.dart';
import '../data/order_repository.dart';
import '../data/product_repository.dart';
import 'widgets/order_widgets.dart';

/// Lỗi tạo link PayOS — backend đã lưu đơn trước khi gọi PayOS.
const _payosLinkErrors = {'PAYOS_CREATE_LINK_FAILED', 'PAYOS_NOT_CONFIGURED'};

/// Thanh toán đơn online: hình thức nhận hàng, địa chỉ hoặc cửa hàng nhận,
/// phương thức thanh toán (COD / chuyển khoản QR PayOS).
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _address;

  FulfillmentType _fulfillment = FulfillmentType.delivery;
  PaymentMethod _payment = PaymentMethod.cod;
  String? _pickupStoreId;

  /// Đã đặt xong và đang rời màn — không hiện "giỏ trống" khi xóa giỏ.
  bool _placed = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _name = TextEditingController(text: user?.fullName ?? '');
    _phone = TextEditingController(text: Validators.localPhone(user?.phone));
    _address = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  bool get _isDelivery => _fulfillment == FulfillmentType.delivery;

  String _stockKey(List<CartItem> items) =>
      (items.map((e) => e.productId).toList()..sort()).join(',');

  /// Cửa hàng xử lý đơn theo hình thức nhận hàng đang chọn.
  Store? _storeFor(CheckoutStock stock) {
    if (_isDelivery) return stock.deliveryStore;
    final chosen = stock.availabilityOf(_pickupStoreId);
    if (chosen != null && chosen.isAvailable) return chosen.store;
    return stock.firstAvailableStore;
  }

  Future<void> _placeOrder(List<CartItem> items, CheckoutStock? stock) async {
    if (_isDelivery && !(_formKey.currentState?.validate() ?? false)) {
      showAppSnackBar('Vui lòng kiểm tra thông tin nhận hàng.', isError: true);
      return;
    }
    if (stock == null) {
      showAppSnackBar('Đang kiểm tra tồn kho, vui lòng đợi.');
      return;
    }
    if (stock.unavailableItems.isNotEmpty) {
      showAppSnackBar(
        'Giỏ hàng có sản phẩm đã ngừng bán. Vui lòng xóa trước khi đặt.',
        isError: true,
      );
      return;
    }
    final store = _storeFor(stock);
    if (store == null) {
      showAppSnackBar(
        _isDelivery
            ? 'Chưa có cửa hàng nào còn đủ hàng để giao.'
            : 'Vui lòng chọn cửa hàng còn đủ hàng để nhận.',
        isError: true,
      );
      return;
    }

    final router = GoRouter.of(context);
    final cart = ref.read(cartControllerProvider.notifier);
    final stockProvider = productsStockProvider(_stockKey(items));
    try {
      final placed = await ref.read(orderRepositoryProvider).placeOnlineOrder((
        storeId: store.id,
        fulfillmentType: _fulfillment,
        paymentMethod: _payment,
        items: [
          for (final e in items) (productId: e.productId, quantity: e.quantity),
        ],
        shippingAddress: _isDelivery
            ? ShippingAddress(
                recipientName: _name.text.trim(),
                phone: Validators.normalizePhone(_phone.text.trim()),
                addressLine: _address.text.trim(),
              )
            : null,
      ));
      ref.invalidate(customerOrdersProvider);
      if (mounted) setState(() => _placed = true);
      final order = placed.order;
      if (order.isBankTransfer) {
        router.go(AppRoutes.customerOrderPayment(order.id));
      } else {
        router.go(AppRoutes.customerOrder(order.id));
        showAppSnackBar('Đặt hàng thành công! Mã đơn ${order.orderCode}.');
      }
      cart.clear();
    } on ApiException catch (e) {
      if (_payosLinkErrors.contains(e.code)) {
        ref.invalidate(customerOrdersProvider);
        if (mounted) setState(() => _placed = true);
        cart.clear();
        router.go(AppRoutes.customerOrders);
        showAppSnackBar(
          'Đơn hàng đã được tạo nhưng chưa tạo được mã QR. '
          'Mở đơn trong mục Đơn hàng để thanh toán lại.',
          isError: true,
        );
        return;
      }
      if (e.code == 'INSUFFICIENT_STOCK' || e.code == 'PRODUCT_UNAVAILABLE') {
        ref.invalidate(stockProvider);
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartControllerProvider);
    final subtotal = ref.watch(cartSubtotalProvider);

    if (_placed) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thanh toán')),
        body: const LoadingView(),
      );
    }
    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thanh toán')),
        body: EmptyState(
          icon: Icons.shopping_bag_outlined,
          message: 'Giỏ hàng đang trống',
          hint: 'Hãy thêm sản phẩm vào giỏ trước khi thanh toán.',
          action: FilledButton(
            onPressed: () => context.go(AppRoutes.customerHome),
            child: const Text('Tiếp tục mua sắm'),
          ),
        ),
      );
    }

    final stockProvider = productsStockProvider(_stockKey(items));
    // Đồng bộ giá/tên mới nhất vào giỏ ngay khi tải xong tồn kho.
    ref.listen(stockProvider, (_, next) {
      final data = next.value;
      if (data == null) return;
      final changed = ref
          .read(cartControllerProvider.notifier)
          .refreshProducts(data.map((e) => e.product));
      if (changed) {
        showAppSnackBar('Giá một số sản phẩm đã thay đổi và được cập nhật.');
      }
    });
    final stockAsync = ref.watch(stockProvider);
    final stock = stockAsync.value == null
        ? null
        : CheckoutStock.analyze(items, stockAsync.value!);
    final store = stock == null ? null : _storeFor(stock);

    final shippingFee = _isDelivery ? AppConstants.deliveryFee : 0;
    final total = subtotal + shippingFee;
    final count = items.fold(0, (sum, e) => sum + e.quantity);

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: OrderContentWidth(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              TitledCard(
                title: 'Hình thức nhận hàng',
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: _ChoiceTile(
                        icon: Icons.local_shipping_outlined,
                        title: 'Giao tận nơi',
                        subtitle:
                            'Phí ship ${formatVnd(AppConstants.deliveryFee)}',
                        selected: _isDelivery,
                        onTap: () => setState(
                          () => _fulfillment = FulfillmentType.delivery,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ChoiceTile(
                        icon: Icons.storefront_outlined,
                        title: 'Nhận tại cửa hàng',
                        subtitle: 'Miễn phí',
                        selected: !_isDelivery,
                        onTap: () => setState(
                          () => _fulfillment = FulfillmentType.storePickup,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isDelivery) ...[
                TitledCard(
                  title: 'Thông tin nhận hàng',
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Họ tên người nhận',
                        controller: _name,
                        prefixIcon: Icons.person_outline,
                        validator: Validators.fullName,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Số điện thoại',
                        controller: _phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: Validators.phone,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Địa chỉ giao hàng',
                        hint:
                            'Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành',
                        controller: _address,
                        prefixIcon: Icons.location_on_outlined,
                        validator: Validators.address,
                        maxLines: 3,
                        keyboardType: TextInputType.streetAddress,
                      ),
                    ],
                  ),
                ),
                TitledCard(
                  title: 'Cửa hàng xử lý đơn',
                  child: _StockState(
                    stock: stockAsync,
                    onRetry: () => ref.invalidate(stockProvider),
                    child: () => _DeliveryStore(store: store),
                  ),
                ),
              ] else
                TitledCard(
                  title: 'Chọn cửa hàng nhận hàng',
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _StockState(
                    stock: stockAsync,
                    onRetry: () => ref.invalidate(stockProvider),
                    padded: true,
                    child: () => _PickupStores(
                      stores: stock!.stores,
                      selectedId: store?.id,
                      onSelected: (id) => setState(() => _pickupStoreId = id),
                    ),
                  ),
                ),
              TitledCard(
                title: 'Sản phẩm ($count)',
                trailing: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Sửa'),
                ),
                child: Column(
                  children: [
                    if (stock != null && stock.unavailableItems.isNotEmpty)
                      _UnavailableNotice(
                        items: stock.unavailableItems,
                        onRemove: () {
                          final cart = ref.read(
                            cartControllerProvider.notifier,
                          );
                          for (final e in stock.unavailableItems) {
                            cart.remove(e.productId);
                          }
                        },
                      ),
                    for (final item in items)
                      OrderLineTile(
                        name: item.name,
                        image: item.image,
                        quantity: item.quantity,
                        unitPrice: item.unitPrice,
                      ),
                  ],
                ),
              ),
              TitledCard(
                title: 'Phương thức thanh toán',
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: RadioGroup<PaymentMethod>(
                  groupValue: _payment,
                  onChanged: (v) => setState(() => _payment = v ?? _payment),
                  child: Column(
                    children: [
                      _PaymentOption(
                        value: PaymentMethod.cod,
                        icon: Icons.payments_outlined,
                        title: _isDelivery
                            ? 'Thanh toán khi nhận hàng (COD)'
                            : 'Thanh toán khi nhận tại cửa hàng',
                        subtitle: _isDelivery
                            ? 'Trả tiền mặt cho nhân viên giao hàng.'
                            : 'Trả tiền tại quầy khi đến lấy hàng.',
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      const _PaymentOption(
                        value: PaymentMethod.bankTransfer,
                        icon: Icons.qr_code_2,
                        title: 'Chuyển khoản qua QR PayOS',
                        subtitle:
                            'Quét mã VietQR bằng app ngân hàng, xác nhận tự '
                            'động. Mã có hiệu lực 15 phút.',
                      ),
                    ],
                  ),
                ),
              ),
              TitledCard(
                title: 'Chi tiết thanh toán',
                child: Column(
                  children: [
                    MoneyRow(label: 'Tạm tính', value: formatVnd(subtotal)),
                    MoneyRow(
                      label: 'Phí vận chuyển',
                      value: shippingFee == 0
                          ? 'Miễn phí'
                          : formatVnd(shippingFee),
                      valueColor: shippingFee == 0 ? AppColors.success : null,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(height: 1),
                    ),
                    MoneyRow(
                      label: 'Tổng thanh toán',
                      value: formatVnd(total),
                      emphasize: true,
                    ),
                    if (total ~/ AppConstants.vndPerPoint > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.stars_outlined,
                              size: 16,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Nhận ${total ~/ AppConstants.vndPerPoint} '
                                'điểm khi đơn hoàn tất',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng thanh toán',
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                  Text(
                    formatVnd(total),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            AppButton(
              expand: false,
              label: 'Đặt hàng',
              onPressed: stockAsync.isLoading && stock == null
                  ? null
                  : () => _placeOrder(items, stock),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ô chọn hình thức nhận hàng.
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.muted;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.primary : AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hiện loading / lỗi của tồn kho, có dữ liệu thì dựng [child].
class _StockState extends StatelessWidget {
  const _StockState({
    required this.stock,
    required this.onRetry,
    required this.child,
    this.padded = false,
  });

  final AsyncValue<List<ProductInventory>> stock;
  final VoidCallback onRetry;
  final Widget Function() child;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final pad = padded
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
        : EdgeInsets.zero;
    if (stock.value != null) return child();
    if (stock.hasError) {
      return Padding(
        padding: pad,
        child: InlineError(
          message:
              'Không kiểm tra được tồn kho. ${errorMessageOf(stock.error!)}',
          onRetry: onRetry,
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _DeliveryStore extends StatelessWidget {
  const _DeliveryStore({required this.store});

  final Store? store;

  @override
  Widget build(BuildContext context) {
    final store = this.store;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          store == null ? Icons.error_outline : Icons.check_circle_outline,
          color: store == null ? AppColors.accent : AppColors.success,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                store?.name ?? 'Chưa có cửa hàng nào còn đủ hàng',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                store == null
                    ? 'Vui lòng giảm số lượng hoặc chọn sản phẩm khác.'
                    : 'Đơn được chuẩn bị và giao từ cửa hàng này.',
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PickupStores extends StatelessWidget {
  const _PickupStores({
    required this.stores,
    required this.selectedId,
    required this.onSelected,
  });

  final List<StoreAvailability> stores;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: Text(
          'Hiện chưa có cửa hàng nào đang hoạt động.',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }
    return RadioGroup<String>(
      groupValue: selectedId,
      onChanged: (id) {
        if (id != null) onSelected(id);
      },
      child: Column(
        children: [
          for (var i = 0; i < stores.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            _PickupStoreTile(availability: stores[i]),
          ],
        ],
      ),
    );
  }
}

class _PickupStoreTile extends StatelessWidget {
  const _PickupStoreTile({required this.availability});

  final StoreAvailability availability;

  @override
  Widget build(BuildContext context) {
    final store = availability.store;
    final ok = availability.isAvailable;
    return RadioListTile<String>(
      value: store.id,
      enabled: ok,
      isThreeLine: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(
        store.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (store.address.isNotEmpty)
            Text(
              store.address,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          const SizedBox(height: 4),
          Text(
            ok ? 'Còn đủ hàng cho giỏ của bạn' : availability.shortageSummary,
            style: TextStyle(
              color: ok ? AppColors.success : AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.value,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final PaymentMethod value;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<PaymentMethod>(
      value: value,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.muted, fontSize: 13),
      ),
    );
  }
}

class _UnavailableNotice extends StatelessWidget {
  const _UnavailableNotice({required this.items, required this.onRemove});

  final List<CartItem> items;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.remove_shopping_cart_outlined,
            color: AppColors.accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Đã ngừng bán: ${items.map((e) => e.name).join(', ')}',
              style: const TextStyle(color: AppColors.accent, fontSize: 13),
            ),
          ),
          TextButton(onPressed: onRemove, child: const Text('Xóa')),
        ],
      ),
    );
  }
}
