import 'package:shared_preferences/shared_preferences.dart';
import '../../models/game_state.dart';
import '../../models/level_model.dart';
import 'haptic_service.dart';

class StorageService {
  static const _prefixBestScore = 'best_score_';
  static const _prefixStars = 'stars_';
  static const _keyDefaultDifficulty = 'default_difficulty';
  static const _keySoundEnabled = 'sound_enabled';
  static const _keyMusicEnabled = 'music_enabled';
  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyShowTileNames = 'show_tile_names';
  static const _keyHapticIntensity = 'haptic_intensity';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Level results
  Future<void> saveLevelResult(int levelId, int score, int stars) async {
    final currentBest = getBestScore(levelId);
    if (score > currentBest) {
      await _prefs.setInt('$_prefixBestScore$levelId', score);
    }
    final currentStars = getStars(levelId);
    if (stars > currentStars) {
      await _prefs.setInt('$_prefixStars$levelId', stars);
    }
  }

  int getBestScore(int levelId) =>
      _prefs.getInt('$_prefixBestScore$levelId') ?? 0;

  int getStars(int levelId) =>
      _prefs.getInt('$_prefixStars$levelId') ?? 0;

  LevelResult? getLevelResult(int levelId) {
    final score = getBestScore(levelId);
    final stars = getStars(levelId);
    if (score == 0 && stars == 0) return null;
    return LevelResult(levelId: levelId, bestScore: score, stars: stars);
  }

  bool isLevelUnlocked(int levelId) {
    if (levelId == 1) return true;
    // Unlocked if previous level has been completed (has stars)
    return getStars(levelId - 1) > 0;
  }

  // Difficulty
  DifficultyMode getDefaultDifficulty() {
    final val = _prefs.getString(_keyDefaultDifficulty);
    return DifficultyMode.values.firstWhere(
      (d) => d.name == val,
      orElse: () => DifficultyMode.normal,
    );
  }

  Future<void> setDefaultDifficulty(DifficultyMode mode) async {
    await _prefs.setString(_keyDefaultDifficulty, mode.name);
  }

  // Sound
  bool isSoundEnabled() => _prefs.getBool(_keySoundEnabled) ?? true;
  Future<void> setSoundEnabled(bool val) async =>
      _prefs.setBool(_keySoundEnabled, val);

  // Music
  bool isMusicEnabled() => _prefs.getBool(_keyMusicEnabled) ?? true;
  Future<void> setMusicEnabled(bool val) async =>
      _prefs.setBool(_keyMusicEnabled, val);

  // Onboarding
  bool isOnboardingComplete() =>
      _prefs.getBool(_keyOnboardingComplete) ?? false;
  Future<void> setOnboardingComplete() async =>
      _prefs.setBool(_keyOnboardingComplete, true);

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

  // Reset
  Future<void> resetAllProgress() async {
    final keys = _prefs.getKeys()
        .where((k) => k.startsWith(_prefixBestScore) || k.startsWith(_prefixStars))
        .toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }
}
