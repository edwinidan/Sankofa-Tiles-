import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/widgets/game_menu_components.dart';
import 'package:sankofa_tiles/widgets/cowrie_icon.dart';

// Optional local review artifacts, not golden baselines or a Home mockup:
// --dart-define=MENU_PREVIEW_DIR=output/ui-foundation
// --dart-define=MENU_PREVIEW_FONT=/path/to/a/local/font.ttf
const _previewDirectory = String.fromEnvironment('MENU_PREVIEW_DIR');
const _previewFont = String.fromEnvironment('MENU_PREVIEW_FONT');
final _captureKey = GlobalKey();

Widget _app(Widget child, {double textScale = 1}) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: _previewFont.isEmpty ? null : 'MenuPreview',
      ),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(body: child),
      ),
    );

Widget _gallery() => GameMenuLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Visual foundation preview',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: GameCurrencyDisplay(amount: 123456)),
              const SizedBox(width: 12),
              GameIconButton(
                label: 'Settings',
                icon: Icons.settings_outlined,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          GamePrimaryButton(label: 'Resume Level 280', onPressed: () {}),
          const SizedBox(height: 16),
          GameNavigationGroup(
            buttons: [
              for (final entry in const [
                ('Daily', Icons.calendar_today_outlined),
                ('Journey', Icons.map_outlined),
                ('Collection', Icons.auto_awesome_outlined),
              ])
                GameNavigationButton(
                  label: entry.$1,
                  icon: entry.$2,
                  onPressed: () {},
                ),
            ],
          ),
          const SizedBox(height: 20),
          GamePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Cream panel', style: TextStyle(fontSize: 20)),
                GameToggle(label: 'Music', value: true, onChanged: (_) {}),
                GameToggle(label: 'Sound', value: false, onChanged: (_) {}),
                const GameToggle(
                  label: 'Disabled control',
                  value: false,
                  onChanged: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const GamePrimaryButton(label: 'Unavailable', onPressed: null),
        ],
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    if (_previewFont.isNotEmpty) {
      final loader = FontLoader('MenuPreview')
        ..addFont(File(_previewFont).readAsBytes().then(ByteData.sublistView));
      await loader.load();
    }
  });

  testWidgets('buttons invoke callbacks and disabled controls stay inert',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(_app(GameMenuLayout(
      child: Column(children: [
        GamePrimaryButton(label: 'Resume Level 7', onPressed: () => calls++),
        GameNavigationButton(
          label: 'Journey',
          icon: Icons.map_outlined,
          onPressed: () => calls++,
        ),
        GameIconButton(
          label: 'Settings',
          icon: Icons.settings,
          onPressed: () => calls++,
        ),
        const GamePrimaryButton(label: 'Unavailable', onPressed: null),
      ]),
    )));
    await tester.tap(find.text('Resume Level 7'));
    await tester.tap(find.text('Journey'));
    await tester.tap(find.byTooltip('Settings'));
    await tester.tap(find.text('Unavailable'));
    expect(calls, 3);
    expect(tester.getSize(find.byType(GameIconButton)).shortestSide,
        greaterThanOrEqualTo(48));
  });

  testWidgets(
      'toggle delegates state changes and wallet announces full balance',
      (tester) async {
    final semantics = tester.ensureSemantics();
    var music = false;
    await tester.pumpWidget(_app(StatefulBuilder(
      builder: (context, setState) => GameMenuLayout(
        child: Column(children: [
          const GameCurrencyDisplay(amount: 987654321),
          GamePanel(
            child: GameToggle(
              label: 'Music',
              value: music,
              onChanged: (value) => setState(() => music = value),
            ),
          ),
        ]),
      ),
    )));
    expect(find.bySemanticsLabel('987654321 Cowries'), findsOneWidget);
    await tester.tap(find.text('Music'));
    await tester.pumpAndSettle();
    expect(music, isTrue);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    semantics.dispose();
  });

  for (final scenario in const [
    ('compact', Size(320, 568), 1.0),
    ('standard', Size(390, 844), 1.0),
    ('large-text', Size(320, 568), 2.0),
    ('largest-text', Size(430, 932), 3.0),
  ]) {
    testWidgets('foundation fits ${scenario.$1} and remains scrollable',
        (tester) async {
      await tester.binding.setSurfaceSize(scenario.$2);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(RepaintBoundary(
        key: _captureKey,
        child: _app(_gallery(), textScale: scenario.$3),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      if (_previewDirectory.isNotEmpty) {
        await tester.runAsync(() => precacheImage(
              const AssetImage(kCowrieCurrencyAsset),
              tester.element(find.byType(GameCurrencyDisplay)),
            ));
        await tester.pumpAndSettle();
        final boundary = _captureKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final directory = Directory(_previewDirectory);
          await directory.create(recursive: true);
          await File('${directory.path}/${scenario.$1}.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await tester.ensureVisible(find.text('Unavailable'));
      await tester.pumpAndSettle();
      expect(find.text('Unavailable').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
