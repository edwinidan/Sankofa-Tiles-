import 'dart:math';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:sankofa_tiles/core/constants/layout_data.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/levels_81_160_candidate_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/layout_similarity.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

void main() {
  test('Levels 81-160 candidates are isolated, portrait-fit, and valid', () {
    expect(kLevels81To160Candidates, hasLength(80));
    expect(
        kLevels81To160Candidates.map((candidate) => candidate.family).toSet(),
        hasLength(80));
    expect(kLevels81To160Candidates.map((candidate) => candidate.level),
        orderedEquals(List.generate(80, (index) => index + 81)));
    expect(
        kLevels81To160Candidates
            .map((candidate) => candidate.layout.id)
            .toSet(),
        hasLength(80));
    for (final candidate in kLevels81To160Candidates) {
      expect(getLevelById(candidate.level)!.layoutName,
          isNot(candidate.layout.id));
      final validation =
          validateLayout(candidate.layout, minimumOpeningTiles: 4);
      expect(validation.issues, isEmpty,
          reason:
              '${candidate.level}: ${validation.issues.map((issue) => issue.message).join('; ')}');
      final fit = BoardLayoutGeometry.fromPositions(candidate.layout.positions)
          .fit(availableWidth: 374, availableHeight: 804);
      expect(fit.tileWidth, greaterThanOrEqualTo(52));
      expect(fit.boardHeight / 804, inInclusiveRange(.60, .82));
      expect(candidate.layout.stats.layerCount, 3);
      final level = getLevelById(candidate.level)!;
      final counts = level.symbolPlan
          .copyCountsForTileCount(candidate.layout.positions.length);
      expect(counts.reduce((a, b) => a + b), candidate.layout.positions.length);
      expect(counts.every((count) => count.isEven), isTrue);
    }
  });

  test('Levels 81-160 satisfy silhouette similarity gates', () {
    for (var i = 0; i < kLevels81To160Candidates.length; i++) {
      final candidate = kLevels81To160Candidates[i];
      for (var j = i + 1; j < kLevels81To160Candidates.length; j++) {
        final other = kLevels81To160Candidates[j];
        expect(candidate.layout.positions,
            isNot(orderedEquals(other.layout.positions)));
        final score =
            compareLayoutSilhouettes(candidate.layout, other.layout).score;
        if (j - i == 1) {
          expect(score, lessThan(.85),
              reason: 'adjacent ${candidate.level}/${other.level}');
        }
        if (j - i == 20) {
          expect(score, lessThan(.75),
              reason: 'offset 20 ${candidate.level}/${other.level}');
        }
        if (j - i == 40) {
          expect(score, lessThan(.72),
              reason: 'offset 40 ${candidate.level}/${other.level}');
        }
      }
      for (final production in kLevels.take(80)) {
        expect(
          compareLayoutSilhouettes(
            candidate.layout,
            production.namedLayout,
          ).score,
          lessThan(.72),
          reason: 'candidate ${candidate.level}/production ${production.id}',
        );
      }
    }
  });

  test('developer catalogue includes isolated Levels 81-160 section', () {
    final source =
        File('lib/screens/developer/developer_level_tester_screen.dart')
            .readAsStringSync();
    expect(source, contains('LEVELS 81–160 CANDIDATES · ISOLATED'));
    expect(source, contains('kLevels81To160Candidates'));
    expect(source, contains('Developer preview only · not assigned'));
  });

  test('candidate preview exports are complete, sized, and nonblank', () {
    const directory = 'artifacts/layout-previews/levels-81-160-candidates';
    for (final candidate in kLevels81To160Candidates) {
      for (final suffix in const [
        '390x844',
        'diagnostic',
        'silhouette',
      ]) {
        final file = File('$directory/${candidate.layout.id}_$suffix.png');
        expect(file.existsSync(), isTrue, reason: file.path);
        final decoded = image.decodePng(file.readAsBytesSync())!;
        expect(decoded.width, 390, reason: file.path);
        expect(decoded.height, 844, reason: file.path);
        expect(_containsVisiblePixels(decoded), isTrue, reason: file.path);
      }
    }
    for (final level in const [100, 120, 140, 160]) {
      final candidate = kLevels81To160Candidates[level - 81];
      for (final size in const ['360x640', '430x932']) {
        final file = File(
          '$directory/${candidate.layout.id}_$size.png',
        );
        expect(file.existsSync(), isTrue, reason: file.path);
        final decoded = image.decodePng(file.readAsBytesSync())!;
        expect('${decoded.width}x${decoded.height}', size);
      }
    }
    for (final name in const [
      'levels-81-90-contact-sheet.png',
      'levels-91-100-contact-sheet.png',
      'levels-101-110-contact-sheet.png',
      'levels-111-120-contact-sheet.png',
      'levels-121-130-contact-sheet.png',
      'levels-131-140-contact-sheet.png',
      'levels-141-150-contact-sheet.png',
      'levels-151-160-contact-sheet.png',
      'chapter-5-overview.png',
      'chapter-6-overview.png',
      'chapter-7-overview.png',
      'chapter-8-overview.png',
      'levels-81-160-overview.png',
      'levels-81-160-silhouette-overview.png',
      'levels-81-160-diagnostic-overview.png',
      'levels-81-160-family-classification.png',
      'chapters-5-8-comparison.png',
      'levels-1-160-silhouette-comparison.png',
      'finale-comparison-levels-20-160.png',
    ]) {
      final file = File('$directory/$name');
      expect(file.existsSync(), isTrue, reason: file.path);
      expect(file.lengthSync(), greaterThan(10000), reason: file.path);
      final decoded = image.decodePng(file.readAsBytesSync())!;
      expect(_containsVisiblePixels(decoded), isTrue, reason: file.path);
    }
  });

  for (final candidate in kLevels81To160Candidates) {
    test('${candidate.layout.id} generates and solves for 100 seeds', () {
      final level = getLevelById(candidate.level)!;
      final minimumPairs =
          const {100, 120, 140, 160}.contains(candidate.level) ? 5 : 3;
      for (var seed = 0; seed < 100; seed++) {
        final tiles = _generate(
          candidate.layout.positions,
          level,
          seed,
          minimumPairs,
        );
        expect(tiles, isNotNull, reason: 'level=${candidate.level} seed=$seed');
        expect(BoardSolver.isSolvable(tiles!), isTrue,
            reason: 'level=${candidate.level} seed=$seed');
        expect(
          tiles.map((tile) => '${tile.row}:${tile.col}:${tile.layer}').toSet(),
          equals(candidate.layout.positions
              .map((position) =>
                  '${position.row}:${position.col}:${position.layer}')
              .toSet()),
        );
      }
    });
  }
}

bool _containsVisiblePixels(image.Image decoded) {
  var bright = 0;
  const samples = 40;
  for (var y = 0; y < samples; y++) {
    for (var x = 0; x < samples; x++) {
      final pixel = decoded.getPixel(
        x * (decoded.width - 1) ~/ (samples - 1),
        y * (decoded.height - 1) ~/ (samples - 1),
      );
      if (pixel.r + pixel.g + pixel.b > 90) bright++;
    }
  }
  return bright > 20;
}

List<TileModel>? _generate(
  List<TilePosition> positions,
  LevelDefinition level,
  int seed,
  int minimumPairs,
) {
  final random = Random(seed);
  for (var attempt = 0; attempt < 250; attempt++) {
    var remaining = <TileModel>[
      for (var index = 0; index < positions.length; index++)
        TileModel(
          uid: 'r${attempt}_$index',
          def: kAllTiles.first,
          row: positions[index].row,
          col: positions[index].col,
          layer: positions[index].layer,
        ),
    ];
    final order = <TileModel>[];
    while (remaining.isNotEmpty) {
      final free = BoardSolver.getFreeTiles(remaining)..shuffle(random);
      if (free.length < 2) break;
      order.addAll([free[0], free[1]]);
      final removed = {free[0].uid, free[1].uid};
      remaining =
          remaining.where((tile) => !removed.contains(tile.uid)).toList();
    }
    if (remaining.isNotEmpty) continue;
    final counts = level.symbolPlan.copyCountsForTileCount(order.length);
    final definitions = <TileDefinition>[];
    for (var index = 0; index < counts.length; index++) {
      definitions.addAll(
        List.filled(counts[index], kAllTiles[index % kAllTiles.length]),
      );
    }
    final generated = [
      for (var index = 0; index < order.length; index++)
        TileModel(
          uid: 'g$index',
          def: definitions[index],
          row: order[index].row,
          col: order[index].col,
          layer: order[index].layer,
        ),
    ];
    final legal = BoardSolver.findAvailableMatchingPairs(generated);
    if (legal.length < minimumPairs) continue;
    final safe = legal
        .where(
          (pair) => BoardSolver.isSafeMove(
            generated,
            pair.first,
            pair.second,
            maxSearchNodes: 25000,
          ),
        )
        .length;
    if (safe < minimumPairs) continue;
    return generated;
  }
  return null;
}
