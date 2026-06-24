import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService._();

  static FirebaseAnalytics? _analytics;

  static void initialize() {
    _analytics = FirebaseAnalytics.instance;
  }

  static void logAppOpen() => _log((analytics) => analytics.logAppOpen());

  static void logPlayPressed(int? levelId) => _event(
        'play_pressed',
        levelId == null ? null : {'level_id': levelId},
      );

  static void logNextGamePressed(int levelId) =>
      _event('next_game_pressed', {'level_id': levelId});

  static void logLevelRetried(int levelId) =>
      _event('level_retried', {'level_id': levelId});

  static void logScreenView(String screenName) => _log(
        (analytics) => analytics.logScreenView(
          screenName: screenName,
          screenClass: screenName,
        ),
      );

  static void logLevelStarted(int levelId, String difficulty) => _event(
        'level_started',
        {'level_id': levelId, 'difficulty': difficulty},
      );

  static void logLevelCompleted(
    int levelId,
    String difficulty,
    int score,
    int stars,
    int secondsElapsed,
  ) =>
      _event('level_completed', {
        'level_id': levelId,
        'difficulty': difficulty,
        'score': score,
        'stars': stars,
        'seconds_elapsed': secondsElapsed,
      });

  static void logLevelFailed(
    int levelId,
    String difficulty,
    int score,
    String reason,
  ) =>
      _event('level_failed', {
        'level_id': levelId,
        'difficulty': difficulty,
        'score': score,
        'reason': reason,
      });

  static void logHintUsed(int levelId, String difficulty) => _event(
        'hint_used',
        {'level_id': levelId, 'difficulty': difficulty},
      );

  static void logShuffleUsed(int levelId, String difficulty) => _event(
        'shuffle_used',
        {'level_id': levelId, 'difficulty': difficulty},
      );

  static void logPauseUsed(int levelId, String difficulty) => _event(
        'pause_used',
        {'level_id': levelId, 'difficulty': difficulty},
      );

  static void logSettingsOpened(String source) =>
      _event('settings_opened', {'source': source});

  static void logTilePreviewOpened() => _event('tile_preview_opened');

  static void logOnboardingCompleted() => _event('onboarding_completed');

  static void logTutorialStarted({required bool replay}) => _event(
        'tutorial_started',
        {'replay': replay},
      );

  static void logTutorialStepCompleted(int step) =>
      _event('tutorial_step_completed', {'step': step});

  static void logTutorialSkipped() => _event('tutorial_skipped');

  static void logTutorialCompleted() => _event('tutorial_completed');

  static void logResetProgress() => _event('reset_progress');

  static void logWalletChanged(String reason, int amount) => _event(
        'wallet_changed',
        {'reason': reason, 'amount': amount},
      );

  static void logBoosterChanged(String booster, String reason, int amount) =>
      _event(
        'booster_changed',
        {'booster': booster, 'reason': reason, 'amount': amount},
      );

  static void logDailyRewardClaimed(int day) =>
      _event('daily_reward_claimed', {'day': day});

  static void logCollectionUnlocked(String symbolId) =>
      _event('collection_unlocked', {'symbol_id': symbolId});

  static void logAchievementUnlocked(String achievementId) =>
      _event('achievement_unlocked', {'achievement_id': achievementId});

  static void _event(
    String name, [
    Map<String, Object>? parameters,
  ]) =>
      _log(
        (analytics) => analytics.logEvent(
          name: name,
          parameters: parameters,
        ),
      );

  static void _log(
    Future<void> Function(FirebaseAnalytics analytics) operation,
  ) {
    final analytics = _analytics;
    if (analytics == null) return;

    unawaited(
      operation(analytics).catchError((Object error) {
        debugPrint('[AnalyticsService] $error');
      }),
    );
  }
}
