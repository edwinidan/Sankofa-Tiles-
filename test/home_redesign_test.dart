import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/models/game_launch_config.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/models/tile_model.dart';
import 'package:sankofa_tiles/providers/settings_provider.dart';
import 'package:sankofa_tiles/screens/home/home_screen.dart';
import 'package:sankofa_tiles/widgets/game_menu_components.dart';

const _previewDir = String.fromEnvironment('HOME_PREVIEW_DIR');
const _previewFont = String.fromEnvironment('HOME_PREVIEW_FONT');
final _capture = GlobalKey();

Future<StorageService> _storage({int completed = 8}) async {
  SharedPreferences.setMockInitialValues({
    'campaign_progress_schema_version': 4,
    'highest_completed_level': completed,
    for (var i = 1; i <= completed; i++) 'completed_$i': true,
    'economy_cowries': 731,
    'tutorial_complete': true,
  });
  final storage = StorageService();
  await storage.init();
  return storage;
}

Future<GoRouter> _mount(
  WidgetTester tester,
  StorageService storage, {
  Size size = const Size(390, 844),
  double textScale = 1,
  EdgeInsets safePadding = const EdgeInsets.only(top: 24, bottom: 20),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    for (final path in [
      '/daily-reward',
      '/journey',
      '/tile-preview',
      '/shop',
      '/settings',
      '/tutorial',
      '/level/:levelId',
      '/game/:levelId',
    ])
      GoRoute(
        path: path,
        builder: (_, state) => Scaffold(body: Text('Destination ${state.uri}')),
      ),
  ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: RepaintBoundary(
      key: _capture,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: _previewFont.isEmpty ? null : 'HomePreview',
          // Reproduce the wider inherited button styling that previously
          // made Collection wrap, without requiring network font downloads.
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: TextStyle(
                fontFamily: _previewFont.isEmpty ? null : 'HomePreview',
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            devicePixelRatio: 2,
            textScaler: TextScaler.linear(textScale),
            padding: safePadding,
          ),
          child: child!,
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return router;
}

Future<void> _savePreview(WidgetTester tester, String name) async {
  if (_previewDir.isEmpty) return;
  final context = tester.element(find.byType(HomeScreen));
  final providers = tester
      .widgetList<Image>(find.byType(Image))
      .map((image) => image.image)
      .toList();
  await tester.runAsync(() async {
    for (final provider in providers) {
      await precacheImage(provider, context);
    }
  });
  await tester.pumpAndSettle();
  for (final rawImage in find.byType(RawImage).evaluate()) {
    expect((rawImage.renderObject! as RenderImage).image, isNotNull,
        reason: 'All Home artwork must be decoded before capture');
  }
  final boundary =
      _capture.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = await Directory(_previewDir).create(recursive: true);
    await File('${dir.path}/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    if (_previewFont.isNotEmpty) {
      final font = FontLoader('HomePreview')
        ..addFont(File(_previewFont).readAsBytes().then(ByteData.sublistView));
      await font.load();
    }
  });

  for (final scenario in const [
    ('compact', Size(320, 568), 1.0),
    ('standard', Size(390, 844), 1.0),
    ('tall', Size(430, 932), 1.0),
    ('notched', Size(393, 852), 1.0),
    ('large-text', Size(320, 568), 2.0),
  ]) {
    testWidgets('Home renders ${scenario.$1} with reachable navigation',
        (tester) async {
      final insets = scenario.$1 == 'notched'
          ? const EdgeInsets.only(top: 59, bottom: 34)
          : const EdgeInsets.only(top: 24, bottom: 20);
      await _mount(tester, await _storage(),
          size: scenario.$2, textScale: scenario.$3, safePadding: insets);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('LEVEL 9'), findsOneWidget);
      if (const bool.fromEnvironment('HOME_MEASUREMENTS')) {
        final primary =
            tester.getSize(find.byKey(const ValueKey('home-continue')));
        final navigation = tester
            .widgetList<GameNavigationButton>(find.byType(GameNavigationButton))
            .map((button) =>
                '${button.label}:${tester.getSize(find.byWidget(button))}')
            .join(', ');
        debugPrint(
            'HOME_METRICS ${scenario.$1}: primary=$primary; navigation=$navigation; wallet=${tester.getSize(find.byType(GameCurrencyDisplay))}; iconTarget=${tester.getSize(find.byTooltip('Settings'))}');
      }
      expect(tester.takeException(), isNull);
      final navigationButtons = find.byType(GameNavigationButton);
      final navigationSizes = tester
          .widgetList<GameNavigationButton>(navigationButtons)
          .map((button) => tester.getSize(find.byWidget(button)))
          .toList();
      expect(navigationSizes.map((size) => size.height).toSet(), hasLength(1));
      expect(
          navigationSizes
              .every((size) => size.height >= 48 && size.width >= 48),
          isTrue);
      for (final label in ['Journey progress', 'Shop', 'Settings']) {
        final bounds = tester.getRect(find.byTooltip(label));
        expect(bounds.top, greaterThanOrEqualTo(insets.top));
        expect(bounds.size.shortestSide, greaterThanOrEqualTo(48));
      }
      final actionBounds =
          tester.getRect(find.byKey(const ValueKey('home-continue')));
      expect(actionBounds.height, greaterThanOrEqualTo(48));
      final playIcon = find.descendant(
          of: find.byKey(const ValueKey('home-continue')),
          matching: find.byIcon(Icons.play_arrow_rounded));
      expect(tester.getCenter(playIcon).dx,
          lessThan(tester.getCenter(find.text('CONTINUE')).dx));
      final navTop = tester.getTopLeft(navigationButtons.first).dy;
      expect(navTop - actionBounds.bottom, greaterThanOrEqualTo(20));
      for (final label in ['Daily', 'Journey', 'Collection']) {
        final paragraph =
            tester.renderObject<RenderParagraph>(find.text(label));
        final boxes = paragraph.getBoxesForSelection(
          TextSelection(baseOffset: 0, extentOffset: label.length),
        );
        expect(boxes.map((box) => box.top).toSet(), hasLength(1),
            reason: '$label must stay on one line');
        expect(boxes.last.right, lessThanOrEqualTo(paragraph.size.width + .1),
            reason: '$label must fit without clipping');
      }
      await _savePreview(tester, scenario.$1);
      await tester.ensureVisible(find.text('Collection'));
      await tester.pumpAndSettle();
      expect(find.text('Collection').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('large Cowries balance remains readable on compact Home',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final storage = await _storage();
    await storage.setCowries(987654321);
    await _mount(tester, storage, size: const Size(320, 568));
    expect(find.text('987654321'), findsOneWidget);
    expect(find.bySemanticsLabel('987654321 Cowries'), findsOneWidget);
    final paragraph =
        tester.renderObject<RenderParagraph>(find.text('987654321'));
    final boxes = paragraph.getBoxesForSelection(
        const TextSelection(baseOffset: 0, extentOffset: 9));
    expect(
        boxes.every((box) => box.right <= paragraph.size.width + .1), isTrue);
    await _savePreview(tester, 'large-balance');
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('Continue opens the actual next pre-level without changing saves',
      (tester) async {
    final storage = await _storage();
    await _mount(tester, storage);
    await _tapText(tester, 'CONTINUE');
    expect(find.text('Destination /level/9'), findsOneWidget);
    expect(storage.getHighestCompletedLevel(), 8);
    expect(storage.getCowries(), 731);
  });

  testWidgets(
      'Resume preserves the saved board and sends the resume launch flag',
      (tester) async {
    final storage = await _storage();
    await storage.saveActiveGame(GameState.initial().copyWith(
      levelId: 7,
      status: GameStatus.playing,
      score: 450,
      tiles: [
        TileModel(def: kAllTiles.first, row: 0, col: 0),
        TileModel(def: kAllTiles.first, row: 0, col: 4),
      ],
    ));
    await _mount(tester, storage);
    expect(find.text('LEVEL 7'), findsOneWidget);
    expect(find.text('2 tiles remaining'), findsOneWidget);
    await _savePreview(tester, 'resume');
    await _tapText(tester, 'RESUME');
    expect(find.text('Destination /game/7'), findsOneWidget);
    final config = GoRouterState.of(
      tester.element(find.text('Destination /game/7')),
    ).extra as GameLaunchConfig;
    expect(config.resumeSavedGame, isTrue);
    expect(config.levelId, 7);
    expect(storage.getActiveGame()!.score, 450);
  });

  testWidgets('Start another level keeps the saved board', (tester) async {
    final storage = await _storage();
    await storage.saveActiveGame(GameState.initial().copyWith(
      levelId: 7,
      status: GameStatus.playing,
      tiles: [TileModel(def: kAllTiles.first, row: 0, col: 0)],
    ));
    await _mount(tester, storage);
    await _tapText(tester, 'Start another level');
    expect(find.text('Destination /level/9'), findsOneWidget);
    expect(storage.getActiveGameSummary()!.levelId, 7);
  });

  testWidgets('Completed campaign does not advertise an unimplemented level',
      (tester) async {
    final router = await _mount(tester, await _storage(completed: 280));
    expect(find.text('JOURNEY COMPLETE'), findsOneWidget);
    expect(find.text('LEVEL 281'), findsNothing);
    await _tapText(tester, 'JOURNEY COMPLETE');
    expect(router.routeInformationProvider.value.uri.path, '/');
    expect(find.text('All Current Levels Completed'), findsOneWidget);
  });

  for (final destination in const [
    ('Daily', '/daily-reward', false),
    ('Journey', '/journey', false),
    ('Collection', '/tile-preview', false),
    ('Shop', '/shop', true),
    ('Settings', '/settings', true),
  ]) {
    testWidgets('${destination.$1} retains its real route', (tester) async {
      await _mount(tester, await _storage());
      if (destination.$3) {
        await tester.tap(find.byTooltip(destination.$1));
        await tester.pumpAndSettle();
      } else {
        await _tapText(tester, destination.$1);
      }
      expect(find.text('Destination ${destination.$2}'), findsOneWidget);
    });
  }

  testWidgets('Progress sheet retains chapter, boosters and next symbol access',
      (tester) async {
    await _mount(tester, await _storage());
    await tester.tap(find.byTooltip('Journey progress'));
    await tester.pumpAndSettle();
    expect(find.text('Current Chapter: Kokrobite to Ada Foah'), findsOneWidget);
    expect(find.textContaining('Levels 8/280'), findsOneWidget);
    expect(find.textContaining('Hints '), findsOneWidget);
    expect(find.text('View Collection'), findsOneWidget);
    await tester.tap(find.byTooltip('Close progress'));
    await tester.pumpAndSettle();
    expect(find.text('CONTINUE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('New players keep tutorial replay access', (tester) async {
    await _mount(tester, await _storage(completed: 0));
    expect(find.text('LEVEL 1'), findsOneWidget);
    await _tapText(tester, 'HOW TO PLAY');
    expect(find.text('Destination /tutorial?replay=1'), findsOneWidget);
  });
}
