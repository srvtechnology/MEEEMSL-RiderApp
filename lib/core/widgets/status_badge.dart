import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum BadgeType { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    this.type = BadgeType.info,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case BadgeType.success:
        bg = AppColors.successLight;
        fg = AppColors.successDark;
        break;
      case BadgeType.warning:
        bg = AppColors.warningLight;
        fg = AppColors.warningDark;
        break;
      case BadgeType.error:
        bg = AppColors.errorLight;
        fg = AppColors.errorDark;
        break;
      case BadgeType.info:
        bg = AppColors.infoLight;
        fg = AppColors.infoDark;
        break;
      case BadgeType.neutral:
        bg = AppColors.lightSurfaceVariant;
        fg = AppColors.textSecondaryLight;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
