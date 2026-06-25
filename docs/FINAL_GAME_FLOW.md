# Final Game Flow

## Scope

This document captures the intended first monetized-release flow after Phase 5 validation. It reflects the current sandbox monetization implementation and marks production-only integrations as blockers where they are not in code yet.

## Launch

```text
Native splash
→ Flutter startup
→ Firebase initializes best-effort
→ StorageService initializes and migrates progress
→ AppStartupController reports loading, ready, or recoverable error
→ GoRouter resolves first destination
```

Firebase Analytics and Crashlytics failures do not block gameplay. Storage initialization failures are shown as recoverable startup errors by the app bootstrapper.

## New Player

```text
/
→ /onboarding
→ cultural introduction
→ /tutorial
→ guided tile match, blocked-tile explanation, Hint introduction
→ Home
→ Continue
→ /level/1
→ /game/1
→ Win result
→ Reward reveal
→ optional rewarded double Cowries
→ Next Level
```

Onboarding and tutorial completion are separate local flags. Tutorial replay is available from Settings.

## Returning Player

```text
Launch
→ Home
→ wallet, booster, chapter, level, and star summary
→ Continue
→ next unfinished pre-level screen
→ Gameplay
```

Home also links to Journey, Daily Reward, Adinkra Collection, Shop, How to Play, and Settings.

## Journey and Replay

```text
Home
→ Journey
→ five chapter sections
→ completed levels can be replayed
→ locked levels explain progression requirement
→ current/next level opens Pre-Level
```

Normal players cannot start locked levels. Developer Level Tester remains isolated behind debug/developer configuration.

## Gameplay

```text
Pre-Level
→ Game
→ match free identical tiles
→ use owned Hint, Shuffle, or Open Path boosters
→ optional rewarded Hint/Shuffle only when inventory is empty
→ Pause/Resume/Quit
→ Win or Loss
```

The game remains untimed and playable without purchases. Auto-shuffle attempts to recover stuck boards before a loss is declared.

## Win

```text
GameStatus.won
→ Result
→ analytics level_completed
→ economy rewards granted idempotently
→ progress saved
→ interstitial eligibility state updated
→ reward reveal
→ optional rewarded double Cowries
→ Next Level / Chapter Complete / Campaign Complete / Replay / Home
```

Developer test wins skip normal progress, economy rewards, and monetization state.

## Loss

```text
No moves and auto-shuffle failed
→ Result
→ analytics level_failed
→ optional rewarded retry Shuffle
→ Retry / Replay / Home
```

Forced interstitials are never eligible immediately after a loss.

## Daily Rewards and Collection

```text
Home → Daily Reward → claim once per local date
Home → Collection → browse unlocked and locked Adinkra symbols
```

Daily reward state, collection unlocks, and achievements are local SharedPreferences data.

## Shop

```text
Home
→ Shop
→ Featured / Boosters / Cowries / Cosmetics / Remove Ads / Restore
→ sandbox product state
→ centralized monetization service
→ economy or entitlement grant
```

Current implementation is SDK-neutral. Live ads, live billing, localized prices, receipt validation, and consent UI are release blockers before a production monetized build.
