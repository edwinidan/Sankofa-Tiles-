import 'package:shared_preferences/shared_preferences.dart';
import '../constants/level_data.dart';
import '../economy/economy_models.dart';
import '../../models/level_model.dart';
import 'crash_reporting_service.dart';
import 'haptic_service.dart';

class StorageService {
  static const _prefixBestScore = 'best_score_';
  static const _prefixStars = 'stars_';
  static const _prefixCompleted = 'completed_';
  static const _keyHighestCompletedLevel = 'highest_completed_level';
  static const _keySoundEnabled = 'sound_enabled';
  static const _keyMusicEnabled = 'music_enabled';
  static const _keyMusicVolume = 'music_volume';
  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyTutorialComplete = 'tutorial_complete';
  static const _keyShowTileNames = 'show_tile_names';
  static const _keyHapticIntensity = 'haptic_intensity';
  static const _keyCampaignProgressSchemaVersion =
      'campaign_progress_schema_version';
  static const _keyCowries = 'economy_cowries';
  static const _prefixBooster = 'economy_booster_';
  static const _prefixEconomyTransaction = 'economy_tx_';
  static const _keyDailyRewardDay = 'daily_reward_day';
  static const _keyLastDailyClaimDate = 'daily_last_claim_date';
  static const _prefixCollectionUnlocked = 'collection_unlocked_';
  static const _prefixAchievementClaimed = 'achievement_claimed_';
  static const _prefixMonetizationEntitlement = 'monetization_entitlement_';
  static const _prefixMonetizationPurchase = 'monetization_purchase_';
  static const _prefixMonetizationCallback = 'monetization_callback_';
  static const _keyInterstitialCompletedSinceLast =
      'monetization_interstitial_completed_since_last';
  static const _keyInterstitialSessionCount =
      'monetization_interstitial_session_count';
  static const _keyLastInterstitialMillis =
      'monetization_last_interstitial_millis';
  static const _keyLastRewardedAdMillis =
      'monetization_last_rewarded_ad_millis';
  static const _campaignProgressSchemaVersion = 3;

  late SharedPreferences _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _migrateCampaignProgressIfNeeded();
      await _prefs.setInt(_keyInterstitialSessionCount, 0);
    } catch (error, stackTrace) {
      CrashReportingService.recordNonFatal(
        error,
        stackTrace,
        reason: 'SharedPreferences initialization failed',
      );
      rethrow;
    }
  }

  Future<void> _migrateCampaignProgressIfNeeded() async {
    final currentVersion =
        _prefs.getInt(_keyCampaignProgressSchemaVersion) ?? 1;
    if (currentVersion >= _campaignProgressSchemaVersion) return;

    if (currentVersion < 3) {
      var migratedHighest = _prefs.getInt(_keyHighestCompletedLevel) ?? 0;

      for (final key in _prefs.getKeys()) {
        if (key.startsWith(_prefixStars) && (_prefs.getInt(key) ?? 0) > 0) {
          final levelId = int.tryParse(key.substring(_prefixStars.length));
          if (levelId != null && levelId > migratedHighest) {
            migratedHighest = levelId;
          }
        }
      }

      for (final legacyKey in const [
        'highest_completed_level',
        'highest_unlocked_level',
        'current_level',
      ]) {
        final value = _prefs.getInt(legacyKey);
        if (value == null) continue;
        final completedValue = legacyKey == 'highest_unlocked_level' ||
                legacyKey == 'current_level'
            ? value - 1
            : value;
        if (completedValue > migratedHighest) {
          migratedHighest = completedValue;
        }
      }

      migratedHighest = migratedHighest.clamp(0, kLevels.length);
      if (migratedHighest > 0) {
        await _prefs.setInt(_keyHighestCompletedLevel, migratedHighest);
        for (var levelId = 1; levelId <= migratedHighest; levelId++) {
          await _prefs.setBool('$_prefixCompleted$levelId', true);
        }
      }
    }

    await _prefs.setInt(
      _keyCampaignProgressSchemaVersion,
      _campaignProgressSchemaVersion,
    );
  }

  // Level results
  Future<void> saveLevelResult(int levelId, int score, int stars) async {
    try {
      final currentBest = getBestScore(levelId);
      if (score > currentBest) {
        await _prefs.setInt('$_prefixBestScore$levelId', score);
      }
      final currentStars = getStars(levelId);
      if (stars > currentStars) {
        await _prefs.setInt('$_prefixStars$levelId', stars);
      }
      await _prefs.setBool('$_prefixCompleted$levelId', true);
      final highestCompleted = getHighestCompletedLevel();
      if (levelId > highestCompleted) {
        await _prefs.setInt(_keyHighestCompletedLevel, levelId);
      }
    } catch (error, stackTrace) {
      CrashReportingService.recordNonFatal(
        error,
        stackTrace,
        reason: 'Level result persistence failed',
      );
      rethrow;
    }
  }

  int getBestScore(int levelId) =>
      _prefs.getInt('$_prefixBestScore$levelId') ?? 0;

  int getStars(int levelId) => _prefs.getInt('$_prefixStars$levelId') ?? 0;

  LevelResult? getLevelResult(int levelId) {
    final score = getBestScore(levelId);
    final stars = getStars(levelId);
    if (score == 0 && stars == 0) return null;
    return LevelResult(levelId: levelId, bestScore: score, stars: stars);
  }

  bool isLevelUnlocked(int levelId) {
    if (levelId == 1) return true;
    return isLevelCompleted(levelId - 1);
  }

  bool isLevelCompleted(int levelId) =>
      _prefs.getBool('$_prefixCompleted$levelId') == true ||
      getStars(levelId) > 0;

  int getHighestCompletedLevel() {
    final stored = _prefs.getInt(_keyHighestCompletedLevel) ?? 0;
    if (stored > 0) return stored;

    var highest = 0;
    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_prefixCompleted) && _prefs.getBool(key) == true) {
        final levelId = int.tryParse(key.substring(_prefixCompleted.length));
        if (levelId != null && levelId > highest) highest = levelId;
      } else if (key.startsWith(_prefixStars) &&
          (_prefs.getInt(key) ?? 0) > 0) {
        final levelId = int.tryParse(key.substring(_prefixStars.length));
        if (levelId != null && levelId > highest) highest = levelId;
      }
    }
    return highest;
  }

  // Sound
  bool isSoundEnabled() => _prefs.getBool(_keySoundEnabled) ?? true;
  Future<void> setSoundEnabled(bool val) async =>
      _prefs.setBool(_keySoundEnabled, val);

  // Music
  bool isMusicEnabled() => _prefs.getBool(_keyMusicEnabled) ?? true;
  Future<void> setMusicEnabled(bool val) async =>
      _prefs.setBool(_keyMusicEnabled, val);
  double getMusicVolume() => _prefs.getDouble(_keyMusicVolume) ?? 0.7;
  Future<void> setMusicVolume(double val) async =>
      _prefs.setDouble(_keyMusicVolume, val.clamp(0.0, 1.0));

  // Onboarding
  bool isOnboardingComplete() =>
      _prefs.getBool(_keyOnboardingComplete) ?? false;
  Future<void> setOnboardingComplete() async =>
      _prefs.setBool(_keyOnboardingComplete, true);

  bool isTutorialComplete() => _prefs.getBool(_keyTutorialComplete) ?? false;
  Future<void> setTutorialComplete() async =>
      _prefs.setBool(_keyTutorialComplete, true);

  // Show tile names
  bool isShowTileNames() => _prefs.getBool(_keyShowTileNames) ?? true;
  Future<void> setShowTileNames(bool val) async =>
      _prefs.setBool(_keyShowTileNames, val);

  // Haptic intensity
  HapticIntensity getHapticIntensity() {
    final val = _prefs.getString(_keyHapticIntensity);
    return HapticIntensity.values.firstWhere(
      (h) => h.name == val,
      orElse: () => HapticIntensity.high,
    );
  }

  Future<void> setHapticIntensity(HapticIntensity intensity) async =>
      _prefs.setString(_keyHapticIntensity, intensity.name);

  int getCowries() => (_prefs.getInt(_keyCowries) ?? 0).clamp(0, 1 << 31);
  Future<void> setCowries(int amount) async =>
      _prefs.setInt(_keyCowries, amount.clamp(0, 1 << 31));

  int getBooster(BoosterType type) =>
      (_prefs.getInt('$_prefixBooster${type.name}') ?? 0).clamp(0, 999999);
  Future<void> setBooster(BoosterType type, int count) async =>
      _prefs.setInt('$_prefixBooster${type.name}', count.clamp(0, 999999));

  bool hasEconomyTransaction(String transactionId) =>
      _prefs.getBool('$_prefixEconomyTransaction$transactionId') == true;
  Future<void> recordEconomyTransaction(String transactionId) async =>
      _prefs.setBool('$_prefixEconomyTransaction$transactionId', true);

  bool hasMonetizationEntitlement(String entitlementId) =>
      _prefs.getBool('$_prefixMonetizationEntitlement$entitlementId') == true;
  Future<void> setMonetizationEntitlement(String entitlementId) async =>
      _prefs.setBool('$_prefixMonetizationEntitlement$entitlementId', true);
  Set<String> getMonetizationEntitlementIds() => _prefs
      .getKeys()
      .where((key) =>
          key.startsWith(_prefixMonetizationEntitlement) &&
          _prefs.getBool(key) == true)
      .map((key) => key.substring(_prefixMonetizationEntitlement.length))
      .toSet();

  bool hasMonetizationPurchase(String productId) =>
      _prefs.getBool('$_prefixMonetizationPurchase$productId') == true;
  Future<void> recordMonetizationPurchase(String productId) async =>
      _prefs.setBool('$_prefixMonetizationPurchase$productId', true);
  Set<String> getMonetizationPurchaseIds() => _prefs
      .getKeys()
      .where((key) =>
          key.startsWith(_prefixMonetizationPurchase) &&
          _prefs.getBool(key) == true)
      .map((key) => key.substring(_prefixMonetizationPurchase.length))
      .toSet();

  bool hasMonetizationCallback(String callbackId) =>
      _prefs.getBool('$_prefixMonetizationCallback$callbackId') == true;
  Future<void> recordMonetizationCallback(String callbackId) async =>
      _prefs.setBool('$_prefixMonetizationCallback$callbackId', true);

  int getInterstitialCompletedSinceLast() =>
      (_prefs.getInt(_keyInterstitialCompletedSinceLast) ?? 0).clamp(0, 999999);
  Future<void> setInterstitialCompletedSinceLast(int count) async =>
      _prefs.setInt(_keyInterstitialCompletedSinceLast, count.clamp(0, 999999));

  int getInterstitialSessionCount() =>
      (_prefs.getInt(_keyInterstitialSessionCount) ?? 0).clamp(0, 999999);
  Future<void> setInterstitialSessionCount(int count) async =>
      _prefs.setInt(_keyInterstitialSessionCount, count.clamp(0, 999999));

  DateTime? getLastInterstitialAt() {
    final millis = _prefs.getInt(_keyLastInterstitialMillis);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> setLastInterstitialAt(DateTime value) async => _prefs.setInt(
        _keyLastInterstitialMillis,
        value.millisecondsSinceEpoch,
      );

  DateTime? getLastRewardedAdAt() {
    final millis = _prefs.getInt(_keyLastRewardedAdMillis);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> setLastRewardedAdAt(DateTime value) async => _prefs.setInt(
        _keyLastRewardedAdMillis,
        value.millisecondsSinceEpoch,
      );

  int getDailyRewardDay() =>
      (_prefs.getInt(_keyDailyRewardDay) ?? 1).clamp(1, 7);
  Future<void> setDailyRewardDay(int day) async =>
      _prefs.setInt(_keyDailyRewardDay, day.clamp(1, 7));
  String? getLastDailyClaimDate() => _prefs.getString(_keyLastDailyClaimDate);
  Future<void> setLastDailyClaimDate(String value) async =>
      _prefs.setString(_keyLastDailyClaimDate, value);

  bool isCollectionUnlocked(String tileId) =>
      _prefs.getBool('$_prefixCollectionUnlocked$tileId') == true;
  Future<void> unlockCollectionId(String tileId) async =>
      _prefs.setBool('$_prefixCollectionUnlocked$tileId', true);
  void unlockCollectionIdSync(String tileId) {
    if (!isCollectionUnlocked(tileId)) {
      _prefs.setBool('$_prefixCollectionUnlocked$tileId', true);
    }
  }

  Set<String> getUnlockedCollectionIds() => _prefs
      .getKeys()
      .where((key) =>
          key.startsWith(_prefixCollectionUnlocked) &&
          _prefs.getBool(key) == true)
      .map((key) => key.substring(_prefixCollectionUnlocked.length))
      .toSet();

  bool isAchievementClaimed(String achievementId) =>
      _prefs.getBool('$_prefixAchievementClaimed$achievementId') == true;
  Future<void> claimAchievement(String achievementId) async =>
      _prefs.setBool('$_prefixAchievementClaimed$achievementId', true);
  Set<String> getClaimedAchievementIds() => _prefs
      .getKeys()
      .where((key) =>
          key.startsWith(_prefixAchievementClaimed) &&
          _prefs.getBool(key) == true)
      .map((key) => key.substring(_prefixAchievementClaimed.length))
      .toSet();

  // Reset
  Future<void> resetAllProgress() async {
    try {
      final keys = _prefs
          .getKeys()
          .where((k) =>
              k.startsWith(_prefixBestScore) ||
              k.startsWith(_prefixStars) ||
              k.startsWith(_prefixCompleted) ||
              k == _keyHighestCompletedLevel)
          .toList();
      for (final k in keys) {
        await _prefs.remove(k);
      }
    } catch (error, stackTrace) {
      CrashReportingService.recordNonFatal(
        error,
        stackTrace,
        reason: 'Progress reset persistence failed',
      );
      rethrow;
    }
  }
}
