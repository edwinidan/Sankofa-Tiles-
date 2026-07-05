# CONTEXT.md — Sankofa Tiles (AI Handoff)

## Project Identity

**Sankofa Tiles** is a Flutter mobile puzzle game — a Mahjong solitaire tile-matching game themed around Ghanaian Adinkra symbols. Players match pairs of identical tiles on a 3D-layered board following classic Mahjong "free tile" rules. The game targets Android and iOS (portrait only), with a chapter-based campaign, in-game economy (cowries currency + boosters), tile collection unlocks, AdMob ads, and IAP monetization.

- **Package:** `com.sankofatiles.sankofa_tiles`
- **Version:** 1.0.4+7
- **Dart SDK:** >=3.0.0 <4.0.0

---

## Tech Stack

| Concern | Package | Version |
|---|---|---|
| State management | `flutter_riverpod` | ^2.5.1 |
| Routing | `go_router` | ^13.2.0 |
| Persistence | `shared_preferences` | ^2.2.3 |
| Audio | `audioplayers` | ^6.0.0 |
| Fonts | `google_fonts` (Cinzel + Nunito) | ^6.2.1 |
| SVG | `flutter_svg` | ^2.0.10+1 |
| Animations | `lottie` + `flutter_animate` | ^3.1.0 / ^4.5.0 |
| IDs | `uuid` | ^4.4.0 |
| Collections | `collection` | ^1.18.0 |
| Firebase | `firebase_core` + `firebase_analytics` + `firebase_crashlytics` | ^4.10.0 / ^12.4.2 / ^5.2.3 |
| Ads | `google_mobile_ads` | ^9.0.0 |
| URL launching | `url_launcher` | ^6.3.2 |
| Code gen | `riverpod_generator` + `build_runner` | dev |

---

## Directory Structure & Purpose

```
lib/
├── main.dart                         # Entry: Firebase init, portrait lock, runs AppBootstrapper
├── app.dart                          # SankofaTilesApp ConsumerWidget — creates GoRouter, applies dark theme
├── app_bootstrapper.dart             # AppBootstrapper — loading screen, storage init, AdMob init, ProviderScope

├── core/
│   ├── ads/
│   │   ├── ad_ids.dart               # Ad unit IDs, platform detection, test/production switching
│   │   ├── admob_service.dart        # Singleton — Mobile Ads SDK init, interstitial preload/cache/show, rewarded ad lifecycle
│   │   └── consent_service.dart      # Singleton — GDPR consent gathering, privacy options form
│   ├── config/
│   │   └── developer_tools_config.dart  # Gates developer features (debug-only or env flag)
│   ├── constants/
│   │   ├── tile_data.dart            # TileDefinition, kAllTiles, kTileIds (~90+ Adinkra symbols)
│   │   ├── level_data.dart           # LevelDefinition, SymbolCopyPlan, kLevels (50 handcrafted + 150 procedural = 200 levels)
│   │   ├── layout_data.dart          # TilePosition, NamedLayout, 50+ layout constants
│   │   ├── chapter_data.dart         # ChapterDefinition, kChapters (20 chapters of 10 levels each)
│   │   └── tile_unlock_data.dart     # TileUnlockRule — progressive symbol unlock schedule across 200 levels
│   ├── economy/
│   │   ├── economy_models.dart       # EconomyState, BoosterType, RewardGrantSummary, DailyReward, AchievementDefinition
│   │   ├── economy_config.dart       # Reward amounts, 7-day daily reward cycle, 10 achievements
│   │   └── economy_service.dart      # Idempotent cowrie/booster add/spend, daily claims, level rewards, achievements
│   ├── monetization/
│   │   ├── monetization_models.dart  # MonetizationState, ShopProduct, RewardedPlacement, InterstitialPlacement, PurchaseStatus
│   │   ├── monetization_config.dart  # IAP catalog (8 products), interstitial gating config, rewarded ad reward mapping
│   │   └── monetization_service.dart # Purchase/restore/rewarded-ad completion, interstitial decision engine (7 gating rules)
│   ├── router/
│   │   └── app_router.dart           # GoRouter: 13 routes + analytics observer + onboarding redirect
│   ├── startup/
│   │   └── app_startup.dart          # AppStartupController, startup loading screen, storage + AdMob bootstrap
│   ├── theme/
│   │   ├── app_colors.dart           # Archive/navy palette (used in overlays and in-game settings)
│   │   ├── app_text_styles.dart      # Cinzel/Nunito styles + archive text styles
│   │   ├── app_theme.dart            # AppTheme.darkTheme — Material 3 dark with gold color scheme
│   │   └── sankofa_game_theme.dart   # Primary visual theme: dark green/teal + parchment + gold
│   └── utils/
│       ├── storage_service.dart      # SharedPreferences wrapper — progress, settings, economy, monetization, ads state, migration
│       ├── audio_service.dart        # 4 SFX players + music player, togglable, .ogg assets
│       ├── haptic_service.dart       # Static HapticService — intensity-gated (off/low/med/high)
│       ├── board_solver.dart         # Mahjong free-tile logic, solvability checker, safe move detection
│       ├── board_layout_geometry.dart    # Dynamic tile sizing and board projection
│       ├── analytics_service.dart    # Firebase Analytics — screen views, gameplay, economy, monetization, ads events
│       └── crash_reporting_service.dart  # Firebase Crashlytics (fatal + non-fatal)

├── models/
│   ├── tile_model.dart               # TileModel — uid, def, position(row,col,layer), TileVisibility, isPeeked (immutable+copyWith)
│   ├── board_model.dart              # BoardModel — rows, cols, tiles list, tileAt(row,col)
│   ├── game_state.dart               # GameState — tiles, status, score, streaks, shufflesUsed, match animation, peek/stuck states
│   ├── game_launch_config.dart       # GameLaunchConfig, GameLaunchMode, GameResultConfig
│   └── level_model.dart              # LevelResult — levelId, bestScore, stars

├── providers/
│   ├── game_provider.dart            # GameNotifier — board generation, matching, unsafe-move blocking, auto-shuffle on stuck
│   ├── progress_provider.dart        # ProgressService — level unlock checks, next level, star queries, "how to play" prompt
│   ├── settings_provider.dart        # SettingsNotifier + SettingsState — user prefs, immediate persistence
│   ├── economy_provider.dart         # EconomyNotifier — cowries balance, boosters, daily rewards, collection, achievements
│   ├── monetization_provider.dart    # MonetizationNotifier — IAP purchases, rewarded ads, interstitial decisions
│   └── admob_provider.dart           # Lightweight providers exposing AdMobService.shared, ConsentService.shared

├── screens/
│   ├── home/home_screen.dart              # Main menu: Play, Journey, Shop, Daily Rewards, Settings, "How to Play", wallet summary
│   ├── onboarding/onboarding_screen.dart   # 4-page PageView (Culture, Rules, Symbols, Ready) — first launch only
│   ├── tutorial/tutorial_screen.dart       # Interactive step-by-step tutorial with practice board, supports replay
│   ├── journey/journey_screen.dart         # Chapter-based level select map with progress indicators
│   ├── pre_level/pre_level_screen.dart     # Level briefing — objectives, unlocked/required symbols
│   ├── daily/daily_reward_screen.dart      # 7-day reward cycle claim screen
│   ├── shop/shop_screen.dart               # IAP store: boosters, cowries, cosmetics, remove ads, restore purchases
│   ├── chapter/chapter_complete_screen.dart # Chapter completion celebration with stats and next chapter
│   ├── developer/developer_level_tester_screen.dart  # All levels with validation status — debug only
│   ├── game/
│   │   ├── game_screen.dart               # Gameplay — compact header + BoardWidget + control dock + overlays
│   │   └── widgets/
│   │       ├── board_widget.dart          # Dynamic board renderer: collision animations, particle bursts, score pops
│   │       ├── game_header.dart           # Compact header: Level/Score/Matches stats + progress bar
│   │       ├── game_control_dock.dart     # Hint, Shuffle, Pause/Resume — booster-inventory-aware
│   │       ├── game_board_backdrop.dart   # Dark green board surface with Adinkra motif
│   │       ├── parchment_background.dart  # Textured parchment gradient background
│   │       ├── tile_widget.dart           # Single tile: 3D slab, visibility states (hidden/covered/revealed), PNG-backed
│   │       └── hint_overlay.dart          # "Hint Active" instructional modal
│   ├── result/result_screen.dart           # Win (stars + economy rewards + collection unlocks + interstitial) / Lose (proverb + retry)
│   ├── settings/settings_screen.dart       # Audio, haptic, gameplay toggles, privacy policy, developer tools
│   └── preview/tile_preview_screen.dart    # Adinkra symbol reference with collection unlock tracking

└── widgets/
    ├── kente_button.dart       # Reusable parchment-on-dark ElevatedButton
    ├── cowrie_icon.dart        # Cowrie currency display icon widget
    ├── adinkra_divider.dart    # —— ◎ —— decorative separator
    ├── sankofa_background.dart # Dark green gradient + texture + vignette background
    └── tile_back.dart          # Tile back face rendering
```

---

## Architecture Pattern

**Layered architecture with Riverpod state management:**

```
UI Layer (screens/ + widgets/ )
    ↕ reads state, dispatches actions via providers
Provider Layer (providers/ ) — all business logic lives here
    ↕ uses
Data Layer (models/ ) — immutable domain types
    ↕ backed by
Service Layer (core/utils/ , core/economy/ , core/monetization/ , core/ads/ ) — platform I/O
    ↕ references
Constants (core/constants/ ) — pure data (tiles, levels, layouts, chapters, unlocks)
```

**Key rules:**
- All models are **immutable** with `copyWith()` — never mutate state in place.
- **Riverpod** is the single source of truth. Widgets are `ConsumerWidget`/`ConsumerStatefulWidget`.
- `StorageService` is injected via `ProviderScope` override in `AppBootstrapper` — swappable for tests.
- Audio is managed by `audioServiceProvider` which auto-syncs with settings and disposes on removal.
- No `setState` is used for game logic — all game state flows through `GameNotifier`.
- Ads, consent, economy, and monetization services are **singletons** (`shared`).
- Economy and monetization transactions use **idempotency keys** stored in SharedPreferences to prevent double-granting.

---

## State Management (Riverpod)

### Game Provider (`gameProvider`)
`StateNotifierProvider<GameNotifier, GameState>` — the game engine.

Key methods:
- `startLevel(levelId, difficulty, isDeveloperTest)` — builds the board from level definition, guarantees solvability
- `selectTile(uid)` — core interaction: select/deselect/match/mismatch with unsafe-move blocking
- `useHint()` — finds a valid free matching pair (prefers safe), highlights for 2s
- `shuffleRemaining()` — redistributes unmatched tile positions preserving pyramid structure, checks solvability
- `pauseGame()` / `resumeGame()` — suspends/resumes interaction
- `leaveGame()` — stops audio, resets state

Tile visibility states: `hidden` (not yet discoverable), `covered` (discoverable but behind another tile), `revealed` (free to select). Visible-only matching ensures progression through the pyramid.

**No timer.** The game has no time limit. `secondsElapsed` exists in the model but is never incremented.

### Settings Provider (`settingsProvider`)
`StateNotifierProvider<SettingsNotifier, SettingsState>` — user preferences.

State fields: `soundEnabled`, `musicEnabled`, `musicVolume`, `showTileNames`, `hapticIntensity`.

All setters write to both in-memory state and SharedPreferences immediately.

### Progress Provider (`progressProvider`)
`Provider<ProgressService>` — adapts StorageService for the UI layer.

Key properties: `isLevelUnlocked(id)`, `nextUnfinishedLevelId`, `hasCompletedAllLevels`, `totalStars`, `shouldShowHowToPlayPrompt` (true until 3 levels completed), `highestCompletedLevel`.

### Economy Provider (`economyProvider`)
`StateNotifierProvider<EconomyNotifier, EconomyState>` — in-game currency and boosters.

State fields: `cowries` (int), `boosters` (Map<BoosterType, int> — hint/shuffle/openPath), `unlockedCollectionIds` (Set of tile symbols), `claimedAchievementIds`, `dailyRewardDay`, `lastDailyClaimDate`.

Key operations: `grantLevelRewards(levelId, score, stars)` returns `RewardGrantSummary`, `claimDailyReward()`, `addCowries(amount, transactionId)`, `spendBooster(type)`, `canAffordBooster(type)`.

Analytics events are logged on every state change (wallet, boosters, daily claims, collections, achievements).

### Monetization Provider (`monetizationProvider`)
`StateNotifierProvider<MonetizationNotifier, MonetizationState>` — IAP and ads.

State fields: `products` (8 shop products), `entitlementIds` (remove_ads, tile_back_kente_gold), `ownedProductIds`, `purchaseStatus`, `offline`.

Key operations: `purchaseProduct(productId)`, `restorePurchases()`, `showRewardedAd(placement)`, `decideAndShowInterstitial(placement)`, `buyBoosterWithCowries(type)`.

### AdMob Providers (`admobProvider`)
Lightweight providers exposing `AdMobService.shared` and `ConsentService.shared` singletons plus a `privacyOptionsRequiredProvider`.

---

## Data Flow

```
AppBootstrapper
    ↓ init
StorageService (SharedPreferences, schema migration v3)
    ↓ inject via ProviderScope override
SankofaTilesApp → GoRouter(custom fade/slide-fade transitions)
    ↓
HomeScreen → Play/Journey/Shop/Settings/DailyReward
    ↓
PreLevelScreen → GameScreen (GameNotifier.startLevel())
    ↓ on win
ResultScreen → economyProvider.grantLevelRewards() + monetizationProvider.decideAndShowInterstitial()
    ↓
ProgressService.saveLevelResult() → StorageService
    ↓
unlocks next level, grants cowries/boosters/collection symbols
```

**App startup flow:**
1. `main.dart`: Firebase init, portrait lock → `runApp(AppBootstrapper())`
2. `AppBootstrapper`: Creates `AppStartupController`, calls `start()`
3. `start()`: Loads `StorageService` (SharedPreferences + campaign schema migration), fires `AdMobService.shared.initialize()` unawaited
4. Loading screen shown until ready (logo + animated indicator, or error + retry)
5. On success: `ProviderScope` with storage override → `SankofaTilesApp`

---

## Game Mechanics

### Board Generation
Two strategies depending on tile count:
- **≥40 tiles** (reverse-solved): Starts with empty board, greedily removes free tile pairs to build valid removal sequence, then assigns tile definitions in reverse. Up to 100 attempts.
- **<40 tiles** (random + solvability check): Generates random boards, checks solvability with BoardSolver (6,000 search nodes). Up to 12 attempts. Falls back to reverse-solved if all fail.
- Final solvability check (50,000 node budget). If unsolvable → loadFailed.

### Free Tile Rule
A tile is "free" (selectable) only if:
1. No tile in a higher layer covers it (2-unit span overlap check)
2. At least one lateral side (left or right) is open on its layer

### Tile Visibility
Tiles exist in one of three visibility states:
- **hidden**: Not yet discoverable — rendered as tile back, not interactable
- **covered**: Discoverable but physically blocked by a tile above — shows a peekable silhouette
- **revealed**: Fully visible, free, and selectable

Visibility transitions flow hidden → covered → revealed as upper layers are cleared.

### Match Flow
1. Tap free revealed tile → selected (lifts, brightens)
2. Tap same tile → deselect
3. Tap another free tile with same `def.id`:
   - **Unsafe move** (would make board unsolvable AND safe alternative exists) → BLOCKED (mismatch feedback)
   - **Safe or only option** → matched (+100 pts, particle burst, streak tracked, collision animation)
4. Tap different ID → mismatch shake, deselected after 600ms, streak reset

### Scoring
- 100 pts per match + streak bonus (3x→+50, 4x→+100, 5x+→+200)
- Shuffle penalty: -50 (clamped at 0)
- Star thresholds computed dynamically per level from complexity formula
- `currentStreak` and `bestStreak` tracked separately

### Win/Lose/Stuck
- **Win:** all tiles matched → star rating, economy rewards, tile collection unlocks, interstitial ad check
- **Stuck:** no available revealed matching pairs → auto-shuffles (free, no penalty). Only declares `lost` if shuffle fails.
- **No time-based loss.**

---

## Economy System

### Currency & Boosters
- **Cowries**: Earned from level completion (40 first clear, +12 per star improvement, 120 chapter completion), daily rewards, shop purchases, rewarded ads. Spent in shop for boosters.
- **Boosters**: hint (`BoosterType.hint`), shuffle (`BoosterType.shuffle`), open path (`BoosterType.openPath`). Earned via daily rewards, achievements, shop purchases, rewarded ads. Consumed during gameplay via the control dock.

### Daily Rewards
7-day cycle: Day 1 (40 cowries), Day 2 (1 hint), Day 3 (55 cowries), Day 4 (1 shuffle), Day 5 (75 cowries), Day 6 (hint+shuffle), Day 7 (120 cowries + open path). Date-keyed to prevent same-day double claims.

### Achievements
10 achievements: First Step, Golden Insight, Flow of Wisdom, Archive Walker, Clear Sight, Steady Path, Chapter Keeper, Symbol Seeker, Star Gatherer, Grand Archivist. Each grants cowries and/or boosters.

### Tile Collection
Progressive symbol unlocks across 200 levels. 10 starter tiles unlocked at level 1, common tiles spread across levels 2-80, advanced across 81-150, remaining across 151-200. Collection backfill runs on app load for completed levels.

---

## Monetization System

### IAP Products (8)
| Product | Type | Reward |
|---|---|---|
| Remove Ads | Non-consumable | `remove_ads` entitlement |
| Starter Pack | One-time bundle | Remove ads, 300 cowries, boosters, Kente Gold tile back |
| Hint Pack | Consumable | 8 hints |
| Shuffle Pack | Consumable | 6 shuffles |
| Mixed Booster Pack | Consumable | 4 hints + 4 shuffles + 2 open paths |
| Cowrie Pouch | Consumable | 250 cowries |
| Cowrie Basket | Consumable | 900 cowries |
| Kente Gold Tile Back | Cosmetic | `tile_back_kente_gold` entitlement |

Sandbox mode auto-enabled in debug builds. Products use `sandbox.adinkra_tiles.*` store IDs in sandbox, `adinkra_tiles.*` in production.

### Rewarded Ads (6 Placements)
`doubleCompletionCowries`, `freeRescueShuffle`, `freeHint`, `bonusDailyChest`, `smallShopReward`, `retryAssistance`. Each maps to a specific reward (cowries or boosters).

### Interstitial Ads — Gating Engine (7 Rules)
Shown only after completed levels (`InterstitialPlacement.afterCompletedLevels`). Must pass ALL checks:
1. User does NOT have `remove_ads` entitlement
2. Not the player's first session completion
3. Tutorial is not active
4. Under session cap (max 2 per session)
5. At least `minimumCompletedLevels` levels completed (2)
6. Frequency: every `completedLevelFrequency` wins (3)
7. Cooldown: 8 minutes between interstitials, 2 minutes after rewarded ads

Ad preloading with 55-minute cache age. Ads-only platform (Android, not Web).

### Consent
GDPR consent gathered at startup via `ConsentService`. Debug EEA geography in debug mode. Privacy options form available if required.

---

## Chapter System

20 chapters of 10 levels each (200 levels total):

| # | Chapter | Levels | Difficulty |
|---|---|---|---|
| 1 | Accra | 1–10 | Novice |
| 2 | Kumasi | 11–20 | Apprentice |
| 3 | Sekondi-Takoradi | 21–30 | Strategic |
| 4 | Obuasi | 31–40 | Advanced |
| 5 | Ho | 41–50 | Master |
| 6 | Kokrobite | 51–60 | Expert |
| 7 | Amanfrom | 61–70 | Elder |
| 8 | Cape Coast | 71–80 | Elder |
| 9 | Tamale | 81–90 | Legendary |
| 10 | Koforidua | 91–100 | Legendary |
| 11 | Ada Foah | 101–110 | Legendary |
| 12 | Sunyani | 111–120 | Legendary |
| 13 | Techiman | 121–130 | Legendary |
| 14 | Wa | 131–140 | Legendary |
| 15 | Elmina | 141–150 | Legendary |
| 16 | Axim | 151–160 | Mythic |
| 17 | Bolgatanga | 161–170 | Mythic |
| 18 | Winneba | 171–180 | Mythic |
| 19 | Akosombo | 181–190 | Mythic |
| 20 | Aburi | 191–200 | Mythic |

Progression is linear: complete level N to unlock N+1. `chapterForLevel(levelId)` and `isChapterFinalLevel(levelId)` helpers available.

---

## Routing (GoRouter)

| Route Name | Path | Screen | Transition |
|---|---|---|---|
| `home` | `/` | HomeScreen | Fade |
| `onboarding` | `/onboarding` | OnboardingScreen | Slide-fade |
| `tutorial` | `/tutorial?replay=1` | TutorialScreen | Slide-fade |
| `journey` | `/journey` | JourneyScreen | Slide-fade |
| `daily_reward` | `/daily-reward` | DailyRewardScreen | Slide-fade |
| `shop` | `/shop` | ShopScreen | Slide-fade |
| `pre_level` | `/level/:levelId` | PreLevelScreen | Slide-fade |
| `game` | `/game/:levelId` (extra: GameLaunchConfig) | GameScreen | Slide-fade |
| `result` | `/result` (extra: GameResultConfig) | ResultScreen | Fade |
| `chapter_complete` | `/chapter-complete/:levelId` | ChapterCompleteScreen | Fade |
| `settings` | `/settings` | SettingsScreen | Slide-fade |
| `tile_preview` | `/tile-preview` | TilePreviewScreen | Slide-fade |
| `developer_level_tester` | `/developer/levels` | DeveloperLevelTesterScreen | Slide-fade |

**Redirect:** `/` → `/onboarding` if `storage.isOnboardingComplete() == false`.

Custom transition types: `_fadePage` (180ms fade) and `_slideFadePage` (220ms slide+fade). Both respect `MediaQuery.disableAnimations` for reduced-motion accessibility.

---

## Visual Design

- **Theme:** Dark green/teal (#101A16 → #17241F gradient), antique gold (#B88A3A) accents, cream parchment panels
- **Tiles:** Cream/ivory face with dark gold 3D edge slab — resembles physical Mahjong tiles. Hidden/covered/revealed visual states with 3D flip animation.
- **Fonts:** Cinzel (display/headings), Nunito (body)
- **Layer offset:** Computed dynamically per tile via `BoardLayoutGeometry.project()`
- **Background:** Dark green gradient + `background green option 2.png` texture + vignette
- **Two palettes:** `SankofaGameTheme` (dark green primary) and `AppColors` (navy/gold archive — used for overlays and in-game settings)

---

## Assets Summary

```
assets/
├── audio/
│   ├── background_music.mp3   # Ghanaian highlife loop
│   ├── match.ogg / no_match.ogg
│   ├── win.ogg / lose.ogg
│   ├── tile_tap.ogg / hint.ogg / shuffle.ogg
├── tiles/
│   ├── tile_back.svg          # Midnight Kente tile back
│   ├── Tile V2 png/ / Tile V2 png.2/
│   ├── Tile v.3 png/ / Tile v.4 png/ / Tile v.5 png/
├── adinkra tile back tile.png  # Tile back PNG
├── cowries currency.png        # Cowrie icon
├── background green option 2.png
├── adinkra_tiles_homescreen_show-removebg-preview.png
├── lottie/                     # Empty (README only)
└── images/                     # Empty (README only)
```

---

## Firebase Integration

- **Analytics:** Tracks screen views, level starts/completions/failures, hint/shuffle/pause usage, settings, tile preview, onboarding, economy events (wallet, boosters, daily claims, collections, achievements), monetization events (shop views, purchases, rewarded ads, interstitials, restore), tutorial events. No PII.
- **Crashlytics:** Records fatal Flutter errors, platform errors, and non-fatal reports for storage, audio, board generation, AdMob, consent, and startup failures.

---

## Coding Conventions

- Use `ConsumerWidget`/`ConsumerStatefulWidget` for all screens that read state
- Use `ref.watch` to read, `ref.read` to dispatch actions (never watch in callbacks)
- Models use `copyWith` — never mutate in place
- Colors: use `SankofaGameTheme.*` or `AppColors.*` constants, never hardcode hex
- Text styles: use `AppTextStyles.*` getters
- Buttons: use `KenteButton` — do not use raw `ElevatedButton`
- Error handling in services: catch, log via `debugPrint`, report non-fatal to Crashlytics
- Route navigation: `context.go()` for replacements, `context.push()` for push, `Navigator.pop()` for back
- Audio/haptic: always check settings state before playing; respect toggle state
- Developer tests: gated behind `developerToolsEnabled` (debug mode or `ENABLE_DEVELOPER_TOOLS=true`)
- Economy/monetization transactions: always use idempotency keys to prevent double-granting
- Ad consent: always gathered before initializing Mobile Ads SDK

---

## Current Status

| Phase | Status |
|---|---|
| Core gameplay (matching, hints, shuffle, visibility) | Complete |
| 200 levels (50 handcrafted + 150 procedural) | Complete |
| 20-chapter campaign with ChapterComplete | Complete |
| Economy (cowries, boosters, daily rewards, achievements) | Complete |
| Tile collection & progressive unlocks | Complete |
| Onboarding | Complete |
| Tutorial | Complete |
| Journey screen (chapter map) | Complete |
| Pre-level briefing screen | Complete |
| Shop (IAP catalog) | Complete |
| Settings + Privacy Policy | Complete |
| Audio (SFX + music) | Complete |
| Haptics + particle effects + match animations | Complete |
| Firebase Analytics + Crashlytics | Complete |
| AdMob (consent, rewarded ads, interstitials with gating) | Complete |
| IAP monetization (sandbox, 8 products) | Complete |
| Developer Level Tester | Complete |
| Timer / timed mode | Not implemented |
| Play Store IAP integration (real billing) | Not started |
| Play Store prep (icon, signing, splash) | Not started |
| iOS AdMob ad units | Not configured |

---

## Known Issues

1. No timer — `secondsElapsed` always remains 0
2. No Lottie animation files — directory is empty
3. `assets/images/` is empty
4. In-game settings sheet uses `AppColors` archive palette while game uses `SankofaGameTheme` dark greens
5. Some PNG filenames have `-removebg-preview` suffixes (unprocessed tool output)
6. IAP integration uses sandbox store IDs only; real Google Play billing not yet integrated
7. Ad units only configured for Android; iOS ad units not set up
8. Extended campaign levels (51-200) are procedurally generated with recycled layout patterns
