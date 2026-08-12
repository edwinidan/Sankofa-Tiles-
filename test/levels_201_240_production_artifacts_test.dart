import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

const _artifactDirectory =
    'artifacts/layout-previews/levels-201-240-production';

void main() {
  test('production previews and review sheets are complete and nonblank', () {
    for (var level = 200; level <= 240; level++) {
      _expectPng(File('$_artifactDirectory/level-${level}_390x844.png'),
          width: 390, height: 844);
      _expectPng(File('$_artifactDirectory/level-${level}_silhouette.png'),
          width: 390, height: 844);
    }
    _expectPng(File('$_artifactDirectory/level-240_current-boundary.png'),
        width: 390, height: 844);
    for (final name in const [
      'levels-201-210-contact-sheet.png',
      'levels-211-220-contact-sheet.png',
      'levels-221-230-contact-sheet.png',
      'levels-231-240-contact-sheet.png',
      'chapter-11-production-overview.png',
      'chapter-12-production-overview.png',
      'levels-201-240-production-overview.png',
      'levels-201-240-production-silhouette-overview.png',
      'level-200-to-201-transition-evidence.png',
      'level-220-to-221-transition-evidence.png',
      'level-220-vs-240-finale-comparison.png',
      'level-240-old-vs-new-comparison.png',
      'production-finale-comparison-levels-200-220-240.png',
    ]) {
      _expectPng(File('$_artifactDirectory/$name'));
    }
    expect(
        File('$_artifactDirectory/production-assignment-matrix.csv')
            .lengthSync(),
        greaterThan(1000));
    expect(
        File('$_artifactDirectory/levels-201-240-production-report.md')
            .lengthSync(),
        greaterThan(4000));
  }, skip: !Directory(_artifactDirectory).existsSync());
}

void _expectPng(File file, {int? width, int? height}) {
  expect(file.existsSync(), isTrue, reason: file.path);
  expect(file.lengthSync(), greaterThan(10000), reason: file.path);
  final decoded = image.decodePng(file.readAsBytesSync());
  expect(decoded, isNotNull, reason: file.path);
  if (width != null) expect(decoded!.width, width, reason: file.path);
  if (height != null) expect(decoded!.height, height, reason: file.path);
}
