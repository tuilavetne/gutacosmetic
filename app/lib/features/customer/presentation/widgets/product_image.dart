import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';

/// Ảnh sản phẩm; không có ảnh hoặc lỗi tải thì hiện ô nền hồng với lá.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url, this.iconSize = 28});

  final String? url;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: const Color(0xFFFFF0F2),
      child: Center(
        child: Icon(
          Icons.eco_outlined,
          size: iconSize,
          color: AppColors.accent,
        ),
      ),
    );
    final src = url;
    if (src == null || src.isEmpty) return placeholder;
    return CachedNetworkImage(
      imageUrl: src,
      fit: BoxFit.cover,
      placeholder: (_, _) => const ColoredBox(color: Color(0xFFF0F1EE)),
      errorWidget: (_, _, _) => placeholder,
    );
  }
}
