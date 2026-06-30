# Current Game Flow

## Scope

This document records the current Adinkra Tiles flow after Phase 5 validation. It reflects the code in `lib/main.dart`, `lib/app.dart`, `lib/core/router/app_router.dart`, the screen files, providers, and persistence services.

## Routes

| Route | Name | Screen | Entry behavior |
|---|---|---|---|
| `/` | `home` | `HomeScreen` | Default route. Redirects to `/onboarding` when `StorageService.isOnboardingComplete()` is false. |
| `/onboarding` | `onboarding` | `OnboardingScreen` | Concise cultural introduction. Skip and Start Playing persist onboarding completion and continue to tutorial. |
| `/tutorial` | `tutorial` | `TutorialScreen` | Interactive tutorial; `?replay=1` marks replay analytics. Completion persists `tutorial_complete`. |
| `/journey` | `journey` | `JourneyScreen` | Grand Archive chapter/level map with locked, current, and replay states. |
| `/level/:levelId` | `pre_level` | `PreLevelScreen` | Pre-level summary and normal campaign launch gate. Blocks locked levels. |
| `/game/:levelId` | `game` | `GameScreen` | Starts a level from `GameLaunchConfig` in `state.extra`; without extra it falls back to the next progression level. Developer test launches are blocked when developer tools are disabled. |
| `/result` | `result` | `ResultScreen` | Requires either `GameResultConfig` or a legacy `GameState` extra. Saves wins unless the launch was a developer test. |
| `/chapter-complete/:levelId` | `chapter_complete` | `ChapterCompleteScreen` | Chapter milestone or final campaign completion after levels 10, 20, 30, 40, and 50. |
| `/settings` | `settings` | `SettingsScreen` | Opens global settings, privacy policy, and developer tools when enabled. |
| `/daily-reward` | `daily_reward` | `DailyRewardScreen` | Seven-day local daily reward claim surface. |
| `/shop` | `shop` | `ShopScreen` | Sandbox product catalog, Remove Ads entitlement, restore purchases, and optional shop reward. |
| `/tile-preview` | `tile_preview` | `TilePreviewScreen` | Progression-based Adinkra Collection with locked and unlocked symbols. |
| `/developer/levels` | `developer_level_tester` | `DeveloperLevelTesterScreen` | Present only when `developerToolsEnabled` is true. Launches levels without saving normal progress. |

Unknown routes render the GoRouter `errorBuilder` with a dark themed page-not-found message.

## Startup

```text
Process start
  -> WidgetsFlutterBinding.ensureInitialized
  -> Firebase.initializeApp best-effort
  -> AnalyticsService.initialize if Firebase succeeds
  -> CrashReportingService.initialize if Firebase succeeds
  -> portrait orientation and dark system UI
  -> StorageService.init
  -> ProviderScope with StorageService override
  -> SankofaTilesApp
  -> GoRouter at /
  -> /onboarding when onboarding_complete is false
  -> / when onboarding_complete is true
```

Firebase failures are logged with `debugPrint` and do not stop startup. Storage initialization failures are reported to Crashlytics when available, then rethrown before `runApp`; before Phase 1 there is no in-app recovery UI for this case.

## First-Time User

```text
/
  -> router redirect detects onboarding_complete == false
  -> /onboarding
  -> Skip or START PLAYING
  -> StorageService.setOnboardingComplete()
  -> AnalyticsService.logOnboardingCompleted()
  -> /tutorial
  -> tutorial completion or skip
  -> StorageService.setTutorialComplete()
  -> /
```

The onboarding is followed by an interactive tutorial. Tutorial completion is stored separately from onboarding and can be replayed from Settings.

## Returning User

```text
/
  -> HomeScreen
  -> wallet and booster summary from EconomyProvider
  -> Shop and Daily Reward entry points remain optional
  -> CONTINUE
  -> ProgressService.nextUnfinishedLevelId
  -> /level/<levelId>
  -> /game/<levelId> with GameLaunchMode.normalProgression
```

If all levels are complete, Home shows a SnackBar saying `All Levels Completed`.

## Level Flow

```text
/game/<levelId>
  -> GameScreen.initState post-frame callback
  -> GameNotifier.startLevel(levelId, DifficultyMode.normal)
  -> board generation and solvability check
  -> GameStatus.playing
  -> user matches pairs, uses hint, shuffles, pauses, or exits
```

If board generation fails, the state becomes `GameStatus.loadFailed`, an overlay shows a retry/back choice, and a non-fatal Crashlytics report is attempted.

## Pause, Resume, Restart, Exit

Pause is available from the in-game header and game settings flow:

```text
Back button or header back
  -> GameNotifier.pauseGame()
  -> Quit dialog
  -> Resume: GameNotifier.resumeGame()
  -> Quit: GameNotifier.leaveGame(), then / or /developer/levels
```

The paused overlay provides Resume and Quit. There is currently no dedicated restart command in the pause overlay. Replay happens from the result screen after a loss, or from developer result actions.

## Win

```text
Final pair matched
  -> GameStatus.won
  -> win audio/haptics
  -> after 600 ms, /result with GameResultConfig
  -> ResultScreen computes stars
  -> AnalyticsService.logLevelCompleted
  -> EconomyNotifier.grantLevelRewards
  -> reward reveal shows Cowries, boosters, collection unlocks, achievements, and balance
  -> ProgressService.saveLevelResult
  -> MonetizationNotifier records interstitial eligibility state
  -> optional rewarded ad can double earned Cowries
  -> NEXT GAME, RETURN HOME, or developer actions
```

Normal wins persist best score, stars, completed flag, highest completed level, one-time economy transactions, collection unlocks, and achievement claims. Developer test wins do not persist normal progress or economy rewards.

## Lose

```text
No available matching pair
  -> GameNotifier tries automatic safe shuffle
  -> if shuffle succeeds, play continues
  -> if shuffle fails, GameStatus.lost
  -> AnalyticsService.logLevelFailed(reason: no_moves)
  -> lose audio/haptics
  -> /result
  -> optional rewarded retry Shuffle
  -> HOME or RETRY
```

## Next Level, Replay, Final Level

The normal win screen offers `NEXT LEVEL` when the completed level id is below the final campaign level and not a chapter endpoint. Every 10th level routes to `/chapter-complete/<levelId>`, with level 200 showing campaign completion.

Loss replay uses `RETRY` and relaunches the same level in normal progression mode. Developer results offer retry and next test-level actions without saving progress.

## Developer-Level Test

```text
/settings
  -> DEV: Level Tester
  -> /developer/levels
  -> selected level
  -> /game/<levelId> with GameLaunchMode.developerTest
  -> /result
  -> developer actions
```

Developer level tests are isolated by `GameLaunchConfig.isDeveloperTest`; analytics and progress writes are skipped in the main game/result paths.

## Daily Reward and Collection

```text
Home
  -> DAILY
  -> /daily-reward
  -> claim once per local date
  -> EconomyProvider refreshes wallet and inventory
```

The daily cycle is local-only and advances through seven configured rewards before looping to day 1. A same-day duplicate claim returns no reward.

```text
Home
  -> COLLECTION
  -> /tile-preview
  -> locked symbols show a lock state and unlock source
  -> unlocked symbols show existing project artwork, Akan name, meaning, and source text
```

Collection unlocks are deterministic. Completing a level unlocks the first two symbols from that level, and existing progress is backfilled from completed levels when the economy state loads.

## Shop and Monetization

```text
Home
  -> SHOP
  -> /shop
  -> Featured / Boosters / Cowries / Cosmetics / Remove Ads / Restore
  -> sandbox purchase state
  -> EconomyService grants Cowries or boosters
  -> StorageService persists permanent entitlements and idempotency markers
```

Current monetization behavior is SDK-neutral and sandbox-oriented:

- Product ids and test store ids are centralized in `MonetizationConfig`.
- Remove Ads is a permanent local entitlement that suppresses forced interstitial eligibility.
- Rewarded placements are voluntary and grant rewards only after a successful callback.
- Interstitials are frequency-gated and are not shown during gameplay, after loss, during tutorial, or to Remove Ads owners.
- Live ad SDKs, platform billing SDKs, server receipt validation, consent UI, and localized store prices remain production integration blockers.
