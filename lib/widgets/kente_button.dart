import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/sankofa_game_theme.dart';

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
          backgroundColor: SankofaGameTheme.parchment,
          foregroundColor: SankofaGameTheme.darkText,
          disabledBackgroundColor:
              SankofaGameTheme.parchmentDark.withValues(alpha: 0.55),
          disabledForegroundColor: SankofaGameTheme.mutedText,
          side: BorderSide(
            color: onTap != null
                ? SankofaGameTheme.antiqueGold.withValues(alpha: 0.72)
                : SankofaGameTheme.mutedText.withValues(alpha: 0.35),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: small ? 16 : 24,
            vertical: small ? 10 : 14,
          ),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.3),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: small ? 16 : 20),
                const SizedBox(width: 8),
              ],
              Text(label,
                  style: small
                      ? AppTextStyles.labelSmall.copyWith(
                          fontSize: 13,
                          color: onTap != null
                              ? SankofaGameTheme.darkText
                              : SankofaGameTheme.mutedText,
                        )
                      : AppTextStyles.archiveButtonText.copyWith(
                          color: onTap != null
                              ? SankofaGameTheme.darkText
                              : SankofaGameTheme.mutedText,
                        )),
            ],
          ),
        ),
      ),
    );
  }
}
