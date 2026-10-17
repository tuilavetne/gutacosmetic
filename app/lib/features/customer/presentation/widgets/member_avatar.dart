import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../shared/models/models.dart';

/// Hạng thành viên theo điểm tích lũy (giống app cũ: từ 1.000 điểm là Vàng).
enum MemberTier {
  silver('Thành viên Bạc', Color(0xFFECEEEC), Color(0xFF5C5E5B)),
  gold('Thành viên Vàng', Color(0xFFFDF0D9), Color(0xFF92660F));

  const MemberTier(this.label, this.background, this.foreground);

  static const goldPoints = 1000;

  factory MemberTier.of(int points) => points >= goldPoints ? gold : silver;

  final String label;
  final Color background;
  final Color foreground;
}

/// Ảnh đại diện: ảnh đã upload (hoặc ảnh Google), không có thì chữ cái đầu.
///
/// [badge] nằm ở góc dưới phải; mặc định là huy hiệu thành viên. Truyền
/// [showBadge] `false` để ẩn (ví dụ avatar nhỏ trên thanh tiêu đề).
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.user,
    this.size = 72,
    this.badge,
    this.showBadge = true,
    this.busy = false,
  });

  final AppUser user;
  final double size;
  final Widget? badge;
  final bool showBadge;

  /// Đang tải ảnh lên — phủ vòng xoay lên ảnh.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.28);
    final initials = Container(
      alignment: Alignment.center,
      color: AppColors.primary,
      child: Text(
        user.initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    final url = user.avatarUrl ?? '';

    final image = ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url.isEmpty)
              initials
            else
              CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, _) => initials,
                errorWidget: (_, _, _) => initials,
              ),
            if (busy)
              const ColoredBox(
                color: Color(0x66000000),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    if (!showBadge) return image;

    return SizedBox(
      width: size + 4,
      height: size + 4,
      child: Stack(
        children: [
          image,
          Positioned(
            right: 0,
            bottom: 0,
            child: badge ?? const _SparkleBadge(),
          ),
        ],
      ),
    );
  }
}

class _SparkleBadge extends StatelessWidget {
  const _SparkleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFE2A83F),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 2),
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 12),
    );
  }
}

/// Nhãn "Thành viên Vàng · 1.250 điểm".
class MemberTierBadge extends StatelessWidget {
  const MemberTierBadge({super.key, required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final tier = MemberTier.of(points);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tier.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, size: 13, color: tier.foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '${tier.label} · ${formatNumber(points)} điểm',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tier.foreground,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
