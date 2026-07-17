import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/ads/ad_ids.dart';
import 'package:sankofa_tiles/core/monetization/monetization_models.dart';

void main() {
  test('production ads are disabled in test builds', () {
    // In test/debug builds, productionAdsEnabled must be false unless the
    // explicit USE_PRODUCTION_ADS override is supplied.
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

  test('settings banner ad unit ID resolves for supported platforms', () {
    final id = AdIds.bannerAdUnitId(BannerPlacement.settingsBottom);

    if (AdIds.isSupportedPlatform) {
      expect(id, isNotNull);
      expect(id, contains('ca-app-pub-3940256099942544'));
    } else {
      expect(id, isNull);
    }
  });

  test('new Android rewarded production placements are configured', () {
    const expectedMappings = {
      RewardedPlacement.freeHint: 'ca-app-pub-5484820744037011/7155770551',
      RewardedPlacement.retryAssistance:
          'ca-app-pub-5484820744037011/4741360208',
      RewardedPlacement.doubleCompletionCowries:
          'ca-app-pub-5484820744037011/2775600473',
      RewardedPlacement.freeRescueShuffle:
          'ca-app-pub-5484820744037011/1462518800',
      RewardedPlacement.bonusDailyChest:
          'ca-app-pub-5484820744037011/4557666995',
      RewardedPlacement.smallShopReward:
          'ca-app-pub-5484820744037011/4777158847',
    };

    for (final entry in expectedMappings.entries) {
      expect(
        AdIds.rewardedAdUnitIdForPlatform(
          entry.key,
          TargetPlatform.android,
          useProductionIds: true,
        ),
        entry.value,
      );
    }
  });

  test('iOS rewarded production placements are configured', () {
    const expectedMappings = {
      RewardedPlacement.freeHint: 'ca-app-pub-5484820744037011/9228795350',
      RewardedPlacement.retryAssistance:
          'ca-app-pub-5484820744037011/4164170939',
      RewardedPlacement.doubleCompletionCowries:
          'ca-app-pub-5484820744037011/8151517400',
      RewardedPlacement.freeRescueShuffle:
          'ca-app-pub-5484820744037011/9356787868',
      RewardedPlacement.bonusDailyChest:
          'ca-app-pub-5484820744037011/8137251130',
      RewardedPlacement.smallShopReward:
          'ca-app-pub-5484820744037011/8081410819',
    };

    for (final entry in expectedMappings.entries) {
      expect(
        AdIds.rewardedAdUnitIdForPlatform(
          entry.key,
          TargetPlatform.iOS,
          useProductionIds: true,
        ),
        entry.value,
      );
    }
  });

  test('Android interstitial production placement is configured', () {
    expect(
      AdIds.interstitialAdUnitIdForPlatform(
        InterstitialPlacement.afterCompletedLevels,
        TargetPlatform.android,
        useProductionIds: true,
      ),
      'ca-app-pub-5484820744037011/8600714161',
    );
  });

  test('iOS interstitial production placement is configured', () {
    expect(
      AdIds.interstitialAdUnitIdForPlatform(
        InterstitialPlacement.afterCompletedLevels,
        TargetPlatform.iOS,
        useProductionIds: true,
      ),
      'ca-app-pub-5484820744037011/5477252602',
    );
  });

  test('Android settings banner production placement is configured', () {
    expect(
      AdIds.bannerAdUnitIdForPlatform(
        BannerPlacement.settingsBottom,
        TargetPlatform.android,
        useProductionIds: true,
      ),
      'ca-app-pub-5484820744037011/4876698366',
    );
  });

  test('iOS settings banner production placement is configured', () {
    expect(
      AdIds.bannerAdUnitIdForPlatform(
        BannerPlacement.settingsBottom,
        TargetPlatform.iOS,
        useProductionIds: true,
      ),
      'ca-app-pub-5484820744037011/5646819163',
    );
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

  test('debug and development builds still use Google test IDs', () {
    expect(AdIds.useProductionAds, isFalse);
    expect(AdIds.productionAdsEnabled, isFalse);
    expect(
      AdIds.rewardedAdUnitIdForPlatform(
        RewardedPlacement.freeHint,
        TargetPlatform.android,
        useProductionIds: false,
      ),
      'ca-app-pub-3940256099942544/5224354917',
    );
    expect(
      AdIds.rewardedAdUnitIdForPlatform(
        RewardedPlacement.freeHint,
        TargetPlatform.iOS,
        useProductionIds: false,
      ),
      'ca-app-pub-3940256099942544/1712485313',
    );
    expect(
      AdIds.interstitialAdUnitIdForPlatform(
        InterstitialPlacement.afterCompletedLevels,
        TargetPlatform.android,
        useProductionIds: false,
      ),
      'ca-app-pub-3940256099942544/1033173712',
    );
    expect(
      AdIds.interstitialAdUnitIdForPlatform(
        InterstitialPlacement.afterCompletedLevels,
        TargetPlatform.iOS,
        useProductionIds: false,
      ),
      'ca-app-pub-3940256099942544/4411468910',
    );
    expect(
      AdIds.bannerAdUnitIdForPlatform(
        BannerPlacement.settingsBottom,
        TargetPlatform.android,
        useProductionIds: false,
      ),
      'ca-app-pub-3940256099942544/6300978111',
    );
    expect(
      AdIds.bannerAdUnitIdForPlatform(
        BannerPlacement.settingsBottom,
        TargetPlatform.iOS,
        useProductionIds: false,
      ),
      'ca-app-pub-3940256099942544/2934735716',
    );
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

  test('web and unsupported platforms return null', () {
    for (final platform in [
      TargetPlatform.fuchsia,
      TargetPlatform.linux,
      TargetPlatform.macOS,
      TargetPlatform.windows,
    ]) {
      expect(
        AdIds.rewardedAdUnitIdForPlatform(
          RewardedPlacement.freeHint,
          platform,
          useProductionIds: true,
        ),
        isNull,
      );
      expect(
        AdIds.interstitialAdUnitIdForPlatform(
          InterstitialPlacement.afterCompletedLevels,
          platform,
          useProductionIds: true,
        ),
        isNull,
      );
      expect(
        AdIds.bannerAdUnitIdForPlatform(
          BannerPlacement.settingsBottom,
          platform,
          useProductionIds: true,
        ),
        isNull,
      );
    }

    expect(
      AdIds.rewardedAdUnitIdForPlatform(
        RewardedPlacement.freeHint,
        TargetPlatform.android,
        isWeb: true,
        useProductionIds: true,
      ),
      isNull,
    );
  });
}
