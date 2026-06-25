# Adinkra Tiles — Project Report

## Overview

**Adinkra Tiles** is a culturally inspired Mahjong solitaire game built with Flutter. Players clear layered boards by matching free pairs of Ghanaian Adinkra symbol tiles, progress through a 50-level campaign, earn Cowries and boosters, unlock collection entries, and can use sandbox monetization flows for optional rewards and purchases.

**Target platforms:** Android and iOS, portrait only.  
**Current version:** 1.0.0+3.  
**Current release status:** Tested sandbox monetization build; production monetized release still blocked by live ad/billing SDK integration, receipt validation, consent/legal work, and store configuration.

## Stack

| Concern | Library |
|---|---|
| UI | Flutter |
| State | Riverpod |
| Routing | GoRouter |
| Persistence | SharedPreferences |
| Audio | audioplayers |
| Typography | google_fonts |
| Analytics | Firebase Analytics |
| Crash reporting | Firebase Crashlytics |
| External links | url_launcher |

No live ad SDK or live billing SDK is currently included.

## Architecture

```text
lib/
├── app.dart
├── main.dart
├── app_bootstrapper.dart
├── core/
│   ├── constants/
│   ├── economy/
│   ├── monetization/
│   ├── router/
│   ├── startup/
│   ├── theme/
│   └── utils/
├── models/
├── providers/
├── screens/
└── widgets/
```

Core state is managed through Riverpod providers. `StorageService` is injected at the app boundary and remains the persistence source for progress, settings, economy, collection, achievements, and local monetization entitlements. Economy grants go through `EconomyService`; monetization grants go through `MonetizationService`.

## Current User Flow

```text
Native splash
→ app startup/loading
→ onboarding for first-time users
→ interactive tutorial
→ Home
→ Journey / Daily Reward / Collection / Shop / Settings
→ Pre-Level
→ Gameplay
→ Win or Loss Result
→ Reward reveal / retry / next level / chapter milestone / campaign complete
```

The Home screen shows campaign progress, next level, total stars, Cowries, boosters, Journey, Daily Reward, Collection, Shop, tutorial replay, and Settings.

## Gameplay

- 50 levels across five chapters.
- Solvable board generation using random+solver or reverse-solved generation.
- Mahjong solitaire free-tile validation.
- Safe-move checks to avoid avoidable dead ends.
- Hint, Shuffle, and Open Path boosters.
- Auto-shuffle attempts recovery before no-moves loss.
- Score, streaks, stars, chapter milestones, and campaign completion.
- No timer; gameplay remains calm and untimed.

## Economy

Phase 3 added:

- Cowrie wallet.
- Booster inventory.
- Daily rewards.
- Level reward reveal.
- Collection unlocks.
- Achievement rewards.
- Idempotent reward transaction markers.

Economy data is local-only. Negative balances and boosters are clamped safely.

## Monetization

Phase 4 added SDK-neutral sandbox monetization:

- Shop route at `/shop`.
- Product catalog with Featured, Boosters, Cowries, Cosmetics, Remove Ads, and Restore.
- Remove Ads local entitlement.
- Starter Pack, booster packs, Cowrie packs, and cosmetic entitlement.
- Rewarded placements for double Cowries, free Hint, free Shuffle, daily bonus, shop gift, and retry assistance.
- Controlled interstitial eligibility state.
- Purchase, restore, failure, cancellation, offline, already-owned, and unavailable states.

Production blockers remain:

- Live Google Mobile Ads SDK.
- Live App Store / Play Billing SDK.
- Server-side receipt validation.
- Consent UI and store privacy declarations.
- Localized platform prices.

## Analytics and Crashlytics

Analytics events cover startup/navigation, tutorial, level lifecycle, gameplay actions, economy, collection, achievements, shop, purchases, restore, rewarded ads, interstitial eligibility, and Remove Ads entitlement. No event intentionally sends PII, receipts, or ad identifiers.

Crashlytics records fatal Flutter/platform errors and non-fatal storage, startup, audio, and board-generation failures when Firebase is available.

## Release Readiness

Automated checks now cover:

- Startup flows.
- Tutorial/progression flows.
- Locked level behavior.
- All 50 campaign levels.
- Board geometry.
- Header layout at compact widths.
- Economy idempotency.
- Monetization idempotency and ad frequency rules.
- Release configuration basics.

Manual checks still required:

- TalkBack and VoiceOver.
- High text scale.
- Store screenshots.
- Store privacy forms.
- Android AAB signing verification.
- iOS signing/profile validation.
- Live Firebase dashboard event validation.

## Verification

Phase 5 verification:

```text
flutter analyze
flutter test
```

Both passed during Phase 5. Build command results and remaining blockers are recorded in `docs/PHASE_5_FINAL_REPORT.md` and `docs/RELEASE_CHECKLIST.md`.

## Key Documentation

- `docs/FINAL_GAME_FLOW.md`
- `docs/ECONOMY_BALANCE.md`
- `docs/MONETIZATION_RULES.md`
- `docs/ANALYTICS_VALIDATION.md`
- `docs/ACCESSIBILITY_REPORT.md`
- `docs/RELEASE_CHECKLIST.md`
- `docs/PHASE_5_FINAL_REPORT.md`

*Last updated: 2026-06-25 — Phase 5 QA and release-readiness pass.*
