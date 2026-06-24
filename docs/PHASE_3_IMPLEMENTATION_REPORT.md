# Phase 3 Implementation Report

## Scope

Phase 3 added the reward economy that sits around the existing game loop. The implementation includes Cowries, booster inventory, level rewards, daily rewards, achievement rewards, result reward reveal UI, and a progression-based Adinkra Collection.

No ads, billing products, shop purchases, or real-money flows were added.

## Key Files

| Area | Files |
|---|---|
| Economy models and config | `lib/core/economy/economy_models.dart`, `lib/core/economy/economy_config.dart` |
| Economy logic | `lib/core/economy/economy_service.dart`, `lib/providers/economy_provider.dart` |
| Persistence | `lib/core/utils/storage_service.dart` |
| Analytics | `lib/core/utils/analytics_service.dart` |
| UI | `lib/screens/home/home_screen.dart`, `lib/screens/daily/daily_reward_screen.dart`, `lib/screens/preview/tile_preview_screen.dart`, `lib/screens/result/result_screen.dart` |
| Gameplay boosters | `lib/providers/game_provider.dart`, `lib/screens/game/widgets/game_control_dock.dart` |
| Routes | `lib/core/router/app_router.dart` |
| Tests | `test/economy_service_test.dart`, `test/result_screen_dispose_test.dart` |

## Economy Table

| Reward source | Grant | Repeat behavior |
|---|---:|---|
| First level clear | 40 Cowries | Once per level through transaction id |
| Star improvement | 12 Cowries per newly earned star | Only for newly improved stars |
| Replay with no improvement | 0 Cowries | No farming reward |
| Chapter completion | 120 Cowries | Once per chapter-final level |
| Daily day 1 | 40 Cowries | Once per local date |
| Daily day 2 | 1 Hint | Once per local date |
| Daily day 3 | 55 Cowries | Once per local date |
| Daily day 4 | 1 Shuffle | Once per local date |
| Daily day 5 | 75 Cowries | Once per local date |
| Daily day 6 | 1 Hint, 1 Shuffle | Once per local date |
| Daily day 7 | 120 Cowries, 1 Open Path | Once per local date, then cycle resets |

Achievement rewards are configured in `EconomyConfig.achievements` and are claim-once. They currently grant Cowries or boosters for first completion, first three-star clear, five-match streak, ten levels, no-hint clear, no-shuffle clear, chapter completion, discovering 20 symbols, earning 50 stars, and completing the campaign.

## Storage Schema

| Key or prefix | Purpose |
|---|---|
| `economy_cowries` | Cowrie wallet balance |
| `economy_booster_<type>` | Booster counts for `hint`, `shuffle`, and `openPath` |
| `economy_tx_<transactionId>` | Idempotent reward transaction markers |
| `daily_reward_day` | Next daily reward day, clamped to 1-7 |
| `daily_last_claim_date` | Last local claim date |
| `collection_unlocked_<tileId>` | Collection unlock flags |
| `achievement_claimed_<achievementId>` | Achievement claim flags |

Cowrie and booster values are clamped to non-negative ranges on read/write. Collection unlocks are backfilled from existing campaign progress by unlocking the first two symbols from each completed level.

## Gameplay Behavior

- Hint and Shuffle now spend booster inventory before using their existing game behavior.
- Open Path spends one `openPath` booster, finds a safe available matching pair, removes it, awards the normal match score, and refunds if no safe use is available.
- Undo was not implemented because the current game state does not keep a bounded move history. This is documented instead of faking an unsafe undo.
- Developer test results still skip normal progression and economy rewards.

## Reward Reveal

Normal wins now:

1. Read previous stars and completion state.
2. Log level completion.
3. Grant idempotent economy rewards.
4. Save the level result.
5. Show a reward reveal with Cowries, boosters, new-best status, chapter rewards, unlocked symbols, achievements, and updated balance.

## Analytics

Added economy analytics wrappers:

- `wallet_changed`
- `booster_changed`
- `daily_reward_claimed`
- `collection_unlocked`
- `achievement_unlocked`

Daily view, missed-day, and cycle-completion events remain future refinements.

## Verification

Commands run:

```text
dart format lib/providers/progress_provider.dart test/result_screen_dispose_test.dart
flutter analyze
flutter test
```

Result:

```text
No issues found.
All tests passed.
```

## Remaining Risks and Follow-Up

- Daily reward timing is local-date based; server-backed anti-clock-tamper logic belongs with the later monetization/account phase.
- Achievement analytics currently logs the displayed achievement title through the existing summary path.
- Shop, rewarded ads, interstitial ads, banner ads, in-app purchases, restore purchases, and remove-ads flows are intentionally deferred to Phase 4.
