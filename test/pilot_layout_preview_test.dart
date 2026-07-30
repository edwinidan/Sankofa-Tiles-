import 'dart:io';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/core/constants/layout_data.dart';
import 'package:sankofa_tiles/core/constants/batch_b_layout_data.dart';
import 'package:sankofa_tiles/core/constants/chapter2_layout_data.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/levels_41_80_candidate_data.dart';
import 'package:sankofa_tiles/core/constants/levels_81_160_candidate_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/theme/sankofa_game_theme.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/audio_service.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/models/tile_model.dart';
import 'package:sankofa_tiles/providers/settings_provider.dart';
import 'package:sankofa_tiles/providers/game_provider.dart';
import 'package:sankofa_tiles/screens/game/widgets/board_widget.dart';
import 'package:sankofa_tiles/widgets/sankofa_background.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const audioGlobalChannel = MethodChannel('xyz.luan/audioplayers.global');
  const audioGlobalEvents =
      MethodChannel('xyz.luan/audioplayers.global/events');
  const audioPlayerChannel = MethodChannel('xyz.luan/audioplayers');

  setUp(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(audioGlobalChannel, (_) async => null);
    messenger.setMockMethodCallHandler(audioGlobalEvents, (_) async => null);
    messenger.setMockMethodCallHandler(audioPlayerChannel, (_) async => null);
  });

  final previews = <NamedLayout>[
    earlyOpenDiamond01Layout,
    earlyOpenDiamond02Layout,
    earlyShrine01Layout,
    earlyBridge01Layout,
    earlyLayeredDiamond01Layout,
  ];
  final sizes = <Size>[
    const Size(360, 640),
    const Size(390, 844),
    const Size(430, 932),
  ];

  for (final layout in previews) {
    for (final size in sizes) {
      testWidgets(
          'render ${layout.id} ${size.width.toInt()}x${size.height.toInt()}',
          (tester) async {
        await _render(
          tester,
          layout: layout,
          size: size,
          diagnostic: false,
        );
      });
    }

    testWidgets('render ${layout.id} diagnostic', (tester) async {
      await _render(
        tester,
        layout: layout,
        size: const Size(390, 844),
        diagnostic: true,
      );
    });
  }

  for (final candidate in kBatchBLayoutCandidates) {
    final layout = candidate.layout;
    for (final size in sizes) {
      testWidgets(
          'render Batch B ${layout.id} '
          '${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        await _render(
          tester,
          layout: layout,
          size: size,
          diagnostic: false,
          outputStem: 'batch-b/${layout.id}',
        );
      });
    }
    testWidgets('render Batch B ${layout.id} diagnostic', (tester) async {
      await _render(
        tester,
        layout: layout,
        size: const Size(390, 844),
        diagnostic: true,
        outputStem: 'batch-b/${layout.id}',
      );
    });
  }

  const portraitAnchorLevels = {6, 8, 13, 14, 16, 18, 20};
  for (final candidate in kBatchBLayoutCandidates.where(
    (candidate) => portraitAnchorLevels.contains(candidate.intendedLevel),
  )) {
    final layout = candidate.layout;
    for (final size in sizes) {
      testWidgets(
          'render portrait anchor ${layout.id} '
          '${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        await _render(
          tester,
          layout: layout,
          size: size,
          diagnostic: false,
          outputStem: 'batch-b-portrait-pass/${layout.id}',
        );
      });
    }
    testWidgets('render portrait anchor ${layout.id} diagnostic',
        (tester) async {
      await _render(
        tester,
        layout: layout,
        size: const Size(390, 844),
        diagnostic: true,
        outputStem: 'batch-b-portrait-pass/${layout.id}',
      );
    });
  }

  for (final candidate in kChapter2LayoutCandidates) {
    final layout = candidate.layout;
    for (final size in sizes) {
      testWidgets(
          'render Chapter 2 ${layout.id} '
          '${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        await _render(
          tester,
          layout: layout,
          size: size,
          diagnostic: false,
          outputStem: 'chapter-2-diversity-pass/${layout.id}',
        );
      });
    }
    testWidgets('render Chapter 2 ${layout.id} diagnostic', (tester) async {
      await _render(
        tester,
        layout: layout,
        size: const Size(390, 844),
        diagnostic: true,
        outputStem: 'chapter-2-diversity-pass/${layout.id}',
      );
    });
    testWidgets('render Chapter 2 ${layout.id} silhouette', (tester) async {
      await _render(
        tester,
        layout: layout,
        size: const Size(390, 844),
        diagnostic: false,
        silhouette: true,
        outputStem: 'chapter-2-diversity-pass/${layout.id}',
      );
    });
  }

  for (final candidate in kLevels41To80Candidates) {
    final layout = candidate.layout;
    for (final size in sizes) {
      testWidgets(
          'render Levels 41-80 ${layout.id} '
          '${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        await _render(
          tester,
          layout: layout,
          size: size,
          diagnostic: false,
          outputStem: 'levels-41-80-candidates/${layout.id}',
        );
      });
    }
    testWidgets('render Levels 41-80 ${layout.id} diagnostic', (tester) async {
      await _render(
        tester,
        layout: layout,
        size: const Size(390, 844),
        diagnostic: true,
        outputStem: 'levels-41-80-candidates/${layout.id}',
      );
    });
    testWidgets('render Levels 41-80 ${layout.id} silhouette', (tester) async {
      await _render(
        tester,
        layout: layout,
        size: const Size(390, 844),
        diagnostic: false,
        silhouette: true,
        outputStem: 'levels-41-80-candidates/${layout.id}',
      );
    });
  }

  for (final candidate in kLevels81To160LegacyCandidates) {
    final layout = candidate.layout;
    final state = _futureCandidateState(candidate);
    testWidgets('render Levels 81-160 ${layout.id} 390x844', (tester) async {
      await _render(
        tester,
        layout: layout,
        size: const Size(390, 844),
        diagnostic: false,
        suppliedState: state,
        outputStem: 'levels-81-160-candidates/${layout.id}',
      );
    });
    testWidgets('render Levels 81-160 ${layout.id} diagnostic', (tester) async {
      await _render(
        tester,
        layout: layout,
        size: const Size(390, 844),
        diagnostic: true,
        suppliedState: state,
        outputStem: 'levels-81-160-candidates/${layout.id}',
      );
    });
    testWidgets('render Levels 81-160 ${layout.id} silhouette', (tester) async {
      await _render(
        tester,
        layout: layout,
        size: const Size(390, 844),
        diagnostic: false,
        silhouette: true,
        outputStem: 'levels-81-160-candidates/${layout.id}',
      );
    });
    if (const {100, 120, 140, 160}.contains(candidate.level)) {
      for (final size in const [Size(360, 640), Size(430, 932)]) {
        testWidgets(
            'render finale ${layout.id} '
            '${size.width.toInt()}x${size.height.toInt()}', (tester) async {
          await _render(
            tester,
            layout: layout,
            size: size,
            diagnostic: false,
            suppliedState: state,
            outputStem: 'levels-81-160-candidates/${layout.id}',
          );
        });
      }
    }
  }

  const additionalVisualAnchorSizes = {
    81,
    100,
    110,
    120,
    121,
    135,
    140,
    141,
    145,
    155,
    160,
  };
  for (final candidate in kLevels81To160Candidates.where(
    (candidate) =>
        kLevels81To160VisualRedesignAnchors.contains(candidate.level),
  )) {
    final layout = candidate.layout;
    final state = _futureCandidateState(candidate);
    const directory = 'levels-81-160-visual-redesign-pass-1';
    testWidgets('render visual anchor ${layout.id} 390x844', (tester) async {
      await _render(
        tester,
        layout: layout,
        size: const Size(390, 844),
        diagnostic: false,
        suppliedState: state,
        outputStem: '$directory/${layout.id}',
      );
    });
    testWidgets('render visual anchor ${layout.id} diagnostic', (tester) async {
      await _render(
        tester,
        layout: layout,
        size: const Size(390, 844),
        diagnostic: true,
        suppliedState: state,
        outputStem: '$directory/${layout.id}',
      );
    });
    testWidgets('render visual anchor ${layout.id} silhouette', (tester) async {
      await _render(
        tester,
        layout: layout,
        size: const Size(390, 844),
        diagnostic: false,
        silhouette: true,
        outputStem: '$directory/${layout.id}',
      );
    });
    if (additionalVisualAnchorSizes.contains(candidate.level)) {
      for (final size in const [Size(360, 640), Size(430, 932)]) {
        testWidgets(
          'render visual anchor ${layout.id} '
          '${size.width.toInt()}x${size.height.toInt()}',
          (tester) async {
            await _render(
              tester,
              layout: layout,
              size: size,
              diagnostic: false,
              suppliedState: state,
              outputStem: '$directory/${layout.id}',
            );
          },
        );
      }
    }
  }

  const portraitPass2Levels = {7, 9, 10, 11, 12, 15, 17, 19, 20};
  for (final candidate in kBatchBLayoutCandidates.where(
    (candidate) => portraitPass2Levels.contains(candidate.intendedLevel),
  )) {
    final layout = candidate.layout;
    for (final size in sizes) {
      testWidgets(
          'render portrait pass 2 ${layout.id} '
          '${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        await _render(
          tester,
          layout: layout,
          size: size,
          diagnostic: false,
          outputStem: 'batch-b-portrait-pass-2/${layout.id}',
        );
      });
    }
    testWidgets('render portrait pass 2 ${layout.id} diagnostic',
        (tester) async {
      await _render(
        tester,
        layout: layout,
        size: const Size(390, 844),
        diagnostic: true,
        outputStem: 'batch-b-portrait-pass-2/${layout.id}',
      );
    });
  }

  for (var levelId = 1; levelId <= 20; levelId++) {
    testWidgets('render campaign level $levelId through startLevel',
        (tester) async {
      final level = getLevelById(levelId)!;
      final state = _startCampaignLevel(levelId);
      expect(state.status, GameStatus.playing);
      expect(state.tiles, hasLength(level.tileCount));
      expect(BoardSolver.isSolvable(state.tiles), isTrue);
      await _render(
        tester,
        layout: level.namedLayout,
        size: const Size(390, 844),
        diagnostic: false,
        suppliedState: state,
        outputStem: 'chapter-1-production/level_$levelId',
      );
    });
  }

  for (var levelId = 21; levelId <= 40; levelId++) {
    testWidgets('render Chapter 2 production level $levelId through startLevel',
        (tester) async {
      final level = getLevelById(levelId)!;
      final state = _startCampaignLevel(levelId);
      expect(state.status, GameStatus.playing);
      expect(state.tiles, hasLength(level.tileCount));
      expect(BoardSolver.isSolvable(state.tiles), isTrue);
      await _render(
        tester,
        layout: level.namedLayout,
        size: const Size(390, 844),
        diagnostic: false,
        suppliedState: state,
        outputStem: 'chapter-2-production/level_$levelId',
      );
    });
  }

  for (var levelId = 41; levelId <= 80; levelId++) {
    testWidgets(
        'render Chapters 3–4 production level $levelId through startLevel',
        (tester) async {
      final level = getLevelById(levelId)!;
      final state = _startCampaignLevel(levelId);
      expect(state.status, GameStatus.playing);
      expect(state.tiles, hasLength(level.tileCount));
      expect(BoardSolver.isSolvable(state.tiles), isTrue);
      await _render(
        tester,
        layout: level.namedLayout,
        size: const Size(390, 844),
        diagnostic: false,
        suppliedState: state,
        outputStem: 'levels-41-80-production/level_$levelId',
      );
    });
  }

  for (var levelId = 1; levelId <= 80; levelId++) {
    testWidgets('render frozen production silhouette level $levelId',
        (tester) async {
      final level = getLevelById(levelId)!;
      await _render(
        tester,
        layout: level.namedLayout,
        size: const Size(390, 844),
        diagnostic: false,
        silhouette: true,
        outputStem: 'levels-1-80-silhouettes/level_$levelId',
      );
    });
  }
}

Future<void> _render(
  WidgetTester tester, {
  required NamedLayout layout,
  required Size size,
  required bool diagnostic,
  bool silhouette = false,
  GameState? suppliedState,
  String? outputStem,
}) async {
  await tester.runAsync(_loadDiagnosticFont);
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  SharedPreferences.setMockInitialValues({'show_tile_names': false});
  final storage = StorageService();
  await storage.init();
  final container = ProviderContainer(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
    ],
  );
  addTearDown(container.dispose);
  final tiles = suppliedState?.tiles ??
      <TileModel>[
        for (var i = 0; i < layout.positions.length; i++)
          TileModel(
            uid: 'preview_$i',
            def: kAllTiles[(i ~/ 2) % kAllTiles.length],
            row: layout.positions[i].row,
            col: layout.positions[i].col,
            layer: layout.positions[i].layer,
          ),
      ];
  final boardState = suppliedState ??
      GameState(
        tiles: tiles,
        status: GameStatus.playing,
        difficulty: DifficultyMode.relaxed,
        score: 0,
        moves: 0,
        hintsUsed: 0,
        secondsElapsed: 0,
        levelId: 1,
      );

  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: boundaryKey,
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
                          ? CustomPaint(painter: _SilhouettePainter(layout))
                          : BoardWidget(
                              previewState: boardState,
                              animateEntrance: false,
                            ),
                    ),
                    if (diagnostic)
                      Positioned.fill(
                        left: 8,
                        right: 8,
                        top: 20,
                        bottom: 20,
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _DiagnosticPainter(layout, tiles),
                          ),
                        ),
                      ),
                    if (diagnostic)
                      Positioned(
                        left: 12,
                        right: 12,
                        top: 8,
                        child: _Legend(layout: layout, tiles: tiles),
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
  final imageContext = boundaryKey.currentContext!;
  await tester.runAsync(() async {
    await Future.wait(<Future<void>>[
      precacheImage(
        const AssetImage(SankofaGameTheme.gameBackgroundTexture),
        imageContext,
      ),
      for (final path in tiles
          .map((tile) => tile.def.assetPath)
          .whereType<String>()
          .toSet())
        precacheImage(AssetImage(path), imageContext),
    ]);
  });
  await tester.pump(const Duration(milliseconds: 600));

  final suffix = silhouette
      ? 'silhouette'
      : diagnostic
          ? 'diagnostic'
          : '${size.width.toInt()}x${size.height.toInt()}';
  final stem = outputStem ?? layout.id;
  final file = File('artifacts/layout-previews/${stem}_$suffix.png');
  await tester.runAsync(() async {
    final boundary = boundaryKey.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    if (silhouette) {
      final raw = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final pixels = raw!.buffer.asUint8List();
      var visiblePixels = 0;
      for (var index = 0; index < pixels.length; index += 4) {
        if (pixels[index] > 200 &&
            pixels[index + 1] > 120 &&
            pixels[index + 2] < 140) {
          visiblePixels++;
        }
      }
      expect(visiblePixels, greaterThan(1000),
          reason: '${layout.id} silhouette must not be blank');
    }
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
  });
  expect(file.lengthSync(), greaterThan(10000));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
}

class _SilhouettePainter extends CustomPainter {
  const _SilhouettePainter(this.layout);

  final NamedLayout layout;

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = BoardLayoutGeometry.fromPositions(layout.positions);
    final fit = geometry.fit(
      availableWidth: size.width,
      availableHeight: size.height,
    );
    final left = (size.width - fit.boardWidth) / 2;
    final top = (size.height - fit.boardHeight) / 2;
    final fill = Paint()..color = const Color(0xFFFFC44D);
    final outline = Paint()
      ..color = const Color(0xFF3A1607)
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
      final rounded = RRect.fromRectAndRadius(rect, const Radius.circular(4));
      canvas.drawRRect(rounded, fill);
      canvas.drawRRect(rounded, outline);
    }
  }

  @override
  bool shouldRepaint(covariant _SilhouettePainter oldDelegate) => false;
}

class _DiagnosticPainter extends CustomPainter {
  final NamedLayout layout;
  final List<TileModel> tiles;

  _DiagnosticPainter(this.layout, this.tiles);

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = BoardLayoutGeometry.fromPositions(layout.positions);
    final fit = geometry.fit(
      availableWidth: size.width,
      availableHeight: size.height,
    );
    final left = (size.width - fit.boardWidth) / 2;
    final top = (size.height - fit.boardHeight) / 2;
    final free =
        BoardSolver.getFreeTiles(tiles).map((tile) => tile.uid).toSet();
    final centrePaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.8)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      centrePaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centrePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(left, top, fit.boardWidth, fit.boardHeight),
      Paint()
        ..color = Colors.yellowAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    for (var i = 0; i < layout.positions.length; i++) {
      final position = layout.positions[i];
      final point = geometry.project(position, fit.tileWidth);
      final offset = Offset(
        left + point.x - geometry.minX * fit.tileWidth,
        top + point.y - geometry.minY * fit.tileWidth,
      );
      final odd = position.row.isOdd || position.col.isOdd;
      final text = TextPainter(
        text: TextSpan(
          text: '${position.row},${position.col}\nL${position.layer}',
          style: TextStyle(
            fontFamily: _diagnosticFontFamily,
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: free.contains(tiles[i].uid)
                ? Colors.lightGreenAccent
                : Colors.redAccent,
            backgroundColor: odd ? Colors.black87 : Colors.black54,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, offset + const Offset(3, 3));
    }
  }

  @override
  bool shouldRepaint(covariant _DiagnosticPainter oldDelegate) => false;
}

class _Legend extends StatelessWidget {
  final NamedLayout layout;
  final List<TileModel> tiles;

  const _Legend({required this.layout, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final free = BoardSolver.getFreeTiles(tiles).length;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.82),
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              layout.id,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: _diagnosticFontFamily,
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${layout.positions.length} tiles • ${layout.stats.layerCount} layers • $free free',
              style: const TextStyle(
                fontFamily: _diagnosticFontFamily,
                color: Colors.white,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 3),
            const Wrap(
              spacing: 10,
              runSpacing: 3,
              children: [
                _LegendKey(color: Colors.lightGreenAccent, label: 'free'),
                _LegendKey(color: Colors.redAccent, label: 'blocked'),
                _LegendKey(color: Colors.cyanAccent, label: 'centre'),
                _LegendKey(color: Colors.yellowAccent, label: 'bounds'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendKey extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendKey({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontFamily: _diagnosticFontFamily,
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      );
}

const _diagnosticFontFamily = 'LayoutDiagnosticSans';
bool _diagnosticFontLoaded = false;

Future<void> _loadDiagnosticFont() async {
  if (_diagnosticFontLoaded) return;
  for (final path in const [
    '/System/Library/Fonts/Supplemental/Arial.ttf',
    '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
  ]) {
    final file = File(path);
    if (!file.existsSync()) continue;
    final bytes = await file.readAsBytes();
    final loader = FontLoader(_diagnosticFontFamily)
      ..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes))));
    await loader.load();
    _diagnosticFontLoaded = true;
    return;
  }
}

GameState _startCampaignLevel(int levelId) {
  final players = List.generate(5, (_) => _SilentAudioPlayer());
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final player in players) {
    messenger.setMockMethodCallHandler(
      MethodChannel('xyz.luan/audioplayers/events/${player.playerId}'),
      (_) async => null,
    );
  }
  final audio = AudioService(
    sound: false,
    music: false,
    musicPlayer: players.first,
    sfxPlayers: players.skip(1).toList(),
  );
  final container = ProviderContainer(
    overrides: [audioServiceProvider.overrideWithValue(audio)],
  );
  container
      .read(gameProvider.notifier)
      .startLevel(levelId, DifficultyMode.relaxed);
  final state = container.read(gameProvider);
  container.dispose();
  return state;
}

GameState _futureCandidateState(FutureCampaignLayoutCandidate candidate) {
  final level = getLevelById(candidate.level)!;
  final definitions = <TileDefinition>[];
  final counts = level.symbolPlan
      .copyCountsForTileCount(candidate.layout.positions.length);
  for (var index = 0; index < counts.length; index++) {
    definitions.addAll(
      List.filled(counts[index], kAllTiles[index % kAllTiles.length]),
    );
  }
  return GameState(
    tiles: [
      for (var index = 0; index < candidate.layout.positions.length; index++)
        TileModel(
          uid: 'future_${candidate.level}_$index',
          def: definitions[index],
          row: candidate.layout.positions[index].row,
          col: candidate.layout.positions[index].col,
          layer: candidate.layout.positions[index].layer,
        ),
    ],
    status: GameStatus.playing,
    difficulty: DifficultyMode.relaxed,
    score: 0,
    moves: 0,
    hintsUsed: 0,
    secondsElapsed: 0,
    levelId: candidate.level,
  );
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
