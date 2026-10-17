import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_messenger.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/state_views.dart';
import '../../shared/models/models.dart';
import '../data/order_repository.dart';
import '../data/review_repository.dart';
import '../orders/order_actions.dart';
import '../orders/order_display.dart';
import 'widgets/order_widgets.dart';
import 'widgets/product_image.dart';

/// Gợi ý chèn nhanh vào nội dung đánh giá.
const _quickTags = [
  'Sản phẩm chính hãng',
  'Đóng gói cẩn thận',
  'Giao hàng nhanh',
  'Đáng tiền',
  'Sẽ mua lại',
];

/// Ảnh JPG/PNG (backend chỉ nhận 2 định dạng này cho ảnh đánh giá); trả về
/// MIME type hoặc `null` nếu không hợp lệ.
String? reviewImageMimeType({String? mimeType, required String fileName}) {
  final mime = mimeType?.toLowerCase();
  if (mime != null && mime.startsWith('image/')) {
    if (mime == 'image/png') return mime;
    if (mime == 'image/jpeg' || mime == 'image/jpg') return 'image/jpeg';
    return null;
  }
  final name = fileName.toLowerCase();
  if (name.endsWith('.png')) return 'image/png';
  if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
  return null;
}

/// Viết đánh giá cho đơn hoàn tất, hoặc sửa đánh giá đã có của đơn.
class WriteReviewScreen extends ConsumerWidget {
  const WriteReviewScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(customerOrderProvider(orderId));
    final reviewAsync = ref.watch(orderReviewProvider(orderId));

    Widget scaffold(Widget body) => Scaffold(
      appBar: AppBar(title: const Text('Đánh giá đơn hàng')),
      body: body,
    );

    final error = orderAsync.error ?? reviewAsync.error;
    if (error != null) {
      return scaffold(
        ErrorState(
          error: error,
          onRetry: () => ref
            ..invalidate(customerOrderProvider(orderId))
            ..invalidate(orderReviewProvider(orderId)),
        ),
      );
    }
    // Đang tải lại (sau khi lưu) thì giữ dữ liệu cũ, không hiện loading.
    final order = orderAsync.value;
    if (order == null || !reviewAsync.hasValue) {
      return scaffold(const LoadingView());
    }
    final review = reviewAsync.value;
    if (review == null && !order.canReview) {
      return scaffold(
        EmptyState(
          icon: Icons.rate_review_outlined,
          message: order.status == OrderStatus.completed
              ? 'Đơn hàng đã được đánh giá'
              : 'Chỉ đánh giá được đơn đã hoàn tất',
          action: OutlinedButton(
            onPressed: () => context.pop(),
            child: const Text('Quay lại'),
          ),
        ),
      );
    }
    // Khóa theo đánh giá để dựng lại form khi tải xong / đổi đánh giá.
    return _ReviewForm(key: ValueKey(review?.id), order: order, review: review);
  }
}

/// Ảnh mới chọn, chưa upload.
typedef _NewImage = ({Uint8List bytes, String fileName, String mimeType});

class _ReviewForm extends ConsumerStatefulWidget {
  const _ReviewForm({super.key, required this.order, required this.review});

  final Order order;

  /// Đánh giá đang sửa; `null` khi viết mới.
  final Review? review;

  @override
  ConsumerState<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends ConsumerState<_ReviewForm> {
  late int _rating = widget.review?.rating.clamp(1, 5) ?? 5;
  late final _comment = TextEditingController(text: widget.review?.comment);
  late final List<String> _keptImages = [
    ...?widget.review?.images.where((e) => e.isNotEmpty),
  ];
  final List<_NewImage> _newImages = [];
  String? _commentError;
  bool _saved = false;

  bool get _isEdit => widget.review != null;
  int get _imageCount => _keptImages.length + _newImages.length;

  bool get _dirty {
    final review = widget.review;
    if (review == null) {
      return _comment.text.trim().isNotEmpty || _newImages.isNotEmpty;
    }
    return _rating != review.rating ||
        _comment.text.trim() != review.comment.trim() ||
        _newImages.isNotEmpty ||
        _keptImages.length != review.images.where((e) => e.isNotEmpty).length;
  }

  /// Backend bỏ qua yêu cầu xóa hết ảnh (cần ít nhất một ảnh cũ hoặc mới).
  bool get _cannotClearImages =>
      _isEdit && _imageCount == 0 && widget.review!.images.isNotEmpty;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final text = _comment.text.trimRight();
    if (text.contains(tag)) return;
    _comment.text = text.isEmpty
        ? tag
        : '$text${RegExp(r'[.!?]$').hasMatch(text) ? '' : '.'} $tag';
    _comment.selection = TextSelection.collapsed(offset: _comment.text.length);
    setState(() => _commentError = null);
  }

  Future<void> _pickImages() async {
    final remaining = AppConstants.maxReviewImages - _imageCount;
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

    final accepted = <_NewImage>[];
    var wrongType = 0;
    var tooLarge = 0;
    for (final file in files.take(remaining)) {
      final mime = reviewImageMimeType(
        mimeType: file.mimeType,
        fileName: file.name,
      );
      if (mime == null) {
        wrongType++;
        continue;
      }
      final bytes = await file.readAsBytes();
      if (bytes.length > AppConstants.maxReviewImageBytes) {
        tooLarge++;
        continue;
      }
      accepted.add((bytes: bytes, fileName: file.name, mimeType: mime));
    }
    if (!mounted) return;
    setState(() => _newImages.addAll(accepted));

    final problems = [
      if (wrongType > 0) '$wrongType ảnh không phải JPG/PNG',
      if (tooLarge > 0) '$tooLarge ảnh lớn hơn 5 MB',
      if (files.length > remaining) 'chỉ thêm được tối đa $remaining ảnh',
    ];
    if (problems.isNotEmpty) {
      showAppSnackBar('Bỏ qua: ${problems.join(', ')}.', isError: true);
    }
  }

  Future<void> _submit() async {
    final comment = _comment.text.trim();
    if (comment.isEmpty) {
      setState(() => _commentError = 'Vui lòng chia sẻ cảm nhận của bạn');
      return;
    }
    final repo = ref.read(reviewRepositoryProvider);
    final review = widget.review;
    final saved = review == null
        ? await repo.createReview(
            orderId: widget.order.id,
            rating: _rating,
            comment: comment,
            images: _newImages,
          )
        : await repo.updateReview(
            review.id,
            rating: _rating,
            comment: comment,
            keptImages: _keptImages,
            newImages: _newImages,
          );
    if (!mounted) return;
    invalidateReviewCaches(ref, widget.order, saved);
    setState(() => _saved = true);
    showAppSnackBar(
      review == null
          ? 'Cảm ơn bạn đã đánh giá!'
          : 'Đã cập nhật đánh giá của bạn.',
    );
    context.pop();
  }

  Future<void> _confirmDiscard() async {
    final discard = await showConfirmDialog(
      context,
      title: _isEdit ? 'Bỏ thay đổi?' : 'Bỏ đánh giá?',
      message: _isEdit
          ? 'Các thay đổi chưa lưu sẽ bị mất.'
          : 'Nội dung bạn đang viết sẽ bị mất.',
      confirmLabel: 'Bỏ',
      cancelLabel: 'Viết tiếp',
      destructive: true,
    );
    if (discard && mounted) {
      setState(() => _saved = true);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final first = order.items.first;
    final others = order.items.length - 1;

    return PopScope(
      canPop: _saved || !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isEdit ? 'Sửa đánh giá' : 'Viết đánh giá')),
        body: OrderContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      ItemThumbnail(url: first.image, size: 60),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              first.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              others > 0
                                  ? 'Đơn ${order.orderCode} · và $others sản '
                                        'phẩm khác'
                                  : 'Đơn ${order.orderCode}',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (others > 0)
                const Padding(
                  padding: EdgeInsets.fromLTRB(4, 8, 4, 0),
                  child: Text(
                    'Mỗi đơn có một đánh giá, hiển thị ở trang của sản phẩm '
                    'đầu tiên trong đơn.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ),
              TitledCard(
                title: 'Chất lượng sản phẩm',
                child: Column(
                  children: [
                    StarPicker(
                      value: _rating,
                      onChanged: (v) => setState(() => _rating = v),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reviewRatingLabels[_rating]!,
                      style: const TextStyle(
                        color: Color(0xFFE09612),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              TitledCard(
                title: 'Cảm nhận của bạn',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _comment,
                      maxLines: 5,
                      minLines: 4,
                      maxLength: 1000,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() => _commentError = null),
                      decoration: InputDecoration(
                        hintText:
                            'Sản phẩm dùng thế nào? Có hợp với làn da của '
                            'bạn không?',
                        errorText: _commentError,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final tag in _quickTags)
                          ActionChip(
                            label: Text(tag),
                            onPressed: () => _addTag(tag),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              TitledCard(
                title:
                    'Hình ảnh ($_imageCount/${AppConstants.maxReviewImages})',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final url in _keptImages)
                          _ImageTile(
                            image: ProductImage(url: url, iconSize: 20),
                            onRemove: () =>
                                setState(() => _keptImages.remove(url)),
                          ),
                        for (final image in _newImages)
                          _ImageTile(
                            image: Image.memory(image.bytes, fit: BoxFit.cover),
                            onRemove: () =>
                                setState(() => _newImages.remove(image)),
                          ),
                        if (_imageCount < AppConstants.maxReviewImages)
                          _AddImageTile(onTap: _pickImages),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _cannotClearImages
                          ? 'Chưa hỗ trợ xóa hết ảnh của đánh giá cũ — nếu '
                                'không thêm ảnh mới, ảnh cũ sẽ được giữ lại.'
                          : 'JPG hoặc PNG, tối đa 5 ảnh, mỗi ảnh ≤ 5 MB.',
                      style: TextStyle(
                        color: _cannotClearImages
                            ? AppColors.warning
                            : AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomActionBar(
          child: AppButton(
            label: _isEdit ? 'Lưu thay đổi' : 'Gửi đánh giá',
            icon: Icons.send_outlined,
            onPressed: _isEdit && !_dirty ? null : _submit,
          ),
        ),
      ),
    );
  }
}

/// 5 ngôi sao bấm được để chọn số sao.
class StarPicker extends StatelessWidget {
  const StarPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 40,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            tooltip: '$i sao',
            onPressed: () => onChanged(i),
            iconSize: size,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            constraints: const BoxConstraints(),
            icon: Icon(
              i <= value ? Icons.star_rounded : Icons.star_outline_rounded,
              color: const Color(0xFFF5A623),
            ),
          ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({required this.image, required this.onRemove});

  final Widget image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 76,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(10), child: image),
          Positioned(
            top: 2,
            right: 2,
            child: Tooltip(
              message: 'Xóa ảnh',
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onRemove,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddImageTile extends StatelessWidget {
  const _AddImageTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          color: AppColors.primary.withValues(alpha: 0.05),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
            SizedBox(height: 4),
            Text(
              'Thêm ảnh',
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
