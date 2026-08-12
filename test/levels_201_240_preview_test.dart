import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/levels_201_240_candidate_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/theme/sankofa_game_theme.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/models/tile_model.dart';
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

  for (final candidate in kLevels201To240Candidates) {
    testWidgets('render level ${candidate.level} candidate previews',
        (tester) async {
      await _render(tester, candidate, const Size(390, 844));
      await _render(tester, candidate, const Size(390, 844), diagnostic: true);
      await _render(tester, candidate, const Size(390, 844), silhouette: true);
      if (kLevels201To240WideOrBorderline.contains(candidate.level)) {
        await _render(tester, candidate, const Size(360, 640));
        await _render(tester, candidate, const Size(430, 932));
      }
    });
  }

  for (final candidate in kLevels201To240LegacyCandidates) {
    testWidgets('render level ${candidate.level} legacy silhouette',
        (tester) async {
      await _render(
        tester,
        candidate,
        const Size(390, 844),
        silhouette: true,
        outputStem: 'legacy-level-${candidate.level}',
      );
    });
  }

  testWidgets('render level 240 pre-final-refinement comparison',
      (tester) async {
    await _render(
      tester,
      kLevel240PreFinalRefinementCandidate,
      const Size(390, 844),
      outputStem: 'level-240-before-final-refinement',
    );
    await _render(
      tester,
      kLevel240PreFinalRefinementCandidate,
      const Size(390, 844),
      silhouette: true,
      outputStem: 'level-240-before-final-refinement',
    );
  });

  for (var levelId = 181; levelId <= 200; levelId++) {
    testWidgets('render production comparison level $levelId', (tester) async {
      final level = getLevelById(levelId)!;
      final snapshot = ExpansionLayoutCandidate(
        level: levelId,
        layout: level.namedLayout,
        family: 'Production comparison',
        silhouetteClass: 'Production',
        proposedName: level.name,
        features: const ['production', 'comparison'],
        symbolPlan: level.symbolPlan,
        difficultyCategory: level.difficultyCategory,
        isBreather: false,
      );
      await _render(
        tester,
        snapshot,
        const Size(390, 844),
        silhouette: true,
        outputStem: 'production-level-$levelId',
      );
      if (levelId == 200) {
        await _render(
          tester,
          snapshot,
          const Size(390, 844),
          outputStem: 'production-level-$levelId',
        );
      }
    });
  }
}

Future<void> _render(
  WidgetTester tester,
  ExpansionLayoutCandidate candidate,
  Size size, {
  bool diagnostic = false,
  bool silhouette = false,
  String? outputStem,
}) async {
  await tester.binding.setSurfaceSize(size);
  SharedPreferences.setMockInitialValues({'show_tile_names': false});
  final storage = StorageService();
  await storage.init();
  final container = ProviderContainer(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
  );
  final positions = candidate.layout.positions;
  final tiles = <TileModel>[
    for (var index = 0; index < positions.length; index++)
      TileModel(
        uid: 'candidate_${candidate.level}_$index',
        def: kAllTiles[(index ~/ 2) % kAllTiles.length],
        row: positions[index].row,
        col: positions[index].col,
        layer: positions[index].layer,
      ),
  ];
  final state = GameState(
    tiles: tiles,
    status: GameStatus.playing,
    difficulty: DifficultyMode.relaxed,
    score: 0,
    moves: 0,
    hintsUsed: 0,
    secondsElapsed: 0,
    levelId: candidate.level,
  );
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
                              painter: _SilhouettePainter(candidate),
                            )
                          : BoardWidget(
                              previewState: state,
                              animateEntrance: false,
                            ),
                    ),
                    if (diagnostic)
                      Positioned(
                        left: 10,
                        right: 10,
                        top: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .78),
                            border: Border.all(color: const Color(0xFFFFC44D)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              'L${candidate.level} · ${candidate.proposedName}\n'
                              '${candidate.family} · ${candidate.silhouetteClass} · '
                              '${candidate.layout.stats.tileCount} tiles · '
                              '${candidate.layout.stats.layerCount} layers',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                height: 1.15,
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
      for (final path in tiles
          .map((tile) => tile.def.assetPath)
          .whereType<String>()
          .toSet())
        precacheImage(AssetImage(path), context),
    ]);
  });
  await tester.pump(const Duration(milliseconds: 450));

  final suffix = silhouette
      ? 'silhouette'
      : diagnostic
          ? 'diagnostic'
          : '${size.width.toInt()}x${size.height.toInt()}';
  final file = File(
    'artifacts/layout-previews/levels-201-240-candidates/'
    '${outputStem ?? candidate.layout.id}_$suffix.png',
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
  container.dispose();
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 100));
}

class _SilhouettePainter extends CustomPainter {
  const _SilhouettePainter(this.candidate);

  final ExpansionLayoutCandidate candidate;

  @override
  void paint(Canvas canvas, Size size) {
    final layout = candidate.layout;
    final geometry = BoardLayoutGeometry.fromPositions(layout.positions);
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
    for (final position in layout.positions) {
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
  bool shouldRepaint(covariant _SilhouettePainter oldDelegate) => false;
}
