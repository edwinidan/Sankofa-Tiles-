import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/utils/audio_service.dart';

class FakeAudioPlayer extends AudioPlayer {
  final List<String> calls = [];

  @override
  Future<void> play(
    Source source, {
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {
    calls.add('play');
  }

  @override
  Future<void> pause() async {
    calls.add('pause');
  }

  @override
  Future<void> resume() async {
    calls.add('resume');
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
  }

  @override
  Future<void> setReleaseMode(ReleaseMode releaseMode) async {
    calls.add('setReleaseMode');
  }

  @override
  Future<void> setVolume(double volume) async {
    calls.add('setVolume');
  }

  @override
  Future<void> setAudioContext(AudioContext context) async {
    calls.add('setAudioContext');
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const audioGlobalChannel = MethodChannel('xyz.luan/audioplayers.global');
  const audioPlayerChannel = MethodChannel('xyz.luan/audioplayers');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioGlobalChannel, (_) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioPlayerChannel, (_) async => null);
  });

  test('AudioService pauses on app background and resumes on foreground', () async {
    final fakeMusicPlayer = FakeAudioPlayer();
    final service = AudioService(
      sound: true,
      music: true,
      musicPlayer: fakeMusicPlayer,
      sfxPlayers: List.generate(4, (_) => FakeAudioPlayer()),
    );
    addTearDown(service.dispose);

    // Request start background music
    await service.startBackgroundMusic();
    expect(fakeMusicPlayer.calls.contains('play'), isTrue);
    fakeMusicPlayer.calls.clear();

    // Simulate putting app in background (paused)
    TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await Future.delayed(Duration.zero);

    // Verify it called pause
    expect(fakeMusicPlayer.calls.contains('pause'), isTrue);
    fakeMusicPlayer.calls.clear();

    // Simulate resuming app (resumed)
    TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await Future.delayed(Duration.zero);

    // Verify it called resume
    expect(fakeMusicPlayer.calls.contains('resume'), isTrue);
  });
}
