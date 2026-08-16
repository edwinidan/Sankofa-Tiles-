import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/chapter_data.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';

void main() {
  test('Ghana Journey grows from smaller places to major cities', () {
    const expectedCities = [
      'Kokrobite',
      'Ada Foah',
      'Aburi',
      'Axim',
      'Akosombo',
      'Elmina',
      'Winneba',
      'Ho',
      'Wa',
      'Bolgatanga',
      'Cape Coast',
      'Koforidua',
      'Techiman',
      'Sunyani',
      'Obuasi',
      'Amanfrom',
      'Sekondi-Takoradi',
      'Tamale',
      'Kumasi',
      'Accra',
    ];

    expect(kJourneyCityNames, expectedCities);
    expect(kLegacyTenLevelChapters.map((chapter) => chapter.title),
        expectedCities);
    expect(kChapters, hasLength(14));
    expect(kChapters.first.levelStart, 1);
    expect(kChapters.last.levelEnd, 280);
    expect(kChapters[10].title, 'The Journey Reopens');
    expect(kChapters[10].levelStart, 201);
    expect(kChapters[10].levelEnd, 220);
    expect(kChapters[11].title, 'Living Memory');
    expect(kChapters[11].levelStart, 221);
    expect(kChapters[11].levelEnd, 240);
    expect(kChapters[12].title, 'Rivers of Counsel');
    expect(kChapters[12].levelStart, 241);
    expect(kChapters[12].levelEnd, 260);
    expect(kChapters[13].title, 'Forest of Ancestors');
    expect(kChapters[13].levelStart, 261);
    expect(kChapters[13].levelEnd, 280);
  });

  test('every level uses the destination assigned to its chapter', () {
    for (final level in kLevels) {
      final chapter = chapterForLevel(level.id);
      expect(chapter.containsLevel(level.id), isTrue);
      expect(chapter.levels, contains(level));
      if (level.id >= 201) {
        expect(chapter.title, level.chapter);
      }
    }
  });
}
