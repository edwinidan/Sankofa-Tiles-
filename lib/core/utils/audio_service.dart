import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  // Only the music player is long-lived. SFX players are spawned per-call
  // so their native prepare/reset cycle never touches the music player's
  // audio focus.
  final AudioPlayer _musicPlayer = AudioPlayer();
  late AudioContext _sfxContext;

  bool _soundEnabled = true;
  bool _musicEnabled = true;

  Future<void> init({bool sound = true, bool music = true}) async {
    _soundEnabled = sound;
    _musicEnabled = music;

    // Music player holds audio focus so it keeps playing continuously.
    final musicContext = AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
        options: const {AVAudioSessionOptions.mixWithOthers},
      ),
    );

    // SFX context: no audio focus — overlays music without interrupting it.
    _sfxContext = AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
        options: const {AVAudioSessionOptions.mixWithOthers},
      ),
    );

    await _musicPlayer.setAudioContext(musicContext);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void setSoundEnabled(bool val) => _soundEnabled = val;
  void setMusicEnabled(bool val) {
    _musicEnabled = val;
    if (!val) _musicPlayer.stop();
  }

  Future<void> _playSfx(String fileName) async {
    if (!_soundEnabled) return;
    try {
      final player = AudioPlayer();
      await player.setAudioContext(_sfxContext);
      await player.play(AssetSource('audio/$fileName'));
      // Auto-dispose once the sound finishes — no lingering players.
      player.onPlayerComplete.listen((_) => player.dispose());
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
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource('audio/background_music.mp3'));
    } catch (e) {
      debugPrint('[AudioService] Missing background music ($e)');
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  void dispose() {
    _musicPlayer.dispose();
  }
}
