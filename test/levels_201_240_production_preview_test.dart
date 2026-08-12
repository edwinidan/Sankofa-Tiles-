import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/theme/sankofa_game_theme.dart';
import 'package:sankofa_tiles/core/utils/audio_service.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/providers/game_provider.dart';
import 'package:sankofa_tiles/providers/settings_provider.dart';
import 'package:sankofa_tiles/screens/game/widgets/board_widget.dart';
import 'package:sankofa_tiles/widgets/sankofa_background.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channels = [
    MethodChannel('xyz.luan/audioplayers.global'),
    MethodChannel('xyz.luan/audioplayers.global/events'),
    MethodChannel('xyz.luan/audioplayers'),
  ];
  setUp(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final channel in channels) {
      messenger.setMockMethodCallHandler(channel, (_) async => null);
    }
  });

  for (var levelId = 200; levelId <= 240; levelId++) {
    testWidgets('render production Level $levelId through GameNotifier',
        (tester) async {
      SharedPreferences.setMockInitialValues({'show_tile_names': false});
      final storage = StorageService();
      await storage.init();
      final players = List.generate(5, (_) => _SilentAudioPlayer());
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      for (final player in players) {
        messenger.setMockMethodCallHandler(
          MethodChannel('xyz.luan/audioplayers/events/${player.playerId}'),
          (_) async => null,
        );
      }
      final container = ProviderContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(
            AudioService(
              sound: false,
              music: false,
              musicPlayer: players.first,
              sfxPlayers: players.skip(1).toList(),
            ),
          ),
          storageServiceProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(gameProvider.notifier)
          .startLevel(levelId, DifficultyMode.relaxed);
      final state = container.read(gameProvider);
      expect(state.status, GameStatus.playing);
      expect(state.tiles, hasLength(getLevelById(levelId)!.tileCount));
      expect(BoardSolver.isSolvable(state.tiles), isTrue);

      await _render(tester, container, state);
      await _render(tester, container, state, silhouette: true);
      if (levelId == 240) {
        await _render(tester, container, state, boundaryEvidence: true);
      }
    });
  }
}

class _SilentAudioPlayer extends AudioPlayer {
  @override
  Future<void> play(
    Source source, {
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

Future<void> _render(
  WidgetTester tester,
  ProviderContainer container,
  GameState state, {
  bool silhouette = false,
  bool boundaryEvidence = false,
}) async {
  const size = Size(390, 844);
  await tester.binding.setSurfaceSize(size);
  final level = getLevelById(state.levelId)!;
  final key = GlobalKey();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: key,
          child: SizedBox.fromSize(
            size: size,
            child: SankofaBackground(
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned.fill(
                      left: 8,
                      right: 8,
                      top: 20,
                      bottom: 20,
                      child: silhouette
                          ? CustomPaint(
                              painter: _ProductionSilhouettePainter(level),
                            )
                          : BoardWidget(
                              previewState: state,
                              animateEntrance: false,
                            ),
                    ),
                    if (boundaryEvidence)
                      Positioned(
                        left: 12,
                        right: 12,
                        top: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .82),
                            border: Border.all(
                              color: SankofaGameTheme.antiqueGold,
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'LEVEL 240 · CURRENT IMPLEMENTED BOUNDARY\n'
                              '240 PLAYABLE · 400 PLANNED · LEVEL 241 UNAVAILABLE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  final context = key.currentContext!;
  await tester.runAsync(() async {
    await Future.wait([
      precacheImage(
        const AssetImage(SankofaGameTheme.gameBackgroundTexture),
        context,
      ),
      for (final path in state.tiles
          .map((tile) => tile.def.assetPath)
          .whereType<String>()
          .toSet())
        precacheImage(AssetImage(path), context),
    ]);
  });
  await tester.pump(const Duration(milliseconds: 450));

  final suffix = boundaryEvidence
      ? 'current-boundary'
      : silhouette
          ? 'silhouette'
          : '390x844';
  final file = File(
    'artifacts/layout-previews/levels-201-240-production/'
    'level-${state.levelId}_$suffix.png',
  );
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final rendered = await boundary.toImage(pixelRatio: 1);
    final bytes = await rendered.toByteData(format: ui.ImageByteFormat.png);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
  });
  expect(file.lengthSync(), greaterThan(10000));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 100));
}

class _ProductionSilhouettePainter extends CustomPainter {
  const _ProductionSilhouettePainter(this.level);

  final LevelDefinition level;

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = BoardLayoutGeometry.fromPositions(level.layout);
    final fit = geometry.fit(
      availableWidth: size.width,
      availableHeight: size.height,
    );
    final left = (size.width - fit.boardWidth) / 2;
    final top = (size.height - fit.boardHeight) / 2;
    final fill = Paint()..color = const Color(0xFFFFC44D);
    final outline = Paint()
      ..color = const Color(0xFF351807)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final position in level.layout) {
      final point = geometry.project(position, fit.tileWidth);
      final rect = Rect.fromLTWH(
        left + point.x - geometry.minX * fit.tileWidth,
        top + point.y - geometry.minY * fit.tileWidth,
        fit.tileWidth,
        fit.tileHeight,
      );
      final rounded = RRect.fromRectAndRadius(rect, const Radius.circular(5));
      canvas.drawRRect(rounded, fill);
      canvas.drawRRect(rounded, outline);
    }
  }

  @override
  bool shouldRepaint(covariant _ProductionSilhouettePainter oldDelegate) =>
      false;
}
