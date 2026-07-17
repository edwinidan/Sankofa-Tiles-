import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/core/utils/audio_service.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/providers/game_provider.dart';
import 'package:sankofa_tiles/providers/settings_provider.dart';
import 'package:sankofa_tiles/screens/game/widgets/tile_widget.dart';
import 'package:sankofa_tiles/screens/tutorial/tutorial_controller.dart';
import 'package:sankofa_tiles/screens/tutorial/tutorial_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  kRunningTests = true;

  test('free-side lesson blocks centre tiles until edges are removed', () {
    final controller = TutorialController();
    _completeCurrentLesson(controller);
    controller.advanceLesson();

    expect(controller.lesson, TutorialLesson.freeSides);
    expect(controller.tap('centre-a'), TutorialTapResult.blocked);
    expect(controller.selectedUid, isNull);
    expect(controller.tap('edge-a'), TutorialTapResult.selected);
    expect(controller.tap('edge-b'), TutorialTapResult.matched);
    expect(controller.isFree(_tile(controller, 'centre-a')), isTrue);
    expect(controller.isFree(_tile(controller, 'centre-b')), isTrue);
  });

  test('covered lesson unlocks lower pair after top pair is removed', () {
    final controller = TutorialController();
    _completeCurrentLesson(controller);
    controller.advanceLesson();
    _completeCurrentLesson(controller);
    controller.advanceLesson();

    expect(controller.tap('lower-a'), TutorialTapResult.covered);
    expect(controller.tap('top-a'), TutorialTapResult.selected);
    expect(controller.tap('top-b'), TutorialTapResult.matched);
    expect(controller.isFree(_tile(controller, 'lower-a')), isTrue);
    expect(controller.isFree(_tile(controller, 'lower-b')), isTrue);
  });

  testWidgets('covered lesson visually stacks top tiles over lower tiles',
      (tester) async {
    final controller = TutorialController();
    _completeCurrentLesson(controller);
    controller.advanceLesson();
    _completeCurrentLesson(controller);
    controller.advanceLesson();
    final storage = await _storage();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
        audioServiceProvider.overrideWithValue(
          AudioService(sound: false, music: false),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            height: 520,
            child: TutorialBoard(
              controller: controller,
              reducedMotion: true,
              onTapTile: controller.tap,
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    final lowerA = tester.getRect(find.byKey(const ValueKey('lower-a')));
    final topA = tester.getRect(find.byKey(const ValueKey('top-a')));
    final lowerB = tester.getRect(find.byKey(const ValueKey('lower-b')));
    final topB = tester.getRect(find.byKey(const ValueKey('top-b')));
    expect(topA.overlaps(lowerA), isTrue);
    expect(topB.overlaps(lowerB), isTrue);
  });

  testWidgets('selected tutorial tile is raised above the hinted match',
      (tester) async {
    final controller = TutorialController();
    _completeCurrentLesson(controller);
    controller.advanceLesson();
    expect(controller.tap('edge-a'), TutorialTapResult.selected);
    final storage = await _storage();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
        audioServiceProvider.overrideWithValue(
          AudioService(sound: false, music: false),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            height: 520,
            child: TutorialBoard(
              controller: controller,
              reducedMotion: true,
              onTapTile: controller.tap,
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    final renderedTiles =
        tester.widgetList<TileWidget>(find.byType(TileWidget));
    final selectedIndex = renderedTiles
        .toList()
        .indexWhere((widget) => widget.tile.uid == 'edge-a');
    final targetIndex = renderedTiles
        .toList()
        .indexWhere((widget) => widget.tile.uid == 'edge-b');
    final target = renderedTiles.firstWhere(
      (widget) => widget.tile.uid == 'edge-b',
    );

    expect(selectedIndex, greaterThan(targetIndex),
        reason: 'The selected tile must paint above its suggested match.');
    expect(target.isHinted, isFalse,
        reason: 'The pointer target should glow without physically lifting.');
    expect(find.byKey(const ValueKey('tutorial-target-glow-edge-b')),
        findsOneWidget);
  });

  test('practice layout is solvable with the production board solver', () {
    final controller = TutorialController();
    _completeCurrentLesson(controller);
    controller.advanceLesson();
    _completeCurrentLesson(controller);
    controller.advanceLesson();
    _completeCurrentLesson(controller);
    controller.advanceLesson();
    _completeCurrentLesson(controller);
    controller.advanceLesson();

    expect(controller.lesson, TutorialLesson.practice);
    expect(controller.tiles, hasLength(12));
    expect(controller.lessonPairTarget, 6);
    final backTiles = controller.tiles.where((tile) => tile.isCovered).toList();
    expect(backTiles, hasLength(4));
    expect(backTiles.any((tile) => tile.row == 0), isTrue);
    expect(backTiles.any((tile) => tile.row == 5), isTrue);
    expect(BoardSolver.isSolvable(controller.tiles), isTrue);
  });

  test('back-tile lesson peeks, hides, and matches face-down tiles', () {
    final controller = TutorialController();
    _advanceTo(controller, TutorialLesson.backTiles);

    expect(controller.tiles.where((tile) => tile.isCovered), hasLength(3));
    expect(controller.tiles.where((tile) => tile.isRevealed), hasLength(3));
    expect(
      controller.tiles.where((tile) => tile.isCovered).map((tile) => tile.row),
      containsAll(<int>[0, 2]),
    );
    expect(_tile(controller, 'back-a1').isCovered, isTrue);
    expect(_tile(controller, 'back-a2').isRevealed, isTrue);
    expect(controller.tap('back-a1'), TutorialTapResult.selected);
    expect(_tile(controller, 'back-a1').isRevealed, isTrue);
    expect(_tile(controller, 'back-a1').isPeeked, isTrue);

    expect(controller.tap('back-c1'), TutorialTapResult.mismatch);
    controller.clearFeedback();
    expect(_tile(controller, 'back-a1').isCovered, isTrue);
    expect(_tile(controller, 'back-c1').isCovered, isTrue);

    expect(controller.tap('back-a1'), TutorialTapResult.selected);
    expect(controller.tap('back-a2'), TutorialTapResult.matched);
    expect(_tile(controller, 'back-a1').isMatched, isTrue);
    expect(_tile(controller, 'back-a2').isMatched, isTrue);
  });

  test('invalid taps do not corrupt selection or pair progress', () {
    final controller = TutorialController();
    _completeCurrentLesson(controller);
    controller.advanceLesson();
    final before = controller.pairsMatched;

    expect(controller.tap('centre-a'), TutorialTapResult.blocked);
    expect(controller.selectedUid, isNull);
    expect(controller.pairsMatched, before);
  });

  testWidgets('tutorial is full screen with focused instruction and pointer',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();
    await tester.pumpWidget(ProviderScope(overrides: [
      storageServiceProvider.overrideWithValue(storage),
      audioServiceProvider.overrideWithValue(
        AudioService(sound: false, music: false),
      ),
    ], child: const MaterialApp(home: TutorialScreen())));
    await tester.pump();

    expect(find.text('Match two identical free tiles.'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.byType(TutorialBoard), findsOneWidget);
    expect(find.byType(TutorialPointer), findsOneWidget);
    expect(find.text('Interactive Tutorial'), findsNothing);
    expect(find.text('Level 0.5'), findsNothing);
    expect(find.text('Free tile'), findsNothing);
  });

  testWidgets('reduced motion keeps the tutorial and target usable',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();
    await tester.pumpWidget(ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
          audioServiceProvider.overrideWithValue(
            AudioService(sound: false, music: false),
          ),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: TutorialScreen(),
          ),
        )));
    await tester.pump();

    expect(find.byType(TutorialPointer), findsOneWidget);
    await tester.tap(
      find.bySemanticsLabel(RegExp(r'Free\. Tap to select\.')).first,
    );
    await tester.pump();
    expect(find.text('Now tap its matching symbol.'), findsOneWidget);
  });

  for (final viewport in const <({String name, Size size})>[
    (name: 'small phone', size: Size(320, 568)),
    (name: 'standard phone', size: Size(390, 844)),
    (name: 'tall phone', size: Size(430, 932)),
    (name: 'tablet', size: Size(768, 1024)),
  ]) {
    testWidgets('tutorial has no overflow on ${viewport.name}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = viewport.size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final storage = await _storage();

      await tester.pumpWidget(_tutorialApp(storage));
      await tester.pump();

      expect(find.byType(TutorialBoard), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tutorial supports increased text scale on a small phone',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final storage = await _storage();

    await tester.pumpWidget(
      _tutorialApp(
        storage,
        mediaQuery: const MediaQueryData(
          size: Size(320, 568),
          textScaler: TextScaler.linear(1.6),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Match two identical free tiles.'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completion persists once and Play Level 1 routes correctly',
      (tester) async {
    final storage = await _storage();
    final router = GoRouter(initialLocation: '/tutorial', routes: [
      GoRoute(
        path: '/tutorial',
        builder: (_, __) => const TutorialScreen(),
      ),
      GoRoute(
        path: '/game/1',
        builder: (_, __) => const Scaffold(body: Text('Level 1 game board')),
      ),
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: Text('Home destination')),
      ),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
        audioServiceProvider.overrideWithValue(
          AudioService(sound: false, music: false),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump();

    Future<void> match(String first, String second,
        {bool completesLesson = false}) async {
      await tester.tap(find.byKey(ValueKey(first)));
      await tester.pump();
      await tester.tap(find.byKey(ValueKey(second)));
      await tester.pump(completesLesson
          ? const Duration(milliseconds: 700)
          : const Duration(milliseconds: 20));
    }

    await match('match-a', 'match-b', completesLesson: true);
    await match('edge-a', 'edge-b');
    await match('centre-a', 'centre-b', completesLesson: true);
    await match('top-a', 'top-b');
    await match('lower-a', 'lower-b', completesLesson: true);
    await match('back-a1', 'back-a2');
    await match('back-b1', 'back-b2');
    await match('back-c1', 'back-c2', completesLesson: true);
    await match('p-edge-a', 'p-edge-b');
    await match('p-block-a', 'p-block-b');
    await match('p-top-a', 'p-top-b');
    await match('p-lower-a', 'p-lower-b');
    await match('p-free-a', 'p-free-b');
    await match('p-inner-a', 'p-inner-b', completesLesson: true);

    expect(find.text('Tutorial Complete'), findsOneWidget);
    expect(find.text('PLAY LEVEL 1'), findsOneWidget);
    expect(storage.isTutorialComplete(), isFalse,
        reason: 'Completion is persisted when the player confirms the action.');

    await tester.tap(find.text('PLAY LEVEL 1'));
    await tester.pumpAndSettle();
    expect(storage.isTutorialComplete(), isTrue);
    expect(find.text('Level 1 game board'), findsOneWidget);
    expect(find.text('Tutorial Complete'), findsNothing);
  });
}

Future<StorageService> _storage() async {
  SharedPreferences.setMockInitialValues({});
  final storage = StorageService();
  await storage.init();
  return storage;
}

Widget _tutorialApp(StorageService storage, {MediaQueryData? mediaQuery}) {
  final tutorial = mediaQuery == null
      ? const TutorialScreen()
      : MediaQuery(data: mediaQuery, child: const TutorialScreen());
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
      audioServiceProvider.overrideWithValue(
        AudioService(sound: false, music: false),
      ),
    ],
    child: MaterialApp(home: tutorial),
  );
}

void _completeCurrentLesson(TutorialController controller) {
  while (!controller.lessonComplete) {
    final pair = BoardSolver.findAvailableMatchingPairs(controller.tiles).first;
    expect(controller.tap(pair.first.uid), TutorialTapResult.selected);
    expect(controller.tap(pair.second.uid), TutorialTapResult.matched);
  }
}

void _advanceTo(
  TutorialController controller,
  TutorialLesson destination,
) {
  while (controller.lesson != destination) {
    _completeCurrentLesson(controller);
    controller.advanceLesson();
  }
}

dynamic _tile(TutorialController controller, String uid) =>
    controller.tiles.firstWhere((tile) => tile.uid == uid);
