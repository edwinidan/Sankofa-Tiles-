import 'package:flutter/material.dart';

import '../core/theme/app_text_styles.dart';
import '../core/theme/sankofa_game_theme.dart';

const String kCowrieCurrencyAsset = 'assets/cowries currency.png';

class CowrieIcon extends StatelessWidget {
  const CowrieIcon({
    super.key,
    this.size = 28,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      kCowrieCurrencyAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: 'Cowries',
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.monetization_on_outlined,
          size: size,
          color: SankofaGameTheme.antiqueGold,
        );
      },
    );
  }
}

class CowrieAmount extends StatelessWidget {
  const CowrieAmount({
    super.key,
    required this.amount,
    this.prefix = '',
    this.style,
    this.iconSize = 28,
    this.label = 'Cowries',
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.textAlign,
  });

  final int amount;
  final String prefix;
  final TextStyle? style;
  final double iconSize;
  final String label;
  final MainAxisAlignment mainAxisAlignment;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        CowrieIcon(size: iconSize),
        const SizedBox(width: 8),
        Text(
          '$prefix$amount $label',
          style: style ??
              AppTextStyles.bodyMedium.copyWith(
                color: SankofaGameTheme.parchmentLight,
              ),
          textAlign: textAlign,
        ),
      ],
    );
  }
}
