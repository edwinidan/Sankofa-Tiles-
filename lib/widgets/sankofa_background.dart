import 'package:flutter/material.dart';

import '../core/theme/sankofa_game_theme.dart';

class SankofaBackground extends StatelessWidget {
  final Widget child;

  const SankofaBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: SankofaGameTheme.screenGradient,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: Image.asset(
              SankofaGameTheme.gameBackgroundTexture,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
          ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: SankofaGameTheme.backgroundTop.withValues(alpha: 0.34),
              ),
            ),
          ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.25),
                  radius: 1.15,
                  colors: [
                    SankofaGameTheme.boardSurfaceAlt.withValues(alpha: 0.12),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                  ],
                  stops: const [0, 0.62, 1],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
