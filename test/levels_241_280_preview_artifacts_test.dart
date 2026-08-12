import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:sankofa_tiles/core/constants/levels_241_280_candidate_data.dart';

const _artifactDirectory =
    'artifacts/layout-previews/levels-241-280-candidates';

void main() {
  test('candidate previews and visual-review sheets are complete and visible',
      () {
    for (final candidate in kLevels241To280Candidates) {
      _expectPng(
        File('$_artifactDirectory/${candidate.layout.id}_390x844.png'),
        width: 390,
        height: 844,
      );
      _expectPng(
        File('$_artifactDirectory/${candidate.layout.id}_diagnostic.png'),
        width: 390,
        height: 844,
      );
      _expectPng(
        File('$_artifactDirectory/${candidate.layout.id}_silhouette.png'),
        width: 390,
        height: 844,
      );
      _expectPng(
        File('$_artifactDirectory/${candidate.layout.id}_360x640.png'),
        width: 360,
        height: 640,
      );
      _expectPng(
        File('$_artifactDirectory/${candidate.layout.id}_430x932.png'),
        width: 430,
        height: 932,
      );
    }
    for (final name in const [
      'levels-241-250-contact-sheet.png',
      'levels-251-260-contact-sheet.png',
      'levels-261-270-contact-sheet.png',
      'levels-271-280-contact-sheet.png',
      'chapter-13-overview.png',
      'chapter-14-overview.png',
      'levels-241-280-visual-overview.png',
      'levels-241-280-silhouette-overview.png',
      'coarse-classification-overview.png',
      'bulk-fullness-distribution.png',
      'envelope-distribution.png',
      'breather-overview.png',
      'showcase-overview.png',
      'levels-221-280-comparison.png',
      'levels-201-280-silhouette-comparison.png',
      'level-240-to-241-comparison.png',
      'finale-comparison-levels-200-220-240-260-280.png',
    ]) {
      _expectPng(File('$_artifactDirectory/$name'));
    }
    expect(File('$_artifactDirectory/metrics.csv').lengthSync(),
        greaterThan(5000));
    expect(
      File('$_artifactDirectory/levels-241-280-candidate-report.md')
          .lengthSync(),
      greaterThan(15000),
    );
  }, skip: !Directory(_artifactDirectory).existsSync());
}

void _expectPng(File file, {int? width, int? height}) {
  expect(file.existsSync(), isTrue, reason: file.path);
  expect(file.lengthSync(), greaterThan(10000), reason: file.path);
  final decoded = image.decodePng(file.readAsBytesSync());
  expect(decoded, isNotNull, reason: file.path);
  if (width != null) expect(decoded!.width, width, reason: file.path);
  if (height != null) expect(decoded!.height, height, reason: file.path);
  var brightest = 0;
  final colors = <int>{};
  for (var y = 0; y < decoded!.height; y += 20) {
    for (var x = 0; x < decoded.width; x += 20) {
      final pixel = decoded.getPixel(x, y);
      brightest = [brightest, pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()]
          .reduce((first, second) => first > second ? first : second);
      colors.add(
        (pixel.r.toInt() << 16) | (pixel.g.toInt() << 8) | pixel.b.toInt(),
      );
    }
  }
  expect(brightest, greaterThan(40), reason: '${file.path} is all-black');
  expect(colors.length, greaterThan(4), reason: '${file.path} is blank');
}
