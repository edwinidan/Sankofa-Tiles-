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

  test('Chapters 13 and 14 exactly own production Levels 241-280', () {
    expect(chapterForLevel(241).index, 13);
    expect(chapterForLevel(260).index, 13);
    expect(chapterForLevel(261).index, 14);
    expect(chapterForLevel(280).index, 14);
    expect(chapterForLevel(241).levels.map((level) => level.id),
        orderedEquals(List.generate(20, (index) => 241 + index)));
    expect(chapterForLevel(261).levels.map((level) => level.id),
        orderedEquals(List.generate(20, (index) => 261 + index)));
    expect(isChapterFinalLevel(260), isTrue);
    expect(isChapterFinalLevel(280), isTrue);
    expect(getLevelById(281), isNull);
  });

  testWidgets('Level-240 veteran sees Level 241 as the next journey action',
      (tester) async {
    final storage = await _storage({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 240,
      'completed_240': true,
    });
    await tester.pumpWidget(_app(storage, const JourneyScreen()));

    expect(find.text('CONTINUE LEVEL 241'), findsOneWidget);
  });

  testWidgets('Level 260 completes Rivers and continues to Level 261',
      (tester) async {
    final storage = await _storage({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 260,
      'completed_260': true,
    });
    await tester.pumpWidget(
      _app(storage, const ChapterCompleteScreen(completedLevelId: 260)),
    );

    expect(find.text('Chapter Complete'), findsOneWidget);
    expect(find.text('Rivers of Counsel'), findsOneWidget);
    expect(find.text('Next: Forest of Ancestors'), findsOneWidget);
  });

  testWidgets('Level 280 enters current-content completion with no 281 route',
      (tester) async {
    final storage = await _storage({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 280,
      'completed_280': true,
    });
    await tester.pumpWidget(
      _app(storage, const ChapterCompleteScreen(completedLevelId: 280)),
    );

    expect(find.text('Current Journey Complete'), findsOneWidget);
    expect(find.text('Forest of Ancestors'), findsOneWidget);
    expect(find.text('RETURN HOME'), findsOneWidget);
    expect(find.textContaining('Next:'), findsNothing);
    expect(getLevelById(281), isNull);
  });

  testWidgets('Level 281 remains unavailable', (tester) async {
    final storage = await _storage({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 280,
      'completed_280': true,
    });
    await tester.pumpWidget(_app(storage, const PreLevelScreen(levelId: 281)));

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
