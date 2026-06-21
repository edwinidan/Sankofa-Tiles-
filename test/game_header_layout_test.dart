import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/screens/game/widgets/game_header.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final size in <Size>[
    const Size(320, 568),
    const Size(390, 844),
    const Size(430, 932),
  ]) {
    testWidgets(
      'compact gameplay header fits ${size.width.toInt()} px screens',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final storage = StorageService();
        await storage.init();

        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              storageServiceProvider.overrideWithValue(storage),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: SafeArea(
                  child: GameHeader(
                    levelId: 50,
                    isDeveloperTest: true,
                    onBack: () {},
                    onSettings: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(
          tester.getSize(find.byKey(const Key('compact-gameplay-header'))),
          Size(size.width, kCompactGameplayHeaderHeight),
        );
        expect(find.text('LEVEL'), findsOneWidget);
        expect(find.text('SCORE'), findsOneWidget);
        expect(find.text('MATCHES'), findsOneWidget);
        expect(
            find.byKey(const Key('developer-test-mode-label')), findsOneWidget);
        expect(find.byKey(const Key('gameplay-progress-bar')), findsOneWidget);
        expect(find.byTooltip('Back'), findsOneWidget);
        expect(find.byTooltip('Settings'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
