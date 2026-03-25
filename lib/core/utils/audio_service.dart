import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;

  Future<void> init({bool sound = true, bool music = true}) async {
    _soundEnabled = sound;
    _musicEnabled = music;
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void setSoundEnabled(bool val) => _soundEnabled = val;
  void setMusicEnabled(bool val) {
    _musicEnabled = val;
    if (!val) _musicPlayer.stop();
  }

  Future<void> _playSfx(String fileName) async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/$fileName'));
    } catch (e) {
      debugPrint('[AudioService] Missing sound: $fileName ($e)');
    }
  }

  Future<void> playTileTap() => _playSfx('tile_tap.mp3');
  Future<void> playMatch() => _playSfx('match.mp3');
  Future<void> playNoMatch() => _playSfx('no_match.mp3');
  Future<void> playWin() => _playSfx('win.mp3');
  Future<void> playLose() => _playSfx('lose.mp3');

  Future<void> startBackgroundMusic() async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.play(AssetSource('audio/background_music.mp3'));
    } catch (e) {
      debugPrint('[AudioService] Missing background music ($e)');
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}
