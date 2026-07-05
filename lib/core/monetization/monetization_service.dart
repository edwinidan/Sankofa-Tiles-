import '../economy/economy_service.dart';
import '../utils/storage_service.dart';
import 'monetization_config.dart';
import 'monetization_models.dart';

class PurchaseResult {
  const PurchaseResult({
    required this.status,
    required this.message,
    this.reward = const MonetizationReward(),
  });

  final PurchaseStatus status;
  final String message;
  final MonetizationReward reward;
}

class RestoreResult {
  const RestoreResult({
    required this.status,
    required this.restoredCount,
    required this.message,
  });

  final PurchaseStatus status;
  final int restoredCount;
  final String message;
}

class MonetizationService {
  MonetizationService(
    this._storage,
    this._economy, {
    bool offline = false,
    bool productsAvailable = true,
  })  : _offline = offline,
        _productsAvailable = productsAvailable;

  final StorageService _storage;
  final EconomyService _economy;
  bool _offline;
  bool _productsAvailable;

  MonetizationState loadState() {
    return MonetizationState(
      environment: MonetizationConfig.environment,
      products: _productsAvailable ? MonetizationConfig.products : const [],
      entitlementIds: _storage.getMonetizationEntitlementIds(),
      ownedProductIds: _storage.getMonetizationPurchaseIds(),
      rewardedAvailability: {
        for (final placement in RewardedPlacement.values)
          placement: rewardedAdAvailability(placement),
      },
      purchaseStatus:
          _productsAvailable ? PurchaseStatus.idle : PurchaseStatus.unavailable,
      lastMessage:
          _productsAvailable ? null : 'Products are currently unavailable.',
      offline: _offline,
      productsLoaded: _productsAvailable,
    );
  }

  void setOfflineForTesting(bool value) {
    _offline = value;
  }

  void setProductsAvailableForTesting(bool value) {
    _productsAvailable = value;
  }

  ShopProduct? productById(String productId) {
    for (final product in MonetizationConfig.products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  Future<PurchaseResult> purchaseProduct(
    String productId, {
    String? transactionId,
    PurchaseStatus simulatedStatus = PurchaseStatus.success,
  }) async {
    if (_offline) {
      return const PurchaseResult(
        status: PurchaseStatus.offline,
        message: 'Purchases are unavailable while offline.',
      );
    }
    if (!_productsAvailable) {
      return const PurchaseResult(
        status: PurchaseStatus.unavailable,
        message: 'Store products could not be loaded.',
      );
    }
    final product = productById(productId);
    if (product == null || !product.available) {
      return const PurchaseResult(
        status: PurchaseStatus.unavailable,
        message: 'This product is unavailable.',
      );
    }
    if (product.oneTime && _storage.hasMonetizationPurchase(product.id)) {
      return const PurchaseResult(
        status: PurchaseStatus.alreadyOwned,
        message: 'You already own this item.',
      );
    }
    if (simulatedStatus == PurchaseStatus.cancelled) {
      return const PurchaseResult(
        status: PurchaseStatus.cancelled,
        message: 'Purchase cancelled.',
      );
    }
    if (simulatedStatus == PurchaseStatus.failed) {
      return const PurchaseResult(
        status: PurchaseStatus.failed,
        message: 'Purchase failed. Nothing was granted.',
      );
    }
    if (simulatedStatus == PurchaseStatus.verificationPending) {
      return const PurchaseResult(
        status: PurchaseStatus.verificationPending,
        message: 'Purchase verification is pending.',
      );
    }

    final callbackId = transactionId ?? 'purchase:${product.id}';
    final granted = await _grantReward(
      product.reward,
      reason: 'purchase',
      transactionId: callbackId,
    );
    if (!granted && product.type == ProductType.consumable) {
      return const PurchaseResult(
        status: PurchaseStatus.alreadyOwned,
        message: 'This purchase callback was already handled.',
      );
    }

    if (product.oneTime || product.type != ProductType.consumable) {
      await _storage.recordMonetizationPurchase(product.id);
    }

    return PurchaseResult(
      status: PurchaseStatus.success,
      message: '${product.title} added.',
      reward: product.reward,
    );
  }

  Future<RestoreResult> restorePurchases() async {
    if (_offline) {
      return const RestoreResult(
        status: PurchaseStatus.offline,
        restoredCount: 0,
        message: 'Restore is unavailable while offline.',
      );
    }

    var restored = 0;
    for (final productId in _storage.getMonetizationPurchaseIds()) {
      final product = productById(productId);
      if (product == null) continue;
      if (product.type == ProductType.consumable) continue;
      for (final entitlementId in product.reward.entitlementIds) {
        if (!_storage.hasMonetizationEntitlement(entitlementId)) {
          await _storage.setMonetizationEntitlement(entitlementId);
          restored += 1;
        }
      }
    }

    if (restored == 0) {
      return const RestoreResult(
        status: PurchaseStatus.nothingToRestore,
        restoredCount: 0,
        message: 'No restorable purchases were found.',
      );
    }
    return RestoreResult(
      status: PurchaseStatus.restored,
      restoredCount: restored,
      message: 'Restored $restored purchase entitlement(s).',
    );
  }

  Future<RewardedAdResult> completeRewardedAd({
    required RewardedPlacement placement,
    required String callbackId,
    String? claimKey,
    int baseCowries = 0,
    bool completed = true,
    DateTime? now,
  }) async {
    if (_offline) {
      return const RewardedAdResult(
        status: PurchaseStatus.offline,
        message: 'Ad unavailable while offline.',
      );
    }
    if (_storage.hasMonetizationCallback(callbackId)) {
      return const RewardedAdResult(
        status: PurchaseStatus.alreadyOwned,
        message: 'Reward already granted.',
      );
    }
    final availability = rewardedAdAvailability(
      placement,
      claimKey: claimKey,
      now: now,
    );
    if (!availability.canRequest) {
      return RewardedAdResult(
        status: PurchaseStatus.unavailable,
        message: _limitMessage(placement, availability.reason),
      );
    }
    if (!completed) {
      return const RewardedAdResult(
        status: PurchaseStatus.cancelled,
        message: 'Ad was not completed.',
      );
    }

    final reward = MonetizationConfig.rewardedReward(
      placement,
      baseCowries: baseCowries,
    );
    await _grantReward(
      reward,
      reason: 'rewarded_ad_${placement.name}',
      transactionId: 'rewarded:$callbackId',
    );
    await _storage.recordMonetizationCallback(callbackId);
    await _recordRewardedClaim(
      placement,
      claimKey: claimKey,
      now: now,
    );
    await _storage.setLastRewardedAdAt(DateTime.now());
    return RewardedAdResult(
      status: PurchaseStatus.success,
      summary: reward,
      message: '${placement.label} reward granted.',
    );
  }

  RewardedAdAvailability rewardedAdAvailability(
    RewardedPlacement placement, {
    String? claimKey,
    DateTime? now,
  }) {
    final dateKey = _dateKey(now ?? DateTime.now());
    return switch (placement) {
      RewardedPlacement.bonusDailyChest => _dailyAvailability(
          placement,
          dateKey,
          limit: MonetizationConfig.bonusDailyChestDailyLimit,
          availableLabel: 'Watch Ad',
          limitLabel: 'Already Claimed',
          limitReason: 'daily_bonus_already_claimed',
        ),
      RewardedPlacement.smallShopReward => _dailyAvailability(
          placement,
          dateKey,
          limit: MonetizationConfig.smallShopRewardDailyLimit,
          availableLabel: 'Watch Ad',
          limitLabel: 'Daily Limit Reached',
          limitReason: 'daily_limit_reached',
        ),
      RewardedPlacement.doubleCompletionCowries => _claimAvailability(
          claimKey,
          availableLabel: 'Watch Ad',
          limitLabel: 'Already Claimed',
          limitReason: 'double_cowries_already_claimed',
        ),
      RewardedPlacement.retryAssistance => _claimAvailability(
          claimKey,
          availableLabel: 'Watch Ad',
          limitLabel: 'Already Claimed',
          limitReason: 'retry_assistance_already_used',
        ),
      RewardedPlacement.freeHint ||
      RewardedPlacement.freeRescueShuffle =>
        const RewardedAdAvailability(
          canRequest: true,
          label: 'Watch Ad',
        ),
    };
  }

  RewardedAdAvailability _dailyAvailability(
    RewardedPlacement placement,
    String dateKey, {
    required int limit,
    required String availableLabel,
    required String limitLabel,
    required String limitReason,
  }) {
    final used = _storage.getRewardedDailyClaimCount(placement.name, dateKey);
    final remaining = (limit - used).clamp(0, limit);
    if (remaining <= 0) {
      return RewardedAdAvailability(
        canRequest: false,
        label: limitLabel,
        remaining: 0,
        limit: limit,
        reason: limitReason,
      );
    }
    return RewardedAdAvailability(
      canRequest: true,
      label: availableLabel,
      remaining: remaining,
      limit: limit,
    );
  }

  RewardedAdAvailability _claimAvailability(
    String? claimKey, {
    required String availableLabel,
    required String limitLabel,
    required String limitReason,
  }) {
    if (claimKey != null && _storage.hasRewardedClaim(claimKey)) {
      return RewardedAdAvailability(
        canRequest: false,
        label: limitLabel,
        reason: limitReason,
      );
    }
    return RewardedAdAvailability(canRequest: true, label: availableLabel);
  }

  Future<void> _recordRewardedClaim(
    RewardedPlacement placement, {
    String? claimKey,
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();
    switch (placement) {
      case RewardedPlacement.bonusDailyChest:
      case RewardedPlacement.smallShopReward:
        final dateKey = _dateKey(timestamp);
        await _storage.setRewardedDailyClaimCount(
          placement.name,
          dateKey,
          _storage.getRewardedDailyClaimCount(placement.name, dateKey) + 1,
        );
        break;
      case RewardedPlacement.doubleCompletionCowries:
      case RewardedPlacement.retryAssistance:
        if (claimKey != null) {
          await _storage.recordRewardedClaim(claimKey);
        }
        break;
      case RewardedPlacement.freeHint:
      case RewardedPlacement.freeRescueShuffle:
        break;
    }
  }

  String _limitMessage(RewardedPlacement placement, String? reason) {
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

  String _dateKey(DateTime date) {
    final local = date.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  InterstitialDecision interstitialDecision({
    required InterstitialPlacement placement,
    required bool isFirstSession,
    required bool tutorialActive,
    required bool afterLoss,
    DateTime? now,
  }) {
    if (_storage
        .hasMonetizationEntitlement(MonetizationEntitlements.removeAds)) {
      return const InterstitialDecision(
        canShow: false,
        reason: 'remove_ads',
      );
    }
    if (isFirstSession) {
      return const InterstitialDecision(
        canShow: false,
        reason: 'first_session',
      );
    }
    if (tutorialActive) {
      return const InterstitialDecision(
        canShow: false,
        reason: 'tutorial',
      );
    }
    if (afterLoss) {
      return const InterstitialDecision(
        canShow: false,
        reason: 'after_loss',
      );
    }
    if (_storage.getInterstitialSessionCount() >=
        MonetizationConfig.sessionInterstitialCap) {
      return const InterstitialDecision(
        canShow: false,
        reason: 'session_cap',
      );
    }
    if (_storage.getHighestCompletedLevel() <
        MonetizationConfig.minimumCompletedLevels) {
      return const InterstitialDecision(
        canShow: false,
        reason: 'minimum_completed_levels',
      );
    }
    if (_storage.getInterstitialCompletedSinceLast() <
        MonetizationConfig.completedLevelFrequency) {
      return const InterstitialDecision(
        canShow: false,
        reason: 'level_frequency',
      );
    }

    final timestamp = now ?? DateTime.now();
    final lastInterstitial = _storage.getLastInterstitialAt();
    if (lastInterstitial != null &&
        timestamp.difference(lastInterstitial) <
            MonetizationConfig.interstitialCooldown) {
      return const InterstitialDecision(
        canShow: false,
        reason: 'interstitial_cooldown',
      );
    }
    final lastRewarded = _storage.getLastRewardedAdAt();
    if (lastRewarded != null &&
        timestamp.difference(lastRewarded) <
            MonetizationConfig.rewardedAdCooldown) {
      return const InterstitialDecision(
        canShow: false,
        reason: 'rewarded_cooldown',
      );
    }

    return const InterstitialDecision(canShow: true, reason: 'eligible');
  }

  Future<void> recordLevelCompletedForInterstitial() async {
    await _storage.setInterstitialCompletedSinceLast(
      _storage.getInterstitialCompletedSinceLast() + 1,
    );
  }

  Future<InterstitialDecision> markInterstitialShown({
    required InterstitialPlacement placement,
    required bool isFirstSession,
    required bool tutorialActive,
    required bool afterLoss,
    DateTime? now,
  }) async {
    final decision = interstitialDecision(
      placement: placement,
      isFirstSession: isFirstSession,
      tutorialActive: tutorialActive,
      afterLoss: afterLoss,
      now: now,
    );
    if (!decision.canShow) return decision;
    final timestamp = now ?? DateTime.now();
    await _storage.setLastInterstitialAt(timestamp);
    await _storage.setInterstitialSessionCount(
      _storage.getInterstitialSessionCount() + 1,
    );
    await _storage.setInterstitialCompletedSinceLast(0);
    return decision;
  }

  Future<bool> _grantReward(
    MonetizationReward reward, {
    required String reason,
    required String transactionId,
  }) async {
    if (_storage.hasMonetizationCallback(transactionId)) return false;

    var granted = false;
    if (reward.cowries > 0) {
      final added = await _economy.addCowries(
        reward.cowries,
        reason: reason,
        transactionId: '$transactionId:cowries',
      );
      granted = granted || added;
    }
    for (final entry in reward.boosters.entries) {
      final added = await _economy.addBooster(
        entry.key,
        entry.value,
        reason: reason,
        transactionId: '$transactionId:${entry.key.name}',
      );
      granted = granted || added;
    }
    for (final entitlementId in reward.entitlementIds) {
      if (!_storage.hasMonetizationEntitlement(entitlementId)) {
        await _storage.setMonetizationEntitlement(entitlementId);
        granted = true;
      }
    }
    for (final cosmeticId in reward.cosmeticIds) {
      if (!_storage.hasMonetizationEntitlement(cosmeticId)) {
        await _storage.setMonetizationEntitlement(cosmeticId);
        granted = true;
      }
    }
    await _storage.recordMonetizationCallback(transactionId);
    return granted;
  }
}
