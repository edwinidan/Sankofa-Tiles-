import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class KenteButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final double? width;
  final bool small;

  const KenteButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.width,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyMid,
          foregroundColor: AppColors.kenteGold,
          disabledBackgroundColor: AppColors.navyDeep,
          side: BorderSide(
            color: onTap != null ? AppColors.kenteGold : AppColors.navyLight,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: small ? 16 : 24,
            vertical: small ? 10 : 14,
          ),
          elevation: 4,
          shadowColor: AppColors.kenteGold.withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: small ? 16 : 20),
              const SizedBox(width: 8),
            ],
            Text(label, style: small ? AppTextStyles.labelSmall.copyWith(
              fontSize: 13,
              color: onTap != null ? AppColors.kenteGold : AppColors.textMuted,
            ) : AppTextStyles.buttonText.copyWith(
              color: onTap != null ? AppColors.kenteGold : AppColors.textMuted,
            )),
          ],
        ),
      ),
    );
  }
}
