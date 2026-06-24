# CONTEXT.md — Sankofa Tiles (AI Handoff)

## Project Identity

**Sankofa Tiles** is a Flutter mobile puzzle game — a Mahjong solitaire tile-matching game themed around Ghanaian Adinkra symbols. Players match pairs of identical tiles on a 3D-layered board following classic Mahjong "free tile" rules. The game targets Android and iOS (portrait only).

- **Package:** `com.sankofatiles.sankofa_tiles`
- **Version:** 1.0.0+3
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
| Firebase | `firebase_core` + `firebase_analytics` + `firebase_crashlytics` | ^4.10.0 / ^12.4.2 / ^5.2.3 |
| URL launching | `url_launcher` | ^6.3.2 |
| Code gen | `riverpod_generator` + `build_runner` | dev |

---

## Directory Structure & Purpose

```
lib/
├── main.dart                    # Entry: Firebase init, portrait lock, storage init, ProviderScope
├── app.dart                     # SankofaTilesApp ConsumerWidget — creates GoRouter, applies dark theme

├── core/
│   ├── config/
│   │   └── developer_tools_config.dart  # Gates developer features (debug-only or env flag)
│   ├── constants/
│   │   ├── tile_data.dart       # TileDefinition, kAllTiles, kTileIds (~90+ Adinkra symbols)
│   │   ├── level_data.dart      # LevelDefinition, SymbolCopyPlan, kLevels (50 levels)
│   │   └── layout_data.dart     # TilePosition, NamedLayout, 50 layout constants
│   ├── router/
│   │   ├── app_router.dart      # GoRouter: 7 routes + analytics observer + onboarding redirect
│   │   └── navigation_helpers.dart  # safeBack() helper
│   ├── theme/
│   │   ├── app_colors.dart      # Archive/navy palette (used in overlays and in-game settings)
│   │   ├── app_text_styles.dart # Cinzel/Nunito styles + archive text styles
│   │   ├── app_theme.dart       # AppTheme.darkTheme — Material 3 dark with gold color scheme
│   │   └── sankofa_game_theme.dart  # Primary visual theme: dark green/teal + parchment + gold
│   └── utils/
│       ├── storage_service.dart     # SharedPreferences wrapper — progress, settings, migration
│       ├── audio_service.dart       # 4 SFX players + music player, togglable, .ogg assets
│       ├── haptic_service.dart      # Static HapticService — intensity-gated (off/low/med/high)
│       ├── board_solver.dart        # Mahjong free-tile logic, solvability checker, safe move detection
│       ├── board_layout_geometry.dart   # Dynamic tile sizing and board projection
│       ├── analytics_service.dart   # Firebase Analytics event logging
│       ├── crash_reporting_service.dart # Firebase Crashlytics (fatal + non-fatal)
│       └── campaign_validator.dart  # Validates level integrity and progression structure

├── models/
│   ├── tile_model.dart          # TileModel — uid, def, position(row,col,layer), state flags (immutable+copyWith)
│   ├── board_model.dart         # BoardModel — rows, cols, tiles list, tileAt(row,col)
│   ├── game_state.dart          # GameState — tiles, status, difficulty, score, moves, streak, match animation state
│   ├── game_launch_config.dart  # GameLaunchConfig, GameLaunchMode, GameResultConfig
│   └── level_model.dart         # LevelResult — levelId, bestScore, stars

├── providers/
│   ├── game_provider.dart       # GameNotifier (~748 lines) — board generation, matching, unsafe-move blocking, auto-shuffle on stuck
│   ├── progress_provider.dart   # ProgressService — level unlock checks, next level resolution, star queries
│   └── settings_provider.dart   # SettingsNotifier + SettingsState — user prefs, immediate persistence

├── screens/
│   ├── home/home_screen.dart              # Main menu: Play, Settings, How to Play, Tile Preview
│   ├── onboarding/onboarding_screen.dart  # 4-page PageView (Culture, Rules, Symbols, Ready) — first launch only
│   ├── developer/developer_level_tester_screen.dart  # All 50 levels with validation status — debug only
│   ├── game/
│   │   ├── game_screen.dart               # Gameplay — compact header + BoardWidget + control dock + overlays
│   │   └── widgets/
│   │       ├── board_widget.dart          # Dynamic board renderer: collision animations, particle bursts, score pops
│   │       ├── game_header.dart           # Compact header: Level/Score/Matches stats + progress bar
│   │       ├── game_control_dock.dart     # Hint, Shuffle, Pause/Resume circular buttons
│   │       ├── game_board_backdrop.dart   # Dark green board surface with Adinkra motif
│   │       ├── parchment_background.dart  # Textured parchment gradient background
│   │       ├── tile_widget.dart           # Single tile: 3D slab, 6+ visual states, PNG-backed
│   │       └── hint_overlay.dart          # "Hint Active" instructional modal
│   ├── result/result_screen.dart          # Win (stars + score breakdown + next game) / Lose (proverb + retry)
│   ├── settings/settings_screen.dart      # Audio, haptic, gameplay toggles, privacy policy, developer tools
│   └── preview/tile_preview_screen.dart   # Adinkra symbol reference gallery (~90 tiles)

└── widgets/
    ├── kente_button.dart       # Reusable parchment-on-dark ElevatedButton
    ├── adinkra_divider.dart    # —— ◎ —— decorative separator
    ├── sankofa_background.dart # Dark green gradient + texture + vignette background
    └── tile_back.dart          # SVG tile back face (Midnight Kente design)
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
Service Layer (core/utils/ ) — platform I/O (storage, audio, haptics, Firebase)
    ↕ references
Constants (core/constants/ ) — pure data (tile catalog, levels, layouts)
```

**Key rules:**
- All models are **immutable** with `copyWith()` — never mutate state in place.
- **Riverpod** is the single source of truth. Widgets are `ConsumerWidget`/`ConsumerStatefulWidget`.
- `StorageService` is injected via `ProviderScope` override — swappable for tests.
- Audio is managed by `audioServiceProvider` which auto-syncs with settings and disposes on removal.
- No `setState` is used for game logic — all game state flows through `GameNotifier`.

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

**No timer.** The game has no time limit. `secondsElapsed` exists in the model but is never incremented.

### Settings Provider (`settingsProvider`)
`StateNotifierProvider<SettingsNotifier, SettingsState>` — user preferences.

State fields: `soundEnabled`, `musicEnabled`, `musicVolume`, `showTileNames`, `hapticIntensity`.

All setters write to both in-memory state and SharedPreferences immediately.

### Progress Provider (`progressProvider`)
`Provider<ProgressService>` — adapts StorageService for the UI layer.

`ProgressService.isLevelUnlocked(id)` — Level 1 always unlocked; level N requires completed flag on N-1.

`progressService.nextUnfinishedLevelId` — the level the Play button navigates to. Resolves via `highestCompletedLevel`.

`computeStars(score, thresholds)` — pure function: returns 0-3 based on threshold array.

---

## Data Flow

```
StorageService (SharedPreferences)
    ↓ init override
SettingsNotifier → SettingsState → UI toggles + AudioService/HapticService
    ↓
ProgressService → nextUnfinishedLevelId → HomeScreen Play button
    ↓
GameNotifier.startLevel() → GameState → GameScreen + BoardWidget + TileWidget
    ↓ on win
ProgressService.saveLevelResult() → StorageService
    ↓
completed_N flag written → unlocks next level
```

---

## Game Mechanics (Quick Reference)

### Board Generation
Two strategies depending on tile count:
- **≥40 tiles** (reverse-solved): Starts with empty board, greedily removes free tile pairs to build valid removal sequence, then assigns tile definitions in reverse. Up to 100 attempts.
- **<40 tiles** (random + solvability check): Generates random boards, checks solvability with BoardSolver (6,000 search nodes). Up to 12 attempts. Falls back to reverse-solved if all fail.
- Final solvability check (50,000 node budget). If unsolvable → loadFailed.

### Free Tile Rule
A tile is "free" (selectable) only if:
1. No tile in a higher layer covers it (2-unit span overlap check)
2. At least one lateral side (left or right) is open on its layer

### Match Flow
1. Tap free tile → selected (lifts, brightens)
2. Tap same tile → deselect
3. Tap another free tile with same `def.id`:
   - **Unsafe move** (would make board unsolvable AND safe alternative exists) → BLOCKED (mismatch feedback)
   - **Safe or only option** → matched (+100 pts, particle burst, streak tracked, collision animation)
4. Tap different ID → mismatch shake, deselected after 600ms, streak reset

### Scoring
- 100 pts per match + streak bonus (3x→+50, 4x→+100, 5x+→+200)
- Shuffle penalty: -50 (clamped at 0)
- **No time bonus** (no timer in current implementation)
- Star thresholds computed dynamically per level from complexity formula

### Difficulty
The game always starts with `DifficultyMode.normal`. However, there is no timer, so all modes effectively play the same way. Hints are unlimited.

### Win/Lose
- **Win:** all tiles matched → star rating from dynamic thresholds
- **Lose (stuck):** no available matching pairs remain → auto-shuffles first, only declares lose if shuffle also fails
- **No time-based loss** (Timer is not implemented)

### Auto-Shuffle on Stuck
When `isStuck` is detected, the game automatically attempts a shuffle without score penalty. Only if the shuffle cannot produce a solvable board does the game transition to `lost`.

---

## Visual Design

- **Theme:** Dark green/teal (#101A16 → #17241F gradient), antique gold (#B88A3A) accents, cream parchment panels
- **Tiles:** Cream/ivory face with dark gold 3D edge slab — resembles physical Mahjong tiles
- **Fonts:** Cinzel (display/headings), Nunito (body)
- **Layer offset:** Computed dynamically per tile via `BoardLayoutGeometry.project()`
- **Background:** Dark green gradient + `background green option 2.png` texture + vignette
- **Two palettes:** `SankofaGameTheme` (dark green primary) and `AppColors` (navy/gold archive — used for overlays and in-game settings)

---

## Routing (GoRouter)

| Path | Screen | Parameters |
|---|---|---|
| `/` | Home | — |
| `/onboarding` | Onboarding (4 pages) | — |
| `/game/:levelId` | Game | Extra: `GameLaunchConfig` (levelId + launchMode) |
| `/result` | Result | Extra: `GameResultConfig` (gameState + launchConfig) |
| `/settings` | Settings | — |
| `/tile-preview` | Tile Preview | — |
| `/developer/levels` | Developer Level Tester | Debug-only (gated by `developerToolsEnabled`) |

**Redirect:** `/` → `/onboarding` if `storage.isOnboardingComplete() == false`.

**No level-select route.** The Play button computes the next unfinished level and goes directly to `/game/:levelId`.

---

## Level System

50 levels across 5 chapters:
- **First Symbols** (levels 1–10): Novice difficulty, 7–15 symbol types
- **Paths of Wisdom** (levels 11–20): Apprentice, 16–24 types
- **Heritage** (levels 21–30): Strategic, 25–33 types
- **Ancestral Trials** (levels 31–40): Advanced, 34–40 types
- **Grand Archive** (levels 41–50): Master, 40–46 types

Each level uses `SymbolCopyPlan` for tile distribution and `NamedLayout` for board structure. Star thresholds are computed dynamically from a complexity formula (tile count × 36 + layer count × 180 + covered tiles × 9 + symbol pool × 22 + max layer × 120).

Progression is linear: complete level N to unlock N+1. Use `completed_N` boolean keys and `highest_completed_level` integer.

---

## Assets Summary

```
assets/
├── audio/
│   ├── background_music.mp3   # Ghanaian highlife loop
│   ├── match.ogg              # Match success
│   ├── no_match.ogg           # Mismatch error
│   ├── win.ogg / lose.ogg     # End-game sounds
│   ├── tile_tap.ogg           # Tile selection tap
│   ├── hint.ogg               # Hint activation
│   └── shuffle.ogg            # Shuffle action
├── tiles/
│   ├── tile_back.svg          # Midnight Kente tile back
│   ├── Tile V2 png/           # PNG assets — various Adinkra symbols
│   ├── Tile V2 png.2/         # Additional PNGs
│   ├── Tile v.3 png/          # v3 PNGs
│   ├── Tile v.4 png/          # v4 PNGs
│   └── Tile v.5 png/          # v5 PNGs
├── lottie/                    # Empty (README only)
├── images/                    # Empty (README only)
├── background green option 2.png  # Dark green textured background
└── adinkra_tiles_homescreen_show-removebg-preview.png  # Home screen logo
```

---

## Firebase Integration

- **Analytics:** Tracks screen views, level starts/completions/failures, hint/shuffle/pause usage, settings, tile preview, onboarding completion, progress reset. No PII.
- **Crashlytics:** Records fatal Flutter errors, platform errors, and non-fatal reports for storage, audio, and board generation failures.

---

## Current Status

| Phase | Status |
|---|---|
| Core gameplay (matching, hints, shuffle) | Complete |
| 50 levels | Complete |
| Onboarding | Complete |
| Settings + Privacy Policy | Complete |
| Audio (SFX + music) | Complete |
| Haptics + particle effects + match animations | Complete |
| Firebase Analytics + Crashlytics | Complete |
| Developer Level Tester | Complete |
| Timer / timed mode | Not implemented |
| Level Select screen | Removed (direct progression) |
| Monetization (AdMob + IAP) | Not started |
| Play Store prep (icon, signing, splash) | Not started |

---

## Known Issues

1. No timer — `secondsElapsed` always remains 0
2. No Lottie animation files — directory is empty
3. `assets/images/` is empty
4. In-game settings sheet uses `AppColors` archive palette while game uses `SankofaGameTheme` dark greens
5. No custom screen transition animations between routes
6. Some PNG filenames have `-removebg-preview` suffixes (unprocessed tool output)
7. Difficulty mode selector no longer exists — always plays as `normal`

---

## Coding Conventions

- Use `ConsumerWidget`/`ConsumerStatefulWidget` for all screens that read state
- Use `ref.watch` to read, `ref.read` to dispatch actions (never watch in callbacks)
- Models use `copyWith` — never mutate in place
- Colors: use `SankofaGameTheme.*` or `AppColors.*` constants, never hardcode hex
- Text styles: use `AppTextStyles.*` getters
- Buttons: use `KenteButton` — do not use raw `ElevatedButton`
- Error handling in services: catch, log via `debugPrint`, report non-fatal to Crashlytics
- Route navigation: contextual — `context.go()` for replacements, `context.push()` for push, `safeBack()` for back
- Audio/haptic: always check settings state before playing; respect toggle state
- Developer tests: gated behind `developerToolsEnabled` (debug mode or `ENABLE_DEVELOPER_TOOLS=true`)
