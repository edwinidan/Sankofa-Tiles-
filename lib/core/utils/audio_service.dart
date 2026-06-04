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

  final List<AudioPlayer> _sfxPlayers = List.generate(4, (_) => AudioPlayer());
  final AudioPlayer _musicPlayer = AudioPlayer();
  final Map<String, DateTime> _lastSfxPlayedAt = {};

  bool _soundEnabled;
  bool _musicEnabled;
  double _musicVolume;
  bool _backgroundMusicRequested = false;
  bool _backgroundMusicPlaying = false;
  int _nextSfxPlayer = 0;

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

  Future<void> _playSfx(
    String fileName, {
    Duration minInterval = const Duration(milliseconds: 45),
    double volume = 1.0,
  }) async {
    if (!_soundEnabled) return;

    final now = DateTime.now();
    final lastPlayedAt = _lastSfxPlayedAt[fileName];
    if (lastPlayedAt != null && now.difference(lastPlayedAt) < minInterval) {
      return;
    }
    _lastSfxPlayedAt[fileName] = now;

    final player = _sfxPlayers[_nextSfxPlayer];
    _nextSfxPlayer = (_nextSfxPlayer + 1) % _sfxPlayers.length;

    try {
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.play(
        AssetSource('audio/$fileName'),
        volume: volume.clamp(0.0, 1.0),
        ctx: _sfxAudioContext,
      );
    } catch (e) {
      debugPrint('[AudioService] $fileName: $e');
    }
  }

  Future<void> playTileTap() => _playSfx(
        'tile_tap.ogg',
        minInterval: const Duration(milliseconds: 70),
        volume: 0.75,
      );
  Future<void> playMatch() => _playSfx('match.ogg', volume: 0.9);
  Future<void> playNoMatch() => _playSfx('no_match.ogg', volume: 0.8);
  Future<void> playWin() => _playSfx('win.ogg', volume: 0.9);
  Future<void> playLose() => _playSfx('lose.ogg', volume: 0.85);
  Future<void> playHint() => _playSfx(
        'hint.ogg',
        minInterval: const Duration(milliseconds: 120),
        volume: 0.7,
      );
  Future<void> playShuffle() => _playSfx(
        'shuffle.ogg',
        minInterval: const Duration(milliseconds: 160),
        volume: 0.7,
      );

  Future<void> startBackgroundMusic() async {
    _backgroundMusicRequested = true;
    if (!_musicEnabled) return;
    if (_backgroundMusicPlaying) return;
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(
        AssetSource('audio/background_music.mp3'),
        volume: _musicVolume,
        ctx: _musicAudioContext,
      );
      _backgroundMusicPlaying = true;
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
      _backgroundMusicPlaying = false;
    } catch (e) {
      debugPrint('[AudioService] Stop music: $e');
    }
  }

  Future<void> stopSfx() async {
    try {
      await Future.wait(_sfxPlayers.map((player) => player.stop()));
    } catch (e) {
      debugPrint('[AudioService] Stop SFX: $e');
    }
  }

  Future<void> stopGameAudio() async {
    await Future.wait([
      stopBackgroundMusic(),
      stopSfx(),
    ]);
  }

  Future<void> _applyMusicVolume() async {
    try {
      await _musicPlayer.setVolume(_musicVolume);
    } catch (e) {
      debugPrint('[AudioService] Music volume: $e');
    }
  }

  void dispose() {
    for (final player in _sfxPlayers) {
      unawaited(
        player.dispose().catchError(
              (Object e) => debugPrint('[AudioService] Dispose SFX: $e'),
            ),
      );
    }
    unawaited(
      _musicPlayer.dispose().catchError(
            (Object e) => debugPrint('[AudioService] Dispose music: $e'),
          ),
    );
  }
}
