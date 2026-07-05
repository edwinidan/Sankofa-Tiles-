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
  bool _initialized = false;
  final Map<InterstitialPlacement, InterstitialAd> _interstitialAds = {};
  final Map<InterstitialPlacement, DateTime> _interstitialLoadedAt = {};
  final Map<InterstitialPlacement, Future<void>> _interstitialLoadFutures = {};
  static const Duration _interstitialMaxCacheAge = Duration(minutes: 55);

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
      _initialized = true;
      unawaited(
          preloadInterstitialAd(InterstitialPlacement.afterCompletedLevels));
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

  Future<void> preloadInterstitialAd(InterstitialPlacement placement) async {
    final adUnitId = AdIds.interstitialAdUnitId(placement);
    if (adUnitId == null || !await initialize()) return;
    await _loadInterstitialAd(placement, adUnitId);
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
    if (adUnitId == null) return false;
    if (!_initialized) {
      unawaited(initialize());
      return false;
    }

    final ad = _takeReadyInterstitial(placement);
    if (ad == null) {
      unawaited(_loadInterstitialAd(placement, adUnitId));
      return false;
    }

    final completed = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(_loadInterstitialAd(placement, adUnitId));
        if (!completed.isCompleted) completed.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        unawaited(_loadInterstitialAd(placement, adUnitId));
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
      unawaited(_loadInterstitialAd(placement, adUnitId));
      CrashReportingService.recordNonFatal(
        error,
        stackTrace,
        reason: 'Interstitial ad show failed for ${placement.name}',
      );
      if (!completed.isCompleted) completed.complete(false);
    }
    return completed.future;
  }

  InterstitialAd? _takeReadyInterstitial(InterstitialPlacement placement) {
    final ad = _interstitialAds.remove(placement);
    final loadedAt = _interstitialLoadedAt.remove(placement);
    if (ad == null || loadedAt == null) return null;
    if (DateTime.now().difference(loadedAt) <= _interstitialMaxCacheAge) {
      return ad;
    }
    ad.dispose();
    return null;
  }

  Future<void> _loadInterstitialAd(
    InterstitialPlacement placement,
    String adUnitId,
  ) {
    final existing = _interstitialLoadFutures[placement];
    if (existing != null) return existing;
    final current = _loadInterstitialAdOnce(placement, adUnitId);
    _interstitialLoadFutures[placement] = current;
    return current.whenComplete(() {
      _interstitialLoadFutures.remove(placement);
    });
  }

  Future<void> _loadInterstitialAdOnce(
    InterstitialPlacement placement,
    String adUnitId,
  ) async {
    final previousAd = _interstitialAds[placement];
    final previousLoadedAt = _interstitialLoadedAt[placement];
    if (previousAd != null &&
        previousLoadedAt != null &&
        DateTime.now().difference(previousLoadedAt) <=
            _interstitialMaxCacheAge) {
      return;
    }
    if (previousAd != null) {
      _interstitialAds.remove(placement);
      _interstitialLoadedAt.remove(placement);
      previousAd.dispose();
    }

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
      if (!loaded.isCompleted) loaded.complete(null);
    }

    final ad = await loaded.future;
    if (ad == null) return;
    _interstitialAds[placement]?.dispose();
    _interstitialAds[placement] = ad;
    _interstitialLoadedAt[placement] = DateTime.now();
  }
}
