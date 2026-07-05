import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/ads/admob_service.dart';
import '../core/monetization/monetization_models.dart';
import '../core/monetization/monetization_service.dart';
import '../core/utils/analytics_service.dart';
import 'admob_provider.dart';
import 'economy_provider.dart';
import 'settings_provider.dart';

final monetizationServiceProvider = Provider<MonetizationService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final economy = ref.watch(economyServiceProvider);
  return MonetizationService(storage, economy);
});

final monetizationProvider =
    StateNotifierProvider<MonetizationNotifier, MonetizationState>((ref) {
  final service = ref.watch(monetizationServiceProvider);
  final adMobService = ref.watch(adMobServiceProvider);
  return MonetizationNotifier(service, adMobService, ref);
});

class MonetizationNotifier extends StateNotifier<MonetizationState> {
  MonetizationNotifier(this._service, this._adMobService, this._ref)
      : super(_service.loadState());

  final MonetizationService _service;
  final AdMobService _adMobService;
  final Ref _ref;
  final Set<RewardedPlacement> _rewardedRequestsInProgress = {};

  void refresh() {
    state = _service.loadState().copyWith(
          purchaseStatus: state.purchaseStatus,
          activeProductId: state.activeProductId,
          lastMessage: state.lastMessage,
        );
  }

  void viewShopSection(ShopSection section) {
    AnalyticsService.logShopViewed(section.name);
  }

  void viewProduct(String productId) {
    AnalyticsService.logProductViewed(productId);
  }

  RewardedAdAvailability rewardedAdAvailability(
    RewardedPlacement placement, {
    String? claimKey,
  }) {
    return _service.rewardedAdAvailability(
      placement,
      claimKey: claimKey,
    );
  }

  Future<PurchaseResult> purchaseProduct(
    String productId, {
    PurchaseStatus simulatedStatus = PurchaseStatus.success,
  }) async {
    AnalyticsService.logPurchaseAttempt(productId);
    state = state.copyWith(
      purchaseStatus: PurchaseStatus.pending,
      activeProductId: productId,
      lastMessage: 'Purchase pending...',
    );
    final result = await _service.purchaseProduct(
      productId,
      transactionId:
          'purchase:$productId:${DateTime.now().microsecondsSinceEpoch}',
      simulatedStatus: simulatedStatus,
    );
    if (result.status == PurchaseStatus.success) {
      AnalyticsService.logPurchaseSuccess(productId);
      if (result.reward.entitlementIds
          .contains(MonetizationEntitlements.removeAds)) {
        AnalyticsService.logRemoveAdsEntitlement(true, 'purchase');
      }
    } else if (result.status == PurchaseStatus.cancelled) {
      AnalyticsService.logPurchaseFailure(productId, 'cancelled');
    } else {
      AnalyticsService.logPurchaseFailure(productId, result.status.name);
    }
    _ref.read(economyProvider.notifier).refresh();
    state = _service.loadState().copyWith(
          purchaseStatus: result.status,
          activeProductId: productId,
          lastMessage: result.message,
        );
    return result;
  }

  Future<RestoreResult> restorePurchases() async {
    state = state.copyWith(
      purchaseStatus: PurchaseStatus.restoring,
      clearActiveProductId: true,
      lastMessage: 'Restoring purchases...',
    );
    final result = await _service.restorePurchases();
    AnalyticsService.logRestorePurchases(
      result.status.name,
      result.restoredCount,
    );
    if (result.restoredCount > 0) {
      AnalyticsService.logRemoveAdsEntitlement(
        state.removeAdsActive,
        'restore',
      );
    }
    state = _service.loadState().copyWith(
          purchaseStatus: result.status,
          lastMessage: result.message,
          clearActiveProductId: true,
        );
    return result;
  }

  Future<RewardedAdResult> completeRewardedAd({
    required RewardedPlacement placement,
    String? claimKey,
    int baseCowries = 0,
    bool completed = true,
  }) async {
    if (_rewardedRequestsInProgress.contains(placement)) {
      AnalyticsService.logRewardedAdRequestBlocked(
        placement.name,
        'already_in_progress',
      );
      state = state.copyWith(
        purchaseStatus: PurchaseStatus.loading,
        lastMessage: '${placement.label} ad is already loading.',
      );
      return RewardedAdResult(
        status: PurchaseStatus.loading,
        message: '${placement.label} ad is already loading.',
      );
    }

    final availability = _service.rewardedAdAvailability(
      placement,
      claimKey: claimKey,
    );
    if (!availability.canRequest) {
      _logRewardedLimit(placement, availability.reason);
      state = _service.loadState().copyWith(
            purchaseStatus: PurchaseStatus.unavailable,
            lastMessage: _blockedRewardMessage(placement, availability.reason),
            clearActiveProductId: true,
          );
      return RewardedAdResult(
        status: PurchaseStatus.unavailable,
        message: _blockedRewardMessage(placement, availability.reason),
      );
    }

    _rewardedRequestsInProgress.add(placement);
    state = state.copyWith(
      purchaseStatus: PurchaseStatus.loading,
      lastMessage: 'Loading ${placement.label} ad...',
    );
    AnalyticsService.logRewardedAdRequested(placement.name);
    try {
      final adCompleted = await _adMobService.showRewardedAd(placement);
      final result = await _service.completeRewardedAd(
        placement: placement,
        callbackId:
            'rewarded:${placement.name}:${DateTime.now().microsecondsSinceEpoch}',
        claimKey: claimKey,
        baseCowries: baseCowries,
        completed: completed && adCompleted,
      );
      if (result.status == PurchaseStatus.success) {
        AnalyticsService.logRewardedAdCompleted(placement.name);
        _logRewardedSuccess(placement);
      } else {
        AnalyticsService.logRewardedAdFailed(
          placement.name,
          result.status.name,
        );
        if (result.status == PurchaseStatus.unavailable) {
          _logRewardedLimit(
            placement,
            _service
                .rewardedAdAvailability(placement, claimKey: claimKey)
                .reason,
          );
        }
      }
      _ref.read(economyProvider.notifier).refresh();
      state = _service.loadState().copyWith(
            purchaseStatus: result.status,
            lastMessage: result.message,
            clearActiveProductId: true,
          );
      return result;
    } finally {
      _rewardedRequestsInProgress.remove(placement);
    }
  }

  void _logRewardedSuccess(RewardedPlacement placement) {
    if (placement == RewardedPlacement.smallShopReward) {
      final availability =
          _service.rewardedAdAvailability(RewardedPlacement.smallShopReward);
      final limit = availability.limit ?? 0;
      final remaining = availability.remaining ?? 0;
      AnalyticsService.logShopGiftClaimCount(limit - remaining, limit);
    }
  }

  void _logRewardedLimit(RewardedPlacement placement, String? reason) {
    AnalyticsService.logRewardedAdLimitReached(
      placement.name,
      reason ?? 'unavailable',
    );
    switch (placement) {
      case RewardedPlacement.bonusDailyChest:
        AnalyticsService.logDailyRewardAdAlreadyClaimed();
        break;
      case RewardedPlacement.smallShopReward:
        final availability =
            _service.rewardedAdAvailability(RewardedPlacement.smallShopReward);
        final limit = availability.limit ?? 0;
        AnalyticsService.logShopGiftClaimCount(limit, limit);
        break;
      case RewardedPlacement.doubleCompletionCowries:
        AnalyticsService.logDoubleCowriesAlreadyClaimed();
        break;
      case RewardedPlacement.retryAssistance:
        AnalyticsService.logRetryAssistanceAlreadyUsed();
        break;
      case RewardedPlacement.freeHint:
      case RewardedPlacement.freeRescueShuffle:
        break;
    }
  }

  String _blockedRewardMessage(RewardedPlacement placement, String? reason) {
    return switch (reason) {
      'daily_bonus_already_claimed' =>
        'Daily Bonus Chest already claimed today.',
      'daily_limit_reached' => 'Daily limit reached for this reward.',
      'double_cowries_already_claimed' =>
        'Cowries already doubled for this result.',
      'retry_assistance_already_used' =>
        'Retry Assistance already used for this attempt.',
      _ => '${placement.label} is unavailable.',
    };
  }

  Future<InterstitialDecision> recordLevelWinAndMaybeShowInterstitial({
    bool isFirstSession = false,
    bool tutorialActive = false,
    bool afterLoss = false,
  }) async {
    await recordCompletedLevelForInterstitial();
    return maybeShowCompletedLevelInterstitial(
      isFirstSession: isFirstSession,
      tutorialActive: tutorialActive,
      afterLoss: afterLoss,
    );
  }

  Future<void> recordCompletedLevelForInterstitial() async {
    await _service.recordLevelCompletedForInterstitial();
  }

  Future<InterstitialDecision> maybeShowCompletedLevelInterstitial({
    bool isFirstSession = false,
    bool tutorialActive = false,
    bool afterLoss = false,
  }) async {
    final decision = _service.interstitialDecision(
      placement: InterstitialPlacement.afterCompletedLevels,
      isFirstSession: isFirstSession,
      tutorialActive: tutorialActive,
      afterLoss: afterLoss,
    );
    if (decision.canShow) {
      final shown = await _adMobService.showInterstitialAd(
        InterstitialPlacement.afterCompletedLevels,
      );
      if (shown) {
        await _service.markInterstitialShown(
          placement: InterstitialPlacement.afterCompletedLevels,
          isFirstSession: isFirstSession,
          tutorialActive: tutorialActive,
          afterLoss: afterLoss,
        );
        AnalyticsService.logInterstitialShown(
          InterstitialPlacement.afterCompletedLevels.name,
        );
      } else {
        AnalyticsService.logInterstitialSkipped(
          InterstitialPlacement.afterCompletedLevels.name,
          'ad_unavailable',
        );
        return const InterstitialDecision(
          canShow: false,
          reason: 'ad_unavailable',
        );
      }
    } else {
      AnalyticsService.logInterstitialSkipped(
        InterstitialPlacement.afterCompletedLevels.name,
        decision.reason,
      );
    }
    return decision;
  }
}
