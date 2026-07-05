import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/core/economy/economy_models.dart';
import 'package:sankofa_tiles/core/economy/economy_service.dart';
import 'package:sankofa_tiles/core/monetization/monetization_config.dart';
import 'package:sankofa_tiles/core/monetization/monetization_models.dart';
import 'package:sankofa_tiles/core/monetization/monetization_service.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';

Future<StorageService> _storage(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final storage = StorageService();
  await storage.init();
  return storage;
}

MonetizationService _service(
  StorageService storage, {
  bool offline = false,
  bool productsAvailable = true,
}) {
  return MonetizationService(
    storage,
    EconomyService(storage),
    offline: offline,
    productsAvailable: productsAvailable,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('purchase success grants consumable rewards once per callback',
      () async {
    final storage = await _storage({});
    final service = _service(storage);

    final first = await service.purchaseProduct(
      ProductIds.hintPack,
      transactionId: 'store_tx_1',
    );
    final duplicate = await service.purchaseProduct(
      ProductIds.hintPack,
      transactionId: 'store_tx_1',
    );

    expect(first.status, PurchaseStatus.success);
    expect(duplicate.status, PurchaseStatus.alreadyOwned);
    expect(storage.getBooster(BoosterType.hint), 8);
  });

  test('purchase cancellation and failure do not grant value', () async {
    final storage = await _storage({});
    final service = _service(storage);

    final cancelled = await service.purchaseProduct(
      ProductIds.smallCowries,
      transactionId: 'store_tx_cancelled',
      simulatedStatus: PurchaseStatus.cancelled,
    );
    final failed = await service.purchaseProduct(
      ProductIds.smallCowries,
      transactionId: 'store_tx_failed',
      simulatedStatus: PurchaseStatus.failed,
    );

    expect(cancelled.status, PurchaseStatus.cancelled);
    expect(failed.status, PurchaseStatus.failed);
    expect(storage.getCowries(), 0);
  });

  test('one-time products become already owned after purchase', () async {
    final storage = await _storage({});
    final service = _service(storage);

    final first = await service.purchaseProduct(
      ProductIds.removeAds,
      transactionId: 'remove_ads_tx',
    );
    final second = await service.purchaseProduct(
      ProductIds.removeAds,
      transactionId: 'remove_ads_tx_2',
    );

    expect(first.status, PurchaseStatus.success);
    expect(second.status, PurchaseStatus.alreadyOwned);
    expect(
      storage.hasMonetizationEntitlement(MonetizationEntitlements.removeAds),
      isTrue,
    );
  });

  test('restore recreates permanent entitlements from owned products',
      () async {
    final storage = await _storage({
      'monetization_purchase_remove_ads': true,
    });
    final service = _service(storage);

    final result = await service.restorePurchases();

    expect(result.status, PurchaseStatus.restored);
    expect(result.restoredCount, 1);
    expect(
      storage.hasMonetizationEntitlement(MonetizationEntitlements.removeAds),
      isTrue,
    );
  });

  test('restore reports nothing when no restorable products exist', () async {
    final storage = await _storage({});
    final service = _service(storage);

    final result = await service.restorePurchases();

    expect(result.status, PurchaseStatus.nothingToRestore);
    expect(result.restoredCount, 0);
  });

  test('offline shop blocks purchases and rewarded ads without grants',
      () async {
    final storage = await _storage({});
    final service = _service(storage, offline: true);

    final purchase = await service.purchaseProduct(ProductIds.smallCowries);
    final rewarded = await service.completeRewardedAd(
      placement: RewardedPlacement.smallShopReward,
      callbackId: 'rewarded_offline',
    );

    expect(purchase.status, PurchaseStatus.offline);
    expect(rewarded.status, PurchaseStatus.offline);
    expect(storage.getCowries(), 0);
  });

  test('unavailable products surface an unavailable state', () async {
    final storage = await _storage({});
    final service = _service(storage, productsAvailable: false);

    final state = service.loadState();
    final result = await service.purchaseProduct(ProductIds.smallCowries);

    expect(state.productsLoaded, isFalse);
    expect(state.purchaseStatus, PurchaseStatus.unavailable);
    expect(result.status, PurchaseStatus.unavailable);
  });

  test('rewarded completion grants once and duplicate callback is ignored',
      () async {
    final storage = await _storage({});
    final service = _service(storage);

    final first = await service.completeRewardedAd(
      placement: RewardedPlacement.smallShopReward,
      callbackId: 'ad_callback_1',
    );
    final duplicate = await service.completeRewardedAd(
      placement: RewardedPlacement.smallShopReward,
      callbackId: 'ad_callback_1',
    );

    expect(first.completed, isTrue);
    expect(duplicate.status, PurchaseStatus.alreadyOwned);
    expect(storage.getCowries(), 25);
  });

  test('Daily Bonus Chest can be claimed once per day and resets next day',
      () async {
    final storage = await _storage({});
    final service = _service(storage);
    final today = DateTime(2026, 7, 4, 10);
    final tomorrow = DateTime(2026, 7, 5, 10);

    final first = await service.completeRewardedAd(
      placement: RewardedPlacement.bonusDailyChest,
      callbackId: 'daily_bonus_1',
      now: today,
    );
    final second = await service.completeRewardedAd(
      placement: RewardedPlacement.bonusDailyChest,
      callbackId: 'daily_bonus_2',
      now: today,
    );
    final nextDay = await service.completeRewardedAd(
      placement: RewardedPlacement.bonusDailyChest,
      callbackId: 'daily_bonus_3',
      now: tomorrow,
    );

    expect(first.completed, isTrue);
    expect(second.status, PurchaseStatus.unavailable);
    expect(nextDay.completed, isTrue);
    expect(storage.getCowries(), 60);
    expect(storage.getBooster(BoosterType.hint), 2);
  });

  test('Shop Gift can be claimed three times per day and resets next day',
      () async {
    final storage = await _storage({});
    final service = _service(storage);
    final today = DateTime(2026, 7, 4, 10);
    final tomorrow = DateTime(2026, 7, 5, 10);

    for (var i = 0; i < 3; i++) {
      final result = await service.completeRewardedAd(
        placement: RewardedPlacement.smallShopReward,
        callbackId: 'shop_gift_$i',
        now: today,
      );
      expect(result.completed, isTrue);
    }
    final fourth = await service.completeRewardedAd(
      placement: RewardedPlacement.smallShopReward,
      callbackId: 'shop_gift_4',
      now: today,
    );
    final nextDay = await service.completeRewardedAd(
      placement: RewardedPlacement.smallShopReward,
      callbackId: 'shop_gift_next_day',
      now: tomorrow,
    );

    expect(fourth.status, PurchaseStatus.unavailable);
    expect(nextDay.completed, isTrue);
    expect(storage.getCowries(), 100);
  });

  test('Double Cowries cannot be claimed twice for the same result', () async {
    final storage = await _storage({});
    final service = _service(storage);

    final first = await service.completeRewardedAd(
      placement: RewardedPlacement.doubleCompletionCowries,
      callbackId: 'double_1',
      claimKey: 'double_cowries:level3:score1500:stars3',
      baseCowries: 64,
    );
    final second = await service.completeRewardedAd(
      placement: RewardedPlacement.doubleCompletionCowries,
      callbackId: 'double_2',
      claimKey: 'double_cowries:level3:score1500:stars3',
      baseCowries: 64,
    );

    expect(first.completed, isTrue);
    expect(second.status, PurchaseStatus.unavailable);
    expect(storage.getCowries(), 64);
  });

  test('duplicate earned-reward callbacks do not duplicate Cowries', () async {
    final storage = await _storage({});
    final service = _service(storage);

    final first = await service.completeRewardedAd(
      placement: RewardedPlacement.doubleCompletionCowries,
      callbackId: 'double_callback',
      claimKey: 'double_cowries:level4:score2000:stars3',
      baseCowries: 80,
    );
    final duplicate = await service.completeRewardedAd(
      placement: RewardedPlacement.doubleCompletionCowries,
      callbackId: 'double_callback',
      claimKey: 'double_cowries:level4:score2000:stars3',
      baseCowries: 80,
    );

    expect(first.completed, isTrue);
    expect(duplicate.status, PurchaseStatus.alreadyOwned);
    expect(storage.getCowries(), 80);
  });

  test('Retry Assistance cannot be used twice for the same failed attempt',
      () async {
    final storage = await _storage({});
    final service = _service(storage);

    final first = await service.completeRewardedAd(
      placement: RewardedPlacement.retryAssistance,
      callbackId: 'retry_1',
      claimKey: 'retry_assistance:attempt_a',
    );
    final second = await service.completeRewardedAd(
      placement: RewardedPlacement.retryAssistance,
      callbackId: 'retry_2',
      claimKey: 'retry_assistance:attempt_a',
    );
    final freshAttempt = await service.completeRewardedAd(
      placement: RewardedPlacement.retryAssistance,
      callbackId: 'retry_3',
      claimKey: 'retry_assistance:attempt_b',
    );

    expect(first.completed, isTrue);
    expect(second.status, PurchaseStatus.unavailable);
    expect(freshAttempt.completed, isTrue);
    expect(storage.getBooster(BoosterType.shuffle), 2);
  });

  test('rewarded failure does not grant value', () async {
    final storage = await _storage({});
    final service = _service(storage);

    final result = await service.completeRewardedAd(
      placement: RewardedPlacement.freeHint,
      callbackId: 'ad_callback_failed',
      completed: false,
    );

    expect(result.status, PurchaseStatus.cancelled);
    expect(storage.getBooster(BoosterType.hint), 0);
  });

  test('interstitial eligibility obeys thresholds and cooldowns', () async {
    final storage = await _storage({'highest_completed_level': 2});
    final service = _service(storage);
    final now = DateTime(2026, 6, 25, 12);

    expect(
      service
          .interstitialDecision(
            placement: InterstitialPlacement.afterCompletedLevels,
            isFirstSession: false,
            tutorialActive: false,
            afterLoss: false,
            now: now,
          )
          .reason,
      'level_frequency',
    );

    for (var i = 0; i < MonetizationConfig.completedLevelFrequency; i++) {
      await service.recordLevelCompletedForInterstitial();
    }

    final shown = await service.markInterstitialShown(
      placement: InterstitialPlacement.afterCompletedLevels,
      isFirstSession: false,
      tutorialActive: false,
      afterLoss: false,
      now: now,
    );
    for (var i = 0; i < MonetizationConfig.completedLevelFrequency; i++) {
      await service.recordLevelCompletedForInterstitial();
    }
    final cooldown = service.interstitialDecision(
      placement: InterstitialPlacement.afterCompletedLevels,
      isFirstSession: false,
      tutorialActive: false,
      afterLoss: false,
      now: now.add(const Duration(minutes: 1)),
    );

    expect(shown.canShow, isTrue);
    expect(cooldown.reason, 'interstitial_cooldown');
  });

  test('interstitials are suppressed for remove ads owners and losses',
      () async {
    final storage = await _storage({
      'highest_completed_level': 4,
      'monetization_entitlement_remove_ads': true,
      'monetization_interstitial_completed_since_last': 99,
    });
    final service = _service(storage);

    final removeAds = service.interstitialDecision(
      placement: InterstitialPlacement.afterCompletedLevels,
      isFirstSession: false,
      tutorialActive: false,
      afterLoss: false,
    );
    final lossStorage = await _storage({
      'highest_completed_level': 4,
      'monetization_interstitial_completed_since_last': 99,
    });
    final loss = _service(lossStorage).interstitialDecision(
      placement: InterstitialPlacement.afterCompletedLevels,
      isFirstSession: false,
      tutorialActive: false,
      afterLoss: true,
    );

    expect(removeAds.reason, 'remove_ads');
    expect(loss.reason, 'after_loss');
  });
}
