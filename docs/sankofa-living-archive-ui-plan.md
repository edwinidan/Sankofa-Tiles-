# Sankofa Living Archive — Game Screen UI Redesign Plan

## 1. Current Architecture Summary

### 1.1 Game Screen Structure (`lib/screens/game/game_screen.dart`)

```
Scaffold (backgroundColor: AppColors.navyDeep #0A2240)
└── SafeArea
    └── Column
        ├── _TopBar (level number, back, settings)
        ├── GameHud (score, time, moves, left — horizontal strip)
        ├── Expanded → Stack
        │   ├── BoardWidget (tiles in computed positions)
        │   └── ComboOverlay (animated streak banner)
        └── _BottomBar (Hint, Shuffle, Pause buttons)
```

- Uses `PopScope` for back-button handling (quit confirmation dialog)
- `GameProvider` listened via `ref.listen` for game-end navigation
- Combo system with haptic feedback
- Pause/load-failed overlay dialogs
- Settings bottom sheet

### 1.2 Board & Tile Rendering (`board_widget.dart` + `tile_widget.dart`)

- **BoardWidget**: `LayoutBuilder` computes tile positions using pyramid projection
  - Layout metrics: stepX=0.5, stepY=0.66, layer offsets for 3D stacking
  - Tiles rendered as `Positioned` widgets in a `Stack` with `Clip.none`
  - Entrance animation: staggered fadeIn + slideY
  - Win overlay: gold shimmer; Lose overlay: red + shake
  - Match burst particle effects (`CustomPainter` with 3 variants)
  - Score pop overlay (+100 text floating up)

- **TileWidget**: Image-based tiles with multiple states
  - PNG images loaded via `Image.asset` in `ClipRect`
  - Default size: 64×85, responsive scaling via `MediaQuery`
  - States: normal, selected (lifted -10px, gold border), hinted (green pulsing), matched (smash animation), mismatched (shake)
  - Fallback text-based tiles for missing assets

### 1.3 HUD (`game_hud.dart`)

```
Container (navyMid background, gold bottom border)
└── Row
    ├── Level name label (expanded)
    ├── _HudChip: SCORE
    ├── _HudChip: TIME (normal mode only, turns red at 240s)
    ├── _HudChip: MOVES
    └── _HudChip: LEFT
```

- Compact horizontal layout, very dense
- Label/value pairs with tiny font sizes (8px labels, 15px values)

### 1.4 Colors (`app_colors.dart`)

```dart
navyDeep     = #0A2240   // main background
navyMid      = #0D2D52   // panels, cards
navyLight    = #1A4060   // borders, disabled
kenteGold    = #EF9F27   // primary accent
kenteGoldDim = #BA7517   // dimmed accent
tileFace     = #F5E6C8   // tile background (cream)
tileBorder   = #C8A96E   // tile border
tileEdge     = #8B6914   // tile 3D edge
boardGreen   = #1A5C38   // board surface
textPrimary  = #F5E6C8   // light text on dark
textSecondary= #BA7517
textMuted    = #5F7A94
matchGreen   = #2E8B57
errorRed     = #CC3333
```

### 1.5 Text Styles (`app_text_styles.dart`)

- **Display**: Google Fonts `Cinzel` (serif/display) — gold colored, used for headings
- **Body**: Google Fonts `Nunito` (sans-serif) — light colored, used for body text
- All styles designed for dark backgrounds

### 1.6 Affected Screens

| Screen | File | Current Background |
|--------|------|-------------------|
| Game Screen | `lib/screens/game/game_screen.dart` | navyDeep |
| Result Screen | `lib/screens/result/result_screen.dart` | navyDeep |
| Level Select | `lib/screens/level_select/level_select_screen.dart` | navyDeep |
| Settings Sheet | (embedded in game_screen.dart) | navyMid |
| Pause Overlay | (embedded in game_screen.dart) | navyMid |
| Quit Dialog | (embedded in game_screen.dart) | navyMid |
| Hint Overlay | `lib/screens/game/widgets/hint_overlay.dart` | navyMid |

### 1.7 Shared Widgets Affected

| Widget | File | Notes |
|--------|------|-------|
| KenteButton | `lib/widgets/kente_button.dart` | navyMid bg, gold text |
| AdinkraDivider | `lib/widgets/adinkra_divider.dart` | gold lines |
| TileBackWidget | `lib/widgets/tile_back.dart` | tile colors (no change needed) |

### 1.8 What Must NOT Change

- PNG tile assets, tile data, tile matching logic, solver, board generator
- Level system, game rules, scoring logic
- `TileDefinition`, `TileModel`, `GameState` models
- `GameNotifier` / `GameProvider` logic
- `BoardSolver` logic
- Audio service, haptic service
- Router / navigation logic
- `pubspec.yaml` dependencies (no new packages needed)

---

## 2. Design Direction: "Sankofa Living Archive"

### 2.1 New Color Palette

```dart
// ── Backgrounds ──
parchmentBase   = #F4EEDC   // warm ivory — main screen background
parchmentLight  = #FFF8E7   // lighter variant for cards/panels
parchmentWarm   = #EFE6D0   // slightly warmer variant

// ── Text ──
archiveInk      = #2F3328   // deep charcoal-green — body text
archiveInkLight = #5C6248   // softer charcoal — secondary text
archiveInkDim   = #8A8F7A   // muted text

// ── Accent ──
archiveGold     = #C7A45D   // warm aged-gold — primary accent
archiveGoldDeep = #9E7E3E   // deeper gold — borders, emphasis
archiveGoldPale = #E0D0A8   // pale gold — subtle borders

// ── Panels ──
panelFill       = #FFFDF5   // near-white cream — floating panels
panelBorder     = #D9CBAA   // soft beige border

// ── Shadows ──
shadowWarm      = #8B7D5E   // warm brown shadow (used with low opacity)

// ── Board Area ──
boardStone      = #E8DFC8   // slightly darker than parchment — tile backdrop
boardRing       = #D4C9A8   // subtle circular ring stroke

// ── Tile colors — kept as-is for contrast ──
tileFace        = #F5E6C8   // unchanged
tileBorder      = #C8A96E   // unchanged
tileEdge        = #8B6914   // unchanged
tileSelected    = #FFF8E8   // unchanged

// ── Feedback — kept ──
matchGreen      = #2E8B57   // unchanged
errorRed        = #CC3333   // unchanged
```

### 2.2 Font Strategy

- **Cinzel** — keep for "LEVEL 10" heading and key display text (now dark color)
- **Nunito** — keep for body/labels/stats (now dark color)
- **Georgia / serif fallback** — already used in tile suit codes, keep

### 2.3 Screen Layout (Game Screen)

```
┌─────────────────────────────────┐
│  ← BACK          LEVEL 10    ⚙  │  ← _GameHeader (extracted)
├─────────────────────────────────┤
│  ┌───────────────────────────┐  │
│  │  🏛 Sankofa Archive      │  │  ← _GameStatsPanel (replaces GameHud)
│  │  ★1280  ⏱02:34  👆12  📦8 │  │     floating rounded panel
│  └───────────────────────────┘  │     with icons + labels
│                                 │
│          ╭─────────╮            │
│         ╱           ╲           │
│        │   ┌─┐ ┌─┐   │         │  ← GameBoardBackdrop
│        │   │▒│ │▒│   │         │     circular stone/sand area
│        │   └─┘ └─┘   │         │     with subtle ring
│        │   ┌─┐ ┌─┐ ┌─┐│         │     tiles unchanged
│        │   │▒│ │▒│ │▒││         │
│        │   └─┘ └─┘ └─┘│         │
│        │               │         │
│         ╲           ╱           │
│          ╰─────────╯            │
│                                 │
│  ┌───────────────────────────┐  │
│  │  💡Hint    🔀Shuffle  ⏸Pause │  │  ← _GameControlDock (extracted)
│  └───────────────────────────┘  │     floating rounded dock
└─────────────────────────────────┘
```

### 2.4 Decorative Elements

1. **Circular board backdrop** — `CustomPainter` drawing a subtle ring/circle behind tiles
2. **Subtle radial gradient** — from center (lighter) to edges (slightly darker parchment)
3. **Optional faint Adinkra motifs** — very low opacity (~0.03-0.05), placed in corners only, never under tiles
4. **Subtle texture dots/noise** — can be done with a very faint repeating pattern via `CustomPainter` if needed; skip if performance concerns

---

## 3. File-by-File Implementation Plan

### 3.1 `lib/core/theme/app_colors.dart` — EXTEND

**Add** new color constants alongside existing ones (keep all existing for tile rendering):

```dart
// New: Living Archive palette
static const parchmentBase   = Color(0xFFF4EEDC);
static const parchmentLight  = Color(0xFFFFF8E7);
static const parchmentWarm   = Color(0xFFEFE6D0);
static const archiveInk      = Color(0xFF2F3328);
static const archiveInkLight = Color(0xFF5C6248);
static const archiveInkDim   = Color(0xFF8A8F7A);
static const archiveGold     = Color(0xFFC7A45D);
static const archiveGoldDeep = Color(0xFF9E7E3E);
static const archiveGoldPale = Color(0xFFE0D0A8);
static const panelFill       = Color(0xFFFFFDF5);
static const panelBorder     = Color(0xFFD9CBAA);
static const shadowWarm      = Color(0xFF8B7D5E);
static const boardStone      = Color(0xFFE8DFC8);
static const boardRing       = Color(0xFFD4C9A8);
```

**Risk**: None — only additive, existing colors fully preserved.

### 3.2 `lib/core/theme/app_text_styles.dart` — EXTEND

**Add** dark-on-light text style variants, keeping existing light-on-dark styles for backward compatibility with any unchanged screens:

```dart
// New: Dark-on-parchment text styles
static TextStyle get archiveDisplayLarge => GoogleFonts.cinzel(
  fontSize: 32, fontWeight: FontWeight.bold,
  color: AppColors.archiveInk, letterSpacing: 2,
);
static TextStyle get archiveDisplaySmall => GoogleFonts.cinzel(
  fontSize: 18, fontWeight: FontWeight.w600,
  color: AppColors.archiveInk, letterSpacing: 1,
);
static TextStyle get archiveTitleLarge => GoogleFonts.nunito(
  fontSize: 18, fontWeight: FontWeight.w700,
  color: AppColors.archiveInk,
);
static TextStyle get archiveBodyMedium => GoogleFonts.nunito(
  fontSize: 14, fontWeight: FontWeight.normal,
  color: AppColors.archiveInk,
);
static TextStyle get archiveBodySmall => GoogleFonts.nunito(
  fontSize: 12, fontWeight: FontWeight.normal,
  color: AppColors.archiveInkLight,
);
static TextStyle get archiveLabelSmall => GoogleFonts.nunito(
  fontSize: 10, fontWeight: FontWeight.w600,
  color: AppColors.archiveInkDim, letterSpacing: 0.5,
);
static TextStyle get archiveButtonText => GoogleFonts.cinzel(
  fontSize: 16, fontWeight: FontWeight.w600,
  color: AppColors.archiveGoldDeep, letterSpacing: 1,
);
```

### 3.3 New: `lib/screens/game/widgets/game_header.dart` — CREATE

Extract top bar as `GameHeader` widget:

```dart
class GameHeader extends StatelessWidget {
  // Props: levelId, onBack, onSettings
  // Layout: Row with back button, "LEVEL X" centered, settings icon
  // Style: parchment background, archiveInk text, archiveGold icons
  // Shadow: subtle bottom shadow
}
```

### 3.4 New: `lib/screens/game/widgets/game_stats_panel.dart` — CREATE

Replace `GameHud` with `GameStatsPanel`:

```dart
class GameStatsPanel extends ConsumerWidget {
  // Props: none (reads gameProvider directly)
  // Layout: Floating rounded container
  //   - Left: "Sankofa Archive" label or level name
  //   - Stats in columns: Score | Time | Moves | Left
  //   - Each stat: icon above, value, small label below
  //   - Icons: star (score), timer, touch_app (moves), layers (left)
  // Style: panelFill background, rounded corners (~14px), soft warm shadow
  // Padding: ~14px horizontal, ~10px vertical
}
```

### 3.5 New: `lib/screens/game/widgets/game_board_backdrop.dart` — CREATE

Circular/semi-circular backdrop behind tiles:

```dart
class GameBoardBackdrop extends StatelessWidget {
  // Wraps the BoardWidget in a Stack:
  //   - Background layer: CustomPaint with circular ring + subtle radial gradient
  //   - Optional faint decorative dots at edges
  //   - Foreground: child (BoardWidget)
  // Uses LayoutBuilder to size the circle based on available space
  // Circle diameter: ~85-90% of min(availableWidth, availableHeight)
  // Ring stroke: boardRing color, 1.5-2px width, ~0.3 opacity
}
```

**CustomPainter** (`ArchiveBoardPainter`):
- Draws a subtle circle centered in the available area
- Light radial gradient from center (slightly lighter) outward
- Thin ring stroke
- Optionally 4 small Adinkra-inspired dots at cardinal points
- All very low opacity to avoid distracting from tiles

### 3.6 New: `lib/screens/game/widgets/game_control_dock.dart` — CREATE

Replace `_BottomBar` with `GameControlDock`:

```dart
class GameControlDock extends ConsumerWidget {
  // Props: none (reads gameProvider directly)
  // Layout: Floating rounded container at bottom
  //   - 3 buttons in a Row: Hint | Shuffle | Pause/Resume
  //   - Each button: large tappable area, icon + label
  //   - Hint shows remaining hint count badge
  //   - Shuffle shows "-50" cost
  // Style: panelFill background, rounded top corners (~18px), soft shadow
  //   - Buttons: archiveGold icons, archiveInk text
  //   - Active state: slightly raised, gold tint
  //   - Disabled state: dimmed
  // Uses Material ripple for touch feedback, combined with existing haptics
}
```

### 3.7 New: `lib/screens/game/widgets/parchment_background.dart` — CREATE

Reusable parchment background for all screens:

```dart
class ParchmentBackground extends StatelessWidget {
  // Simple Container with parchmentBase color
  // Optional: very subtle CustomPainter gradient overlay
  // Optional: faint corner decorations
  // Used as the Scaffold backgroundColor or as a background widget
}
```

### 3.8 `lib/screens/game/game_screen.dart` — REFACTOR

**Changes**:
1. Replace `backgroundColor: AppColors.navyDeep` → `AppColors.parchmentBase`
2. Replace `_TopBar` → `GameHeader` (new extracted widget)
3. Replace `GameHud` → `GameStatsPanel` (new extracted widget)
4. Wrap `BoardWidget` in `GameBoardBackdrop` (new extracted widget)
5. Replace `_BottomBar` → `GameControlDock` (new extracted widget)
6. Update `_PausedOverlay`, `_LoadFailedOverlay`, `_ComboOverlay` colors to use archive palette
7. Update `_QuitDialog`, `_GameSettingsSheet` colors to use archive palette
8. Update icon colors from `kenteGold` → `archiveGold`
9. Update text colors from `textPrimary` → `archiveInk`
10. **Preserve**: all callbacks, provider logic, animation logic, combo system, haptics

### 3.9 `lib/screens/result/result_screen.dart` — UPDATE COLORS

**Changes** (visual consistency only):
1. Scaffold `backgroundColor` → `AppColors.parchmentBase`
2. Text colors → archive palette equivalents
3. Keep all layout, animation, and navigation logic unchanged

### 3.10 `lib/screens/level_select/level_select_screen.dart` — UPDATE COLORS

**Changes** (visual consistency only):
1. Scaffold `backgroundColor` → `AppColors.parchmentBase`
2. Card colors → archive palette
3. Keep all layout and logic unchanged

### 3.11 `lib/widgets/kente_button.dart` — UPDATE COLORS

**Changes** (visual consistency):
1. Background → `panelFill` or transparent
2. Text → `archiveGoldDeep`
3. Border → `archiveGold`
4. Keep API, sizing, and behavior unchanged

### 3.12 `lib/widgets/adinkra_divider.dart` — UPDATE COLORS

**Changes** (visual consistency):
1. Line color → `archiveGoldPale`
2. Symbol color → `archiveGold`
3. Keep API unchanged

### 3.13 `lib/screens/game/widgets/hint_overlay.dart` — UPDATE COLORS

**Changes** (visual consistency):
1. Background → `panelFill`
2. Text → archiveInk
3. Keep structure unchanged

### 3.14 Screen-specific changes NOT needed

The following files remain **untouched**:
- `lib/core/constants/tile_data.dart` — tile definitions
- `lib/core/constants/level_data.dart` — level definitions
- `lib/core/constants/layout_data.dart` — board layouts
- `lib/models/tile_model.dart` — tile model
- `lib/models/game_state.dart` — game state
- `lib/providers/game_provider.dart` — game logic
- `lib/providers/progress_provider.dart` — progress
- `lib/providers/settings_provider.dart` — settings
- `lib/core/utils/board_solver.dart` — solver
- `lib/core/utils/audio_service.dart` — audio
- `lib/core/utils/haptic_service.dart` — haptics
- `lib/core/router/app_router.dart` — navigation
- `lib/screens/game/widgets/tile_widget.dart` — tile rendering
- `lib/screens/game/widgets/board_widget.dart` — board logic (wrapping it, not editing it)
- `lib/widgets/tile_back.dart` — tile back (no change needed)
- `pubspec.yaml` — no new dependencies

---

## 4. Responsive Design Strategy

- All new widgets use `LayoutBuilder` for sizing
- `GameBoardBackdrop`: circle diameter = `min(width, height) * 0.88`
- `GameStatsPanel`: horizontal padding proportional to screen width
- `GameControlDock`: buttons sized with `Expanded` or `flex` ratios
- Tile sizing remains handled by existing `BoardWidget`'s `LayoutBuilder` logic (unchanged)
- Safe areas preserved throughout

---

## 5. Implementation Order (Risk-Minimizing)

1. **Phase 1 — Color & Text Foundation**
   - Extend `app_colors.dart` with archive palette
   - Extend `app_text_styles.dart` with archive text styles
   - Verify: `flutter analyze` passes

2. **Phase 2 — Extracted Widgets**
   - Create `parchment_background.dart`
   - Create `game_header.dart`
   - Create `game_stats_panel.dart`
   - Create `game_board_backdrop.dart` (with `ArchiveBoardPainter`)
   - Create `game_control_dock.dart`
   - Verify: `flutter analyze` passes

3. **Phase 3 — Game Screen Refactor**
   - Rewire `game_screen.dart` to use new widgets
   - Replace all navy palette references
   - Update overlays/dialogs colors
   - Test: run the app, verify all game states (playing, paused, won, lost, loadFailed)

4. **Phase 4 — Supporting Screens & Widgets**
   - Update `result_screen.dart` colors
   - Update `level_select_screen.dart` colors
   - Update `kente_button.dart` colors
   - Update `adinkra_divider.dart` colors
   - Update `hint_overlay.dart` colors

5. **Phase 5 — Polish**
   - Run `dart format` on all changed files
   - Run `flutter analyze` — fix any warnings
   - Run `flutter test` — ensure no regressions
   - Manual visual QA on different screen sizes

---

## 6. Risk Assessment

| Risk | Level | Mitigation |
|------|-------|------------|
| Tile visibility on light background | Low | Tiles use `tileFace` (#F5E6C8 cream) with `tileBorder` (#C8A96E) and `tileEdge` (#8B6914 dark) — they already have strong contrast against a parchment background. The board backdrop will add an additional slightly-darker stone area behind tiles |
| Text readability | Low | All new text styles use dark `archiveInk` (#2F3328) on light parchment — higher contrast than the current light-on-dark setup |
| Breaking existing layouts | Low | Only replacing containers/wrappers; tile positioning math is untouched |
| Performance | Low | One additional `CustomPainter` for the circular backdrop — lightweight; no blur effects |
| Overlays looking wrong | Low | Each overlay gets explicit new colors; tested in Phase 3 |
| Level select / result breakage | Very Low | Color-only changes to those screens |

---

## 7. Summary of Files to Create/Modify

### New Files (5):
1. `lib/screens/game/widgets/game_header.dart`
2. `lib/screens/game/widgets/game_stats_panel.dart`
3. `lib/screens/game/widgets/game_board_backdrop.dart`
4. `lib/screens/game/widgets/game_control_dock.dart`
5. `lib/screens/game/widgets/parchment_background.dart`

### Modified Files (8):
1. `lib/core/theme/app_colors.dart` — add archive palette (additive only)
2. `lib/core/theme/app_text_styles.dart` — add archive text styles (additive only)
3. `lib/screens/game/game_screen.dart` — rewire to new widgets + new colors
4. `lib/screens/result/result_screen.dart` — color update
5. `lib/screens/level_select/level_select_screen.dart` — color update
6. `lib/widgets/kente_button.dart` — color update
7. `lib/widgets/adinkra_divider.dart` — color update
8. `lib/screens/game/widgets/hint_overlay.dart` — color update

### Untouched (all game logic, tile data, solver, etc.):
Everything else — ~15+ files remain completely untouched.
