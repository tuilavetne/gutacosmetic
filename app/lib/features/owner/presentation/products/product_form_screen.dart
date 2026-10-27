import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_messenger.dart';
import '../../../customer/presentation/widgets/product_image.dart';
import '../../../shared/models/models.dart';
import '../../data/owner_repository.dart';

/// 1 ảnh chính + tối đa 5 ảnh phụ.
const maxProductImages = 6;
const _maxImageBytes = 5 * 1024 * 1024;

/// Ảnh trong form: ảnh đã có (URL) hoặc ảnh mới chọn, chờ tải lên khi lưu.
sealed class ProductImageSlot {
  const ProductImageSlot();
}

class RemoteImage extends ProductImageSlot {
  const RemoteImage(this.url);
  final String url;
}

class LocalImage extends ProductImageSlot {
  const LocalImage(this.upload);
  final ImageUpload upload;
}

/// MIME backend nhận (JPG/PNG/WEBP); `null` nếu không hợp lệ.
String? productImageMimeType({String? mimeType, required String fileName}) {
  final mime = mimeType?.toLowerCase();
  if (mime != null && mime.startsWith('image/')) {
    if (mime == 'image/jpg') return 'image/jpeg';
    return const {'image/jpeg', 'image/png', 'image/webp'}.contains(mime)
        ? mime
        : null;
  }
  final name = fileName.toLowerCase();
  if (name.endsWith('.png')) return 'image/png';
  if (name.endsWith('.webp')) return 'image/webp';
  if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
  // Ảnh đã nén lại (imageQuality) trên Android/iOS luôn là JPEG.
  return kIsWeb ? null : 'image/jpeg';
}

int? _money(String text) {
  final v = text.trim().replaceAll('.', '').replaceAll(',', '');
  return v.isEmpty ? null : int.tryParse(v);
}

/// Thêm (product == null) hoặc sửa sản phẩm. SKU không đổi được sau khi tạo.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _form = GlobalKey<FormState>();
  late final Product? _p = widget.product;
  late final _sku = TextEditingController(text: _p?.sku);
  late final _name = TextEditingController(text: _p?.name);
  late final _brand = TextEditingController(text: _p?.brand);
  late final _price = TextEditingController(
    text: _p == null ? '' : '${_p.price}',
  );
  late final _originalPrice = TextEditingController(
    text: _p?.originalPrice?.toString(),
  );
  late final _costPrice = TextEditingController(
    text: _p?.costPrice?.toString(),
  );
  late final _volume = TextEditingController(text: _p?.volume);
  late final _origin = TextEditingController(text: _p?.origin);
  late final _expiry = TextEditingController(text: _p?.expiryDate);
  late final _description = TextEditingController(text: _p?.description);
  late String? _category = _p?.category;
  late final Set<String> _skinTypes = {...?_p?.skinTypes};
  late bool _isActive = _p?.isActive ?? true;
  late final List<ProductImageSlot> _images = [
    for (final url in _p?.gallery ?? const <String>[]) RemoteImage(url),
  ];
  bool _saving = false;

  bool get _isEdit => _p != null;

  @override
  void dispose() {
    for (final c in [
      _sku,
      _name,
      _brand,
      _price,
      _originalPrice,
      _costPrice,
      _volume,
      _origin,
      _expiry,
      _description,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    final remaining = maxProductImages - _images.length;
    if (remaining <= 0) return;
    final List<XFile> files;
    try {
      final picker = ImagePicker();
      // `limit` của pickMultiImage phải ≥ 2.
      files = remaining >= 2
          ? await picker.pickMultiImage(
              maxWidth: 1600,
              maxHeight: 1600,
              imageQuality: 85,
              limit: remaining,
            )
          : [
              ?await picker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 1600,
                maxHeight: 1600,
                imageQuality: 85,
              ),
            ];
    } catch (_) {
      showAppSnackBar(
        'Không mở được thư viện ảnh. Kiểm tra quyền truy cập.',
        isError: true,
      );
      return;
    }

    final accepted = <ProductImageSlot>[];
    var rejected = 0;
    for (final file in files.take(remaining)) {
      final mime = productImageMimeType(
        mimeType: file.mimeType,
        fileName: file.name,
      );
      final bytes = mime == null ? null : await file.readAsBytes();
      if (mime == null || bytes == null || bytes.length > _maxImageBytes) {
        rejected++;
        continue;
      }
      accepted.add(
        LocalImage((bytes: bytes, fileName: file.name, mimeType: mime)),
      );
    }
    if (!mounted) return;
    setState(() => _images.addAll(accepted));
    if (rejected > 0) {
      showAppSnackBar(
        'Bỏ qua $rejected ảnh: chỉ nhận JPG/PNG/WEBP, tối đa 5MB.',
        isError: true,
      );
    }
  }

  void _makeMain(int index) => setState(() {
    final slot = _images.removeAt(index);
    _images.insert(0, slot);
  });

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_category == null) {
      showAppSnackBar('Vui lòng chọn danh mục.', isError: true);
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(ownerRepositoryProvider);
    try {
      final locals = [
        for (final slot in _images)
          if (slot is LocalImage) slot.upload,
      ];
      final uploaded = locals.isEmpty
          ? const <String>[]
          : await repo.uploadProductImages(locals);
      var next = 0;
      final urls = [
        for (final slot in _images)
          switch (slot) {
            RemoteImage(:final url) => url,
            LocalImage() => uploaded[next++],
          },
      ];
      final data = <String, Object?>{
        if (!_isEdit) 'sku': _sku.text.trim().toUpperCase(),
        'name': _name.text.trim(),
        'brand': _brand.text.trim(),
        'category': _category,
        'price': _money(_price.text),
        'originalPrice': _money(_originalPrice.text),
        'costPrice': _money(_costPrice.text),
        'skinTypes': _skinTypes.toList(),
        'volume': _volume.text.trim(),
        'origin': _origin.text.trim(),
        'expiryDate': _expiry.text.trim(),
        'description': _description.text.trim(),
        'image': urls.firstOrNull ?? '',
        'images': urls.skip(1).toList(),
        'isActive': _isActive,
      };
      if (_isEdit) {
        await repo.updateProduct(_p!.id, data);
      } else {
        await repo.createProduct(data);
      }
      ref.invalidate(ownerProductsProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      showAppSnackBar(_isEdit ? 'Đã lưu sản phẩm.' : 'Đã thêm sản phẩm.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar('Không lưu được: ${errorMessageOf(e)}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      for (final c in productCategories) c.name,
      // Giữ danh mục cũ không nằm trong danh sách chuẩn.
      if (_category != null &&
          !productCategories.any((c) => c.name == _category))
        _category!,
    ];
    InputDecoration deco(String label, {String? hint, String? helper}) =>
        InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helper,
          border: const OutlineInputBorder(),
        );
    const gap = SizedBox(height: 12);
    final digits = [FilteringTextInputFormatter.digitsOnly];

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm')),
      body: Form(
        key: _form,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ImagesEditor(
                  images: _images,
                  enabled: !_saving,
                  onAdd: _pickImages,
                  onRemove: (i) => setState(() => _images.removeAt(i)),
                  onMakeMain: _makeMain,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('product-sku'),
                  controller: _sku,
                  enabled: !_isEdit,
                  textCapitalization: TextCapitalization.characters,
                  decoration: deco(
                    'SKU',
                    helper: _isEdit
                        ? 'SKU không đổi được sau khi tạo'
                        : 'Không đổi được sau khi tạo',
                  ),
                  validator: (v) => Validators.required(v, 'SKU'),
                ),
                gap,
                TextFormField(
                  key: const ValueKey('product-name'),
                  controller: _name,
                  decoration: deco('Tên sản phẩm'),
                  validator: (v) => Validators.required(v, 'Tên sản phẩm'),
                ),
                gap,
                TextFormField(
                  key: const ValueKey('product-brand'),
                  controller: _brand,
                  decoration: deco('Thương hiệu'),
                  validator: (v) => Validators.required(v, 'Thương hiệu'),
                ),
                gap,
                DropdownButtonFormField<String>(
                  key: const ValueKey('product-category'),
                  initialValue: _category,
                  decoration: deco('Danh mục'),
                  items: [
                    for (final c in categories)
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                  validator: (v) => v == null ? 'Vui lòng chọn danh mục' : null,
                  onChanged: (v) => setState(() => _category = v),
                ),
                gap,
                TextFormField(
                  key: const ValueKey('product-price'),
                  controller: _price,
                  keyboardType: TextInputType.number,
                  inputFormatters: digits,
                  decoration: deco('Giá bán (đ)'),
                  validator: (v) =>
                      Validators.nonNegativeMoney(v, field: 'Giá bán'),
                ),
                gap,
                TextFormField(
                  controller: _originalPrice,
                  keyboardType: TextInputType.number,
                  inputFormatters: digits,
                  decoration: deco(
                    'Giá gốc (đ)',
                    helper: 'Để trống nếu không giảm giá',
                  ),
                  validator: (v) {
                    final base = Validators.nonNegativeMoney(
                      v,
                      allowEmpty: true,
                      field: 'Giá gốc',
                    );
                    if (base != null) return base;
                    final original = _money(v ?? '');
                    final price = _money(_price.text);
                    if (original != null && price != null && original < price) {
                      return 'Giá gốc phải ≥ giá bán';
                    }
                    return null;
                  },
                ),
                gap,
                TextFormField(
                  key: const ValueKey('product-cost'),
                  controller: _costPrice,
                  keyboardType: TextInputType.number,
                  inputFormatters: digits,
                  decoration: deco(
                    'Giá vốn (đ)',
                    helper: 'Dùng để tính lợi nhuận gộp — chỉ Owner thấy',
                  ),
                  validator: (v) => Validators.nonNegativeMoney(
                    v,
                    allowEmpty: true,
                    field: 'Giá vốn',
                  ),
                ),
                gap,
                const Text('Loại da phù hợp'),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final skin in {...skinTypeOptions, ..._skinTypes})
                      FilterChip(
                        label: Text(skin),
                        selected: _skinTypes.contains(skin),
                        onSelected: (on) => setState(
                          () => on
                              ? _skinTypes.add(skin)
                              : _skinTypes.remove(skin),
                        ),
                      ),
                  ],
                ),
                gap,
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _volume,
                        decoration: deco('Dung tích', hint: '50ml'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _origin,
                        decoration: deco('Xuất xứ', hint: 'Hàn Quốc'),
                      ),
                    ),
                  ],
                ),
                gap,
                TextFormField(
                  controller: _expiry,
                  decoration: deco(
                    'Hạn sử dụng (mô tả)',
                    hint: '36 tháng kể từ NSX',
                  ),
                ),
                gap,
                TextFormField(
                  controller: _description,
                  minLines: 3,
                  maxLines: 8,
                  decoration: deco('Mô tả'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Đang bán'),
                  subtitle: const Text('Tắt để ẩn sản phẩm khỏi cửa hàng'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  key: const ValueKey('product-save'),
                  onPressed: _saving ? null : _save,
                  child: Text(
                    _saving
                        ? 'Đang lưu...'
                        : _isEdit
                        ? 'Lưu thay đổi'
                        : 'Thêm sản phẩm',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagesEditor extends StatelessWidget {
  const _ImagesEditor({
    required this.images,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
    required this.onMakeMain,
  });

  final List<ProductImageSlot> images;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onMakeMain;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ảnh sản phẩm (${images.length}/$maxProductImages)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text(
          'Ảnh đầu tiên là ảnh chính. Chạm vào ảnh phụ để đặt làm ảnh chính.',
          style: TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (index, slot) in images.indexed)
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    GestureDetector(
                      onTap: enabled && index > 0
                          ? () => onMakeMain(index)
                          : null,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: switch (slot) {
                          RemoteImage(:final url) => ProductImage(url: url),
                          LocalImage(:final upload) => Image.memory(
                            upload.bytes,
                            fit: BoxFit.cover,
                          ),
                        },
                      ),
                    ),
                    if (index == 0)
                      Positioned(
                        left: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Ảnh chính',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton.filledTonal(
                        tooltip: 'Bỏ ảnh',
                        visualDensity: VisualDensity.compact,
                        iconSize: 16,
                        onPressed: enabled ? () => onRemove(index) : null,
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),
            if (images.length < maxProductImages)
              SizedBox(
                width: 92,
                height: 92,
                child: OutlinedButton(
                  key: const ValueKey('product-add-image'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: enabled ? onAdd : null,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined),
                      Text('Thêm ảnh', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
