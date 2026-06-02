import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioContext _sfxAudioContext = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none,
    ),
    // `ambient` mixes with other apps on iOS. The audioplayers API asserts if
    // mixWithOthers is explicitly provided for ambient because it is implicit.
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.ambient,
    ),
  );

  static final AudioContext _musicAudioContext = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.ambient,
    ),
  );

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _soundEnabled;
  bool _musicEnabled;
  double _musicVolume;
  bool _backgroundMusicRequested = false;

  AudioService({
    bool sound = true,
    bool music = true,
    double musicVolume = 0.7,
  })  : _soundEnabled = sound,
        _musicEnabled = music,
        _musicVolume = musicVolume.clamp(0.0, 1.0);

  void setSoundEnabled(bool val) => _soundEnabled = val;

  void setMusicEnabled(bool val) {
    _musicEnabled = val;
    if (val && _backgroundMusicRequested) {
      unawaited(startBackgroundMusic());
    } else if (!val) {
      unawaited(_stopMusicPlayback(clearRequest: false));
    }
  }

  void setMusicVolume(double val) {
    _musicVolume = val.clamp(0.0, 1.0);
    unawaited(_applyMusicVolume());
  }

  Future<void> _playSfx(String fileName) async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.play(
        AssetSource('audio/$fileName'),
        ctx: _sfxAudioContext,
      );
    } catch (e) {
      debugPrint('[AudioService] $fileName: $e');
    }
  }

  Future<void> playTileTap() => _playSfx('tile_tap.mp3');
  Future<void> playMatch() => _playSfx('match.mp3');
  Future<void> playNoMatch() => _playSfx('no_match.mp3');
  Future<void> playWin() => _playSfx('win.mp3');
  Future<void> playLose() => _playSfx('lose.mp3');
  Future<void> playHint() => _playSfx('tile_tap.mp3');
  Future<void> playShuffle() => _playSfx('tile_tap.mp3');

  Future<void> startBackgroundMusic() async {
    _backgroundMusicRequested = true;
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(
        AssetSource('audio/background_music.mp3'),
        volume: _musicVolume,
        ctx: _musicAudioContext,
      );
    } catch (e) {
      debugPrint('[AudioService] Music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _stopMusicPlayback(clearRequest: true);
  }

  Future<void> _stopMusicPlayback({required bool clearRequest}) async {
    if (clearRequest) {
      _backgroundMusicRequested = false;
    }
    try {
      await _musicPlayer.stop();
    } catch (e) {
      debugPrint('[AudioService] Stop music: $e');
    }
  }

  Future<void> _applyMusicVolume() async {
    try {
      await _musicPlayer.setVolume(_musicVolume);
    } catch (e) {
      debugPrint('[AudioService] Music volume: $e');
    }
  }

  void dispose() {
    unawaited(
      _sfxPlayer.dispose().catchError(
            (Object e) => debugPrint('[AudioService] Dispose SFX: $e'),
          ),
    );
    unawaited(
      _musicPlayer.dispose().catchError(
            (Object e) => debugPrint('[AudioService] Dispose music: $e'),
          ),
    );
  }
}
