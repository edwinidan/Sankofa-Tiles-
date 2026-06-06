import 'package:flutter/material.dart';

class SankofaGameTheme {
  const SankofaGameTheme._();

  static const gameBackgroundTexture = 'assets/background green option 2.png';

  static const backgroundTop = Color(0xFF101A16);
  static const backgroundMiddle = Color(0xFF13241E);
  static const backgroundBottom = Color(0xFF17241F);

  static const boardSurface = Color(0xFF203329);
  static const boardSurfaceAlt = Color(0xFF263A30);
  static const boardEdge = Color(0xFF17271F);

  static const parchment = Color(0xFFF1E6CF);
  static const parchmentLight = Color(0xFFF8F0DE);
  static const parchmentDark = Color(0xFFE2D2AD);

  static const antiqueGold = Color(0xFFB88A3A);
  static const mutedGold = Color(0xFF8B6A35);
  static const darkText = Color(0xFF2B2418);
  static const mutedText = Color(0xFF74664E);
  static const lightText = Color(0xFFF1E6CF);
  static const mutedLightText = Color(0xFFCBBFA8);
  static const tileShadow = Color(0xFF000000);

  static const panelRadius = 18.0;
  static const boardRadius = 28.0;
  static const tileRadius = 5.0;

  static const screenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundTop, backgroundMiddle, backgroundBottom],
  );

  static const boardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2A4035), boardSurface, Color(0xFF14251E)],
    stops: [0.0, 0.52, 1.0],
  );

  static const panelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [parchmentLight, parchment],
  );

  static List<BoxShadow> get panelShadow => [
        BoxShadow(
          color: tileShadow.withValues(alpha: 0.24),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  static BoxDecoration get parchmentPanelDecoration => BoxDecoration(
        gradient: panelGradient,
        borderRadius: BorderRadius.circular(panelRadius),
        border: Border.all(
          color: antiqueGold.withValues(alpha: 0.52),
        ),
        boxShadow: panelShadow,
      );

  static BoxDecoration darkPanelDecoration({
    bool emphasized = false,
    bool disabled = false,
  }) {
    final borderColor = disabled
        ? mutedLightText.withValues(alpha: 0.18)
        : antiqueGold.withValues(alpha: emphasized ? 0.58 : 0.4);

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: disabled
            ? const [Color(0xFF17221D), Color(0xFF111B17)]
            : const [boardSurfaceAlt, boardSurface, boardEdge],
      ),
      borderRadius: BorderRadius.circular(panelRadius),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: tileShadow.withValues(alpha: emphasized ? 0.3 : 0.22),
          blurRadius: emphasized ? 16 : 12,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }

  static List<BoxShadow> tileShadowsForLayer(int layer) {
    final factor = layer.clamp(0, 6).toDouble();
    return [
      BoxShadow(
        color: tileShadow.withValues(alpha: 0.24 + factor * 0.025),
        offset: Offset(1.5 + factor * 0.35, 2.5 + factor * 0.45),
        blurRadius: 4.0 + factor * 0.75,
        spreadRadius: 0.2,
      ),
      BoxShadow(
        color: parchmentLight.withValues(alpha: 0.10),
        offset: const Offset(-0.7, -0.7),
        blurRadius: 1.2,
      ),
    ];
  }
}
