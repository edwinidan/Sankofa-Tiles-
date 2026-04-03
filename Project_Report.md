# Sankofa Tiles — Project Report

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Technology Stack](#2-technology-stack)
3. [Architecture](#3-architecture)
4. [Design System](#4-design-system)
5. [Data Layer](#5-data-layer)
6. [State Management](#6-state-management)
7. [Screens](#7-screens)
8. [Widgets](#8-widgets)
9. [Game Mechanics](#9-game-mechanics)
10. [Progression & Persistence](#10-progression--persistence)
11. [Audio](#11-audio)
12. [Routing & Navigation](#12-routing--navigation)
13. [Tile Catalogue](#13-tile-catalogue)
14. [Level Catalogue](#14-level-catalogue)
15. [Recent Changes](#15-recent-changes)
16. [Visual Feedback & Juice](#16-visual-feedback--juice)

---

## 1. Project Overview

**Sankofa Tiles** is a culturally-inspired mobile puzzle game built in Flutter. It is a Mahjong solitaire tile-matching game themed around Ghanaian Adinkra symbols — visual icons created by the Akan people of West Africa that encode proverbs, values, and philosophical concepts.

The name **Sankofa** (ⵙ) comes from the Akan proverb *"Se wo were fi na wosankofa a yenkyi"* — "It is not wrong to go back for what you forgot." The game embodies this spirit by encouraging players to engage deeply with ancestral symbols and their meanings.

**Core Gameplay:** Players tap pairs of matching Adinkra tiles to clear the board. Tiles must share the same ID (definition) to match. Successfully clearing a board earns a score and star rating, and unlocks the next level.

**Target Platforms:** Android and iOS (portrait orientation only).

---

## 2. Technology Stack

| Concern | Library / Version |
|---|---|
| UI Framework | Flutter 3.0+ (Dart) |
| State Management | `flutter_riverpod ^2.5.1` |
| Navigation / Routing | `go_router ^13.2.0` |
| Local Persistence | `shared_preferences ^2.2.3` |
| Audio Playback | `audioplayers ^6.0.0` |
| Typography | `google_fonts ^6.2.1` |
| SVG Rendering | `flutter_svg ^2.0.10+1` |
| Lottie Animations | `lottie ^3.1.0` |
| UUID Generation | `uuid ^4.4.0` |

**Font Families:**
- **Cinzel** (Google Fonts) — Display headings, level names, button labels
- **Nunito** (Google Fonts) — Body text, descriptive content
- **Georgia / system serif** — Tile face suit codes and Adinkra symbols

---

## 3. Architecture

The project follows a **layered architecture** with strict separation of concerns:

```
lib/
├── main.dart                   # App bootstrap & orientation lock
├── app.dart                    # Root widget, router configuration
│
├── core/
│   ├── theme/
│   │   ├── app_colors.dart     # All color constants
│   │   ├── app_text_styles.dart# All TextStyle definitions
│   │   └── app_theme.dart      # ThemeData (Material 3 dark)
│   ├── router/
│   │   └── app_router.dart     # GoRouter with 6 named routes
│   ├── utils/
│   │   ├── storage_service.dart# SharedPreferences wrapper
│   │   └── audio_service.dart  # AudioPlayer wrapper
│   └── constants/
│       ├── tile_data.dart      # 28 tile definitions + TileSuit enum
│       └── level_data.dart     # 10 level definitions + helpers
│
├── models/
│   ├── tile_model.dart         # Runtime tile instance (immutable)
│   ├── board_model.dart        # Board container
│   ├── level_model.dart        # LevelResult for persistence
│   └── game_state.dart         # GameState + enums
│
├── providers/
│   ├── game_provider.dart      # GameNotifier — full game logic
│   ├── progress_provider.dart  # ProgressService + computeStars()
│   └── settings_provider.dart  # SettingsNotifier + SettingsState
│
├── screens/
│   ├── home/                   # Home screen
│   ├── onboarding/             # 4-page tutorial
│   ├── level_select/           # Grid of levels + difficulty picker
│   ├── game/
│   │   ├── game_screen.dart    # Main gameplay screen
│   │   └── widgets/
│   │       ├── tile_widget.dart    # Physical tile rendering
100: │       ├── board_widget.dart   # Responsive grid layout
101: │       ├── game_hud.dart       # Score/time/moves chips
102: │       └── hint_overlay.dart   # Hint active indicator
│   ├── result/                 # Win/lose result screen
│   └── settings/               # Settings toggles
│
└── widgets/
    ├── kente_button.dart        # Custom gold/navy button
    ├── adinkra_divider.dart     # Decorative line separator
    └── tile_back.dart           # SVG tile back face (decorative)
```

**Key architectural decisions:**

- All models are **immutable** with `copyWith()` methods. State is never mutated in place.
- **Riverpod** providers are the single source of truth. Widgets only read and dispatch actions.
- `StorageService` is injected via `ProviderScope` override in `main.dart`, enabling it to be swapped for tests.
- Audio is managed through a singleton-like `audioServiceProvider` with `onDispose` cleanup.

---

## 4. Design System

### 4.1 Color Palette

```dart
// Background layers
navyDeep      = #0A2240   // Primary background (screens)
navyMid       = #0D2D52   // Secondary background (cards)
navyLight     = #1A4060   // Tertiary background (chips)

// Accent
kenteGold     = #EF9F27   // Primary action / selected border
kenteGoldDim  = #BA7517   // Secondary text / muted accent

// Tile surface
tileFace      = #F5E6C8   // Cream/ivory tile background
tileBorder    = #C8A96E   // Default tile border
tileEdge      = #8B6914   // 3D bottom slab + symbol color
tileSelected  = #FFF8E8   // Brighter cream when selected

// Board
boardGreen    = #1A5C38   // Semi-transparent board background

// Feedback
matchGreen    = #2E8B57   // Hint border / match flash
errorRed      = #CC3333   // Destructive actions (reset)
```

### 4.2 Typography

| Style | Font | Size | Weight | Usage |
|---|---|---|---|---|
| `displayLarge` | Cinzel | 32px | Bold | Screen titles |
| `displayMedium` | Cinzel | 24px | Bold | Section headers |
| `displaySmall` | Cinzel | 18px | SemiBold | Sub-headers |
| `headlineMedium` | Cinzel | 20px | Normal | Level names |
| `titleLarge` | Nunito | 18px | SemiBold | Card titles |
| `titleMedium` | Nunito | 16px | Bold | Sub-titles |
| `bodyLarge` | Nunito | 16px | Normal | Body copy |
| `bodyMedium` | Nunito | 14px | Normal | Descriptions |
| `bodySmall` | Nunito | 12px | Normal | Fine print |
| `buttonText` | Cinzel | 16px | Normal | Buttons |
| `tileSymbol` | Cinzel | 28px | Bold | Tile symbols (legacy) |
| `tileName` | Nunito | 9px | SemiBold | Tile label (legacy) |

### 4.3 Component Conventions

- **Buttons:** Navy fill, 1px gold border, Cinzel label. Disabled state uses muted colours.
- **Cards:** `navyMid` background, subtle `kenteGoldDim` border.
- **Chips (HUD):** `navyLight` fill, small Nunito label + bold value.
- **Dividers:** `AdinkraDivider` — thin dim-gold lines flanking a centered symbol.
- **App Bar:** `navyDeep` background, centred Cinzel title, gold back icon, no elevation.

---

## 5. Data Layer

### 5.1 Tile Definition (`TileDefinition`)

Every Adinkra tile type is described by an immutable `TileDefinition`:

| Field | Type | Description |
|---|---|---|
| `id` | String | Unique kebab-case identifier (e.g., `nyansapo`) |
| `name` | String | Display name (e.g., `Nyansapo`) |
| `meaning` | String | English meaning (e.g., `Wisdom knot`) |
| `symbol` | String | Unicode character rendered on the tile face |
| `suit` | `TileSuit` | `wisdom`, `earth`, `royalty`, or `honor` |
| `suitNumber` | int | Position within suit (1–9) |

### 5.2 Runtime Tile (`TileModel`)

Each tile on the board is a `TileModel` wrapping a `TileDefinition`:

| Field | Type | Description |
|---|---|---|
| `uid` | String | UUID v4 — unique per placed tile instance |
| `def` | `TileDefinition` | Reference to the tile type |
| `row`, `col` | int | Grid position |
| `layer` | int | Stack layer (default 0; reserved for 3D boards) |
| `isMatched` | bool | Cleared from board |
| `isSelected` | bool | Currently selected by the player |
| `isHinted` | bool | Highlighted by hint system |

### 5.3 Game State (`GameState`)

```
GameState
├── tiles            List<TileModel>
├── status           GameStatus (idle | playing | paused | won | lost)
├── difficulty       DifficultyMode (easy | normal | relaxed)
├── score            int
├── moves            int
├── hintsUsed        int
├── secondsElapsed   int
├── levelId          int
└── selectedTileUid  String?
```

Computed properties:
- `remainingPairs` → unmatched tile count ÷ 2
- `hasWon` → all tiles matched
- `isStuck` → no available matching pairs remain

### 5.4 Level Definition (`LevelDefinition`)

| Field | Type | Description |
|---|---|---|
| `id` | int | Numeric level ID (1–10) |
| `name` | String | Level display name |
| `boardRows`, `boardCols` | int | Grid dimensions |
| `tileCount` | int | Number of tiles (always even) |
| `tileIds` | List<String> | Tile definition IDs used in this level |
| `unlockRequirement` | int | Stars required on previous level |
| `starThresholds` | List<int> | Min scores for 1★, 2★, 3★ |

### 5.5 Persistence Keys (SharedPreferences)

| Key | Type | Default | Description |
|---|---|---|---|
| `best_score_{levelId}` | int | 0 | Best score ever on that level |
| `stars_{levelId}` | int | 0 | Best star count on that level |
| `sound_enabled` | bool | true | Sound effects on/off |
| `music_enabled` | bool | true | Background music on/off |
| `show_tile_names` | bool | true | Show names under symbols |
| `default_difficulty` | String | `normal` | Selected difficulty enum name |
| `onboarding_complete` | bool | false | Whether tutorial was finished |

---

## 6. State Management

All state is managed with **Riverpod** (`StateNotifierProvider`). No `setState` is used for game logic.

### 6.1 `gameProvider` / `GameNotifier`

The most complex provider. Owns all in-game logic.

**Public actions:**

| Method | Description |
|---|---|
| `startLevel(levelId, difficulty)` | Builds the tile grid, starts timer (normal mode), plays music |
| `selectTile(uid)` | Core matching logic — select, deselect, match, no-match |
| `useHint()` | Highlights a valid pair for 2 seconds, increments `hintsUsed` |
| `shuffleRemaining()` | Redistributes unmatched tiles; costs 50 points |
| `pauseGame()` | Pauses timer, sets status `paused` |
| `resumeGame()` | Resumes timer, sets status `playing` |
| `tick()` | Called each second by internal `Timer`; triggers lose at 300s (normal mode) |

**Match logic flow:**
1. First tap → `isSelected = true`
2. Second tap on same tile → deselect
3. Second tap on different tile:
   - **Same `def.id`** → both marked `isMatched`, score +100, move +1, check win
   - **Different id** → briefly shown, deselected after 400ms, check stuck

**Win condition:** `_checkWin()` fires after every match. If no unmatched tiles remain, status → `won`, time bonus calculated.

**Lose conditions:** Timer reaches 300s (normal difficulty) or `isStuck` returns true.

### 6.2 `settingsProvider` / `SettingsNotifier`

Reads initial values from `StorageService` on construction. Exposes async setters that update both state and persistent storage atomically.

### 6.3 `progressProvider` / `ProgressService`

A thin adapter over `StorageService` that exposes level unlock checks and result queries to the UI layer without exposing raw storage keys.

**`computeStars(score, thresholds)`** — Pure function used by both the result screen and the progress service to convert a raw score to a 0–3 star count.

---

## 7. Screens

### 7.1 Home Screen (`/`)

Static screen. No state management. Displays the game logo (◎ symbol, "SANKOFA ⟳ TILES" title), a decorative divider, and three navigation buttons: **Play**, **Settings**, **How to Play**.

### 7.2 Onboarding Screen (`/onboarding`)

4-page `PageView` tutorial:

| Page | Content |
|---|---|
| 1 | Cultural welcome — what Adinkra symbols are |
| 2 | How to play — 4 numbered steps, hints and shuffle explained |
| 3 | Symbol preview — grid of 6 sample tile previews |
| 4 | Closing philosophy — Gye Nyame and the Sankofa concept |

Navigation: Skip button (any page), dot indicators, Next/Finish. On finish: `setOnboardingComplete()` is called and the player is routed to level select. The router's redirect logic sends first-time users here automatically.

### 7.3 Level Select Screen (`/level-select`)

2-column `GridView` of `_LevelCard` widgets. Each card shows:
- Level number badge
- Lock icon (if not unlocked) or star row (if played)
- Level name, tile count, grid dimensions

Tapping an unlocked card opens a modal bottom sheet (`_DifficultySheet`) where the player picks Easy, Normal, or Relaxed before starting. The selected difficulty is passed as a route `extra` to the game screen.

### 7.4 Game Screen (`/game/:levelId`)

Main gameplay view. Calls `startLevel()` on the first frame.

**Layout (top to bottom):**
1. Top bar — back/pause button, level name
2. `GameHud` — score, timer (normal only), moves, pairs remaining
3. `BoardWidget` — the playable tile grid
4. Bottom bar — Hint, Shuffle, Pause/Resume action buttons

**Overlays:**
- **Pause overlay:** Shown over the board when paused; Resume and Quit buttons.
- **Quit dialog:** Confirmation alert when back button pressed while playing.

Status transitions trigger navigation: `won` or `lost` → navigate to `/result` after 600ms.

### 7.5 Result Screen (`/result`)

Receives `GameState` as route extra.

**Win view:** Scale+fade animation on entry (600ms elasticOut). Shows ★ rating, level name, score breakdown (matches, time bonus, total). Buttons: **Menu** and **Next Level**.

**Lose view:** Shows lose icon, Sankofa quote, score reached, pairs matched. Buttons: **Menu** and **Try Again**.

`_saveResult()` is called once on won state, writing to `ProgressService` only if the new score/stars exceeds the previous best.

### 7.6 Settings Screen (`/settings`)

Three sections rendered as a `ListView`:

| Section | Controls |
|---|---|
| **Audio** | Sound effects toggle, background music toggle |
| **Gameplay** | Show tile names toggle, default difficulty selector |
| **Data** | Reset all progress (confirmation dialog) |

All toggles are wired directly to `SettingsNotifier` methods; persistence is immediate.

---

## 8. Widgets

### 8.1 `TileWidget`

The most visually complex widget in the project. Redesigned to look like a physical Mahjong tile.

**Dimensions:** 64 × 85 px (default). Scales up to 1.6× on screens wider than 400 px when using defaults. The board passes explicit sizes computed from `LayoutBuilder`.

**3D construction:**
```
SizedBox (64 × 85)
└── Stack
    ├── Positioned.fill → Container (dark gold #8B6914, rounded 9px)
    │     ← full-height "slab" — the bottom 5px shows as the raised edge
    └── Positioned (top=0, height=80) → Container (ivory face, gold border)
          └── Stack (tile content)
              ├── Positioned top-left  → suit code text ("W1", "E3", etc.)
              ├── Center               → Adinkra symbol (28px serif)
              └── Positioned bottom    → tile name (7.5px, if enabled)
```

**State rendering:**

| State | Visual |
|---|---|
| Normal | Cream face, 1.5px gold border |
| Selected | Brighter cream (#FFF8E8), 2.5px gold (#EF9F27), lifts 10px |
| Hinted | Green border (#2E8B57) 2.5px, opacity pulses 0.6→1.0 over 800ms |
| Matched | `AnimatedOpacity` → 0 and `AnimatedScale` → 0, both 400ms |

Only a **single** `AnimationController` is used (for the hint pulse). The matched animation uses Flutter's implicit `AnimatedOpacity` / `AnimatedScale` widgets.

### 8.2 `BoardWidget`

Responsive grid using `LayoutBuilder` + `GridView`. Tile sizing:
```dart
tileW = (availableWidth / cols).clamp(36.0, 80.0)
tileH = tileW * (85 / 64)   // correct 64:85 aspect ratio
```
If the grid would overflow vertically, a `Transform.scale` shrinks the entire board to fit. Matched tiles are rendered in-place (the widget handles its own disappear animation).

### 8.3 `GameHud`

Four `_HudChip` widgets in a horizontal row: Score, Time (hidden in easy/relaxed), Moves, Pairs Left. The time chip turns red when `secondsElapsed >= 240` (last minute of normal difficulty).

### 8.4 `KenteButton`

Reusable custom button with consistent Kente-cloth aesthetic. Supports:
- Optional leading icon
- Optional fixed width
- `small` mode for compact layouts
- Disabled state (null `onTap`)

### 8.5 `AdinkraDivider`

Thin decorative separator: `—— ◎ ——`. Used on Home, Onboarding, and Result screens.

---

## 9. Game Mechanics

### 9.1 Board Generation

On `startLevel(levelId, difficulty)`:
1. Fetch `LevelDefinition` by ID.
2. Build a list of tile definition IDs — each unique ID appears **twice** (a pair).
3. Shuffle the list.
4. Trim to `tileCount`.
5. Assign tiles to specific 3D coordinates `(row, col, layer)` defined in the level layout.
6. Store in `GameState.tiles`.

### 9.2 Mahjong Solitaire Logic (Layered Stacking)

The game follows classic Mahjong Solitaire rules for tile interaction:

- **Availability:** A tile is only "free" (selectable) if:
    1. It is not covered by any tile in a layer above it.
    2. It has at least one side (left or right) completely clear of adjacent tiles on the same layer.
- **Visual Stacking:** Tiles are rendered with 3D offsets (`layer * 4.0` pixels) to create depth.
- **Selection:** Only "available" tiles can be tapped. Unavailable tiles are dimmed or lack the "available glow."

### 9.3 Match Logic

```
Player taps Tile A (Available):
  → Tile A becomes selected.

Player taps Tile A again:
  → Tile A is deselected.

Player taps Tile B (Available, Tile A already selected):
  if A.def.id == B.def.id:
    → Both marked isMatched.
    → score += 100 + Streak Bonus.
    → Particle burst and score pop triggered.
    → _checkWin() called.
  else:
    → Both shake (mismatch animation).
    → Deselected after 600ms.
    → Streak reset to 0.
    → _checkStuck() called.
```

### 9.4 Scoring & Streaks

| Component | Formula |
|---|---|
| Match points | 100 per matched pair |
| **Streak Bonus** | Bonus points for rapid successive matches (3+ streak) |
| Time bonus (normal only) | `max(0, 300 - secondsElapsed) × 2` |
| Shuffle penalty | -50 per use (clamped at 0) |

### 9.5 Win / Lose Conditions

| Condition | Trigger |
|---|---|
| **Win** | All tiles matched (`remainingPairs == 0`) |
| **Lose (stuck)** | No remaining *available* pairs can be matched (`isStuck == true`) |
| **Lose (time)** | Normal difficulty, `secondsElapsed >= 300` (5 minutes) |

---

## 10. Progression & Persistence

### 10.1 Unlock System

Level 1 is always available. Level N is unlocked if the player has earned at least 1 star on level N−1. This is checked via `StorageService.isLevelUnlocked(id)`.

### 10.2 Star Thresholds

Each level has three score thresholds. `computeStars(score, thresholds)` returns 0–3:

```
score >= thresholds[2] → 3 stars
score >= thresholds[1] → 2 stars
score >= thresholds[0] → 1 star
otherwise              → 0 stars
```

### 10.3 Best Score Logic

`StorageService.saveLevelResult(levelId, score, stars)` only writes if the new score exceeds the stored best. Stars are saved independently and also only updated upward.

### 10.4 Progress Reset

`SettingsNotifier.resetProgress()` calls `StorageService.resetAllProgress()`, which removes all `best_score_*` and `stars_*` keys from SharedPreferences. Level 1 immediately becomes the only accessible level again.

---

## 11. Audio

Managed by `AudioService`, which owns two `AudioPlayer` instances:

| Player | Role | File |
|---|---|---|
| `_sfxPlayer` | Sound effects (one-shot) | Multiple |
| `_musicPlayer` | Background music (looping) | `audio/background_music.mp3` |

**Sound effect triggers:**

| Event | File |
|---|---|
| Tile tapped | `audio/tile_tap.mp3` |
| Successful match | `audio/match.mp3` |
| Failed match | `audio/no_match.mp3` |
| Board cleared (win) | `audio/win.mp3` |
| Game lost | `audio/lose.mp3` |

Audio failures (e.g. missing files) are caught silently and logged via `debugPrint` — they do not crash the game.

Settings changes take immediate effect: disabling music calls `stopBackgroundMusic()` instantly; re-enabling it does not auto-restart (the next `startLevel` call will start music if enabled).

---

## 12. Routing & Navigation

Implemented with **GoRouter**. All routes are defined in `createAppRouter()`.

| Route | Path | Transition |
|---|---|---|
| Home | `/` | — |
| Onboarding | `/onboarding` | Default slide |
| Level Select | `/level-select` | Default slide |
| Game | `/game/:levelId` | Default slide |
| Result | `/result` | Default slide |
| Settings | `/settings` | Default slide |

**Redirect logic:** If the user navigates to `/` and `StorageService.isOnboardingComplete()` returns false, the router redirects to `/onboarding`.

**Parameter passing:**
- `levelId` is a path parameter (`:levelId`) extracted as a String and parsed to int in `GameScreen`.
- `difficulty` (DifficultyMode) and `gameState` (GameState) are passed as `extra` objects in `GoRouterState`.

---

## 13. Tile Catalogue

The tile system has transitioned from unicode symbols to **High-Resolution PNG Assets** (Asset v2) for better cultural representation and visual fidelity.

### Image Assets
Most tiles now use custom artwork located in `assets/tiles/symbols/asset v2/`. When an `assetPath` is provided in the `TileDefinition`, the `TileWidget` renders the image and hides the default decorative frame to let the artwork fill the tile face.

### Suit Summary
- **Wisdom (W):** Nyansapo, Nkyinkyim, Mate Masie, etc.
- **Earth & Nature (E):** Denkyem, Aya, Asase Ye Duru, etc.
- **Royalty & Power (R):** Adinkrahene, Akofena, Aban, etc.
- **Honor (H):** Gye Nyame, Dwennimmen, Mpatapo, etc.

---

## 14. Level Catalogue

| # | Name | Grid | Tiles | Suits Used | 1★ | 2★ | 3★ |
|---|---|---|---|---|---|---|---|
| 1 | Awakening | 4 × 4 | 16 | Wisdom (8) | 400 | 650 | 800 |
| 2 | Roots | 4 × 5 | 20 | Wisdom (all 9) | 500 | 800 | 1000 |
| 3 | Harvest | 4 × 6 | 24 | Wisdom + 3 Earth | 600 | 950 | 1200 |
| 4 | River | 4 × 7 | 28 | Wisdom + 5 Earth | 700 | 1100 | 1400 |
| 5 | Confluence | 6 × 6 | 36 | Wisdom + Earth | 900 | 1400 | 1800 |
| 6 | Kingdom | 5 × 8 | 40 | Wisdom + Earth + 2 Royalty | 1000 | 1600 | 2000 |
| 7 | Council | 4 × 11 | 44 | Mixed | 1100 | 1750 | 2200 |
| 8 | Heritage | 6 × 8 | 48 | 3 main suits + Honor | 1200 | 1900 | 2400 |
| 9 | Ancestors | 4 × 13 | 52 | All suits with repeats | 1300 | 2100 | 2600 |
| 10 | Sankofa | 7 × 8 | 56 | All suits + repeats | 1400 | 2300 | 2800 |

Each level requires 1 star on the previous level to unlock. Level 1 is always accessible.

---

## 15. Recent Changes

### 15.1 Advanced Visual & Tactile Feedback (Juice Phase)
- **Haptic Feedback Profile**: Comprehensive tactile vibration system using `lightImpact` for taps, `mediumImpact` for matches, `vibrate` for errors, and `heavyImpact` for speed bursts.
- **Particle Burst System:** High-performance particle effects (Gold Confetti, Inferno, Nova) triggered on successful matches.
- **Score Pops & Combo Indicators:** Repositioned, scaled-down banner rewarding rapid play with a time-gated Speed Streak (within 2s and 5s windows).
- **No-Match Shake & Ripple:** Tactile and visual feedback for invalid moves.
- **Available Glow:** Subtle outer pulse on "free" tiles to guide the player.

### 15.2 Mahjong Solitaire Implementation
- **3D Stacking:** Implemented a full coordinate system `(row, col, layer)` allowing for complex pyramid and bridge layouts.
- **Layer Offsets:** Fine-tuned to **11x11** for a pronounced 3D effect.
- **Availability Logic:** Strict enforcement of "free tile" rules (no top cover, one side open).
- **Auto-Stuck Detection:** The game now detects when no available matches remain and triggers a loss or suggests a shuffle.

### 15.3 Visual Refinement
- **Asset Migration:** Moved all tile symbols to high-res transparent PNGs.
- **Scale Update:** Increased tile scaling to **1.634** on larger screens for better visibility.
- **Layout Precision:** Fixed tile spacing to fill the board width exactly with zero gaps, creating a "solid" block feel.

---

## 16. Visual Feedback & Juice

To create a "Premium" feel, several micro-interaction systems were added:

- **The "Dip" Effect:** Tapping a tile briefly scales it down (`0.95x`) to provide tactile feedback.
- **Match Variants:** Different match animations (bursts, streaks, pulses) randomly selected to keep gameplay feeling fresh.
- **Speed Combo Indicators:** Visual "X x Combo!" banner that is **time-gated** (requires matching within 2s, 5s, or 4s) to reward high-intensity play.
- **Adaptive Spacing:** `BoardWidget` dynamically calculates tile dimensions to ensure the 3D stack fits perfectly on any mobile screen aspect ratio.
- **Physical Feedback:** `lightImpact` click whenever a tile is pressed down, enhancing the "clicky" feel of the ivory tiles.
