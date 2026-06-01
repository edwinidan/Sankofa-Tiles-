# CONTEXT.md — Sankofa Tiles (AI Handoff)

## Project Identity

**Sankofa Tiles** is a Flutter mobile puzzle game — a Mahjong solitaire tile-matching game themed around Ghanaian Adinkra symbols. Players match pairs of identical tiles on a 3D-layered board following classic Mahjong "free tile" rules. The game targets Android and iOS (portrait only).

- **Package:** `com.sankofatiles.app`
- **Version:** 1.0.0+1
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
| Code gen | `riverpod_generator` + `build_runner` | dev |

---

## Directory Structure & Purpose

```
lib/
├── main.dart                    # Entry: WidgetsFlutterBinding, portrait lock, ProviderScope(storage override)
├── app.dart                     # SankofaTilesApp ConsumerWidget — creates GoRouter, applies dark theme
│
├── core/
│   ├── constants/
│   │   ├── tile_data.dart       # TileSuit enum, TileDefinition, kAllTiles (~54 Adinkra symbols)
│   │   ├── level_data.dart      # LevelDefinition, kLevels (20 levels), getLevelById()
│   │   └── layout_data.dart     # TilePosition(row,col,layer), 20 layout constants (level1Layout..level20Layout)
│   ├── router/
│   │   └── app_router.dart      # GoRouter: 7 routes + onboarding redirect, dark error page
│   ├── theme/
│   │   ├── app_colors.dart      # Static AppColors class — navy palette, gold accents, tile colors
│   │   ├── app_text_styles.dart # Static AppTextStyles — Cinzel/Nunito styles via Google Fonts
│   │   └── app_theme.dart       # AppTheme.darkTheme — Material 3 dark with gold color scheme
│   └── utils/
│       ├── storage_service.dart # SharedPreferences wrapper — scores, stars, settings, onboarding
│       ├── audio_service.dart   # Two AudioPlayer instances (SFX + music), togglable
│       └── haptic_service.dart  # Static HapticService — intensity-gated (off/low/med/high)
│
├── models/
│   ├── tile_model.dart          # TileModel — uid, def, position(row,col,layer), state flags (immutable+copyWith)
│   ├── board_model.dart         # BoardModel — rows, cols, tiles list, tileAt(row,col)
│   ├── game_state.dart          # GameState — tiles, status, difficulty, score, moves, streak, computed props
│   └── level_model.dart         # LevelResult — levelId, bestScore, stars
│
├── providers/
│   ├── game_provider.dart       # GameNotifier (~367 lines) — core game engine (select, match, hint, shuffle, timer)
│   ├── progress_provider.dart   # ProgressService — level unlock checks, star queries, computeStars()
│   └── settings_provider.dart   # SettingsNotifier + SettingsState — all user prefs, immediate persistence
│
├── screens/
│   ├── home/home_screen.dart              # Main menu: Play, Settings, How to Play, Tile Preview
│   ├── onboarding/onboarding_screen.dart  # 4-page PageView (Culture, Rules, Symbols, Ready) — first launch only
│   ├── level_select/level_select_screen.dart # 20-level grid + difficulty bottom sheet (Easy/Normal/Relaxed)
│   ├── game/
│   │   ├── game_screen.dart               # Gameplay — HUD + BoardWidget + combo/pause overlays + action bar
│   │   └── widgets/
│   │       ├── board_widget.dart          # 3D board renderer: layer offsets, particle bursts, score pops, overlays
│   │       ├── game_hud.dart              # Score/Time/Moves/Left chips bar
│   │       ├── hint_overlay.dart          # "Hint Active" instructional modal
│   │       └── tile_widget.dart           # Single tile: 3D slab, 5 visual states, press-dip, image support
│   ├── result/result_screen.dart          # Win (stars + score breakdown) / Lose (proverb + retry)
│   ├── settings/settings_screen.dart      # Audio, haptic, gameplay toggles, reset progress
│   └── preview/tile_preview_screen.dart   # Adinkra symbol reference gallery
│
└── widgets/
    ├── kente_button.dart       # Reusable gold-on-navy ElevatedButton with icon/small/width variants
    ├── adinkra_divider.dart    # —— ◎ —— decorative separator (configurable symbol)
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
Service Layer (core/utils/ ) — platform I/O (storage, audio, haptics)
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
- `startLevel(levelId, difficulty)` — builds the board from level definition, starts timer
- `selectTile(uid)` — core interaction: select/deselect/match/mismatch with streak tracking
- `useHint()` — finds and highlights a valid free matching pair (2s duration)
- `shuffleRemaining()` — redistributes unmatched tile positions, -50 points
- `pauseGame()` / `resumeGame()` — timer control
- `tick()` — fires each second; triggers lose at 300s in normal mode

### Settings Provider (`settingsProvider`)
`StateNotifierProvider<SettingsNotifier, SettingsState>` — user preferences.

State fields: `soundEnabled`, `musicEnabled`, `defaultDifficulty`, `showTileNames`, `hapticIntensity`.

All setters write to both in-memory state and SharedPreferences immediately.

### Progress Provider (`progressProvider`)
`Provider<ProgressService>` — thin read-only adapter over StorageService.

`ProgressService.isLevelUnlocked(id)` — Level 1 always unlocked; level N requires ≥1 star on N-1.

`computeStars(score, thresholds)` — pure function: returns 0-3 based on threshold array.

---

## Data Flow

```
StorageService (SharedPreferences)
    ↓ init override
SettingsNotifier → SettingsState → UI toggles + AudioService/HapticService
    ↓
ProgressService → level unlock checks → LevelSelectScreen
    ↓
GameNotifier.startLevel() → GameState → GameScreen + BoardWidget + TileWidget
    ↓ on win
ProgressService.saveLevelResult() → StorageService
```

---

## Game Mechanics (Quick Reference)

### Board Setup
Level definitions specify exact `(row, col, layer)` positions. Each level has `tileIds` — every ID appears twice (a pair). Pairs are shuffled then assigned to positions.

### Free Tile Rule
A tile is "free" (selectable) only if:
1. No tile in a higher layer covers it
2. At least one lateral side (left or right) is open on its layer

### Match Flow
1. Tap free tile → selected (lifts 10px, brightens)
2. Tap same tile → deselect
3. Tap another free tile with same `def.id` → both matched (+100 pts, particle burst, streak tracked)
4. Tap different ID → mismatch shake, deselect after 600ms, streak reset

### Scoring
- 100 pts per match + streak bonus for consecutive matches
- Time bonus (normal mode): `max(0, 300 - seconds) * 2`
- Shuffle penalty: -50

### Difficulty Modes
| Mode | Timer | Hints |
|---|---|---|
| Easy | None | Unlimited |
| Normal | 5 min | 3 |
| Relaxed | None | Unlimited |

### Win/Lose
- **Win:** all tiles matched → star rating (1-3) based on score thresholds
- **Lose (time):** 300s elapsed in normal mode
- **Lose (stuck):** no available matching pairs remain (`isStuck == true`)

---

## Visual Design

- **Theme:** Dark navy (#0A2240) background, Kente gold (#EF9F27) accents
- **Tiles:** Cream/ivory face with dark gold 3D edge slab — resembles physical Mahjong tiles
- **Fonts:** Cinzel (display/headings), Nunito (body)
- **Layer offset:** 24px — each higher layer shifts tiles left+up for 3D pyramid effect
- **Tile scaling:** Up to 1.634× on larger screens; BoardWidget computes dynamically from `LayoutBuilder`

---

## Routing (GoRouter)

| Path | Screen | Parameters |
|---|---|---|
| `/` | Home | — |
| `/onboarding` | Onboarding (4 pages) | — |
| `/level-select` | Level Select (20 levels) | — |
| `/game/:levelId` | Game | Path: levelId (int); Extra: DifficultyMode |
| `/result` | Result | Extra: GameState |
| `/settings` | Settings | — |
| `/tile-preview` | Tile Preview | — |

**Redirect:** `/` → `/onboarding` if `StorageService.isOnboardingComplete() == false`.

---

## Assets Summary

```
assets/
├── audio/
│   ├── background_music.mp3   # Ghanaian highlife loop (363 KB)
│   ├── match.mp3              # Match success (3.9 KB)
│   ├── no_match.mp3           # Mismatch error (4 KB)
│   ├── win.mp3 / lose.mp3     # End-game sounds (554 KB each)
│   └── tile_tap.mp3           # EMPTY FILE (0 bytes) — tile tap is silent
├── tiles/
│   ├── tile_back.svg          # Midnight Kente tile back
│   ├── symbols/               # v1 PNGs (18 files, 1-1.6 MB each)
│   └── symbols/asset v2/      # v2 PNGs (36 files, ~200-300 KB each, transparent)
├── lottie/                    # Empty — win_starburst.json is missing
└── images/                    # Empty
```

---

## Current Status

| Phase | Status |
|---|---|
| 1-8 (Concept through Settings) | Complete |
| 9 (Visual Polish / Juice) | In progress — haptics, particles, combos done; screen transitions pending |
| 10 (Monetization — AdMob + RevenueCat) | Not started |
| 11 (Pre-Launch — Play Store prep) | Not started |
| 12 (Post-Launch & Growth) | Not started |

---

## Known Issues

1. `tile_tap.mp3` is a 0-byte file — tap sound effects are silent
2. No Lottie animation files — `win_starburst.json` is referenced but missing
3. `fawohodie-removebg-preview.png` and `mekyea_wo-removebg-preview.png` have unprocessed filenames
4. No tests — only a Flutter scaffolding placeholder (`1 + 1 == 2`)
5. Web manifest description still says "A new Flutter project."
6. No custom screen transition animations between routes

---

## Coding Conventions

- Use `ConsumerWidget`/`ConsumerStatefulWidget` for all screens that read state
- Use `ref.watch` to read, `ref.read` to dispatch actions (never watch in callbacks)
- Models use `copyWith` — never mutate in place
- Asset paths with spaces: `'assets/tiles/symbols/asset v2/'` — keep the space, it's intentional
- Colors: use `AppColors.*` constants, never hardcode hex values
- Text styles: use `AppTextStyles.*` getters
- Buttons: use `KenteButton` — do not use raw `ElevatedButton`
- Error handling in services: catch silently, log via `debugPrint` — do not propagate to UI
- Route navigation: use `context.go()` not `context.push()` (GoRouter)
- Audio/haptic: always check settings state before playing; respect toggle state
