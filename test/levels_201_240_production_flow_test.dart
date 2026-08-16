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

  test('Chapter 11 and 12 transitions match the production assignment', () {
    expect(chapterForLevel(201).index, 11);
    expect(chapterForLevel(220).index, 11);
    expect(chapterForLevel(221).index, 12);
    expect(chapterForLevel(240).index, 12);
    expect(isChapterFinalLevel(220), isTrue);
    expect(isChapterFinalLevel(240), isTrue);
    expect(isChapterFinalLevel(200), isTrue);
    expect(getLevelById(241), isNotNull);
  });

  testWidgets('Level-200 veteran sees Level 201 as the next journey action',
      (tester) async {
    final storage = await _storage({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 200,
      'completed_200': true,
    });
    await tester.pumpWidget(_app(storage, const JourneyScreen()));

    expect(find.text('CONTINUE LEVEL 201'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('The Journey Reopens'),
      800,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('The Journey Reopens'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Living Memory'),
      800,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Living Memory'), findsOneWidget);
  });

  testWidgets(
      'Level 240 continues into the next implemented production chapter',
      (tester) async {
    final storage = await _storage({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 240,
      'completed_240': true,
    });
    await tester.pumpWidget(
      _app(storage, const ChapterCompleteScreen(completedLevelId: 240)),
    );

    expect(find.text('Chapter Complete'), findsOneWidget);
    expect(find.text('Living Memory'), findsOneWidget);
    expect(find.text('Next: Rivers of Counsel'), findsOneWidget);
  });

  testWidgets('Level 241 is available to a Level-240 veteran', (tester) async {
    final storage = await _storage({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 240,
      'completed_240': true,
    });
    await tester.pumpWidget(_app(storage, const PreLevelScreen(levelId: 241)));

    expect(find.text('Level Not Found'), findsNothing);
    expect(find.text('PLAY'), findsOneWidget);
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
