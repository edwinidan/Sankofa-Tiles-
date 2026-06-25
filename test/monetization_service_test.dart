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
