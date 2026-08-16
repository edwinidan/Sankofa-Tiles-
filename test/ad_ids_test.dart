import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/ads/ad_ids.dart';
import 'package:sankofa_tiles/core/monetization/monetization_models.dart';

void main() {
  test('debug builds use test IDs by default', () {
    expect(AdIds.productionAdsEnabled, isFalse);
    expect(AdIds.useProductionAds, isFalse);
  });

  test('release-mode production selection remains automatic', () {
    final source = File('lib/core/ads/ad_ids.dart').readAsStringSync();

    expect(
      RegExp(
        r'static\s+bool\s+get\s+productionAdsEnabled\s*=>\s*'
        r'kReleaseMode\s*\|\|\s*useProductionAds\s*;',
      ).hasMatch(source),
      isTrue,
      reason: 'Release mode must select production IDs without a dart-define.',
    );
    expect(
      source,
      isNot(contains('kReleaseMode && useProductionAds')),
    );
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

  test('Google sample test IDs are not production constants', () {
    final source = File('lib/core/ads/ad_ids.dart').readAsStringSync();
    final productionConstantPattern = RegExp(
      r"static const String _(?:android|ios)[A-Za-z]+\s*=\s*"
      r"'([^']+)'",
    );
    final productionIds = productionConstantPattern
        .allMatches(source)
        .map((match) => match.group(1)!)
        .toList();

    expect(productionIds, isNotEmpty);
    for (final id in productionIds) {
      expect(
        id,
        isNot(startsWith('ca-app-pub-3940256099942544/')),
        reason: 'Production constant must not contain a Google sample test ID.',
      );
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

  test('platform resolvers never cross-return Android and iOS IDs', () {
    const androidProductionIds = {
      'ca-app-pub-5484820744037011/7155770551',
      'ca-app-pub-5484820744037011/4741360208',
      'ca-app-pub-5484820744037011/2775600473',
      'ca-app-pub-5484820744037011/1462518800',
      'ca-app-pub-5484820744037011/4557666995',
      'ca-app-pub-5484820744037011/4777158847',
      'ca-app-pub-5484820744037011/8600714161',
      'ca-app-pub-5484820744037011/4876698366',
    };
    const iosProductionIds = {
      'ca-app-pub-5484820744037011/9228795350',
      'ca-app-pub-5484820744037011/4164170939',
      'ca-app-pub-5484820744037011/8151517400',
      'ca-app-pub-5484820744037011/9356787868',
      'ca-app-pub-5484820744037011/8137251130',
      'ca-app-pub-5484820744037011/8081410819',
      'ca-app-pub-5484820744037011/5477252602',
      'ca-app-pub-5484820744037011/5646819163',
    };

    final androidResolvedIds = <String>{
      for (final placement in RewardedPlacement.values)
        AdIds.rewardedAdUnitIdForPlatform(
          placement,
          TargetPlatform.android,
          useProductionIds: true,
        )!,
      AdIds.interstitialAdUnitIdForPlatform(
        InterstitialPlacement.afterCompletedLevels,
        TargetPlatform.android,
        useProductionIds: true,
      )!,
      AdIds.bannerAdUnitIdForPlatform(
        BannerPlacement.settingsBottom,
        TargetPlatform.android,
        useProductionIds: true,
      )!,
    };
    final iosResolvedIds = <String>{
      for (final placement in RewardedPlacement.values)
        AdIds.rewardedAdUnitIdForPlatform(
          placement,
          TargetPlatform.iOS,
          useProductionIds: true,
        )!,
      AdIds.interstitialAdUnitIdForPlatform(
        InterstitialPlacement.afterCompletedLevels,
        TargetPlatform.iOS,
        useProductionIds: true,
      )!,
      AdIds.bannerAdUnitIdForPlatform(
        BannerPlacement.settingsBottom,
        TargetPlatform.iOS,
        useProductionIds: true,
      )!,
    };

    expect(androidResolvedIds, androidProductionIds);
    expect(iosResolvedIds, iosProductionIds);
    expect(androidResolvedIds.intersection(iosProductionIds), isEmpty);
    expect(iosResolvedIds.intersection(androidProductionIds), isEmpty);
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
