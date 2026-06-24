# Analytics Event Map

## Initialization

`AnalyticsService.initialize()` stores `FirebaseAnalytics.instance` after Firebase initializes. Every log call is a no-op when analytics is unavailable, so Firebase startup failure does not block app usage.

The router installs `_AnalyticsNavigatorObserver`, which attempts to log screen views for named routes.

## Events

| Event | Parameters | Called from |
|---|---|---|
| `logAppOpen()` | Firebase app-open event | Available but not currently called in startup. |
| `play_pressed` | `level_id` when known | Home Play button. |
| `next_game_pressed` | `level_id` | Result Next Game button. |
| `level_retried` | `level_id` | Result Retry button. |
| Screen view | `screenName`, `screenClass` | GoRouter navigator observer. |
| `level_started` | `level_id`, `difficulty` | `GameNotifier.startLevel`, skipped for developer tests. |
| `level_completed` | `level_id`, `difficulty`, `score`, `stars`, `seconds_elapsed` | Result screen normal win save. |
| `level_failed` | `level_id`, `difficulty`, `score`, `reason` | Board load failure and no-moves loss, skipped for developer tests. |
| `hint_used` | `level_id`, `difficulty` | Hint button, skipped for developer tests. |
| `shuffle_used` | `level_id`, `difficulty` | User shuffle, skipped for developer tests. |
| `pause_used` | `level_id`, `difficulty` | `GameNotifier.pauseGame`, skipped for developer tests. |
| `wallet_changed` | `reason`, `delta` | Cowrie grants and spends through `EconomyNotifier`. |
| `booster_changed` | `booster_type`, `reason`, `delta` | Booster grants and spends through `EconomyNotifier`. |
| `daily_reward_claimed` | `day` | Successful daily reward claim. |
| `collection_unlocked` | `symbol_id` | New Adinkra Collection symbol unlocked from a level reward. |
| `achievement_unlocked` | `achievement_id` | Newly earned achievement reward. |
| `settings_opened` | `source` | Home/settings entry and game settings sheet. |
| `tile_preview_opened` | none | Home Tile Preview button. |
| `onboarding_completed` | none | Onboarding finish/skip. |
| `tutorial_started` | `replay` | Tutorial entry. |
| `tutorial_step_completed` | `step` | Tutorial step progression. |
| `tutorial_skipped` | none | Tutorial skip. |
| `tutorial_completed` | none | Tutorial completion. |
| `reset_progress` | none | Developer reset confirmation. |

## Crashlytics Coverage

`CrashReportingService.initialize()` stores `FirebaseCrashlytics.instance` after Firebase initializes.

Current non-fatal reports:

- SharedPreferences initialization failure.
- Storage level-result persistence failure.
- Progress reset persistence failure.
- Unexpected level startup exception.
- Board generation load failure.

`main.dart` also wires `FlutterError.onError` and `PlatformDispatcher.instance.onError` to Crashlytics after Firebase startup succeeds.

## Gaps

- `logAppOpen()` exists but is not called.
- Router screen names may depend on route settings provided by GoRouter; this should be verified after transition changes.
- Daily reward view, missed-day, and cycle-completion analytics are not separated yet; Phase 3 logs successful claims only.
