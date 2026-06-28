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
  static const appParchment = Color(0xFFEDE0C4);
  static const appParchmentLight = Color(0xFFF1E6CF);
  static const appParchmentDark = Color(0xFFE8D8B7);

  static const levelCardTop = Color(0xFF203329);
  static const levelCardBottom = Color(0xFF1A2D25);
  static const levelCardDisabledTop = Color(0xFF192720);
  static const levelCardDisabledBottom = Color(0xFF142019);

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

  static const appPanelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [appParchmentLight, appParchment, appParchmentDark],
    stops: [0.0, 0.62, 1.0],
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

  static BoxDecoration get appParchmentPanelDecoration => BoxDecoration(
        gradient: appPanelGradient,
        borderRadius: BorderRadius.circular(panelRadius),
        border: Border.all(
          color: antiqueGold.withValues(alpha: 0.5),
        ),
        boxShadow: panelShadow,
      );

  static BoxDecoration levelCardDecoration({
    required bool unlocked,
  }) =>
      BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: unlocked
              ? const [levelCardTop, levelCardBottom]
              : const [levelCardDisabledTop, levelCardDisabledBottom],
        ),
        borderRadius: BorderRadius.circular(panelRadius),
        border: Border.all(
          color: unlocked
              ? antiqueGold.withValues(alpha: 0.46)
              : mutedLightText.withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: tileShadow.withValues(alpha: unlocked ? 0.3 : 0.2),
            blurRadius: unlocked ? 14 : 10,
            offset: const Offset(0, 7),
          ),
        ],
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
        color: tileShadow.withValues(alpha: 0.16 + factor * 0.018),
        offset: Offset(0, 4.0 + factor * 0.55),
        blurRadius: 11.0 + factor * 1.4,
        spreadRadius: -2.0,
      ),
      BoxShadow(
        color: tileShadow.withValues(alpha: 0.08 + factor * 0.01),
        offset: Offset(0, 1.2 + factor * 0.18),
        blurRadius: 3.5 + factor * 0.35,
        spreadRadius: -1.5,
      ),
    ];
  }
}
