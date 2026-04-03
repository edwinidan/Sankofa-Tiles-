import 'package:flutter/services.dart';

enum HapticIntensity { off, low, medium, high }

/// All haptic calls go through here so the user's intensity setting
/// is always respected throughout the game.
class HapticService {
  // Light snap — tile selection confirm
  static void selectionClick(HapticIntensity intensity) {
    if (intensity == HapticIntensity.off) return;
    HapticFeedback.selectionClick();
  }

  // Mid-weight press — tile tap-down
  static void tilePress(HapticIntensity intensity) {
    switch (intensity) {
      case HapticIntensity.off:
        break;
      case HapticIntensity.low:
        HapticFeedback.selectionClick();
        break;
      case HapticIntensity.medium:
      case HapticIntensity.high:
        HapticFeedback.mediumImpact();
        break;
    }
  }

  // Single heavy impact — match slam, denied hit
  static void heavyImpact(HapticIntensity intensity) {
    switch (intensity) {
      case HapticIntensity.off:
        break;
      case HapticIntensity.low:
        HapticFeedback.lightImpact();
        break;
      case HapticIntensity.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticIntensity.high:
        HapticFeedback.heavyImpact();
        break;
    }
  }

  // Timed sequence — combo bursts, win/lost
  static void sequence(HapticIntensity intensity, List<int> delaysMs) {
    if (intensity == HapticIntensity.off) return;
    for (final ms in delaysMs) {
      Future.delayed(Duration(milliseconds: ms), () => heavyImpact(intensity));
    }
  }
}
