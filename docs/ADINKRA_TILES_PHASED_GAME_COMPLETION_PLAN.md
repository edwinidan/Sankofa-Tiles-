# Adinkra Tiles — Phased Game Completion & Monetization Implementation Plan

> **Project:** Adinkra Tiles (formerly Sankofa Tiles)  
> **Framework:** Flutter + Riverpod + GoRouter  
> **Current Version:** 1.0.0+3  
> **Current Campaign:** 50 levels  
> **Document Purpose:** Break the remaining game-completion and monetization work into controlled implementation phases that can be assigned to AI coding agents one phase at a time.

---

## 1. Current Project Context

Adinkra Tiles is a culturally inspired Mahjong solitaire game built with Flutter. The core game engine is functional and includes:

- 50 playable levels
- Solvable board generation
- Tile matching and free-tile validation
- Linear progression
- Score and star calculation
- Audio and haptics
- Firebase Analytics
- Firebase Crashlytics
- SharedPreferences persistence
- Developer level testing
- Automated tests

The game is technically playable, but the experience surrounding gameplay is incomplete. The current flow is close to:

```text
Launch
  → Home
  → Play
  → Game
  → Result
  → Next Level
```

The target experience should become:

```text
Native Splash
  → App Initialization / Loading
  → First-Time Introduction
  → Interactive Tutorial
  → Home
  → Journey / Chapter Progress
  → Pre-Level
  → Gameplay
  → Win / Lose Result
  → Reward Reveal
  → Next Level / Replay / Home
```

Supporting systems will later include:

```text
Pause Menu
Daily Rewards
Cowrie Currency
Booster Inventory
Adinkra Collection
Achievements
Shop
Rewarded Ads
Interstitial Ads
In-App Purchases
Restore Purchases
```

---

# 2. Global Implementation Rules

Every AI coding agent working on this project must follow these rules.

## 2.1 Do Not Implement Multiple Phases at Once

Each phase must be completed, tested, reviewed, and documented before the next phase begins.

Do not pre-implement features from later phases unless a minimal interface or model is required to keep the current phase extensible.

## 2.2 Preserve Existing Gameplay

Do not rewrite the board generator, matching rules, progression logic, score system, or level definitions unless a phase explicitly requires it.

Existing tests must remain passing.

## 2.3 Follow Existing Architecture

Use the existing architecture:

- Riverpod for shared state
- GoRouter for navigation
- Immutable models with `copyWith`
- Services injected through providers
- SharedPreferences through the existing storage abstraction
- Firebase Analytics through the existing analytics abstraction
- Crashlytics through the existing crash-reporting abstraction

Do not introduce a second state-management framework.

## 2.4 Maintain Visual Consistency

The main game identity must use:

- Dark green / teal backgrounds
- Antique gold accents
- Cream parchment surfaces
- Cinzel for display headings
- Nunito for body text
- Adinkra-inspired decorative details
- Calm, premium, culturally respectful presentation

Remove or migrate screens that still use the unrelated navy `AppColors` palette where it causes inconsistency.

## 2.5 Mobile-First Requirements

- Portrait orientation only
- Android and iOS supported
- Responsive on small and large phones
- Respect safe areas
- Avoid clipped controls
- Avoid fixed pixel assumptions
- Handle interrupted lifecycle states safely

## 2.6 Quality Requirements for Every Phase

At the end of each phase:

1. Run `dart format`.
2. Run `flutter analyze`.
3. Run all existing tests.
4. Add tests for new important logic.
5. Verify navigation back behavior.
6. Verify state restoration after app restart where applicable.
7. Check Android and iOS layouts.
8. Update project documentation.
9. Produce a concise implementation report.
10. Do not claim success if tests or analysis fail.

---

# 3. Phase Overview

| Phase | Status | Name | Main Goal |
|---|---|---|---|
| Phase 0 | Completed | Audit and Game-Flow Documentation | Map the current project before changing code |
| Phase 1 | Completed | Launch Experience and Visual Foundation | Fix splash, loading, theme consistency, transitions, and app shell |
| Phase 2 | Completed | Complete Core Game Flow | Add tutorial, Journey, pre-level, pause, result, and chapter screens |
| Phase 3 | Completed | Rewards, Currency, Boosters, and Collection | Build the meta-game and player reward loop |
| Phase 4 | Completed | Shop, Ads, and In-App Purchases | Add monetization only after the economy exists |
| Phase 5 | Completed | QA, Balancing, Analytics, and Release Readiness | Validate the full experience before production release |

---

# 4. Phase 0 — Audit and Game-Flow Documentation

**Status:** Completed  
**Completion Report:** `docs/PHASE_0_AUDIT_REPORT.md`

## Goal

Understand the current codebase precisely before implementation begins. Produce documentation showing every screen, route, provider, persistence key, analytics event, and gameplay transition.

## Do Not

- Do not redesign screens.
- Do not add monetization.
- Do not refactor working game logic.
- Do not delete existing files.
- Do not change progression behavior.

## Required Deliverables

Create or update:

```text
docs/
├── CURRENT_GAME_FLOW.md
├── SCREEN_INVENTORY.md
├── STATE_AND_STORAGE_MAP.md
├── ANALYTICS_EVENT_MAP.md
├── DESIGN_SYSTEM_AUDIT.md
└── PHASE_0_AUDIT_REPORT.md
```

## Audit Requirements

Document:

- Every GoRouter route
- Every screen and entry point
- All dialogs, sheets, overlays, and result states
- How first launch is detected
- How onboarding completion is persisted
- How the next unfinished level is resolved
- How win and loss navigation works
- How settings are stored
- How level progress is stored
- How audio is initialized
- How Firebase is initialized
- How startup failures are currently handled
- Which screens use `SankofaGameTheme`
- Which screens use the navy `AppColors` palette
- Existing animation assets and empty asset directories
- Existing app icon and splash configuration
- Current accessibility labels and missing semantics
- Existing analytics events
- Existing Crashlytics reporting
- Tests that protect the current behavior

## Required Game-Flow Diagram

Include a clear diagram covering:

```text
Cold Launch
Warm Launch
First-Time User
Returning User
Start Level
Pause
Resume
Restart
Win
Lose
Next Level
Replay
Exit to Home
Complete Final Level
Developer-Level Test
```

## Acceptance Criteria

- No production behavior is changed.
- Documentation matches the actual code.
- All routes and persistence keys are accounted for.
- Any uncertainty is marked explicitly.
- Existing tests remain passing.

## Copy-Paste Prompt for the AI Agent

```text
You are working on the Flutter project Adinkra Tiles.

Your task is to complete Phase 0 only: audit the existing codebase and document the current game flow before making product changes.

Read the full project carefully, including:
- lib/main.dart
- lib/app.dart
- router configuration
- all screens
- all providers and services
- progress persistence
- settings persistence
- Firebase initialization
- analytics and Crashlytics utilities
- Android and iOS splash/icon configuration
- existing tests
- pubspec.yaml
- asset folders

Create these Markdown files:
- docs/CURRENT_GAME_FLOW.md
- docs/SCREEN_INVENTORY.md
- docs/STATE_AND_STORAGE_MAP.md
- docs/ANALYTICS_EVENT_MAP.md
- docs/DESIGN_SYSTEM_AUDIT.md
- docs/PHASE_0_AUDIT_REPORT.md

The documentation must show:
1. Every current route and screen.
2. First-time and returning-user startup flows.
3. Level start, pause, win, loss, replay, next-level, and final-level flows.
4. Riverpod providers and their responsibilities.
5. SharedPreferences keys and legacy migration behavior.
6. Existing analytics events and Crashlytics coverage.
7. Theme inconsistencies between SankofaGameTheme and AppColors.
8. Missing accessibility semantics.
9. Existing splash and icon state.
10. Risks that later phases must account for.

Do not redesign or implement new product features in this phase.
Do not change gameplay behavior.
Do not begin monetization work.
Only make tiny code corrections if required to complete analysis, and document every correction.

After completing the audit:
- run dart format if any code changed
- run flutter analyze
- run all tests
- provide a concise report of findings, files created, risks, and verification results
```

---

# 5. Phase 1 — Launch Experience and Visual Foundation

**Status:** Completed  
**Completion Report:** `docs/PHASE_1_IMPLEMENTATION_REPORT.md`

## Goal

Make the game feel intentional from the moment it opens and establish a consistent visual and navigation foundation for later screens.

## Included Work

- Custom Android and iOS app icon verification
- Dark branded native splash
- Flutter initialization/loading screen
- Startup state controller
- Loading, success, recoverable error, and fatal error states
- Consistent green-and-gold theme
- Shared screen-transition system
- Reusable game screen scaffold
- Accessibility foundation
- Button press, disabled, loading, and focus states

## 5.1 Native Splash

Replace the white Android splash with a branded dark splash.

Target appearance:

```text
Dark green background
Centered Adinkra Tiles logo
Subtle antique-gold accent
No white flash between native splash and Flutter
```

The native splash must remain static and lightweight.

## 5.2 App Initialization Screen

Add an initialization screen after the native splash.

It may initialize:

- Firebase readiness
- StorageService
- Settings
- Player progress
- Audio
- First-launch status
- Future monetization interfaces
- Daily reward status placeholder
- Inventory placeholder

Suggested status text:

```text
Preparing the Grand Archive…
Arranging the tiles…
Restoring your journey…
Gathering ancient symbols…
```

Do not add an artificial delay. Continue immediately once required initialization is complete.

## 5.3 Startup State

Create a clear startup state model, such as:

```dart
enum AppStartupStatus {
  loading,
  ready,
  recoverableError,
  fatalError,
}
```

The exact implementation may differ, but startup must not rely on scattered booleans.

## 5.4 Error States

Provide:

- Retry button for recoverable initialization failures
- Safe fallback if non-critical services fail
- Crashlytics logging for initialization exceptions
- User-friendly message without technical stack traces

## 5.5 Theme Unification

Create or strengthen shared components for:

- Screen background
- Parchment panel
- Game dialog
- Primary gold button
- Secondary button
- Icon button
- Section heading
- Currency badge placeholder
- Modal overlay
- Loading indicator
- Error state

Migrate the in-game settings presentation away from the mismatched navy palette.

## 5.6 Route Transitions

Add subtle transitions:

- Fade for startup and home
- Fade/slide for normal screen navigation
- Scale/fade for dialogs
- No excessive or slow animation
- Respect reduced-motion accessibility settings where possible

## 5.7 Accessibility Foundation

Add:

- Semantics labels to major buttons
- Minimum touch targets
- Sufficient text contrast
- Scalable text handling
- Logical screen-reader order
- Reduced-motion-aware helpers where practical

## Acceptance Criteria

- No white launch flash on supported Android versions.
- App initialization has explicit loading and error states.
- Existing startup behavior still works.
- First-time and returning users reach the correct screen.
- Major shared components use one visual identity.
- Navigation transitions are consistent.
- Existing gameplay tests remain passing.
- New startup logic has tests.

## Copy-Paste Prompt for the AI Agent

```text
Implement Phase 1 only for Adinkra Tiles: Launch Experience and Visual Foundation.

First read the Phase 0 documentation and inspect the actual code before changing anything.

Implement:
1. A branded dark native splash for Android and iOS.
2. Verification or correction of the custom app icon setup.
3. A Flutter startup/loading screen that performs real initialization without artificial delay.
4. A centralized startup state model with loading, ready, recoverable error, and fatal error handling.
5. Retry behavior for recoverable startup failures.
6. Crashlytics reporting for startup exceptions.
7. Shared green-and-gold game UI components.
8. Migration of obvious navy-palette in-game UI inconsistencies to the primary game theme.
9. Reusable route transitions.
10. Accessibility foundations including semantics, minimum touch targets, contrast, text scaling, and reduced-motion-aware animation helpers where practical.

Do not implement:
- Journey screen
- Interactive tutorial
- Pre-level screen
- Rewards
- Currency
- Boosters
- Shop
- Ads
- In-app purchases

Preserve existing gameplay, progression, and routes unless a minimal routing adjustment is necessary for startup.

Add or update tests for:
- startup state transitions
- first-time user routing
- returning-user routing
- recoverable initialization failure
- retry behavior

At completion:
- run dart format
- run flutter analyze
- run all tests
- update project documentation
- produce a Phase 1 implementation report listing changed files, design decisions, remaining risks, and verification results
```

---

# 6. Phase 2 — Complete Core Game Flow

**Status:** Completed  
**Completion Report:** `docs/PHASE_2_IMPLEMENTATION_REPORT.md`

## Goal

Make the game feel like a complete commercial mobile game before adding an economy or monetization.

## Included Screens and Systems

- Refined first-time introduction
- Interactive tutorial level
- Improved Home screen
- Journey / Chapter Progress screen
- Pre-level screen
- Improved gameplay HUD
- Pause overlay
- Win result screen
- Loss / no-moves screen
- Chapter-complete screen
- Final campaign-complete screen
- Consistent navigation and state handling

---

## 6.1 First-Time Introduction

Keep cultural introduction concise.

The introduction should explain:

- What Adinkra symbols are
- That the game is inspired by Ghanaian cultural heritage
- The basic objective
- That an interactive tutorial will teach the controls

Do not overload the user with four pages of gameplay instructions.

## 6.2 Interactive Tutorial

Create a small controlled board with approximately six tiles.

Tutorial steps:

1. Highlight a free tile.
2. Ask the user to select it.
3. Highlight the matching tile.
4. Animate the successful pair removal.
5. Demonstrate a blocked tile.
6. Explain that at least one side must be open.
7. Introduce the Hint button.
8. Let the player clear the final pair.
9. Mark the tutorial complete.
10. Continue to Home or the first campaign level.

Requirements:

- Guided hand or pointer animation
- Pulsing highlight
- Short instructions
- Input restricted to the required action where necessary
- Tutorial can be replayed from Settings or How to Play
- Tutorial completion persists
- Tutorial does not save normal campaign progress
- Analytics events for start, step completion, skip, replay, and completion

## 6.3 Improved Home Screen

The Home screen should show:

- Current chapter
- Next unfinished level
- Campaign progress
- Stars earned
- Main `CONTINUE` button
- Journey entry
- Daily Reward placeholder for Phase 3
- Adinkra Collection placeholder for Phase 3
- Shop placeholder hidden until Phase 4
- Settings access

The primary action remains direct continuation to the next unfinished level.

## 6.4 Journey / Grand Archive Screen

Add a visible campaign-progression screen.

It should display the five chapters:

1. First Symbols — Levels 1–10
2. Paths of Wisdom — Levels 11–20
3. Heritage — Levels 21–30
4. Ancestral Trials — Levels 31–40
5. Grand Archive — Levels 41–50

Show:

- Chapter title
- Chapter artwork or decorative header
- Completed levels
- Locked levels
- Star ratings
- Current level
- Chapter completion status
- Replay access for completed levels
- Locked-state explanation
- Main Continue action

Do not allow normal players to start locked levels.

Developer Level Tester behavior must remain isolated.

## 6.5 Pre-Level Screen

Before gameplay, show:

- Level number
- Chapter
- Tile count
- Layer count
- Optional board silhouette or layout preview
- Best score
- Best stars
- Booster area placeholder for Phase 3
- Play button
- Back button

The player should be able to move through this screen quickly.

## 6.6 Gameplay HUD

Improve the in-game layout to include:

- Pause
- Level number
- Score
- Remaining pairs or remaining tiles
- Combo / streak feedback
- Hint
- Shuffle
- Future Undo placeholder only if needed
- Clear blocked-tile feedback
- Clear no-moves feedback
- Smooth score updates
- Safe-area support

Do not add a timer. The current game identity remains calm and untimed.

## 6.7 Pause Overlay

Include:

- Resume
- Restart Level
- Sound toggle
- Music toggle
- Haptics toggle
- How to Play
- Exit to Home

Show confirmation before restart or exit when current progress will be lost.

## 6.8 Win Result Screen

Add a staged result sequence:

1. Final match completes.
2. Board celebration begins.
3. Level complete title appears.
4. Stars reveal one at a time.
5. Score counts upward.
6. Statistics appear.
7. Reward area placeholder appears for Phase 3.
8. Next Level becomes available.

Show:

- Stars
- Score
- Best score
- Best streak
- Pairs matched
- Shuffles used
- Next Level
- Replay
- Home

Do not add rewarded ads yet.

## 6.9 Loss / No-Moves Screen

Provide:

- Clear reason for failure
- Retry
- Restart
- Home
- Future rescue-booster placeholder hidden until Phase 3
- No interstitial ad

## 6.10 Chapter Completion

After levels 10, 20, 30, 40, and 50, show a dedicated milestone screen.

Include:

- Chapter name
- Total chapter stars
- Completion celebration
- Featured Adinkra symbol
- Short cultural meaning
- Next chapter preview
- Continue button

Level 50 must use a distinct campaign-complete experience.

## Acceptance Criteria

- A new player can understand the game without external explanation.
- Tutorial state persists and can be replayed.
- Journey accurately reflects progress and stars.
- Locked levels cannot be started through normal UI.
- Home always resolves the correct next level.
- Pre-level data matches the selected level.
- Pause, restart, exit, win, loss, chapter completion, and final completion work correctly.
- Developer testing remains isolated.
- No ads, currency, or purchases are introduced.
- Navigation tests cover major flows.

## Copy-Paste Prompt for the AI Agent

```text
Implement Phase 2 only for Adinkra Tiles: Complete Core Game Flow.

Read the Phase 0 audit and Phase 1 report first. Preserve the existing board generator, matching rules, score rules, progression storage, and developer tester isolation.

Implement:
1. A concise cultural first-time introduction.
2. A real interactive tutorial using a controlled small board.
3. A redesigned Home screen showing current chapter, next unfinished level, stars, progress, Continue, Journey, and Settings.
4. A Journey / Grand Archive screen showing all five chapters and all 50 levels.
5. Replay access for completed levels only.
6. Locked-state handling for unavailable levels.
7. A pre-level screen with level information and best results.
8. An improved gameplay HUD with pause, score, level, remaining tiles or pairs, streak feedback, Hint, and Shuffle.
9. A pause overlay with Resume, Restart, audio controls, How to Play, and Exit.
10. A polished win result screen with staged star and score reveal.
11. A clear loss / no-moves screen.
12. Chapter-complete screens after levels 10, 20, 30, and 40.
13. A distinct campaign-complete screen after level 50.
14. Analytics for important screen and tutorial events.

Do not implement:
- Player currency
- Daily rewards
- Booster inventory
- Achievements
- Shop
- Ads
- In-app purchases

The Home Continue button must still go directly to the correct next unfinished level flow.
The Journey screen is for visibility and replay, not for bypassing progression.
The Developer Level Tester must never save normal player progress.

Add tests for:
- tutorial completion and replay
- next unfinished level presentation
- locked-level behavior
- completed-level replay
- pause/resume
- restart confirmation
- exit confirmation
- win navigation
- loss navigation
- chapter completion routing
- final campaign completion
- developer test isolation

At completion:
- run dart format
- run flutter analyze
- run all tests
- update documentation
- produce a Phase 2 report listing all implemented screens, navigation flows, tests, known limitations, and verification results
```

---

# 7. Phase 3 — Rewards, Currency, Boosters, and Collection

**Status:** Completed  
**Completion Report:** `docs/PHASE_3_IMPLEMENTATION_REPORT.md`

## Goal

Create the player reward loop that will later support fair ads and in-app purchases.

Target loop:

```text
Play
  → Complete Level
  → Earn Rewards
  → Unlock Symbols
  → Collect Currency
  → Spend on Helpful Items or Cosmetics
  → Return and Play Again
```

## Included Systems

- Cowrie soft currency
- Player wallet
- Booster inventory
- Level reward calculation
- Daily rewards
- Adinkra Collection
- Achievements
- Reward reveal UI
- Chapter rewards
- Economy persistence
- Economy analytics
- Migration and corruption recovery

---

## 7.1 Cowrie Currency

Use **Cowries** as the soft currency.

The game should briefly explain that cowrie shells have historical cultural and economic significance in West Africa.

Store currency as a non-negative integer.

Required operations:

- Read balance
- Add currency
- Spend currency
- Reject invalid spending
- Prevent negative balance
- Record transaction reason
- Restore safely after restart
- Migrate future schema versions

Use a central wallet service or notifier. Do not modify balances directly from screens.

## 7.2 Booster Inventory

Initial boosters:

### Hint

Highlights a safe matching pair.

### Shuffle

Rearranges remaining tiles into a solvable state.

### Undo

Reverses the most recent valid match if technically safe and supported by a bounded game-state history.

If Undo introduces excessive instability, document the risk and implement a safe alternative only after review. Do not fake Undo.

### Open Path

Automatically resolves or removes one blocking pair selected by game-safe logic.

Every booster must have:

- Inventory count
- Spend validation
- UI state
- Analytics event
- Persistence
- Clear behavior when count is zero

Boosters must not silently spend premium value.

## 7.3 Reward Calculation

Reward levels based on:

- Level completion
- Star rating
- First completion
- Replay completion
- Chapter completion
- Achievement completion

Prevent easy replay farming.

Possible rule structure:

```text
First completion: full reward
Improved star rating: improvement reward
Replay with no improvement: very small reward or no currency reward
Chapter completion: one-time bonus
Achievement: one-time reward
```

All values must be configurable in one economy configuration file.

## 7.4 Daily Reward

Implement a seven-day reward cycle.

Example structure:

```text
Day 1 — Cowries
Day 2 — Hint
Day 3 — Cowries
Day 4 — Shuffle
Day 5 — Cowries
Day 6 — Booster Chest
Day 7 — Cosmetic or larger reward
```

Requirements:

- Local date handling
- Protection against duplicate same-day claims
- Clear next-claim state
- Streak behavior documented
- Clock-change edge cases handled reasonably
- Analytics for view, claim, missed day, cycle completion
- No ad multiplier yet

## 7.5 Adinkra Collection

Transform Tile Preview into a progression-based Adinkra Collection.

Each item may show:

- Symbol
- Akan name
- English meaning
- Associated proverb
- Short explanation
- Unlock source
- Locked silhouette before discovery

Requirements:

- Existing cultural content must be reviewed for accuracy.
- Do not invent meanings.
- Collection unlocks must be deterministic.
- Previously completed players must receive correct backfilled unlocks.
- Collection progress persists.
- Collection is accessible from Home.

## 7.6 Achievements

Initial achievement categories:

- First level completed
- First three-star level
- Five-match streak
- Ten levels completed
- Complete a level without Hint
- Complete a level without Shuffle
- Complete a chapter
- Discover a set number of Adinkra symbols
- Earn a set number of stars
- Complete all 50 levels

Achievements should reward:

- Cowries
- Boosters
- Cosmetic unlocks

Achievement rewards must be claim-once.

## 7.7 Reward Reveal

Update the result flow to show:

- Base reward
- Star bonus
- First-clear bonus
- New best result
- New symbol unlocked
- Achievement completed
- Updated Cowrie balance

Do not include ads yet.

## Acceptance Criteria

- Currency cannot become negative.
- All economy transactions are centralized.
- Booster counts persist.
- Rewards cannot be claimed repeatedly through simple navigation.
- Daily rewards cannot be claimed twice on the same eligible day.
- Existing players receive safe migration.
- Collection unlocks match progress.
- Achievement rewards are claim-once.
- No real-money purchases or ads are included.
- Economy logic has unit tests.

## Copy-Paste Prompt for the AI Agent

```text
Implement Phase 3 only for Adinkra Tiles: Rewards, Currency, Boosters, and Collection.

Read all previous phase reports first. Do not begin ads or in-app purchase integration.

Implement:
1. A centralized Cowrie wallet with non-negative balances and transaction reasons.
2. Persistent booster inventory.
3. Initial boosters: Hint, Shuffle, Undo only if technically safe, and Open Path.
4. Central configurable economy values.
5. First-clear, star-improvement, chapter, and achievement rewards.
6. Replay-farming prevention.
7. A seven-day daily reward system.
8. A progression-based Adinkra Collection replacing the unrestricted Tile Preview behavior.
9. Locked silhouettes and deterministic symbol unlocks.
10. Backfilled collection unlocks for existing player progress.
11. Achievements with one-time claimable rewards.
12. Reward reveal UI on the result screen.
13. Wallet, inventory, reward, collection, daily reward, and achievement analytics.
14. Safe persistence migration and corrupted-data fallback.

Cultural accuracy is required. Do not invent Adinkra meanings, names, or proverbs. Reuse verified project data and clearly mark any missing content for later review.

Do not implement:
- Google Mobile Ads
- Rewarded ads
- Interstitial ads
- Banner ads
- Billing products
- Real-money purchases
- Remove Ads
- Starter Pack

Add tests for:
- adding and spending Cowries
- insufficient balance
- non-negative balance enforcement
- transaction idempotency
- booster spending
- zero-inventory handling
- first-clear rewards
- replay reward restrictions
- star-improvement rewards
- daily reward eligibility
- duplicate daily claims
- achievement claim-once behavior
- collection unlock backfill
- persistence migration
- corrupted storage recovery

At completion:
- run dart format
- run flutter analyze
- run all tests
- update documentation
- provide a Phase 3 report including the economy table, storage schema, migration behavior, reward rules, tests, and remaining risks
```

---

# 8. Phase 4 — Shop, Ads, and In-App Purchases

**Status:** Completed  
**Completion Report:** `docs/PHASE_4_IMPLEMENTATION_REPORT.md`

## Goal

Add monetization in a way that fits the completed game loop and does not damage player trust.

## Included Systems

- Shop
- Product catalog abstraction
- Rewarded ads
- Controlled interstitial ads
- Remove Ads purchase
- Starter Pack
- Booster packs
- Cowrie packs
- Cosmetic products
- Purchase restoration
- Purchase loading, success, cancellation, and failure states
- Ad frequency controls
- Consent and privacy handling where required
- Monetization analytics
- Test-mode and production-mode separation

---

## 8.1 Monetization Principles

- Rewarded ads are the primary ad format.
- Interstitials are limited and never shown during gameplay.
- Do not show an interstitial immediately after a loss.
- Do not show an interstitial immediately after a rewarded ad.
- Do not show ads to users who purchased Remove Ads, except optional rewarded ads they voluntarily request.
- Do not use banners in the initial release.
- Purchases must never silently fail or silently consume value.
- Purchases must be restorable where platform rules require it.
- Product IDs must be centralized and environment-aware.

## 8.2 Shop Sections

```text
Featured
Boosters
Cowries
Cosmetics
Remove Ads
Restore Purchases
```

## 8.3 Initial Product Types

### Remove Ads

Removes forced interstitial advertisements permanently.

Optional rewarded ads remain available because the player chooses to watch them.

### Starter Pack

Suggested contents:

- Remove Ads
- Cowries
- Hints
- Shuffles
- Exclusive tile back

Ensure one-time purchase behavior if designed as a one-time product.

### Booster Packs

Examples:

- Hint Pack
- Shuffle Pack
- Mixed Booster Pack

### Cowrie Packs

Provide a small number of clearly differentiated bundles.

### Cosmetics

Examples:

- Tile backs
- Board themes
- Match effects

Cosmetics should not affect level fairness.

## 8.4 Rewarded Ad Placements

Allowed placements:

- Double level-completion Cowries
- Free rescue Shuffle
- Free Hint
- Bonus daily chest
- Small free Shop reward
- Optional retry assistance

Every rewarded ad flow must:

1. Explain the reward before playback.
2. Grant the reward only after verified completion callback.
3. Prevent duplicate callback rewards.
4. Handle load failure.
5. Handle dismissal.
6. Handle offline state.
7. Record analytics.
8. Never deduct player inventory if the ad fails.

## 8.5 Interstitial Ad Rules

Potential placements:

- After several completed levels
- Returning Home after a longer gameplay session
- Before entering a new chapter, only if not disruptive

Required controls:

- Minimum completed-level threshold
- Minimum time since last interstitial
- Level-count frequency cap
- Session frequency cap
- No display during first-session tutorial
- No display after purchase
- No display directly after rewarded ad
- No display after loss
- Remote-configurable values if Remote Config is added safely

A conservative initial rule may be one interstitial after every 2–4 completed levels with a time-based cooldown. Final values must be configurable.

## 8.6 Purchase States

Provide UI for:

- Loading products
- Product unavailable
- Purchase pending
- Purchase successful
- Purchase cancelled
- Purchase failed
- Restore in progress
- Restore completed
- Nothing to restore
- Network unavailable
- Already owned
- Verification pending

## 8.7 Purchase Security and Idempotency

- Do not grant consumables twice for repeated callbacks.
- Store transaction identifiers securely enough for the chosen package.
- Centralize entitlement logic.
- Validate permanent entitlements on startup.
- Restore non-consumable purchases.
- Document server-side verification limitations if no backend is used.
- Never log sensitive billing data.

## 8.8 Privacy and Consent

Update:

- Privacy policy
- Settings → Privacy / Legal
- Ad consent flow where legally required
- Data disclosure documentation
- Store listing declarations
- Analytics and ad SDK initialization order

Ads should not initialize in a way that violates required consent behavior.

## Acceptance Criteria

- Test ads are used during development.
- No production ad IDs are hard-coded into debug builds.
- Rewarded rewards are granted once only after completion.
- Interstitial frequency caps work.
- Remove Ads persists and restores correctly.
- Purchase states are visible and recoverable.
- Shop handles offline and unavailable products.
- Existing economy remains consistent.
- Purchase and ad events are tracked.
- No banner ads are introduced.
- All required store and privacy documentation is updated.

## Copy-Paste Prompt for the AI Agent

```text
Implement Phase 4 only for Adinkra Tiles: Shop, Ads, and In-App Purchases.

Read the completed Phase 3 economy documentation before changing code. The wallet and inventory systems must remain the single source of truth.

Implement:
1. A Shop screen with Featured, Boosters, Cowries, Cosmetics, Remove Ads, and Restore Purchases.
2. A centralized product catalog and product ID configuration.
3. Environment separation for debug/test and production monetization identifiers.
4. Rewarded ads for:
   - double completion reward
   - free rescue Shuffle
   - free Hint
   - bonus daily reward
   - optional small Shop reward
5. Strict rewarded-ad idempotency so rewards are granted once only after successful completion.
6. Controlled interstitial ads with:
   - first-session protection
   - tutorial protection
   - loss-screen protection
   - rewarded-ad cooldown
   - time cooldown
   - completed-level frequency cap
   - session cap
   - Remove Ads entitlement check
7. Remove Ads as a permanent entitlement.
8. A one-time Starter Pack.
9. Booster packs.
10. Cowrie packs.
11. Cosmetic products.
12. Purchase loading, pending, success, cancellation, failure, unavailable, offline, already-owned, and restore states.
13. Restore Purchases.
14. Startup entitlement restoration.
15. Monetization analytics.
16. Privacy, consent, legal, and store-declaration documentation updates.

Do not add banner ads in this phase.

Use test ad units and sandbox billing while developing.
Do not hard-code production IDs into source files that should be environment-configured.
Do not grant purchases or ad rewards from UI code directly.
Use centralized services and idempotent transaction handling.
Do not show an interstitial:
- during gameplay
- after a loss
- immediately after a rewarded ad
- during the first tutorial session
- to a Remove Ads owner

Add tests for:
- rewarded completion callback
- duplicate rewarded callback
- rewarded failure
- interstitial eligibility
- cooldown behavior
- session cap
- Remove Ads suppression
- product loading states
- purchase success
- cancellation
- failure
- already-owned state
- restore flow
- duplicate purchase callback
- permanent entitlement restoration
- consumable grant idempotency
- offline Shop behavior

At completion:
- run dart format
- run flutter analyze
- run all tests
- verify sandbox/test monetization behavior
- update privacy and monetization documentation
- provide a Phase 4 report listing product IDs, entitlement rules, ad placements, frequency rules, tests, configuration requirements, and known limitations
```

---

# 9. Phase 5 — QA, Balancing, Analytics, and Release Readiness

**Status:** Completed  
**Completion Report:** `docs/PHASE_5_FINAL_REPORT.md`

## Goal

Test the complete game as a product, balance the reward and monetization systems, fix edge cases, and prepare a production-ready release.

## Included Work

- Full game-flow QA
- Economy balancing
- Booster balancing
- Ad-frequency tuning
- Purchase restoration testing
- Offline behavior
- Lifecycle testing
- Device-size testing
- Accessibility review
- Performance review
- Analytics validation
- Crashlytics validation
- Store-readiness checklist
- Regression testing
- Documentation finalization

---

## 9.1 Full User Journeys

Test:

### New Player

```text
Install
→ Splash
→ Loading
→ Introduction
→ Interactive Tutorial
→ Home
→ Pre-Level
→ Level 1
→ Win
→ Reward
→ Next Level
```

### Returning Player

```text
Launch
→ Loading
→ Home
→ Continue
→ Pre-Level
→ Gameplay
```

### Loss and Recovery

```text
Gameplay
→ No Moves / Loss
→ Free recovery option where available
→ Rewarded rescue where available
→ Retry
→ Home
```

### Purchase Journey

```text
Shop
→ Select Product
→ Pending
→ Success
→ Entitlement or inventory granted
→ Restart App
→ Entitlement restored
```

### Restore Journey

```text
Fresh Install
→ Shop
→ Restore Purchases
→ Permanent entitlement restored
```

### Final Campaign Journey

```text
Level 50
→ Win
→ Reward
→ Campaign Complete
→ Journey shows full completion
→ Replay remains possible
```

## 9.2 Economy Balancing

Review:

- Cowries earned per level
- Cost of boosters
- Daily reward value
- Achievement rewards
- Chapter rewards
- Free-to-play ability to progress
- Replay farming
- Value of rewarded ads
- Value of paid bundles
- Starter Pack value
- Cosmetic pricing

The game must remain fully playable without purchases.

## 9.3 Ad Balancing

Validate:

- No first-session interruption
- No excessive ad repetition
- No ad immediately after loss
- No ad during emotional reward animation
- Rewarded ads always feel optional
- Interstitial cooldown works across navigation
- Remove Ads works after restart and restore
- Offline state does not block gameplay

## 9.4 Performance

Measure:

- Cold startup
- Warm startup
- Level generation
- Frame stability during match animations
- Result animations
- Journey scrolling
- Collection scrolling
- Memory behavior
- Audio lifecycle
- Ad and billing SDK initialization impact

## 9.5 Accessibility

Review:

- TalkBack
- VoiceOver
- Dynamic text scaling
- Contrast
- Touch targets
- Reduced motion
- Button labels
- Dialog focus order
- Locked-state descriptions
- Purchase-state announcements

## 9.6 Analytics Validation

Validate that events exist for:

- Startup
- Tutorial
- Home
- Journey
- Pre-level
- Level start
- Level complete
- Level fail
- Booster use
- Reward grant
- Daily reward
- Collection unlock
- Achievement
- Shop view
- Product view
- Purchase attempt
- Purchase success
- Purchase failure
- Restore
- Rewarded ad request
- Rewarded ad completion
- Interstitial display
- Remove Ads entitlement

Ensure no PII is sent.

## 9.7 Release Checklist

Verify:

- App icon
- Splash
- Version and build number
- Release signing
- Privacy policy
- Terms or purchase disclosures where needed
- Google Play Data Safety
- Apple privacy declarations
- AdMob app configuration
- Billing products active
- Test accounts removed
- Debug tools disabled in release
- Developer tester inaccessible in production unless intentionally enabled
- Production analytics enabled
- Crashlytics symbol upload
- Store screenshots updated
- Store description reflects monetization
- Restore Purchases visible on iOS
- Purchase prices loaded from store rather than hard-coded

## Acceptance Criteria

- Full campaign can be completed.
- No progression-breaking bug remains.
- No currency duplication path remains.
- No purchase duplication path remains.
- Offline gameplay remains available.
- Monetization failure does not block normal gameplay.
- Ads obey all frequency rules.
- Permanent entitlements restore.
- Accessibility blockers are documented or fixed.
- Release build passes analysis and tests.
- Production checklist is complete.

## Copy-Paste Prompt for the AI Agent

```text
Complete Phase 5 only for Adinkra Tiles: QA, Balancing, Analytics, and Release Readiness.

Do not add major new product features. This phase is for validation, balancing, bug fixing, regression protection, performance, accessibility, and production preparation.

Test and validate:
1. New-player flow.
2. Returning-player flow.
3. Tutorial replay.
4. Journey and locked-level behavior.
5. All 50 campaign levels.
6. Replay behavior.
7. Pause, restart, exit, win, loss, chapter completion, and campaign completion.
8. Cowrie wallet integrity.
9. Booster inventory integrity.
10. Daily rewards.
11. Collection unlocks.
12. Achievement claim behavior.
13. Rewarded ads.
14. Interstitial eligibility and cooldowns.
15. Remove Ads.
16. Starter Pack and consumables.
17. Purchase cancellation and failure.
18. Restore Purchases.
19. Offline gameplay.
20. App restart and lifecycle restoration.
21. Android and iOS layouts.
22. Small and large phones.
23. TalkBack, VoiceOver, text scaling, touch targets, contrast, focus order, and reduced motion.
24. Firebase Analytics event delivery.
25. Crashlytics test reporting.
26. Release signing and production configuration.

Balance:
- Cowrie earnings
- Booster costs
- Daily rewards
- Achievement rewards
- Chapter rewards
- Rewarded-ad value
- Interstitial frequency
- Product bundle value

The full game must remain playable without purchases.
Monetization failure must never block normal gameplay.
Do not hard-code store prices; display localized prices returned by the platform.

Create or update:
- docs/FINAL_GAME_FLOW.md
- docs/ECONOMY_BALANCE.md
- docs/MONETIZATION_RULES.md
- docs/ANALYTICS_VALIDATION.md
- docs/ACCESSIBILITY_REPORT.md
- docs/RELEASE_CHECKLIST.md
- docs/PHASE_5_FINAL_REPORT.md

At completion:
- run dart format
- run flutter analyze
- run all unit, widget, and integration tests
- build Android release AAB
- build or validate the iOS release configuration
- report every unresolved issue honestly
- provide final release-readiness status with blockers clearly separated from non-blocking improvements
```

---

# 10. Screen Inventory After All Phases

The completed game should contain or support the following screens and overlays.

## Launch and Onboarding

- Native Splash
- App Loading
- Startup Error
- Cultural Introduction
- Interactive Tutorial

## Core Navigation

- Home
- Journey / Grand Archive
- Pre-Level
- Gameplay
- Pause Overlay
- How to Play
- Settings

## Results and Progression

- Win Result
- Loss / No-Moves Result
- Chapter Complete
- Campaign Complete
- Reward Reveal

## Meta-Game

- Daily Reward
- Adinkra Collection
- Achievement List
- Achievement Detail or Claim State
- Shop
- Product Detail or Confirmation
- Purchase Status
- Restore Purchases

## Developer Only

- Developer Level Tester
- Debug economy controls, if added, must be excluded or protected in production

---

# 11. Final Navigation Target

```text
Native Splash
  ↓
Initialization
  ├── Recoverable Error → Retry
  ├── Fatal Error → Safe Error Screen
  └── Ready
       ↓
First Launch?
  ├── Yes → Cultural Introduction → Interactive Tutorial → Home
  └── No  → Home

Home
  ├── Continue → Pre-Level → Game
  ├── Journey → Chapter → Level → Pre-Level → Game
  ├── Daily Reward
  ├── Adinkra Collection
  ├── Achievements
  ├── Shop
  └── Settings

Game
  ├── Pause → Resume
  ├── Pause → Restart
  ├── Pause → Exit Home
  ├── Win → Result → Reward → Next Level / Replay / Home
  ├── Chapter End → Chapter Complete
  ├── Level 50 End → Campaign Complete
  └── Loss → Retry / Rescue / Home
```

---

# 12. Required Documentation Maintenance

After each phase, update:

- `PROJECT_REPORT.md`
- `PROJECT_CONTEXT.md`
- `GAME_FLOW.md`
- Relevant technical documentation
- Test inventory
- Storage schema
- Analytics event map
- Known issues
- Current version and implemented features

Do not leave project-context files describing old behavior after code changes.

---

# 13. Final Definition of Done

Adinkra Tiles is considered product-complete for the first monetized release when:

- Startup is branded and reliable.
- New players are taught through interaction.
- Progress is visible across 50 levels and five chapters.
- Gameplay has complete pause, win, loss, replay, and milestone flows.
- The game has a meaningful reward loop.
- Cowries and boosters are persistent and balanced.
- Adinkra Collection provides cultural progression.
- Daily rewards and achievements encourage return play.
- Rewarded ads provide voluntary value.
- Interstitial ads are limited and respectful.
- Remove Ads and other purchases work and restore correctly.
- Monetization failures do not block gameplay.
- The app is accessible at a reasonable baseline.
- Analytics and Crashlytics are validated.
- Release signing, privacy, store declarations, and production configuration are complete.
- All critical tests pass.
- No known progression, currency, or purchase-duplication blocker remains.
