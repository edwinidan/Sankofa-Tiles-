import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/utils/campaign_validator.dart';

void main() {
  final issues = validateCampaignStructure();
  if (issues.isNotEmpty) {
    for (final issue in issues) {
      // ignore: avoid_print
      print(issue);
    }
    throw StateError('Campaign validation failed');
  }

  // ignore: avoid_print
  print(buildCampaignValidationReport());
  // ignore: avoid_print
  print(
      '| # | Level | Layout | Tiles | Pairs | Layers | Symbols | Copies | Difficulty |');
  // ignore: avoid_print
  print(
      '|---|-------|--------|-------|-------|--------|---------|--------|------------|');
  for (final level in kLevels) {
    // ignore: avoid_print
    print(
      '| ${level.id} | ${level.name} | ${level.layoutName} | '
      '${level.tileCount} | ${level.pairCount} | ${level.layerCount} | '
      '${level.symbolPoolSize} | ${level.symbolDistributionLabel} | '
      '${level.difficultyCategory} |',
    );
  }
}
