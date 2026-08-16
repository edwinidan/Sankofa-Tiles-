import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/tile_unlock_data.dart';

void main() {
  test('implemented, planned, and collection horizons are distinct', () {
    expect(kImplementedCampaignLevelCount, 280);
    expect(kImplementedFinalLevelId, 280);
    expect(kPlannedCampaignLevelCount, 400);
    expect(kCollectionScheduleFinalLevel, 400);
    expect(kLevels, hasLength(kImplementedCampaignLevelCount));
    expect(getLevelById(kImplementedFinalLevelId + 1), isNull);
  });

  test('approved handcrafted assignments remain unchanged', () {
    expect(
      [for (var id = 1; id <= 5; id++) getLevelById(id)!.layoutName],
      const [
        'earlyOpenDiamond01',
        'earlyOpenDiamond02',
        'earlyBridge01',
        'earlyShrine01',
        'earlyLayeredDiamond01',
      ],
    );
  });
}
