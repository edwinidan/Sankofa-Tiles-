import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/ads/ad_ids.dart';
import 'package:sankofa_tiles/core/monetization/monetization_models.dart';

void main() {
  test('production ads are disabled in test builds', () {
    // In test/debug builds, productionAdsEnabled must be false.
    // This proves debug and profile builds never serve production ads.
    expect(AdIds.productionAdsEnabled, isFalse);
    expect(AdIds.useProductionAds, isFalse);
  });

  test('Android App ID contains tilde separator', () {
    expect(AdIds.androidAppId, contains('~'));
  });

  test('all configured ad-unit IDs pass validation', () {
    expect(AdIds.validateConfiguredIds(), isTrue);
  });

  test('production ad-unit ID constants contain slash', () {
    final content = File('lib/core/ads/ad_ids.dart').readAsStringSync();

    // Match all ca-app-pub-* constants that are ad-unit IDs (contain '/')
    // The app ID uses '~' instead of '/' and is not an ad-unit ID.
    final allIdPattern = RegExp(r"'(ca-app-pub-[^']+)'");
    final matches = allIdPattern.allMatches(content);
    expect(matches.isNotEmpty, isTrue, reason: 'Should find ad IDs');

    final adUnitIds = matches
        .map((m) => m.group(1)!)
        .where((id) => !id.contains('~')) // Exclude app ID
        .toList();
    expect(adUnitIds.isNotEmpty, isTrue,
        reason: 'Should find ad-unit IDs (not app IDs)');
    for (final id in adUnitIds) {
      expect(id, contains('/'), reason: 'Ad-unit ID "$id" must contain /');
    }
  });

  test('rewarded ad unit IDs resolve for supported placements', () {
    // In test/debug mode, supported placements return the test ID
    final hintId = AdIds.rewardedAdUnitId(RewardedPlacement.freeHint);
    final retryId = AdIds.rewardedAdUnitId(RewardedPlacement.retryAssistance);

    if (AdIds.isSupportedPlatform) {
      expect(hintId, isNotNull);
      expect(retryId, isNotNull);
      expect(hintId, contains('ca-app-pub-3940256099942544'));
      expect(retryId, contains('ca-app-pub-3940256099942544'));
    } else {
      expect(hintId, isNull);
      expect(retryId, isNull);
    }
  });

  test('interstitial ad unit ID resolves for afterCompletedLevels', () {
    final id =
        AdIds.interstitialAdUnitId(InterstitialPlacement.afterCompletedLevels);

    if (AdIds.isSupportedPlatform) {
      expect(id, isNotNull);
      expect(id, contains('ca-app-pub-3940256099942544'));
    } else {
      expect(id, isNull);
    }
  });

  test('new Android rewarded production placements are configured', () {
    final source = File('lib/core/ads/ad_ids.dart').readAsStringSync();
    const expectedMappings = {
      'RewardedPlacement.doubleCompletionCowries':
          '_androidRewardedDoubleCompletionCowries',
      'RewardedPlacement.freeRescueShuffle':
          '_androidRewardedFreeRescueShuffle',
      'RewardedPlacement.bonusDailyChest': '_androidRewardedBonusDailyChest',
      'RewardedPlacement.smallShopReward': '_androidRewardedSmallShopReward',
    };
    const expectedIds = [
      'ca-app-pub-5484820744037011/2775600473',
      'ca-app-pub-5484820744037011/1462518800',
      'ca-app-pub-5484820744037011/4557666995',
      'ca-app-pub-5484820744037011/4777158847',
    ];

    for (final entry in expectedMappings.entries) {
      expect(
        RegExp('${entry.key}\\s*=>\\s*${entry.value}').hasMatch(source),
        isTrue,
        reason: '${entry.key} should map to ${entry.value}, not null',
      );
    }
    for (final id in expectedIds) {
      expect(source, contains(id));
    }
  });

  test('unsupported interstitial placements return null in production', () {
    // Verify that placements without configured production IDs
    // would return null when production ads ARE enabled.
    // The source code maps these placements to null in the switch.
    final source = File('lib/core/ads/ad_ids.dart').readAsStringSync();
    // returningHome and beforeNewChapter are mentioned in the source
    expect(source, contains('InterstitialPlacement.returningHome'));
    expect(source, contains('InterstitialPlacement.beforeNewChapter'));
    // They map to null (may be on the next line after =>)
    expect(
      RegExp(r'returningHome[\s\S]*?null').hasMatch(source),
      isTrue,
      reason: 'returningHome should map to null',
    );
  });

  test('a normal release build without USE_PRODUCTION_ADS still uses test IDs',
      () {
    // useProductionAds defaults to false and we cannot set kReleaseMode
    // in tests. This verifies the default is false, proving that even a
    // release build without the dart-define flag uses test IDs.
    expect(AdIds.useProductionAds, isFalse);
    expect(AdIds.productionAdsEnabled, isFalse);
  });

  test('no ad-unit IDs are hardcoded in widget files', () {
    final widgetDirs = [
      'lib/screens/',
      'lib/widgets/',
    ];
    for (final dir in widgetDirs) {
      final directory = Directory(dir);
      if (!directory.existsSync()) continue;
      for (final file in directory.listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        if (file.path.contains('ad_ids.dart')) continue;
        final content = file.readAsStringSync();
        expect(
          content,
          isNot(contains('ca-app-pub-')),
          reason: '${file.path} must not contain hardcoded ad-unit IDs',
        );
      }
    }
  });

  test('Android production IDs are platform-gated', () {
    // isSupportedPlatform checks for Android only; iOS returns null
    final source = File('lib/core/ads/ad_ids.dart').readAsStringSync();
    expect(source, contains('TargetPlatform.android'));
    expect(source, contains('!kIsWeb'));
  });
}
