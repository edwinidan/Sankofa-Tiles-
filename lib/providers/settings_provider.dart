import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/storage_service.dart';
import '../core/utils/haptic_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError(
      'StorageService must be overridden in ProviderScope');
});

class SettingsState {
  final bool soundEnabled;
  final bool musicEnabled;
  final double musicVolume;
  final bool showTileNames;
  final HapticIntensity hapticIntensity;

  const SettingsState({
    required this.soundEnabled,
    required this.musicEnabled,
    required this.musicVolume,
    required this.showTileNames,
    required this.hapticIntensity,
  });

  SettingsState copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    double? musicVolume,
    bool? showTileNames,
    HapticIntensity? hapticIntensity,
  }) =>
      SettingsState(
        soundEnabled: soundEnabled ?? this.soundEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        musicVolume: musicVolume ?? this.musicVolume,
        showTileNames: showTileNames ?? this.showTileNames,
        hapticIntensity: hapticIntensity ?? this.hapticIntensity,
      );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final StorageService _storage;

  SettingsNotifier(this._storage)
      : super(SettingsState(
          soundEnabled: _storage.isSoundEnabled(),
          musicEnabled: _storage.isMusicEnabled(),
          musicVolume: _storage.getMusicVolume(),
          showTileNames: _storage.isShowTileNames(),
          hapticIntensity: _storage.getHapticIntensity(),
        ));

  Future<void> setSoundEnabled(bool val) async {
    await _storage.setSoundEnabled(val);
    state = state.copyWith(soundEnabled: val);
  }

  Future<void> setMusicEnabled(bool val) async {
    await _storage.setMusicEnabled(val);
    state = state.copyWith(musicEnabled: val);
  }

  Future<void> setMusicVolume(double val) async {
    final volume = val.clamp(0.0, 1.0);
    await _storage.setMusicVolume(volume);
    state = state.copyWith(musicVolume: volume);
  }

  Future<void> setShowTileNames(bool val) async {
    await _storage.setShowTileNames(val);
    state = state.copyWith(showTileNames: val);
  }

  Future<void> setHapticIntensity(HapticIntensity intensity) async {
    await _storage.setHapticIntensity(intensity);
    state = state.copyWith(hapticIntensity: intensity);
  }

  Future<void> resetProgress() async {
    await _storage.resetAllProgress();
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SettingsNotifier(storage);
});
