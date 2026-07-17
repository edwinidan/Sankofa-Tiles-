import 'package:flutter/foundation.dart';

import '../monetization/monetization_models.dart';

class AdIds {
  const AdIds._();

  static const bool useProductionAds = bool.fromEnvironment(
    'USE_PRODUCTION_ADS',
    defaultValue: false,
  );

  static const String androidAppId = 'ca-app-pub-5484820744037011~7670775878';

  static const String _androidRewardedHint =
      'ca-app-pub-5484820744037011/7155770551';
  static const String _androidRewardedContinue =
      'ca-app-pub-5484820744037011/4741360208';
  static const String _androidRewardedDoubleCompletionCowries =
      'ca-app-pub-5484820744037011/2775600473';
  static const String _androidRewardedFreeRescueShuffle =
      'ca-app-pub-5484820744037011/1462518800';
  static const String _androidRewardedBonusDailyChest =
      'ca-app-pub-5484820744037011/4557666995';
  static const String _androidRewardedSmallShopReward =
      'ca-app-pub-5484820744037011/4777158847';
  static const String _androidInterstitialLevelTransition =
      'ca-app-pub-5484820744037011/8600714161';
  static const String _androidSettingsBottomBanner =
      'ca-app-pub-5484820744037011/4876698366';

  static const String _iosRewardedHint =
      'ca-app-pub-5484820744037011/9228795350';
  static const String _iosRewardedContinue =
      'ca-app-pub-5484820744037011/4164170939';
  static const String _iosRewardedDoubleCompletionCowries =
      'ca-app-pub-5484820744037011/8151517400';
  static const String _iosRewardedFreeRescueShuffle =
      'ca-app-pub-5484820744037011/9356787868';
  static const String _iosRewardedBonusDailyChest =
      'ca-app-pub-5484820744037011/8137251130';
  static const String _iosRewardedSmallShopReward =
      'ca-app-pub-5484820744037011/8081410819';
  static const String _iosInterstitialLevelTransition =
      'ca-app-pub-5484820744037011/5477252602';
  static const String _iosSettingsBottomBanner =
      'ca-app-pub-5484820744037011/5646819163';

  static const String _testAndroidRewarded =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testAndroidInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testAndroidBanner =
      'ca-app-pub-3940256099942544/6300978111';

  static const String _testIosRewarded =
      'ca-app-pub-3940256099942544/1712485313';
  static const String _testIosInterstitial =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _testIosBanner = 'ca-app-pub-3940256099942544/2934735716';

  static bool get productionAdsEnabled => kReleaseMode || useProductionAds;

  static bool get isSupportedPlatform =>
      !kIsWeb && isSupportedTargetPlatform(defaultTargetPlatform);

  static bool isSupportedTargetPlatform(TargetPlatform platform) =>
      platform == TargetPlatform.android || platform == TargetPlatform.iOS;

  static String? rewardedAdUnitId(RewardedPlacement placement) {
    return rewardedAdUnitIdForPlatform(
      placement,
      defaultTargetPlatform,
      isWeb: kIsWeb,
      useProductionIds: productionAdsEnabled,
    );
  }

  static String? rewardedAdUnitIdForPlatform(
    RewardedPlacement placement,
    TargetPlatform platform, {
    required bool useProductionIds,
    bool isWeb = false,
  }) {
    if (isWeb || !isSupportedTargetPlatform(platform)) return null;
    if (!useProductionIds) return _testRewardedAdUnitId(platform);

    final id = switch (placement) {
      RewardedPlacement.freeHint => switch (platform) {
          TargetPlatform.android => _androidRewardedHint,
          TargetPlatform.iOS => _iosRewardedHint,
          _ => null,
        },
      RewardedPlacement.retryAssistance => switch (platform) {
          TargetPlatform.android => _androidRewardedContinue,
          TargetPlatform.iOS => _iosRewardedContinue,
          _ => null,
        },
      RewardedPlacement.doubleCompletionCowries => switch (platform) {
          TargetPlatform.android => _androidRewardedDoubleCompletionCowries,
          TargetPlatform.iOS => _iosRewardedDoubleCompletionCowries,
          _ => null,
        },
      RewardedPlacement.freeRescueShuffle => switch (platform) {
          TargetPlatform.android => _androidRewardedFreeRescueShuffle,
          TargetPlatform.iOS => _iosRewardedFreeRescueShuffle,
          _ => null,
        },
      RewardedPlacement.bonusDailyChest => switch (platform) {
          TargetPlatform.android => _androidRewardedBonusDailyChest,
          TargetPlatform.iOS => _iosRewardedBonusDailyChest,
          _ => null,
        },
      RewardedPlacement.smallShopReward => switch (platform) {
          TargetPlatform.android => _androidRewardedSmallShopReward,
          TargetPlatform.iOS => _iosRewardedSmallShopReward,
          _ => null,
        },
    };
    return _validAdUnitId(id) ? id : null;
  }

  static String? interstitialAdUnitId(InterstitialPlacement placement) {
    return interstitialAdUnitIdForPlatform(
      placement,
      defaultTargetPlatform,
      isWeb: kIsWeb,
      useProductionIds: productionAdsEnabled,
    );
  }

  static String? interstitialAdUnitIdForPlatform(
    InterstitialPlacement placement,
    TargetPlatform platform, {
    required bool useProductionIds,
    bool isWeb = false,
  }) {
    if (isWeb || !isSupportedTargetPlatform(platform)) return null;
    if (!useProductionIds) return _testInterstitialAdUnitId(platform);

    final id = switch (placement) {
      InterstitialPlacement.afterCompletedLevels => switch (platform) {
          TargetPlatform.android => _androidInterstitialLevelTransition,
          TargetPlatform.iOS => _iosInterstitialLevelTransition,
          _ => null,
        },
      InterstitialPlacement.returningHome ||
      InterstitialPlacement.beforeNewChapter =>
        null,
    };
    return _validAdUnitId(id) ? id : null;
  }

  static String? bannerAdUnitId(BannerPlacement placement) {
    return bannerAdUnitIdForPlatform(
      placement,
      defaultTargetPlatform,
      isWeb: kIsWeb,
      useProductionIds: productionAdsEnabled,
    );
  }

  static String? bannerAdUnitIdForPlatform(
    BannerPlacement placement,
    TargetPlatform platform, {
    required bool useProductionIds,
    bool isWeb = false,
  }) {
    if (isWeb || !isSupportedTargetPlatform(platform)) return null;
    if (!useProductionIds) return _testBannerAdUnitId(platform);

    final id = switch (placement) {
      BannerPlacement.settingsBottom => switch (platform) {
          TargetPlatform.android => _androidSettingsBottomBanner,
          TargetPlatform.iOS => _iosSettingsBottomBanner,
          _ => null,
        },
    };
    return _validAdUnitId(id) ? id : null;
  }

  static bool validateConfiguredIds() =>
      androidAppId.contains('~') &&
      _validAdUnitId(_androidRewardedHint) &&
      _validAdUnitId(_androidRewardedContinue) &&
      _validAdUnitId(_androidRewardedDoubleCompletionCowries) &&
      _validAdUnitId(_androidRewardedFreeRescueShuffle) &&
      _validAdUnitId(_androidRewardedBonusDailyChest) &&
      _validAdUnitId(_androidRewardedSmallShopReward) &&
      _validAdUnitId(_androidInterstitialLevelTransition) &&
      _validAdUnitId(_androidSettingsBottomBanner) &&
      _validAdUnitId(_iosRewardedHint) &&
      _validAdUnitId(_iosRewardedContinue) &&
      _validAdUnitId(_iosRewardedDoubleCompletionCowries) &&
      _validAdUnitId(_iosRewardedFreeRescueShuffle) &&
      _validAdUnitId(_iosRewardedBonusDailyChest) &&
      _validAdUnitId(_iosRewardedSmallShopReward) &&
      _validAdUnitId(_iosInterstitialLevelTransition) &&
      _validAdUnitId(_iosSettingsBottomBanner) &&
      _validAdUnitId(_testAndroidRewarded) &&
      _validAdUnitId(_testAndroidInterstitial) &&
      _validAdUnitId(_testAndroidBanner) &&
      _validAdUnitId(_testIosRewarded) &&
      _validAdUnitId(_testIosInterstitial) &&
      _validAdUnitId(_testIosBanner);

  static String? _testRewardedAdUnitId(TargetPlatform platform) =>
      switch (platform) {
        TargetPlatform.android => _testAndroidRewarded,
        TargetPlatform.iOS => _testIosRewarded,
        _ => null,
      };

  static String? _testInterstitialAdUnitId(TargetPlatform platform) =>
      switch (platform) {
        TargetPlatform.android => _testAndroidInterstitial,
        TargetPlatform.iOS => _testIosInterstitial,
        _ => null,
      };

  static String? _testBannerAdUnitId(TargetPlatform platform) =>
      switch (platform) {
        TargetPlatform.android => _testAndroidBanner,
        TargetPlatform.iOS => _testIosBanner,
        _ => null,
      };

  static bool _validAdUnitId(String? id) => id != null && id.contains('/');
}
