import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AdinkraDivider extends StatelessWidget {
  final String symbol;
  final double height;

  const AdinkraDivider({
    super.key,
    this.symbol = '◎',
    this.height = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.kenteGoldDim.withValues(alpha: 0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              symbol,
              style: const TextStyle(
                color: AppColors.kenteGold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.kenteGoldDim.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
