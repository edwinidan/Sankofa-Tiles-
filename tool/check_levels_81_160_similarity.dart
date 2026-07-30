// ignore_for_file: avoid_print

import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/levels_81_160_candidate_data.dart';
import 'package:sankofa_tiles/core/utils/layout_similarity.dart';

void main() {
  final candidates = kLevels81To160Candidates;
  var exact = 0;
  var adjacent = 0.0;
  var offset20 = 0.0;
  var offset40 = 0.0;
  var prior = 0.0;
  for (var i = 0; i < candidates.length; i++) {
    for (var j = i + 1; j < candidates.length; j++) {
      if (candidates[i].layout.positions.toSet().containsAll(
                candidates[j].layout.positions,
              ) &&
          candidates[j].layout.positions.toSet().containsAll(
                candidates[i].layout.positions,
              )) {
        exact++;
      }
      final score = compareLayoutSilhouettes(
        candidates[i].layout,
        candidates[j].layout,
      ).score;
      if (j - i == 1 && score > adjacent) adjacent = score;
      if (j - i == 20 && score > offset20) offset20 = score;
      if (j - i == 40 && score > offset40) offset40 = score;
    }
    for (final production in kLevels.take(80)) {
      final score = compareLayoutSilhouettes(
        candidates[i].layout,
        production.namedLayout,
      ).score;
      if (score > prior) prior = score;
    }
  }
  print('exact=$exact adjacent=$adjacent offset20=$offset20 '
      'offset40=$offset40 prior=$prior');
  for (var chapter = 0; chapter < 4; chapter++) {
    final counts = candidates
        .skip(chapter * 20)
        .take(20)
        .map((candidate) => candidate.layout.stats.tileCount)
        .toList();
    print(
      'chapter${chapter + 5} tiles=${counts.reduce((a, b) => a < b ? a : b)}-'
      '${counts.reduce((a, b) => a > b ? a : b)}',
    );
  }
  print(
    'finales=${[
      100,
      120,
      140,
      160
    ].map((level) => '$level:${candidates[level - 81].layout.stats.tileCount}').join(',')}',
  );
}
