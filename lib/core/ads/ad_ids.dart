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
  static const String _androidInterstitialLevelTransition =
      'ca-app-pub-5484820744037011/8600714161';

  static const String _testAndroidRewarded =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testAndroidInterstitial =
      'ca-app-pub-3940256099942544/1033173712';

  static bool get productionAdsEnabled => kReleaseMode && useProductionAds;

  static bool get isSupportedPlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static String? rewardedAdUnitId(RewardedPlacement placement) {
    if (!isSupportedPlatform) return null;
    if (!productionAdsEnabled) return _testAndroidRewarded;

    final id = switch (placement) {
      RewardedPlacement.freeHint => _androidRewardedHint,
      RewardedPlacement.retryAssistance => _androidRewardedContinue,
      RewardedPlacement.doubleCompletionCowries ||
      RewardedPlacement.freeRescueShuffle ||
      RewardedPlacement.bonusDailyChest ||
      RewardedPlacement.smallShopReward =>
        null,
    };
    return _validAdUnitId(id) ? id : null;
  }

  static String? interstitialAdUnitId(InterstitialPlacement placement) {
    if (!isSupportedPlatform) return null;
    if (!productionAdsEnabled) return _testAndroidInterstitial;

    final id = switch (placement) {
      InterstitialPlacement.afterCompletedLevels =>
        _androidInterstitialLevelTransition,
      InterstitialPlacement.returningHome ||
      InterstitialPlacement.beforeNewChapter =>
        null,
    };
    return _validAdUnitId(id) ? id : null;
  }

  static bool validateConfiguredIds() =>
      androidAppId.contains('~') &&
      _validAdUnitId(_androidRewardedHint) &&
      _validAdUnitId(_androidRewardedContinue) &&
      _validAdUnitId(_androidInterstitialLevelTransition) &&
      _validAdUnitId(_testAndroidRewarded) &&
      _validAdUnitId(_testAndroidInterstitial);

  static bool _validAdUnitId(String? id) => id != null && id.contains('/');
}
