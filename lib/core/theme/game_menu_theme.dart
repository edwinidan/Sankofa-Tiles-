import 'package:flutter/material.dart';

/// Menu-only tokens. Keep the board theme and legacy screens independent.
abstract final class GameMenuTheme {
  static const emerald = Color(0xFF073D30);
  static const forest = Color(0xFF052B22);
  static const gold = Color(0xFFE3B657);
  static const amber = Color(0xFFC5A05A);
  static const primaryEdge = Color(0xFF795D32);
  static const cream = Color(0xFFFFF1D3);
  static const ink = Color(0xFF302619);
  static const mutedInk = Color(0xFF66543A);
  static const disabled = Color(0xFF46574F);
  static const outlineWidth = 1.5;
  static const contentWidth = 560.0;
  static const gap = 12.0;

  static ButtonStyle buttonStyle({bool primary = false}) =>
      ElevatedButton.styleFrom(
        backgroundColor: primary ? amber : emerald,
        foregroundColor: primary ? ink : cream,
        disabledBackgroundColor: disabled,
        disabledForegroundColor: cream,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        elevation: primary ? 1 : 0,
        minimumSize: Size(48, primary ? 64 : 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        side: BorderSide(
            color: primary ? primaryEdge : gold, width: outlineWidth),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(primary ? 28 : 24)),
      );
}
