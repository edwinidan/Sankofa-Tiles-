import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/level_data.dart';
import '../models/level_model.dart';
import 'settings_provider.dart';

final progressProvider = Provider<ProgressService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ProgressService(storage);
});

class ProgressService {
  final dynamic _storage;

  ProgressService(this._storage);

  bool isLevelUnlocked(int levelId) => _storage.isLevelUnlocked(levelId);

  LevelResult? getLevelResult(int levelId) {
    try {
      return _storage.getLevelResult(levelId);
    } on NoSuchMethodError {
      return null;
    }
  }

  int getStars(int levelId) {
    try {
      return _storage.getStars(levelId);
    } on NoSuchMethodError {
      return 0;
    }
  }

  bool isLevelCompleted(int levelId) {
    try {
      return _storage.isLevelCompleted(levelId);
    } on NoSuchMethodError {
      return false;
    }
  }

  int get highestCompletedLevel {
    final highest = _storage.getHighestCompletedLevel() as int;
    return highest.clamp(0, kLevels.length);
  }

  int? get nextUnfinishedLevelId {
    if (kLevels.isEmpty || highestCompletedLevel >= kLevels.length) return null;
    return kLevels[highestCompletedLevel].id;
  }

  bool get hasCompletedAllLevels =>
      kLevels.isNotEmpty && highestCompletedLevel >= kLevels.length;

  int get totalStars =>
      kLevels.fold(0, (sum, level) => sum + getStars(level.id));

  List<bool> get unlockedLevels =>
      kLevels.map((l) => isLevelUnlocked(l.id)).toList();

  Future<void> saveLevelResult(int levelId, int score, int stars) =>
      _storage.saveLevelResult(levelId, score, stars);
}

// Helper: compute star count from score and thresholds
int computeStars(int score, List<int> thresholds) {
  if (score >= thresholds[2]) return 3;
  if (score >= thresholds[1]) return 2;
  if (score >= thresholds[0]) return 1;
  return 0;
}
