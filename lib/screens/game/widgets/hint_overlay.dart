import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HintOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const HintOverlay({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.navyMid,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.kenteGold, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lightbulb, color: AppColors.kenteGold, size: 40),
                const SizedBox(height: 12),
                Text('Hint Active', style: AppTextStyles.displaySmall),
                const SizedBox(height: 8),
                Text(
                  'Matching tiles are glowing green.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tap anywhere to dismiss',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
