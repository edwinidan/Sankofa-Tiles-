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

Future<StorageService> _storage(int completed) async {
  SharedPreferences.setMockInitialValues({
    'campaign_progress_schema_version': 4,
    'highest_completed_level': completed,
    'completed_$completed': true,
  });
  final storage = StorageService();
  await storage.init();
  return storage;
}

Widget _app(StorageService storage, Widget child) => ProviderScope(
      overrides: [storageServiceProvider.overrideWithValue(storage)],
      child: MaterialApp(home: child),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('chapter 19 owns exactly Levels 361-380 and 381 stays unavailable', () {
    final chapter = chapterForLevel(361);
    expect(chapter.index, 19);
    expect(chapter.title, 'Still Waters');
    expect(chapterForLevel(380), same(chapter));
    expect(chapter.levels.map((l) => l.id),
        orderedEquals(List.generate(20, (i) => 361 + i)));
    expect(isChapterFinalLevel(380), isTrue);
    expect(getLevelById(381), isNull);
  });

  testWidgets('a Level-360 veteran continues at 361 in Journey',
      (tester) async {
    await tester.pumpWidget(_app(await _storage(360), const JourneyScreen()));
    expect(find.text('CONTINUE LEVEL 361'), findsOneWidget);
  });

  testWidgets('Level 360 chapter recap now continues to Still Waters',
      (tester) async {
    await tester.pumpWidget(_app(await _storage(360),
        const ChapterCompleteScreen(completedLevelId: 360)));
    expect(find.text('Chapter Complete'), findsOneWidget);
    expect(find.text('Festival of Light'), findsOneWidget);
    expect(find.text('Next: Still Waters'), findsOneWidget);
    expect(find.text('NEXT LEVEL'), findsOneWidget);
  });

  testWidgets('Level 380 is the current ending and returns home',
      (tester) async {
    await tester.pumpWidget(_app(await _storage(380),
        const ChapterCompleteScreen(completedLevelId: 380)));
    expect(find.text('Current Journey Complete'), findsOneWidget);
    expect(find.text('Still Waters'), findsOneWidget);
    expect(find.text('RETURN HOME'), findsOneWidget);
    expect(find.textContaining('Next:'), findsNothing);
  });

  testWidgets('Level 381 is not playable', (tester) async {
    await tester.pumpWidget(
        _app(await _storage(380), const PreLevelScreen(levelId: 381)));
    expect(find.text('Level Not Found'), findsOneWidget);
    expect(find.text('PLAY'), findsNothing);
  });
}
