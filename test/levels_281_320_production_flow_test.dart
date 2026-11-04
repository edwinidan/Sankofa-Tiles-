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

  test('Chapters 15 and 16 exactly own production Levels 281-320', () {
    expect(chapterForLevel(281).index, 15);
    expect(chapterForLevel(300).index, 15);
    expect(chapterForLevel(301).index, 16);
    expect(chapterForLevel(320).index, 16);
    expect(chapterForLevel(281).levels.map((level) => level.id),
        orderedEquals(List.generate(20, (index) => 281 + index)));
    expect(chapterForLevel(301).levels.map((level) => level.id),
        orderedEquals(List.generate(20, (index) => 301 + index)));
    expect(isChapterFinalLevel(300), isTrue);
    expect(isChapterFinalLevel(320), isTrue);
    expect(getLevelById(321), isNotNull);
  });

  testWidgets('Level-280 veteran sees Level 281 as the next journey action',
      (tester) async {
    final storage = await _storage({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 280,
      'completed_280': true,
    });
    await tester.pumpWidget(_app(storage, const JourneyScreen()));

    expect(find.text('CONTINUE LEVEL 281'), findsOneWidget);
  });

  testWidgets('Level 300 completes Royal Roads and continues to Level 301',
      (tester) async {
    final storage = await _storage({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 300,
      'completed_300': true,
    });
    await tester.pumpWidget(
      _app(storage, const ChapterCompleteScreen(completedLevelId: 300)),
    );

    expect(find.text('Chapter Complete'), findsOneWidget);
    expect(find.text('Royal Roads'), findsOneWidget);
    expect(find.text('Next: Voices of the Drum'), findsOneWidget);
  });

  testWidgets('Level 320 now continues to Northern Weaves', (tester) async {
    final storage = await _storage({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 320,
      'completed_320': true,
    });
    await tester.pumpWidget(
      _app(storage, const ChapterCompleteScreen(completedLevelId: 320)),
    );

    expect(find.text('Chapter Complete'), findsOneWidget);
    expect(find.text('Voices of the Drum'), findsOneWidget);
    expect(find.text('NEXT LEVEL'), findsOneWidget);
    expect(find.text('Next: Northern Weaves'), findsOneWidget);
    expect(getLevelById(321), isNotNull);
  });

  testWidgets('Level 361 remains unavailable', (tester) async {
    final storage = await _storage({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 320,
      'completed_320': true,
    });
    await tester.pumpWidget(_app(storage, const PreLevelScreen(levelId: 361)));

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
