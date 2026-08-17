import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sankofa_tiles/core/ads/admob_service.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/economy/economy_models.dart';
import 'package:sankofa_tiles/core/monetization/monetization_models.dart';
import 'package:sankofa_tiles/core/utils/audio_service.dart';
import 'package:sankofa_tiles/core/utils/haptic_service.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/models/game_launch_config.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/models/level_model.dart';
import 'package:sankofa_tiles/models/tile_model.dart';
import 'package:sankofa_tiles/providers/admob_provider.dart';
import 'package:sankofa_tiles/providers/game_provider.dart';
import 'package:sankofa_tiles/providers/progress_provider.dart';
import 'package:sankofa_tiles/providers/settings_provider.dart';
import 'package:sankofa_tiles/screens/daily/daily_reward_screen.dart';
import 'package:sankofa_tiles/screens/game/widgets/game_control_dock.dart';
import 'package:sankofa_tiles/screens/result/result_screen.dart';
import 'package:sankofa_tiles/screens/shop/shop_screen.dart';

class _FakeAdMobService extends AdMobService {
  final rewardedPlacements = <RewardedPlacement>[];
  final interstitialPlacements = <InterstitialPlacement>[];
  Completer<bool>? rewardedCompleter;
  bool rewardedResult = true;
  bool interstitialResult = false;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> preloadInterstitialAd(InterstitialPlacement placement) async {}

  @override
  Future<bool> showRewardedAd(RewardedPlacement placement) async {
    rewardedPlacements.add(placement);
    final completer = rewardedCompleter;
    if (completer != null) return completer.future;
    return rewardedResult;
  }

  @override
  Future<bool> showInterstitialAd(InterstitialPlacement placement) async {
    interstitialPlacements.add(placement);
    return interstitialResult;
  }
}

class _SilentAudioService extends AudioService {
  _SilentAudioService() : super(sound: false, music: false);

  @override
  Future<void> playHint() async {}

  @override
  Future<void> playShuffle() async {}

  @override
  Future<void> stopSfx() async {}
}

class _MemoryStorage extends StorageService {
  int cowries = 0;
  int highestCompletedLevel = 0;
  final bestScores = <int, int>{};
  final stars = <int, int>{};
  final completedLevels = <int>{};
  final boosters = <BoosterType, int>{};
  final economyTransactions = <String>{};
  final claimedAchievementIds = <String>{};
  final monetizationEntitlements = <String>{};
  final monetizationPurchases = <String>{};
  final monetizationCallbacks = <String>{};
  final rewardedDailyCounts = <String, int>{};
  final rewardedClaims = <String>{};
  int interstitialCompletedSinceLast = 0;
  int interstitialSessionCount = 0;
  DateTime? lastInterstitialAt;
  DateTime? lastRewardedAdAt;
  bool firstSessionCompleted = true;
  bool tutorialComplete = true;

  @override
  Future<void> saveLevelResult(int levelId, int score, int stars) async {
    completedLevels.add(levelId);
    bestScores[levelId] = score;
    this.stars[levelId] = stars;
    if (levelId > highestCompletedLevel) highestCompletedLevel = levelId;
  }

  @override
  int getBestScore(int levelId) => bestScores[levelId] ?? 0;

  @override
  int getStars(int levelId) => stars[levelId] ?? 0;

  @override
  bool isLevelCompleted(int levelId) => completedLevels.contains(levelId);

  @override
  int getHighestCompletedLevel() => highestCompletedLevel;

  @override
  LevelResult? getLevelResult(int levelId) => null;

  @override
  bool isSoundEnabled() => false;

  @override
  bool isMusicEnabled() => false;

  @override
  double getMusicVolume() => 0;

  @override
  bool isShowTileNames() => false;

  @override
  HapticIntensity getHapticIntensity() => HapticIntensity.off;

  @override
  int getCowries() => cowries;

  @override
  Future<void> setCowries(int amount) async {
    cowries = amount;
  }

  @override
  int getBooster(BoosterType type) => boosters[type] ?? 0;

  @override
  Future<void> setBooster(BoosterType type, int count) async {
    boosters[type] = count;
  }

  @override
  bool hasEconomyTransaction(String transactionId) =>
      economyTransactions.contains(transactionId);

  @override
  Future<void> recordEconomyTransaction(String transactionId) async {
    economyTransactions.add(transactionId);
  }

  @override
  int getDailyRewardDay() => 1;

  @override
  Future<void> setDailyRewardDay(int day) async {}

  @override
  String? getLastDailyClaimDate() => null;

  @override
  Future<void> setLastDailyClaimDate(String value) async {}

  @override
  bool isCollectionUnlocked(String tileId) => true;

  @override
  Future<void> unlockCollectionId(String tileId) async {}

  @override
  void unlockCollectionIdSync(String tileId) {}

  @override
  Set<String> getUnlockedCollectionIds() => const {};

  @override
  bool isAchievementClaimed(String achievementId) =>
      claimedAchievementIds.contains(achievementId);

  @override
  Future<void> claimAchievement(String achievementId) async {
    claimedAchievementIds.add(achievementId);
  }

  @override
  Set<String> getClaimedAchievementIds() => claimedAchievementIds;

  @override
  bool hasMonetizationEntitlement(String entitlementId) =>
      monetizationEntitlements.contains(entitlementId);

  @override
  Future<void> setMonetizationEntitlement(String entitlementId) async {
    monetizationEntitlements.add(entitlementId);
  }

  @override
  Set<String> getMonetizationEntitlementIds() => monetizationEntitlements;

  @override
  bool hasMonetizationPurchase(String productId) =>
      monetizationPurchases.contains(productId);

  @override
  Future<void> recordMonetizationPurchase(String productId) async {
    monetizationPurchases.add(productId);
  }

  @override
  Set<String> getMonetizationPurchaseIds() => monetizationPurchases;

  @override
  bool hasMonetizationCallback(String callbackId) =>
      monetizationCallbacks.contains(callbackId);

  @override
  Future<void> recordMonetizationCallback(String callbackId) async {
    monetizationCallbacks.add(callbackId);
  }

  @override
  int getRewardedDailyClaimCount(String placement, String dateKey) =>
      rewardedDailyCounts['${placement}_$dateKey'] ?? 0;

  @override
  Future<void> setRewardedDailyClaimCount(
    String placement,
    String dateKey,
    int count,
  ) async {
    rewardedDailyCounts['${placement}_$dateKey'] = count;
  }

  @override
  bool hasRewardedClaim(String claimKey) => rewardedClaims.contains(claimKey);

  @override
  Future<void> recordRewardedClaim(String claimKey) async {
    rewardedClaims.add(claimKey);
  }

  @override
  int getInterstitialCompletedSinceLast() => interstitialCompletedSinceLast;

  @override
  Future<void> setInterstitialCompletedSinceLast(int count) async {
    interstitialCompletedSinceLast = count;
  }

  @override
  int getInterstitialSessionCount() => interstitialSessionCount;

  @override
  Future<void> setInterstitialSessionCount(int count) async {
    interstitialSessionCount = count;
  }

  @override
  DateTime? getLastInterstitialAt() => lastInterstitialAt;

  @override
  Future<void> setLastInterstitialAt(DateTime value) async {
    lastInterstitialAt = value;
  }

  @override
  DateTime? getLastRewardedAdAt() => lastRewardedAdAt;

  @override
  Future<void> setLastRewardedAdAt(DateTime value) async {
    lastRewardedAdAt = value;
  }

  @override
  bool isFirstSessionCompleted() => firstSessionCompleted;

  @override
  Future<void> setFirstSessionCompleted() async {
    firstSessionCompleted = true;
  }

  @override
  bool isTutorialComplete() => tutorialComplete;
}

ProviderContainer _container(_MemoryStorage storage, _FakeAdMobService ads) {
  return ProviderContainer(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
      progressProvider.overrideWithValue(ProgressService(storage)),
      adMobServiceProvider.overrideWithValue(ads),
      audioServiceProvider.overrideWithValue(_SilentAudioService()),
    ],
  );
}

GameState _playingState() {
  final def = kAllTiles.first;
  return GameState(
    tiles: [
      TileModel(uid: 'a', def: def, row: 0, col: 0),
      TileModel(uid: 'b', def: def, row: 0, col: 4),
    ],
    status: GameStatus.playing,
    difficulty: DifficultyMode.relaxed,
    score: 500,
    moves: 4,
    hintsUsed: 0,
    secondsElapsed: 12,
    levelId: 1,
  );
}

GameState _wonState({int levelId = 3}) {
  final def = kAllTiles.first;
  return GameState(
    tiles: [
      TileModel(uid: 'a', def: def, row: 0, col: 0, isMatched: true),
      TileModel(uid: 'b', def: def, row: 0, col: 4, isMatched: true),
    ],
    status: GameStatus.won,
    difficulty: DifficultyMode.relaxed,
    score: 1800,
    moves: 8,
    hintsUsed: 0,
    secondsElapsed: 30,
    levelId: levelId,
    bestStreak: 2,
  );
}

Future<ProviderContainer> _pumpDock(
  WidgetTester tester, {
  required _MemoryStorage storage,
  required _FakeAdMobService ads,
}) async {
  final container = _container(storage, ads);
  container.read(gameProvider.notifier).replaceStateForTesting(_playingState());

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: GameControlDock(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return container;
}

Future<GoRouter> _pumpResult(
  WidgetTester tester, {
  required _MemoryStorage storage,
  required _FakeAdMobService ads,
  GameState? gameState,
  bool settle = true,
  bool disableAnimations = false,
}) async {
  await tester.binding.setSurfaceSize(const Size(900, 1100));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final router = GoRouter(
    initialLocation: '/result',
    routes: [
      GoRoute(
        path: '/result',
        builder: (context, state) => ResultScreen(
          gameState: gameState ?? _wonState(),
          launchConfig: const GameLaunchConfig(
            levelId: 3,
            launchMode: GameLaunchMode.normalProgression,
          ),
        ),
      ),
      GoRoute(
        path: '/level/:levelId',
        builder: (context, state) =>
            Text('Level ${state.pathParameters['levelId']}'),
      ),
      GoRoute(
        path: '/game/:levelId',
        builder: (context, state) =>
            Text('Game ${state.pathParameters['levelId']}'),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const Text('Home'),
      ),
      GoRoute(
        path: '/chapter-complete/:levelId',
        builder: (context, state) => const Text('Chapter Complete'),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
        progressProvider.overrideWithValue(ProgressService(storage)),
        adMobServiceProvider.overrideWithValue(ads),
        audioServiceProvider.overrideWithValue(_SilentAudioService()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: disableAnimations,
          ),
          child: child!,
        ),
      ),
    ),
  );
  if (settle) await tester.pumpAndSettle();
  return router;
}

Future<ProviderContainer> _pumpProvidedScreen(
  WidgetTester tester, {
  required _MemoryStorage storage,
  required _FakeAdMobService ads,
  required Widget child,
}) async {
  final container = _container(storage, ads);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: child),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  group('GameControlDock rewarded booster confirmation', () {
    testWidgets('tapping Hint with inventory uses the booster directly',
        (tester) async {
      final storage = _MemoryStorage()..boosters[BoosterType.hint] = 1;
      final ads = _FakeAdMobService();
      final container = await _pumpDock(tester, storage: storage, ads: ads);
      addTearDown(container.dispose);

      await tester.tap(find.bySemanticsLabel('Hint 1'));
      await tester.pump();

      expect(ads.rewardedPlacements, isEmpty);
      expect(storage.getBooster(BoosterType.hint), 0);
      expect(container.read(gameProvider).hintsUsed, 1);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('tapping Hint with zero inventory opens confirmation only',
        (tester) async {
      final storage = _MemoryStorage();
      final ads = _FakeAdMobService();
      final container = await _pumpDock(tester, storage: storage, ads: ads);
      addTearDown(container.dispose);

      await tester.tap(find.bySemanticsLabel('Hint 0'));
      await tester.pumpAndSettle();

      expect(find.text('No Hints Left'), findsOneWidget);
      expect(find.text('Watch a short ad to receive 1 free Hint?'),
          findsOneWidget);
      expect(ads.rewardedPlacements, isEmpty);
    });

    testWidgets('canceling the Hint dialog does not show an ad',
        (tester) async {
      final storage = _MemoryStorage();
      final ads = _FakeAdMobService();
      final container = await _pumpDock(tester, storage: storage, ads: ads);
      addTearDown(container.dispose);

      await tester.tap(find.bySemanticsLabel('Hint 0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('No Hints Left'), findsNothing);
      expect(ads.rewardedPlacements, isEmpty);
      expect(container.read(gameProvider).hintsUsed, 0);
    });

    testWidgets('confirming the Hint dialog requests freeHint', (tester) async {
      final storage = _MemoryStorage();
      final ads = _FakeAdMobService();
      final container = await _pumpDock(tester, storage: storage, ads: ads);
      addTearDown(container.dispose);

      await tester.tap(find.bySemanticsLabel('Hint 0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Watch Ad'));
      await tester.pump();

      expect(ads.rewardedPlacements, [RewardedPlacement.freeHint]);
      expect(container.read(gameProvider).hintsUsed, 1);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('Free Hint cannot start overlapping rewarded requests',
        (tester) async {
      final storage = _MemoryStorage();
      final ads = _FakeAdMobService()..rewardedCompleter = Completer<bool>();
      final container = await _pumpDock(tester, storage: storage, ads: ads);
      addTearDown(container.dispose);

      await tester.tap(find.bySemanticsLabel('Hint 0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Watch Ad'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Hint 0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Watch Ad'));
      await tester.pump();

      expect(ads.rewardedPlacements, [RewardedPlacement.freeHint]);
      expect(storage.getBooster(BoosterType.hint), 0);

      ads.rewardedCompleter!.complete(true);
      await tester.pumpAndSettle();
      expect(storage.getBooster(BoosterType.hint), 0);
      expect(container.read(gameProvider).hintsUsed, 1);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('tapping Shuffle with inventory uses the booster directly',
        (tester) async {
      final storage = _MemoryStorage()..boosters[BoosterType.shuffle] = 1;
      final ads = _FakeAdMobService();
      final container = await _pumpDock(tester, storage: storage, ads: ads);
      addTearDown(container.dispose);

      await tester.tap(find.bySemanticsLabel('Shuffle 1'));
      await tester.pump();

      expect(ads.rewardedPlacements, isEmpty);
      expect(storage.getBooster(BoosterType.shuffle), 0);
      expect(container.read(gameProvider).shufflesUsed, 1);
    });

    testWidgets('tapping Shuffle with zero inventory opens confirmation only',
        (tester) async {
      final storage = _MemoryStorage();
      final ads = _FakeAdMobService();
      final container = await _pumpDock(tester, storage: storage, ads: ads);
      addTearDown(container.dispose);

      await tester.tap(find.bySemanticsLabel('Shuffle 0'));
      await tester.pumpAndSettle();

      expect(find.text('No Shuffles Left'), findsOneWidget);
      expect(find.text('Watch a short ad to receive 1 free Shuffle?'),
          findsOneWidget);
      expect(ads.rewardedPlacements, isEmpty);
    });

    testWidgets('canceling the Shuffle dialog does not show an ad',
        (tester) async {
      final storage = _MemoryStorage();
      final ads = _FakeAdMobService();
      final container = await _pumpDock(tester, storage: storage, ads: ads);
      addTearDown(container.dispose);

      await tester.tap(find.bySemanticsLabel('Shuffle 0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('No Shuffles Left'), findsNothing);
      expect(ads.rewardedPlacements, isEmpty);
      expect(container.read(gameProvider).shufflesUsed, 0);
    });

    testWidgets('confirming the Shuffle dialog requests freeRescueShuffle',
        (tester) async {
      final storage = _MemoryStorage();
      final ads = _FakeAdMobService();
      final container = await _pumpDock(tester, storage: storage, ads: ads);
      addTearDown(container.dispose);

      await tester.tap(find.bySemanticsLabel('Shuffle 0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Watch Ad'));
      await tester.pump();

      expect(ads.rewardedPlacements, [RewardedPlacement.freeRescueShuffle]);
      expect(container.read(gameProvider).shufflesUsed, 1);
    });

    testWidgets('Free Shuffle cannot start overlapping rewarded requests',
        (tester) async {
      final storage = _MemoryStorage();
      final ads = _FakeAdMobService()..rewardedCompleter = Completer<bool>();
      final container = await _pumpDock(tester, storage: storage, ads: ads);
      addTearDown(container.dispose);

      await tester.tap(find.bySemanticsLabel('Shuffle 0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Watch Ad'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Shuffle 0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Watch Ad'));
      await tester.pump();

      expect(ads.rewardedPlacements, [RewardedPlacement.freeRescueShuffle]);
      expect(storage.getBooster(BoosterType.shuffle), 0);

      ads.rewardedCompleter!.complete(true);
      await tester.pumpAndSettle();
      expect(storage.getBooster(BoosterType.shuffle), 0);
      expect(container.read(gameProvider).shufflesUsed, 1);
    });
  });

  group('ResultScreen star celebration', () {
    double starOpacity(WidgetTester tester, int star) => tester
        .widget<Opacity>(
          find.byKey(ValueKey('result-star-opacity-$star')),
        )
        .opacity;

    testWidgets('earned stars reveal sequentially about 200ms apart',
        (tester) async {
      final storage = _MemoryStorage();
      final ads = _FakeAdMobService();

      await _pumpResult(
        tester,
        storage: storage,
        ads: ads,
        gameState: _wonState().copyWith(
          score: getLevelById(3)!.starThresholds[2],
        ),
        settle: false,
      );

      expect(starOpacity(tester, 1), 0);
      expect(starOpacity(tester, 2), 0);
      expect(starOpacity(tester, 3), 0);

      await tester.pump(const Duration(milliseconds: 100));
      expect(starOpacity(tester, 1), greaterThan(0));
      expect(starOpacity(tester, 2), 0);

      await tester.pump(const Duration(milliseconds: 120));
      expect(starOpacity(tester, 2), greaterThan(0));
      expect(starOpacity(tester, 3), 0);

      await tester.pump(const Duration(milliseconds: 200));
      expect(starOpacity(tester, 3), greaterThan(0));
      await tester.pumpAndSettle();
    });

    testWidgets('unearned stars stay visible and do not animate',
        (tester) async {
      final level = getLevelById(3)!;
      final storage = _MemoryStorage();
      final ads = _FakeAdMobService();
      final twoStarState = _wonState().copyWith(
        score: level.starThresholds[1],
      );

      await _pumpResult(
        tester,
        storage: storage,
        ads: ads,
        gameState: twoStarState,
        settle: false,
      );

      final semantics = tester.widget<Semantics>(
        find.byKey(const ValueKey('result-stars')),
      );
      expect(semantics.properties.label, '2 of 3 stars earned');
      expect(starOpacity(tester, 3), 1);
      await tester.pump(const Duration(milliseconds: 100));
      expect(starOpacity(tester, 3), 1);
      await tester.pumpAndSettle();
    });

    testWidgets('reduced motion displays earned stars immediately',
        (tester) async {
      final storage = _MemoryStorage();
      final ads = _FakeAdMobService();

      await _pumpResult(
        tester,
        storage: storage,
        ads: ads,
        gameState: _wonState().copyWith(
          score: getLevelById(3)!.starThresholds[2],
        ),
        settle: false,
        disableAnimations: true,
      );

      expect(starOpacity(tester, 1), 1);
      expect(starOpacity(tester, 2), 1);
      expect(starOpacity(tester, 3), 1);
    });
  });

  group('ResultScreen X2 Cowries reward', () {
    testWidgets('shows the dynamically doubled completion reward',
        (tester) async {
      final storage = _MemoryStorage();
      final ads = _FakeAdMobService();

      await _pumpResult(tester, storage: storage, ads: ads);

      expect(
        find.text('X2 CLAIM ${storage.cowries * 2} COWRIES'),
        findsOneWidget,
      );
    });

    testWidgets('completion grants only one additional base reward',
        (tester) async {
      final storage = _MemoryStorage();
      final ads = _FakeAdMobService();

      await _pumpResult(tester, storage: storage, ads: ads);
      final baseReward = storage.cowries;
      final claimLabel = 'X2 CLAIM ${baseReward * 2} COWRIES';
      await Scrollable.ensureVisible(tester.element(find.text(claimLabel)));
      await tester.tap(find.text(claimLabel));
      await tester.pumpAndSettle();

      expect(storage.cowries, baseReward * 2);
      expect(storage.rewardedClaims, hasLength(1));
      expect(find.text('X2 REWARD CLAIMED'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('double-cowries-reward-button')),
      );
      await tester.pump();
      expect(ads.rewardedPlacements, hasLength(1));
      expect(storage.cowries, baseReward * 2);
    });

    testWidgets('rapid taps start one ad and grant one additional reward',
        (tester) async {
      final storage = _MemoryStorage();
      final ads = _FakeAdMobService()..rewardedCompleter = Completer<bool>();

      await _pumpResult(tester, storage: storage, ads: ads);
      final baseReward = storage.cowries;
      final button = find.byKey(
        const ValueKey('double-cowries-reward-button'),
      );
      await Scrollable.ensureVisible(tester.element(button));
      await tester.tap(button);
      await tester.tap(button);
      await tester.pump();

      expect(
        ads.rewardedPlacements,
        [RewardedPlacement.doubleCompletionCowries],
      );
      expect(storage.cowries, baseReward);

      ads.rewardedCompleter!.complete(true);
      await tester.pumpAndSettle();
      expect(storage.cowries, baseReward * 2);
      expect(storage.rewardedClaims, hasLength(1));
    });

    testWidgets('cancelled or failed ads do not grant Cowries', (tester) async {
      final storage = _MemoryStorage();
      final ads = _FakeAdMobService()..rewardedResult = false;

      await _pumpResult(tester, storage: storage, ads: ads);
      final baseReward = storage.cowries;
      final claimLabel = 'X2 CLAIM ${baseReward * 2} COWRIES';
      await Scrollable.ensureVisible(tester.element(find.text(claimLabel)));
      await tester.tap(find.text(claimLabel));
      await tester.pumpAndSettle();

      expect(storage.cowries, baseReward);
      expect(storage.rewardedClaims, isEmpty);
      expect(find.text(claimLabel), findsOneWidget);
    });

    testWidgets('navigation during an ad is safe and preserves earned callback',
        (tester) async {
      final storage = _MemoryStorage();
      final ads = _FakeAdMobService()..rewardedCompleter = Completer<bool>();

      final router = await _pumpResult(tester, storage: storage, ads: ads);
      final baseReward = storage.cowries;
      final button = find.byKey(
        const ValueKey('double-cowries-reward-button'),
      );
      await Scrollable.ensureVisible(tester.element(button));
      await tester.tap(button);
      await tester.pump();

      router.go('/');
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);

      ads.rewardedCompleter!.complete(true);
      await tester.pumpAndSettle();
      expect(storage.cowries, baseReward * 2);
      expect(storage.rewardedClaims, hasLength(1));
      expect(tester.takeException(), isNull);
    });
  });

  group('ResultScreen completed-level interstitial timing', () {
    testWidgets('does not trigger interstitial automatically on entry',
        (tester) async {
      final storage = _MemoryStorage()
        ..highestCompletedLevel = 2
        ..interstitialCompletedSinceLast = 2;
      final ads = _FakeAdMobService();

      await _pumpResult(tester, storage: storage, ads: ads);

      expect(ads.interstitialPlacements, isEmpty);
      expect(storage.getInterstitialCompletedSinceLast(), 3);
    });

    testWidgets('Next Level triggers the interstitial decision engine',
        (tester) async {
      final storage = _MemoryStorage()
        ..highestCompletedLevel = 2
        ..interstitialCompletedSinceLast = 2;
      final ads = _FakeAdMobService();

      await _pumpResult(tester, storage: storage, ads: ads);
      await tester.tap(find.text('NEXT LEVEL'));
      await tester.pumpAndSettle();

      expect(ads.interstitialPlacements,
          [InterstitialPlacement.afterCompletedLevels]);
      expect(find.text('Game 4'), findsOneWidget);
    });

    testWidgets(
        'rewarded-ad cooldown prevents immediate interstitial after Double Cowries',
        (tester) async {
      final storage = _MemoryStorage()
        ..highestCompletedLevel = 2
        ..interstitialCompletedSinceLast = 2;
      final ads = _FakeAdMobService();

      await _pumpResult(tester, storage: storage, ads: ads);
      final claimLabel = 'X2 CLAIM ${storage.cowries * 2} COWRIES';
      await Scrollable.ensureVisible(
        tester.element(find.text(claimLabel)),
        alignment: 0.5,
      );
      await tester.tap(find.text(claimLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT LEVEL'));
      await tester.pumpAndSettle();

      expect(
          ads.rewardedPlacements, [RewardedPlacement.doubleCompletionCowries]);
      expect(ads.interstitialPlacements, isEmpty);
      expect(find.text('Game 4'), findsOneWidget);
    });

    testWidgets('navigation continues when the interstitial is unavailable',
        (tester) async {
      final storage = _MemoryStorage()
        ..highestCompletedLevel = 2
        ..interstitialCompletedSinceLast = 2;
      final ads = _FakeAdMobService()..interstitialResult = false;

      await _pumpResult(tester, storage: storage, ads: ads);
      await tester.tap(find.text('NEXT LEVEL'));
      await tester.pumpAndSettle();

      expect(ads.interstitialPlacements,
          [InterstitialPlacement.afterCompletedLevels]);
      expect(find.text('Game 4'), findsOneWidget);
    });
  });

  group('rewarded daily limit UI states', () {
    testWidgets('Daily Bonus limit-reached state does not request an ad',
        (tester) async {
      final now = DateTime.now();
      final dateKey = '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      final storage = _MemoryStorage()
        ..rewardedDailyCounts['bonusDailyChest_$dateKey'] = 1;
      final ads = _FakeAdMobService();
      final container = await _pumpProvidedScreen(
        tester,
        storage: storage,
        ads: ads,
        child: const DailyRewardScreen(),
      );
      addTearDown(container.dispose);

      expect(find.text('Already Claimed'), findsOneWidget);
      await tester.tap(find.text('Already Claimed'), warnIfMissed: false);
      await tester.pump();

      expect(ads.rewardedPlacements, isEmpty);
    });

    testWidgets('Shop Gift shows remaining claims and blocks the fourth claim',
        (tester) async {
      final now = DateTime.now();
      final dateKey = '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      final storage = _MemoryStorage()
        ..rewardedDailyCounts['smallShopReward_$dateKey'] = 1;
      final ads = _FakeAdMobService();
      final container = await _pumpProvidedScreen(
        tester,
        storage: storage,
        ads: ads,
        child: const ShopScreen(),
      );
      addTearDown(container.dispose);

      expect(find.text('2 of 3 remaining today'), findsOneWidget);

      await tester.tap(find.text('Watch Ad'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Watch Ad'));
      await tester.pumpAndSettle();

      expect(find.text('Daily Limit Reached'), findsNWidgets(2));
      await tester.tap(
        find.text('Daily Limit Reached').last,
        warnIfMissed: false,
      );
      await tester.pump();

      expect(ads.rewardedPlacements, [
        RewardedPlacement.smallShopReward,
        RewardedPlacement.smallShopReward,
      ]);
      expect(storage.getCowries(), 50);
    });

    testWidgets('reward is granted only after earned callback succeeds',
        (tester) async {
      final storage = _MemoryStorage();
      final ads = _FakeAdMobService()..rewardedCompleter = Completer<bool>();
      final container = await _pumpProvidedScreen(
        tester,
        storage: storage,
        ads: ads,
        child: const ShopScreen(),
      );
      addTearDown(container.dispose);

      await tester.tap(find.text('Watch Ad'));
      await tester.pump();

      expect(storage.getCowries(), 0);
      ads.rewardedCompleter!.complete(true);
      await tester.pumpAndSettle();
      expect(storage.getCowries(), 25);
    });
  });
}
