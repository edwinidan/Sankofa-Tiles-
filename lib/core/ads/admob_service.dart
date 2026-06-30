import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../monetization/monetization_models.dart';
import '../utils/crash_reporting_service.dart';
import 'ad_ids.dart';
import 'consent_service.dart';

class AdMobService {
  static final AdMobService shared = AdMobService(
    consentService: ConsentService.shared,
  );

  AdMobService({
    ConsentService? consentService,
  }) : _consentService = consentService ?? ConsentService();

  final ConsentService _consentService;
  Future<bool>? _initializeFuture;

  Future<bool> initialize() {
    if (_initializeFuture != null) return _initializeFuture!;
    _initializeFuture = _initialize();
    return _initializeFuture!;
  }

  Future<bool> _initialize() async {
    if (!AdIds.isSupportedPlatform || !AdIds.validateConfiguredIds()) {
      return false;
    }

    final canRequestAds = await _consentService.gatherConsent();
    if (!canRequestAds) return false;

    try {
      await MobileAds.instance.initialize();
      return true;
    } catch (error, stackTrace) {
      CrashReportingService.recordNonFatal(
        error,
        stackTrace,
        reason: 'Google Mobile Ads initialization failed',
      );
      return false;
    }
  }

  Future<bool> showRewardedAd(RewardedPlacement placement) async {
    final adUnitId = AdIds.rewardedAdUnitId(placement);
    if (adUnitId == null || !await initialize()) return false;

    final loaded = Completer<RewardedAd?>();
    try {
      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: loaded.complete,
          onAdFailedToLoad: (error) {
            CrashReportingService.recordNonFatal(
              Exception('Rewarded ad failed to load: ${error.code}'),
              StackTrace.current,
              reason: 'Rewarded ad load failed for ${placement.name}',
            );
            loaded.complete(null);
          },
        ),
      );
    } catch (error, stackTrace) {
      CrashReportingService.recordNonFatal(
        error,
        stackTrace,
        reason: 'Rewarded ad load failed for ${placement.name}',
      );
      loaded.complete(null);
    }

    final ad = await loaded.future;
    if (ad == null) return false;

    final completed = Completer<bool>();
    var earnedReward = false;
    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completed.isCompleted) completed.complete(earnedReward);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        CrashReportingService.recordNonFatal(
          Exception('Rewarded ad failed to show: ${error.code}'),
          StackTrace.current,
          reason: 'Rewarded ad show failed for ${placement.name}',
        );
        if (!completed.isCompleted) completed.complete(false);
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (_, __) {
          earnedReward = true;
        },
      );
    } catch (error, stackTrace) {
      ad.dispose();
      CrashReportingService.recordNonFatal(
        error,
        stackTrace,
        reason: 'Rewarded ad show failed for ${placement.name}',
      );
      if (!completed.isCompleted) completed.complete(false);
    }
    return completed.future;
  }

  Future<bool> showInterstitialAd(InterstitialPlacement placement) async {
    final adUnitId = AdIds.interstitialAdUnitId(placement);
    if (adUnitId == null || !await initialize()) return false;

    final loaded = Completer<InterstitialAd?>();
    try {
      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: loaded.complete,
          onAdFailedToLoad: (error) {
            CrashReportingService.recordNonFatal(
              Exception('Interstitial ad failed to load: ${error.code}'),
              StackTrace.current,
              reason: 'Interstitial ad load failed for ${placement.name}',
            );
            loaded.complete(null);
          },
        ),
      );
    } catch (error, stackTrace) {
      CrashReportingService.recordNonFatal(
        error,
        stackTrace,
        reason: 'Interstitial ad load failed for ${placement.name}',
      );
      loaded.complete(null);
    }

    final ad = await loaded.future;
    if (ad == null) return false;

    final completed = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completed.isCompleted) completed.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        CrashReportingService.recordNonFatal(
          Exception('Interstitial ad failed to show: ${error.code}'),
          StackTrace.current,
          reason: 'Interstitial ad show failed for ${placement.name}',
        );
        if (!completed.isCompleted) completed.complete(false);
      },
    );

    try {
      await ad.show();
    } catch (error, stackTrace) {
      ad.dispose();
      CrashReportingService.recordNonFatal(
        error,
        stackTrace,
        reason: 'Interstitial ad show failed for ${placement.name}',
      );
      if (!completed.isCompleted) completed.complete(false);
    }
    return completed.future;
  }
}
