import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/core/constants/chapter_data.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/providers/settings_provider.dart';
import 'package:sankofa_tiles/screens/chapter/chapter_complete_screen.dart';
import 'package:sankofa_tiles/screens/journey/journey_screen.dart';
import 'package:sankofa_tiles/screens/pre_level/pre_level_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Chapters 17 and 18 exactly own production Levels 321-360', () {
    expect(chapterForLevel(321).index, 17);
    expect(chapterForLevel(340).index, 17);
    expect(chapterForLevel(341).index, 18);
    expect(chapterForLevel(360).index, 18);
    expect(chapterForLevel(321).levels.map((level) => level.id),
        orderedEquals(List.generate(20, (index) => 321 + index)));
    expect(chapterForLevel(341).levels.map((level) => level.id),
        orderedEquals(List.generate(20, (index) => 341 + index)));
    expect(isChapterFinalLevel(340), isTrue);
    expect(isChapterFinalLevel(360), isTrue);
    expect(getLevelById(361), isNotNull);
  });

  testWidgets('Level-320 veteran sees Level 321 as the next journey action',
      (tester) async {
    final storage = await _storage({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 320,
      'completed_320': true,
    });
    await tester.pumpWidget(_app(storage, const JourneyScreen()));

    expect(find.text('CONTINUE LEVEL 321'), findsOneWidget);
  });

  testWidgets('Level 340 completes Northern Weaves and continues to Level 341',
      (tester) async {
    final storage = await _storage({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 340,
      'completed_340': true,
    });
    await tester.pumpWidget(
      _app(storage, const ChapterCompleteScreen(completedLevelId: 340)),
    );

    expect(find.text('Chapter Complete'), findsOneWidget);
    expect(find.text('Northern Weaves'), findsOneWidget);
    expect(find.text('Next: Festival of Light'), findsOneWidget);
  });

  testWidgets('Level 360 continues from Festival of Light to Still Waters',
      (tester) async {
    final storage = await _storage({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 360,
      'completed_360': true,
    });
    await tester.pumpWidget(
      _app(storage, const ChapterCompleteScreen(completedLevelId: 360)),
    );

    expect(find.text('Chapter Complete'), findsOneWidget);
    expect(find.text('Festival of Light'), findsOneWidget);
    expect(find.text('NEXT LEVEL'), findsOneWidget);
    expect(find.text('Next: Still Waters'), findsOneWidget);
    expect(getLevelById(361), isNotNull);
  });

  testWidgets('Level 381 remains unavailable', (tester) async {
    final storage = await _storage({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 360,
      'completed_360': true,
    });
    await tester.pumpWidget(_app(storage, const PreLevelScreen(levelId: 381)));

    expect(find.text('Level Not Found'), findsOneWidget);
    expect(find.text('PLAY'), findsNothing);
  });
}

Future<StorageService> _storage(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final storage = StorageService();
  await storage.init();
  return storage;
}

Widget _app(StorageService storage, Widget child) => ProviderScope(
      overrides: [storageServiceProvider.overrideWithValue(storage)],
      child: MaterialApp(home: child),
    );
