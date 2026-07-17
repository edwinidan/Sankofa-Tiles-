# Tile Layout System — Technical Audit Report

**Date:** 2026-07-12
**Branch:** `feature/admob-integration`
**Repository:** Sankofa Tiles (Flutter Mahjong-Solitaire)

**Update — 2026-07-12:** Odd-coordinate verification is complete. The integer half-grid approach works across all systems without any changes to the solver, blocking logic, or saved-game format. A pilot layout (`pilotSmallDiamondLayout`) has been created and passes all 153 tests.

---

## 1. Executive Summary

The game currently uses **36 named, manually authored layout templates** defined via procedural builder methods (`compactLayeredFormation`, `centeredPyramid`). These templates are pre-designed — they are not randomly generated at runtime. However, their visual quality is uneven because the builder methods produce rows of evenly spaced tiles at integer column offsets, creating blocky, grid-aligned formations that lack the organic, overlapping look of polished Mahjong games.

**Key finding:** The architecture already separates layout (positions) from symbols (matching pairs). The reverse-solved generator (`_buildReverseSolvedBoard`) works entirely from a fixed list of `TilePosition` objects and does not care how they were created. This means **predefined, visually designed layout coordinates can be used with the current guaranteed-solvability generator without any changes to the generator itself.**

The current system supports:
- Integer row/col coordinates with a tile-span of 2 units
- Multiple layers (up to 3 in production levels)
- Layer-based visual offsets (`kLayerOffsetX`, `kLayerOffsetY`)
- Half-tile visual offsets (via the projection system, not in the coordinate system)
- Automatic responsive scaling and centring
- A developer level tester screen at `/developer/levels`

The system does NOT currently support:
- True half-tile gameplay offsets (col values are integers, step is always 2)
- Tiles bridging across two lower tiles at different positions
- Fractional coordinate positions
- Per-tile custom visual offsets
- Layout preview with placeholder faces showing coordinates and layers

---

## 2. Relevant Files and Responsibilities

### Core Data & Constants

| File | Responsibility |
|------|---------------|
| `lib/core/constants/layout_data.dart` | Defines `TilePosition` (row, col, layer), `NamedLayout`, `LayoutStats`, `TileLayoutBuilder` (procedural builder methods), all 36 named layout constants (`compactDiamondLayout`, `beginnerBridgeLayout`, etc.), the `kLayoutLibrary` registry, and helper functions (`translate`, `mirrorHorizontally`, `combineLayouts`, `centeredPyramid`, `compactLayeredFormation`, `splitIslands`, `wingedLayout`, `courtyardLayout`, `windingPathLayout`). Also contains overlap/support validation (`_isPositionFree`, `_overlaps`, `_axisOverlaps`). |
| `lib/core/constants/level_data.dart` | Defines `LevelDefinition` (id, name, chapter, namedLayout, symbolPlan, difficultyCategory), `SymbolCopyPlan` (symbol pool size, copy counts), and `kLevels` — the complete list of 200 campaign levels. Each level references a `NamedLayout`. |
| `lib/core/constants/tile_data.dart` | Defines `TileDefinition` (id, name, symbol, suit, assetPath) and the full `kAllTiles` list of 98 Adinkra symbols. Also exports `kTileIds`. |

### Models

| File | Responsibility |
|------|---------------|
| `lib/models/tile_model.dart` | Defines `TileModel` (uid, def, row, col, layer, visibility states, selection states). The canonical tile data object used throughout the game. |
| `lib/models/game_state.dart` | Defines `GameState` with the tile list, status, difficulty, score, and computed properties (`freeTileUids`, `availableTileUids`, `peekableTileUids`, `isStuck`). Delegates free-tile calculation to `BoardSolver`. |
| `lib/models/board_model.dart` | Lightweight `BoardModel` class with `rows`, `cols`, and `tiles`. Provides `tileAt(row, col)` lookup. Not heavily used in the current rendering path. |
| `lib/models/game_launch_config.dart` | `GameLaunchConfig` and `GameResultConfig` — carries level ID and launch mode. |

### Game Logic

| File | Responsibility |
|------|---------------|
| `lib/providers/game_provider.dart` | `GameNotifier` — the central game controller. `startLevel()` orchestrates level loading: selects layout, builds symbol deck, generates board (random or reverse-solved), validates solvability, applies peek coverage. Also handles tile selection, matching, hints, shuffling, win/loss detection. |
| `lib/core/utils/board_solver.dart` | `BoardSolver` — all blocking, free-tile, matching-pair, and solvability logic. `isTileFree()` checks cover (layer above + overlap) and side-blocking (same layer, adjacent columns). `findAvailableMatchingPairs()`, `isSolvable()`, `profileSolvability()`, `isSafeMove()`, `isFinalPairPlayable()`. Uses DFS with memoization and a search-node budget. |
| `lib/core/utils/board_layout_geometry.dart` | `BoardLayoutGeometry` — converts tile positions to screen coordinates. `projectX(col, layer)` = `col * 0.425 - layer * 0.14`. `projectY(row, layer)` = `row * 0.736 - layer * 0.085`. `fit()` calculates tile width/height to fit available space. |
| `lib/core/utils/campaign_validator.dart` | `validateCampaignStructure()` — static validation of all level definitions: duplicate IDs, duplicate coordinates, odd tile counts, symbol pool consistency, opening geometry, board bounds, viewport fit. |

### UI / Rendering

| File | Responsibility |
|------|---------------|
| `lib/screens/game/game_screen.dart` | `GameScreen` — the main gameplay screen. Wraps `BoardWidget` in a `Column` with header, controls, and overlays. Triggers `startLevel()` on first frame. |
| `lib/screens/game/widgets/board_widget.dart` | `BoardWidget` — renders tiles in a `Stack` with `Positioned` widgets. Uses `BoardLayoutGeometry` to compute tile offsets. Handles render order (layer first, then index), match animations, burst effects, win/loss overlays. |
| `lib/screens/game/widgets/tile_widget.dart` | `TileWidget` — renders a single tile with face image, suit code, name, shadows, interactive states (pressed, selected, hinted, mismatched, matched, blocked). |
| `lib/screens/game/widgets/hint_overlay.dart` | `HintOverlay` — a simple informational overlay, not related to layout. |
| `lib/screens/developer/developer_level_tester_screen.dart` | `DeveloperLevelTesterScreen` — a developer-only screen listing all 200 levels with layout name, tile count, difficulty, and validity status. Opens any level in developer test mode. |
| `lib/core/theme/sankofa_game_theme.dart` | `SankofaGameTheme` — tile shadows per layer (`tileShadowsForLayer`), colors, gradients, radii. |

### Tests

| File | Responsibility |
|------|---------------|
| `test/board_layout_geometry_test.dart` | Tests: all 200 campaign boards fit viewport presets; tile scale stays close to Level 6 standard; every layout has unique coordinates and valid opening geometry (≥2 free tiles). |
| `test/game_provider_startup_test.dart` | Tests: campaign structure validity; representative levels start quickly with solvable boards; layered levels have mixed face-up/covered tiles; all campaign levels generate without exceptions; reverse-generation exhaustion fails safely; late levels maintain progression constraints. |
| `test/board_widget_ghost_tile_test.dart` | Tests: `shouldRenderBoardTile()` — unmatched visible, hidden not rendered, matched visible only during animation. |
| `test/tile_visibility_test.dart` | Tests: visibility states, available vs free vs peekable tile sets, stuck detection. |
| `test/phase2_flow_test.dart` | Tests: tutorial completion, home screen, pre-level locking, chapter complete routing. |
| `test/phase4_peek_gameplay_test.dart` | Tests: peek/cover gameplay mechanics. |

---

## 3. Current Level-Generation Flow

### Step-by-step execution order:

1. **Player selects a level** → `GameScreen` is pushed with `GameLaunchConfig(levelId, launchMode)`.

2. **`GameScreen.initState()`** → schedules `startLevel()` via `addPostFrameCallback`.

3. **`GameNotifier.startLevel(levelId, difficulty)`**:
   - Calls `getLevelById(levelId)` → retrieves the `LevelDefinition` from `kLevels`.
   - Calls `_buildSymbolDeck(levelDef)` → uses `symbolCopyCounts` and `tileIds` to build a shuffled list of `TileDefinition` copies (always an even count matching `tileCount`).
   - **Generation strategy decision:**
     - If `tileCount >= 40` (the `_reverseSolvedTileThreshold`) → uses `_buildReverseSolvedBoard()`.
     - Otherwise → tries up to 12 random boards via `_buildRandomBoard()`, checking solvability of each with `BoardSolver.profileSolvability()`. Falls back to reverse-solved if all fail.
   - **Final solvability verification** → `BoardSolver.profileSolvability()` on the resulting tiles. If unsolvable, shows load-failed state.
   - Calls `_applyInitialPeekCoverage()` → randomly covers some free and blocked tiles based on difficulty category and level progression.
   - Sets `state = GameState(tiles: preparedTiles, status: playing, ...)`.

4. **`BoardWidget.build()`** consumes the `GameState`:
   - Gets the `LevelDefinition` again for the current `levelId`.
   - Extracts `TilePosition` list from `gameState.tiles` (row, col, layer).
   - Creates `BoardLayoutGeometry.fromPositions(positions)`.
   - Calls `geometry.fit(availableWidth, availableHeight)` → gets `tileWidth`, `tileHeight`, `boardWidth`, `boardHeight`.
   - Centers the board: `boardLeft = (availableWidth - boardWidth) / 2`, `boardTop = (availableHeight - boardHeight) / 2`.
   - For each tile, computes `tileOffset(row, col, layer)` using `geometry.project()`.
   - Renders tiles in a `Stack` with `Positioned(left: offset.dx, top: offset.dy, width: tileW, height: tileH)`.
   - Sort order: by layer ascending, then by index. Then reordered for visual priority (matched/animated on top).

### Key separation:

- **Layout positions are defined statically** in `kLevels` → `LevelDefinition.namedLayout.positions`.
- **Symbols are assigned dynamically** during `startLevel()` — either randomly or via reverse-solved generation.
- **Solvability is guaranteed** after symbol assignment, not before.

---

## 4. Current Layout-Generation System

### How layouts work:

The layouts are **manually authored via procedural builder methods**, not randomly generated. Each of the 36 `NamedLayout` constants in `layout_data.dart` is constructed using builder methods like:

- `compactLayeredFormation()` — takes a list of row-count-per-layer arrays, centers them around `centerCol=20`, and staggers them vertically with `rowStep=2`.
- `centeredPyramid()` — similar but with a different row-start calculation.
- `splitIslands()`, `wingedLayout()`, `courtyardLayout()`, `windingPathLayout()` — more complex shapes.

Each layout produces a `List<TilePosition>` where:
- `row` values are integers, spaced by 2 (a "tile-span" of 2 units).
- `col` values are integers, typically even (since rows start at even column offsets).
- `layer` values start at 0 (base layer) and go up to 2 or 3.

### Layout characteristics:

| Property | Current State |
|----------|--------------|
| Randomly generated? | No |
| Procedurally generated? | Yes, via builder methods |
| Manually authored? | Yes, the builder parameters are hand-chosen |
| Loaded from templates? | Yes, as Dart constants |
| All levels use same generator? | Yes, all use `compactLayeredFormation` or `centeredPyramid` |
| Each level has unique layout? | No — layouts are reused across levels (e.g., `sacredBridgeLayout` used in levels 31, 36) |
| Level number affects complexity? | Indirectly — later levels use layouts with more tiles and layers |
| Tile count varies? | Yes, from 24 tiles (level 1) to ~130 tiles (level 200) |
| Layers vary? | Yes, from 2 to 3 layers |
| Intentional symmetry? | Approximate — centered rows produce horizontal symmetry, but not exact due to integer positioning |
| Board silhouette concept? | Yes — names like "Turtle", "Crown", "Butterfly" suggest intended shapes, but the grid-aligned integer positions limit how recognizable these shapes are |

### Why current boards look irregular:

1. **Grid-aligned integer coordinates**: All tiles sit on a strict grid with row/col spacing of 2 units. This creates a blocky, "pixelated" look rather than the smooth, organic shapes of polished Mahjong games.

2. **No half-tile offsets**: The `col` and `row` values are always integers. True half-tile overlaps (where a tile on layer 1 sits halfway between two tiles on layer 0) are not possible.

3. **Uniform row widths**: The `compactLayeredFormation` builder creates layers where each row has a fixed number of tiles specified in arrays like `[4, 6, 7, 7, 6, 4]`. While this creates a rough diamond/hexagonal shape, it lacks the nuance of hand-placed tiles.

4. **No deliberate negative space within layers**: Empty space only occurs between rows/layers, not within a single layer's structure.

5. **Uniform vertical spacing**: All rows within a layer are spaced by exactly 2 units. There's no variation in vertical density.

6. **Limited layer interplay**: Upper layers always sit centered above lower layers. There are no offset bridges, no tiles that span gaps, no cantilevered tiles.

---

## 5. Coordinate System

### The coordinate system in detail:

Tiles use **integer grid coordinates** with these properties:

| Property | Value |
|----------|-------|
| Coordinate type | Integer rows and columns |
| Tile span | 2 units (a tile occupies from `col` to `col+2` horizontally, `row` to `row+2` vertically) |
| Horizontal step between adjacent tiles | 2 (tiles at col=0 and col=2 are adjacent with no gap) |
| Vertical step between rows | 2 |
| Layer | Integer starting at 0 (base layer) |
| Max layers in production | 3 |

### Visual projection (gameplay → screen):

```dart
// board_layout_geometry.dart lines 93-99
static double projectX(int col, int layer) {
  return col * kBoardStepX - layer * kLayerOffsetX;
  // kBoardStepX = 0.425
  // kLayerOffsetX = 0.14
}

static double projectY(int row, int layer) {
  return row * kBoardStepY - layer * kLayerOffsetY;
  // kBoardStepY = kTileAspectRatio * 0.425 ≈ 0.736
  // kLayerOffsetY = kTileAspectRatio * 0.10 ≈ 0.085
}
```

This means:
- **X position**: `col * 0.425 - layer * 0.14` (in tile-width units). Higher layers shift left/up.
- **Y position**: `row * 0.736 - layer * 0.085` (in tile-width units). Higher layers shift upward.
- **Screen position**: `projected * tileWidth` gives pixel coordinates.

### Overlap detection:

```dart
// board_solver.dart lines 205-211 and layout_data.dart lines 441-448
static bool _overlaps(int rowA, int colA, int rowB, int colB) {
  return _axisOverlaps(rowA, rowB) && _axisOverlaps(colA, colB);
}

static bool _axisOverlaps(int startA, int startB) {
  const tileSpan = 2;
  return startA < startB + tileSpan && startB < startA + tileSpan;
}
```

Two tiles overlap if their row ranges AND column ranges overlap. The range for a tile at `(row, col)` is `[row, row+2)` in rows, `[col, col+2)` in columns.

### What coordinates mean:

| Term | Meaning |
|------|---------|
| `row` | Integer Y-position. Range is typically 0 to ~20. Spacing between rows is 2. |
| `col` | Integer X-position. Range is typically 8 to ~32. Spacing between adjacent tiles is 2. |
| `layer` | Integer Z-position. 0 = bottom layer. Higher = on top. |
| Visual X | `col * 0.425 * tileWidth - layer * 0.14 * tileWidth` |
| Visual Y | `row * 0.736 * tileWidth - layer * 0.085 * tileWidth` |
| Render order | Sorted by layer ascending, then by index. Layer 0 renders first (bottom). |

### What's NOT supported:

- **Decimal/fractional positions**: `row` and `col` are `int`, not `double`.
- **Half-tile offsets**: Adjacent tiles must be at col difference of 2 (exact alignment) or ≥4 (gap). No col=1 or col=3 positions for bridging.
- **Quarter-tile offsets**: Not possible with integer coordinates.
- **Tiles bridging two lower tiles**: Not possible because upper tiles must have exact overlap with lower tiles.
- **Per-tile custom visual offsets**: All tiles at a given (row, col, layer) project to the same screen position. The projection formula is uniform.

### Visual vs gameplay coordinates:

They use the **same row/col/layer values** but different interpretations:
- **Gameplay**: Uses integer ranges with tile-span of 2 for overlap/blocking checks.
- **Visual**: Projects integers to floating-point screen coordinates with layer offsets.

Both systems use the exact same `row`, `col`, `layer` values. There is no separate "visual position" property.

---

## 6. Layering and Render Order

### How layers work:

1. **Layer assignment**: Each `TilePosition` has a `layer` field (integer, 0-based). Set at layout definition time in the builder methods.

2. **Layer 0 = bottom layer**: The base layer. Layer 1 tiles sit on top of layer 0 tiles. Layer 2 on top of layer 1.

3. **Render order** (board_widget.dart lines 64-68):
   ```dart
   indexedTiles = gameState.tiles.indexed.toList()
     ..sort((a, b) {
       final layerComparison = a.$2.layer.compareTo(b.$2.layer);
       if (layerComparison != 0) return layerComparison;
       return a.$1.compareTo(b.$1);
     });
   ```
   Layer 0 renders first (visually behind), then layer 1, then layer 2.

4. **Visual depth cue**: Higher layers get stronger shadows via `SankofaGameTheme.tileShadowsForLayer(layer)` (line 440 of tile_widget.dart). The shadow offset and blur increase with layer number.

5. **Layer offset in screen projection**: Higher layers shift left (`-layer * 0.14 * tileWidth`) and up (`-layer * 0.085 * tileWidth`), giving a 3D isometric-like effect.

### Support/validation:

- **Support is NOT validated at layout-build time**: The `namedLayout()` function checks for even tile count and opening geometry, but does NOT check that every upper-layer tile has a tile directly beneath it. The `_isPositionFree()` function in `layout_data.dart` checks for coverage (tiles above) and side-blocking — it assumes upper tiles overlap lower tiles but does not validate structural support.

- **Floating tiles are currently possible**: Nothing in the layout builder prevents defining a tile on layer 1 at a position with no layer 0 tile beneath it.

- **Upper tile overlapping two lower tiles**: Not supported with the current integer coordinate system. A tile at `(row=4, col=10, layer=1)` has range `[4,6) × [10,12)`. It could overlap two tiles at `(4,8)` and `(4,10)` on layer 0, but since coordinates are always even, the upper tile would have to be at an odd offset to bridge between them — which the integer system doesn't allow.

- **Maximum layers**: Currently 3 in production levels (enforced by the test: `layerCount > 3` is empty). The shadows and rendering support up to layer 6 (`layer.clamp(0, 6)` in the theme).

### Suitability for designed layouts:

The layering system is **adequate but limited**. The visual projection gives a nice 3D effect, and the blocking rules correctly handle overlapping tiles. However, the inability to have fractional tile positions means designed layouts cannot achieve the smooth, staggered look of premium Mahjong games where upper tiles partially overlap two lower tiles.

---

## 7. Blocking and Selectability Rules

### The `isTileFree()` method (board_solver.dart lines 24-52):

A tile is **free** (selectable) when ALL of these are true:
1. It is not matched.
2. It is not covered by any tile on a higher layer that overlaps it.
3. At least one side (left OR right) is not blocked by an adjacent tile on the same layer.

### Detailed checks:

**Cover check (from above):**
```dart
final isCovered = unmatched.any(
  (other) =>
      other.uid != tile.uid &&
      other.layer > tile.layer &&
      _overlaps(tile.row, tile.col, other.row, other.col),
);
```
- Any tile on a higher layer whose row AND column ranges overlap blocks this tile.
- Overlap uses `_axisOverlaps` with `tileSpan = 2`.

**Left-side block check:**
```dart
final leftBlocked = unmatched.any(
  (other) =>
      other.uid != tile.uid &&
      other.layer == tile.layer &&
      other.col + _tileSpan == tile.col &&  // other.col + 2 == tile.col
      _axisOverlaps(tile.row, other.row),
);
```
- A tile is left-blocked if there's a tile on the SAME layer with its right edge touching this tile's left edge, AND their row ranges overlap.

**Right-side block check:**
```dart
final rightBlocked = unmatched.any(
  (other) =>
      other.uid != tile.uid &&
      other.layer == tile.layer &&
      other.col == tile.col + _tileSpan &&  // tile.col + 2 == other.col
      _axisOverlaps(tile.row, other.row),
);
```
- A tile is right-blocked if there's a tile on the SAME layer with its left edge touching this tile's right edge, AND their row ranges overlap.

**Free condition:**
```dart
return !leftBlocked || !rightBlocked;
```
- The tile must have at least one open side. If BOTH sides are blocked, it's not free (even if uncovered).

### Matching rules:
- Two tiles match if they are both free AND have the same `def.id`.

### Safe-move check (board_solver.dart lines 116-129):
- After removing a pair, the remaining board must be solvable. This prevents moves that would make the board impossible to complete.

### Coordinate dependencies:

| Check | Depends on |
|-------|-----------|
| Cover detection | `_axisOverlaps` — row AND column range overlap with higher layer |
| Left blocking | Exact col adjacency: `other.col + 2 == tile.col` |
| Right blocking | Exact col adjacency: `tile.col + 2 == other.col` |
| Same-layer check | `other.layer == tile.layer` |
| Row overlap | `_axisOverlaps` — row ranges must intersect |

### Critical observation for half-tile offsets:

The blocking logic **depends on exact integer equality** (`other.col + 2 == tile.col`) for side-blocking. If future layouts use half-tile offsets (e.g., a tile at col=1 that sits halfway between col=0 and col=2), the current blocking check would not detect it as blocking either neighbor, since `0 + 2 != 1` and `1 + 2 != 2`. This would need to change to a range-overlap check.

---

## 8. Guaranteed-Solvability System

### How reverse-solved generation works (game_provider.dart lines 268-340):

1. **Input**: A `List<TileDefinition>` symbol deck and a `List<TilePosition>` layout (fixed positions).

2. **Phase 1 — Build removal order**:
   - Start with all layout positions populated with placeholder tiles.
   - Repeatedly: find two free tiles, record their positions in `removalOrder`, remove them, continue.
   - Free tiles are shuffled each iteration for randomness.
   - If `remaining.isNotEmpty` after the loop (stuck), retry the entire process (up to 100 attempts).
   - This produces an ordered list of position-pairs that can be legally removed from the full board down to empty.

3. **Phase 2 — Assign symbols**:
   - Take the `pairDefs` (symbol definitions, each appearing once per pair).
   - Shuffle the pair definitions.
   - Assign: `shuffledPairs[i]` → `removalOrder[i*2]` and `removalOrder[i*2+1]`.
   - This ensures the board can be solved by removing pairs in the reverse of the order they were generated.

4. **Result**: A `List<TileModel>` where:
   - Positions come from the layout template.
   - Symbols are assigned so the board is guaranteed solvable by construction.
   - Solvability does NOT depend on a specific stored path — it's inherent in the assignment because the removal order used for assignment IS a valid solution.

### Key architectural fact:

**The reverse-solved generator operates entirely on the provided `List<TilePosition> layout` parameter.** It does not generate positions. It does not care where the positions came from. It only needs:
- The positions to be a valid Mahjong layout (no duplicate coords, opening geometry exists).
- The tile count to be even.

### Can it accept manually designed coordinates?

**Yes.** The generator at `game_provider.dart:268` receives `List<TilePosition> layout` as a parameter. If that list comes from a predefined `LayoutTemplate` instead of a procedurally built one, the generator works identically. The generator:
- Iterates over `layout` positions (line 277-278)
- Creates placeholder tiles at those positions
- Finds free-tile pairs based on the blocking rules
- Assigns symbols to create guaranteed solvability

The separation is already architecturally clean: `layout` provides positions, `symbolDeck` provides tile faces, and the generator pairs them with a solvability guarantee.

---

## 9. Existing Level-Layout Analysis

### Summary of all 36 named layouts:

| # | Layout ID | Name | Tiles | Pairs | Layers | Width (cols) | Height (rows) | Symmetrical? |
|---|-----------|------|-------|-------|--------|-------------|--------------|--------------|
| 1 | compactDiamond | Compact Diamond | 38 | 19 | 3 | ~16 | ~14 | Approx |
| 2 | beginnerBridge | Beginner Bridge | 36 | 18 | 3 | ~16 | ~12 | Approx |
| 3 | smallTurtle | Small Turtle | 44 | 22 | 3 | ~20 | ~14 | Approx |
| 4 | firstCross | First Cross | 38 | 19 | 3 | ~18 | ~14 | Approx |
| 5 | smallShrine | Small Shrine | 54 | 27 | 3 | ~20 | ~12 | Approx |
| 6 | openCourtyard | Open Courtyard | 46 | 23 | 3 | ~18 | ~12 | Approx |
| 7 | riverPath | River Path | 52 | 26 | 3 | ~20 | ~12 | Approx |
| 8 | wisdomHouse | Wisdom House | 48 | 24 | 3 | ~14 | ~12 | Approx |
| 9 | gatheringWings | Gathering Wings | 62 | 31 | 3 | ~24 | ~12 | Approx |
| 10 | elderBridge | Elder Bridge | 50 | 25 | 3 | ~20 | ~12 | Approx |
| 11 | heritageTurtle | Heritage Turtle | 66 | 33 | 3 | ~28 | ~14 | Approx |
| 12 | butterfly | Butterfly | 72 | 36 | 3 | ~26 | ~14 | Asymmetric |
| 13 | templeSteps | Temple Steps | 66 | 33 | 3 | ~26 | ~12 | Approx |
| 14 | wisdomStaircase | Wisdom Staircase | 54 | 27 | 3 | ~20 | ~12 | Approx |
| 15 | crown | Crown | 66 | 33 | 3 | ~26 | ~12 | Approx |
| 16 | sacredGrove | Sacred Grove | 56 | 28 | 3 | ~20 | ~12 | Approx |
| 17 | royalStool | Royal Stool | 76 | 38 | 3 | ~28 | ~12 | Asymmetric |
| 18 | ancestralGate | Ancestral Gate | 62 | 31 | 3 | ~24 | ~12 | Approx |
| 19 | twinTowers | Twin Towers | 54 | 27 | 3 | ~20 | ~12 | Approx |
| 20 | raisedCourtyard | Raised Courtyard | 66 | 33 | 3 | ~26 | ~12 | Approx |
| 21 | splitIslands | Split Islands | 72 | 36 | 3 | ~28 | ~12 | Approx |
| 22 | fortress | Fortress | 66 | 33 | 3 | ~26 | ~12 | Approx |
| 23 | hiddenCenter | Hidden Center | 86 | 43 | 3 | ~30 | ~14 | Approx |
| 24 | festivalArchive | Festival Archive | 82 | 41 | 3 | ~30 | ~14 | Asymmetric |
| 25 | layeredCourtyard | Layered Courtyard | 60 | 30 | 3 | ~18 | ~12 | Approx |
| 26 | windingPath | Winding Path | 54 | 27 | 3 | ~20 | ~12 | Approx |
| 27 | grandTurtle | Grand Turtle | 86 | 43 | 3 | ~34 | ~16 | Asymmetric |
| 28 | layeredShrine | Layered Shrine | 88 | 44 | 3 | ~34 | ~16 | Asymmetric |
| 29 | multiPeak | Multi Peak | 72 | 36 | 3 | ~28 | ~16 | Approx |
| 30 | complexFortress | Complex Fortress | 64 | 32 | 3 | ~28 | ~16 | Approx |
| 31 | sacredBridge | Sacred Bridge | 68 | 34 | 3 | ~30 | ~16 | Approx |
| 32 | ancestralCrown | Ancestral Crown | 92 | 46 | 3 | ~34 | ~18 | Asymmetric |
| 33 | grandTreasury | Grand Treasury | 108 | 54 | 3 | ~40 | ~18 | Asymmetric |
| 34 | templeComplex | Temple Complex | 70 | 35 | 3 | ~28 | ~16 | Approx |
| 35 | finalArchive | Final Archive | 108 | 54 | 3 | ~40 | ~18 | Asymmetric |

### Observed issues:

1. **No true symmetry**: Because tiles are placed on an integer grid with even spacing, "centered" layouts have approximate symmetry but not pixel-perfect symmetry. The center column (20) creates left-right balance, but the specific column positions don't always mirror exactly.

2. **Asymmetric layouts**: `butterfly`, `royalStool`, `festivalArchive`, `grandTurtle`, `layeredShrine`, `ancestralCrown`, `grandTreasury`, `finalArchive` have intentionally asymmetric row structures (different left and right side lengths).

3. **No half-tile offsets**: All tiles sit at even column positions. There's no visual staggering or bridging.

4. **Limited shape variety**: Despite 36 named layouts, most use `compactLayeredFormation` with different numeric arrays. The shapes are all variations of centered pyramids/diamonds — no rings, no hollow centers, no disconnected islands, no true bridges.

5. **Grid-like appearance**: The even spacing creates visible columns, making the board look like a grid rather than an organic arrangement.

6. **Uniform density**: Within each row, tiles are tightly packed (col step = 2). There are no deliberate gaps within a row.

7. **No deliberate negative space**: Empty areas only exist at the edges of rows, not as designed holes within the board silhouette.

---

## 10. Responsive Scaling and Centring

### How it works (board_widget.dart lines 81-108, board_layout_geometry.dart lines 65-84):

1. **Available area**: `LayoutBuilder` provides `constraints.maxWidth` and `constraints.maxHeight` (the Expanded area between the header and control dock).

2. **Safety inset**: `safeWidth = availableWidth - 16`, `safeHeight = availableHeight - 16` (8px inset on each side).

3. **Tile size calculation**:
   ```dart
   final widthFit = safeWidth / widthInTileUnits;
   final heightFit = safeHeight / heightInTileUnits;
   final fittedWidth = min(kPreferredTileWidth, min(widthFit, heightFit));
   final tileWidth = max(0.0, fittedWidth);
   ```
   - `widthInTileUnits` and `heightInTileUnits` are the board's extent in projected tile-width units.
   - Tile width is capped at 64px (`kPreferredTileWidth`).
   - Aspect ratio is maintained: `tileHeight = tileWidth * kTileAspectRatio` (85/64).
   - X and Y scale together (uniform scaling).

4. **Centring**:
   ```dart
   final boardLeft = (constraints.maxWidth - boardW) / 2;
   final boardTop = (constraints.maxHeight - boardH) / 2;
   ```
   - Both horizontally and vertically centred in the available area.
   - The centring accounts for the board's projected bounds, not the raw coordinate min/max.

5. **Tile positioning**:
   ```dart
   Offset tileOffset(int row, int col, int layer) {
     final projected = geometry.project(TilePosition(row, col, layer), tileW);
     return Offset(
       boardLeft + projected.x - geometry.minX * tileW,
       boardTop + projected.y - geometry.minY * tileW,
     );
   }
   ```
   - `projected.x` = `col * 0.425 * tileW - layer * 0.14 * tileW`
   - `projected.y` = `row * 0.736 * tileW - layer * 0.085 * tileW`
   - Subtracting `minX * tileW` and `minY * tileW` normalizes so the top-left of the board bounds starts at the board origin.

### What is NOT accounted for:
- **Top HUD**: The board area is the `Expanded` widget between the header and dock. The header and dock have fixed heights, so they reduce available board space but the board auto-fits.
- **Shadows**: Shadow offsets are not included in the board bounds calculation. Shadows extend beyond the tile rect but are clipped by `Clip.hardEdge` on the Stack or overflow naturally.
- **Tile themes**: All tiles use the same aspect ratio (`85/64`). Different themes don't change tile dimensions — only the artwork.

### Predefined layouts and responsive scaling:

Predefined layouts **automatically fit** because `BoardLayoutGeometry.fromPositions()` calculates bounds from whatever positions are provided, and `fit()` scales them to the available space. A layout with wider bounds will get smaller tiles; a layout with narrower bounds will get tiles up to the 64px cap. The system handles this correctly for all 200 levels, verified by the test at `board_layout_geometry_test.dart:11`.

---

## 11. Compatibility with Predefined Templates

### Is the proposed architecture compatible?

**Yes, and it's essentially already the architecture in use.** The current system already separates:

1. **Layout definition** (`NamedLayout` / `TilePosition`) — defines WHERE tiles go.
2. **Symbol assignment** (reverse-solved generator) — defines WHAT symbol goes WHERE.
3. **Solvability guarantee** (reverse-solved generator) — ensures the board is completable.

The proposed `LayoutTemplate` + `LayoutPosition` model is a near-exact match for the existing `NamedLayout` + `TilePosition` model:

| Proposed | Existing | Notes |
|----------|----------|-------|
| `LayoutPosition(x, y, layer)` | `TilePosition(row, col, layer)` | Currently uses `int` for row/col. Would need `double` for half-tile offsets. |
| `LayoutTemplate(id, name, positions)` | `NamedLayout(id, name, positions)` | Essentially identical. |
| Solvability generator operates on positions | `_buildReverseSolvedBoard(symbolDeck, layout)` | Already takes a position list as input. |

### What would need to change for the proposed architecture:

1. **`TilePosition.row` and `.col` from `int` to `double`**: To support half-tile offsets and bridging. This is the single biggest change — it propagates through blocking logic, overlap detection, and visual projection.

2. **Blocking logic would need range-based checks**: Instead of `other.col + 2 == tile.col` for side-blocking, use range overlap: `_axisOverlaps(tile.col, other.col + _tileSpan)` or similar.

3. **`TileModel.row` and `.col` would also need to change**: Since `TileModel` stores these values and they're used in `BoardSolver`.

4. **`TilePosition` equality and hashCode**: Would need to handle floating-point comparison (epsilon-based).

---

## 12. Recommended Layout-Template Architecture

The current `NamedLayout` + `TilePosition` system is architecturally sound. The recommended approach is to **extend** it rather than replace it:

```dart
// Proposed extension to the existing TilePosition
class TilePosition {
  final double row;    // Changed from int to double
  final double col;    // Changed from int to double
  final int layer;

  const TilePosition(this.row, this.col, this.layer);

  // Epsilon-based equality for floating point
  @override
  bool operator ==(Object other) {
    if (other is! TilePosition) return false;
    return (row - other.row).abs() < 1e-6 &&
           (col - other.col).abs() < 1e-6 &&
           layer == other.layer;
  }
}
```

**Keep the existing:**
- `NamedLayout` class (rename to `LayoutTemplate` if desired, but structurally the same)
- `TileLayoutBuilder` (extend with methods for half-tile offsets)
- `LayoutStats` (update for double coordinates)
- `BoardLayoutGeometry` (already works with double projection)
- `kLayoutLibrary` registry
- Level definitions referencing layouts

**Benefits of this approach:**
- Minimal architectural change.
- All existing layouts continue to work (integers are valid doubles).
- New layouts can use fractional positions.
- The reverse-solved generator continues to work unchanged (it only reads positions, doesn't care about integer vs double).
- Existing tests continue to pass with the type change.

---

## 13. Validation System

### Recommended validators:

#### At build/compile time (static assertions in layout definitions):

| Validation | How |
|-----------|-----|
| Even tile count | `namedLayout()` already checks `stats.tileCount.isOdd` |
| Opening geometry | `namedLayout()` already checks `stats.startingFreeTileCount >= 2` |
| No duplicate coords | `TileLayoutBuilder.add()` already throws on duplicates |
| Max layers ≤ reasonable limit | Add to `namedLayout()`: assert `stats.maxLayer <= 4` |
| Board bounds within limits | Add to `namedLayout()` or campaign validator |

#### In unit tests (run on every `flutter test`):

| Validation | File |
|-----------|------|
| All layouts have unique coordinates | `board_layout_geometry_test.dart` — already exists |
| All layouts have valid opening geometry | `board_layout_geometry_test.dart` — already exists |
| All layouts fit viewport presets | `board_layout_geometry_test.dart` — already exists |
| Campaign structure consistency | `game_provider_startup_test.dart` — already exists |
| All levels generate solvable boards | `game_provider_startup_test.dart` — already exists |
| **New: Upper tiles have support beneath them** | Add to `board_layout_geometry_test.dart` |
| **New: No floating tiles** | Add to `board_layout_geometry_test.dart` |
| **New: Layout symmetry validation (optional)** | New test file |
| **New: All production layouts pass full validation** | New test file |

#### At app startup (debug mode only):

| Validation | How |
|-----------|-----|
| Layout library integrity | `validateCampaignStructure()` or equivalent |
| No duplicate layout IDs | Check in debug mode |
| Layout names are unique | Check in debug mode |

#### During level generation (runtime):

| Validation | How |
|-----------|-----|
| Solvability verified after generation | Already done in `startLevel()` |
| Tile count matches layout | Already enforced by `_buildReverseSolvedBoard` |
| Safe-move checking | Already done on match attempts |

### New validations needed for half-tile offsets:

1. **Support validation**: For each tile on layer > 0, at least one tile on the layer below must overlap it. This prevents "floating" tiles.
2. **Coverage validation**: Upper tiles should cover the seams between lower tiles (the visual purpose of upper layers in Mahjong).
3. **Precision validation**: Coordinates should be multiples of 0.5 (half-tile increments), not arbitrary floats.
4. **Balance scoring**: A heuristic that scores left-right and top-bottom symmetry for development-time feedback.

---

## 14. Developer Preview Tool

### Current state:

The `DeveloperLevelTesterScreen` at `lib/screens/developer/developer_level_tester_screen.dart` already provides:
- A scrollable grid of all 200 levels
- Layout name, tile count, difficulty, validity status
- Tap to open any level in developer test mode

### Recommended enhancements (not yet implemented):

A new `DeveloperLayoutPreviewScreen` could be added that:
- Lists all `NamedLayout` entries from `kLayoutLibrary`
- Selecting a layout renders it with placeholder gray tiles
- Shows layer numbers as text overlays
- Shows X/Y coordinates on each tile
- Highlights free (selectable) tiles with a green border
- Highlights blocked tiles with a red tint
- Allows manual tile removal (simulating gameplay)
- Shows board bounds as a rectangle
- Shows the centre point as a crosshair
- Shows symmetry guide lines (vertical and horizontal)
- Highlights unsupported tiles (layer > 0 with no tile beneath)
- Highlights duplicate coordinates
- Allows switching between tile themes
- Provides viewport size presets (compact phone, standard phone, tall phone)
- Runs the solvability checker and shows results

This could fit into the existing developer tools pattern at `lib/screens/developer/` and be accessed from the `DeveloperLevelTesterScreen` or a separate developer menu.

---

## 15. Existing Tests

| Test File | What It Tests | Relevance to Layout Redesign |
|-----------|--------------|---------------------------|
| `board_layout_geometry_test.dart` | All 200 boards fit viewports, tile sizes consistent, unique coords, valid opening geometry | **Directly relevant** — must continue passing |
| `game_provider_startup_test.dart` | Campaign structure, level startup speed, solvability, mixed visibility, all levels generate, failure safety | **Directly relevant** — must continue passing |
| `board_widget_ghost_tile_test.dart` | Tile render filtering (hidden, matched, animating) | **Indirectly relevant** — should still pass |
| `tile_visibility_test.dart` | Visibility states, available/free/peekable sets | **Indirectly relevant** — should still pass |
| `phase2_flow_test.dart` | Tutorial, home screen, pre-level locking | Not relevant |
| `phase4_peek_gameplay_test.dart` | Peek/cover mechanics | **Indirectly relevant** — should still pass |
| `ad_ids_test.dart` | Ad unit IDs | Not relevant |
| `ad_monetization_ux_test.dart` | Ad UX rules | Not relevant |
| `audio_lifecycle_test.dart` | Audio lifecycle | Not relevant |
| `economy_service_test.dart` | Economy/in-app purchases | Not relevant |
| `game_header_layout_test.dart` | Header layout | Not relevant |
| `monetization_service_test.dart` | Monetization | Not relevant |
| `progression_flow_test.dart` | Level progression | **Indirectly relevant** — should still pass |
| `release_readiness_test.dart` | Release readiness checks | Not relevant |
| `result_screen_dispose_test.dart` | Result screen lifecycle | Not relevant |
| `result_unlock_reveal_test.dart` | Unlock reveal animation | Not relevant |
| `tile_collection_integration_test.dart` | Collection integration | Not relevant |
| `tile_unlock_rules_test.dart` | Tile unlock rules | Not relevant |

---

## 16. Missing Tests

### Critical tests needed before layout redesign:

1. **Fixed layout remains solvable**: Given a predefined `List<TilePosition>`, verify the reverse-solved generator always produces a solvable board.
2. **All templates have even tile count**: Already covered by `namedLayout()`, but add explicit tests.
3. **No duplicate coordinates on same layer**: Already covered by `TileLayoutBuilder` and tests, but extend to double-precision coords.
4. **Upper tiles have valid support**: New test — for each layout, every tile on layer > 0 must overlap at least one tile on the layer below.
5. **Blocking works with half-tile offsets**: New test — create a layout with tiles at col=0, col=1, col=2 on the same layer and verify correct blocking.
6. **Cover detection works across layers with fractional positions**: New test — verify that a tile at (row=0, col=1, layer=1) correctly covers tiles at (0,0) and (0,2) on layer 0.
7. **Selectability updates after tile removal**: Test that removing a tile correctly frees adjacent tiles.
8. **Layout bounds calculated correctly with double coords**: Verify `BoardLayoutGeometry.fromPositions()` handles fractional positions.
9. **Layouts remain centred on different screen sizes**: Widget test with different viewport sizes.
10. **Layouts do not overflow on small screens**: Already partially covered by viewport fit tests.
11. **Solvability generation is deterministic with fixed seed**: New test — verify that `_buildReverseSolvedBoard` with the same RNG seed produces the same result.
12. **Every production layout passes full validation**: New comprehensive test.
13. **Every production level has at least one valid starting move**: Already covered.
14. **Every generated board has a complete solution path**: Already covered by solvability check.
15. **Symbol assignment doesn't change visual layout**: Verify that after generation, positions match the input layout.
16. **Different tile themes don't change gameplay coordinates**: Verify that switching themes doesn't affect blocking or matching.

---

## 17. Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|-----------|
| **Breaking solvability** | Critical | Keep reverse-solved generator unchanged. Test every new layout with solvability check before committing. |
| **Incorrect blocking with half-tile offsets** | High | Change side-blocking from exact equality to range-overlap. Add comprehensive tests for all overlap scenarios. |
| **Unsupported (floating) tiles** | High | Add support validation in layout builder and tests. Reject layouts with floating tiles. |
| **Floating-point comparison errors** | High | Use epsilon-based equality (1e-6) for all coordinate comparisons. Hash by rounding to a fixed precision. |
| **Responsive scaling breaks with wider layouts** | Medium | All layouts must pass viewport fit tests. Enforce maximum board width/height constraints. |
| **Render-order bugs with overlapping tiles** | Medium | The current index-based secondary sort should still work. Test with layouts that have dense overlapping. |
| **Performance regression** | Low | The number of tiles per level doesn't change. Blocking checks are O(n²) but n ≤ 130, which is fast. |
| **Existing saved games broken** | Medium | Saved games store the full `GameState` including tile positions. Changing `TilePosition` from `int` to `double` would make deserialization fail. Either: (a) migrate saved data, or (b) keep `TileModel` using `int` and add a separate `visualOffset` field. **Recommend option (b)** — keep gameplay coordinates as `int` and add a `double visualOffsetX`/`visualOffsetY` to `TilePosition` for visual staggering while keeping blocking logic unchanged. |
| **Existing level progress broken** | Low | Progress is keyed by level ID, not layout. Unchanged. |
| **Shuffle behaviour** | Low | Shuffle permutes (row, col, layer) triples. With integer coords, this is unaffected. With double coords, need to ensure shuffle still produces valid boards. |
| **Hint behaviour** | Low | Hint uses `BoardSolver.findAvailableMatchingPairs()`. Works the same regardless of coordinate type. |
| **Replay behaviour** | Low | Replay just restarts the level. Same generation logic applies. |
| **Theme compatibility** | Low | Themes only change tile artwork and colors, not dimensions or positions. |
| **Test coverage gaps** | Medium | Add new tests before changing production code. Run existing test suite after each change. |

### Recommended approach for the int→double transition:

Instead of changing `TileModel.row` and `.col` from `int` to `double` (which has cascading effects on saved games, shuffle, blocking, and serialization), **add visual offset fields**:

```dart
class TilePosition {
  final int row;       // Gameplay row (unchanged)
  final int col;       // Gameplay col (unchanged)
  final int layer;     // Layer (unchanged)
  final double visualOffsetX;  // Visual stagger X in tile-width units (default 0)
  final double visualOffsetY;  // Visual stagger Y in tile-width units (default 0)
}
```

This way:
- Blocking logic continues to use exact integer comparisons (no changes needed).
- Visual projection adds the offset: `projectX = col * stepX - layer * offsetX + visualOffsetX`.
- Half-tile offsets are purely visual — the gameplay grid remains integer-based.
- Saved games are unaffected (the `visualOffset` is cosmetic, not structural).
- **Tradeoff**: Tiles cannot truly "bridge" across two lower tiles for gameplay purposes because the gameplay grid is still integer-based. For true bridging, you'd need fractional gameplay coordinates.

---

## 18. Files That Would Eventually Need Modification

### Phase 1 (models & validation — no behaviour change):

| File | Change |
|------|--------|
| `lib/core/constants/layout_data.dart` | Add `visualOffsetX`/`visualOffsetY` to `TilePosition`. Add new builder methods for half-tile-staggered layouts. Add support validation. |
| `lib/core/utils/campaign_validator.dart` | Add support validation, symmetry scoring, half-tile offset validation. |
| `lib/core/utils/board_layout_geometry.dart` | Update `projectX`/`projectY` to use visual offsets if present. |

### Phase 2 (generator — accept predefined positions):

| File | Change |
|------|--------|
| `lib/providers/game_provider.dart` | No changes needed — `_buildReverseSolvedBoard` already accepts `List<TilePosition>`. If visual offsets are added, propagate them to `TileModel`. |
| `lib/models/tile_model.dart` | Optionally add `visualOffsetX`/`visualOffsetY` fields. |

### Phase 3 (new layouts):

| File | Change |
|------|--------|
| `lib/core/constants/layout_data.dart` | Add new `NamedLayout` entries for polished templates. |
| `lib/core/constants/level_data.dart` | Update `kLevels` to reference new layouts for selected levels. |

### Phase 4 (all levels):

| File | Change |
|------|--------|
| `lib/core/constants/level_data.dart` | Replace remaining old layout references with new ones. |

### Phase 5 (cleanup):

| File | Change |
|------|--------|
| `lib/core/constants/layout_data.dart` | Remove unused procedural builder methods if all layouts are now manually authored templates. Remove old `NamedLayout` entries that are no longer referenced. |

### Files that should NOT change:

| File | Reason |
|------|--------|
| `lib/core/utils/board_solver.dart` | Blocking logic is correct and tested. Visual-only changes don't affect it. |
| `lib/screens/game/widgets/board_widget.dart` | Rendering works with projected coordinates. New layouts project the same way. |
| `lib/screens/game/widgets/tile_widget.dart` | Tile rendering is independent of position logic. |
| `lib/models/game_state.dart` | State management is independent of layout design. |
| `lib/core/constants/tile_data.dart` | Tile definitions are unrelated to layout. |
| `lib/core/theme/sankofa_game_theme.dart` | Theming is unrelated to layout. |

---

## 19. Recommended Phased Implementation Plan

### Phase 1 — Foundation (no behaviour change)
**Goal**: Add infrastructure for visual offsets without changing gameplay.

1. Add `visualOffsetX` and `visualOffsetY` fields to `TilePosition` (default 0.0).
2. Update `BoardLayoutGeometry.projectX()` and `projectY()` to incorporate visual offsets.
3. Add `TileLayoutBuilder` methods for creating half-tile-staggered rows.
4. Add support validation to `campaign_validator.dart`.
5. Add comprehensive tests for the new offset system.
6. Verify all 200 existing levels still generate and pass tests (they will — offsets default to 0.0).

### Phase 2 — Generator Compatibility
**Goal**: Confirm the reverse-solved generator works with visually offset positions.

1. Create 2-3 test layouts with half-tile visual offsets.
2. Verify the reverse-solved generator accepts them and produces solvable boards.
3. Write tests confirming blocking logic still works (blocking ignores visual offsets).
4. Write tests confirming visual projection includes offsets.
5. Run the full test suite.

### Phase 3 — First Polished Layouts
**Goal**: Create a small set of polished layouts and deploy them to a few early levels.

1. Design 3-5 new layout templates with:
   - Precise symmetry (mirror positions across center axis)
   - Half-tile visual offsets for organic staggering
   - Clear recognizable silhouettes (diamond, turtle, crown)
   - Deliberate negative space
   - Validated support for all upper-layer tiles
2. Add them to `kLayoutLibrary`.
3. Assign them to levels 1-5 (replacing the existing layouts for those levels).
4. Run all tests.
5. Manual visual review on device.

### Phase 4 — Full Campaign Redesign
**Goal**: Replace all 36 layouts with polished templates.

1. Design 36+ polished layout templates with difficulty progression.
2. Assign layouts to levels based on tile count, layer count, and complexity.
3. Update `kLevels` with new layout assignments.
4. Run full test suite (all 200 levels must generate solvable boards).
5. Verify viewport fit for all layouts on all screen sizes.

### Phase 5 — Cleanup (optional, only after all tests pass)
**Goal**: Remove obsolete code.

1. Remove procedural builder methods that are no longer used.
2. Remove old `NamedLayout` entries that are no longer referenced.
3. Run tests to confirm nothing is broken.

---

## 20. Questions That Need Your Approval Before Implementation

1. **Visual-only offsets vs. true gameplay offsets**: Do you prefer the safer approach of visual-only offsets (blocking stays integer-based, no saved-game migration needed) or the more flexible approach of changing to `double` coordinates (enables true bridging but requires changes to blocking logic, saved games, and shuffle)?

2. **How many new layouts**: Do you want 36 new layouts (one-to-one replacement) or fewer layouts with more intentional reuse across levels?

3. **Layout complexity curve**: Should difficulty increase primarily through more tiles, more layers, more complex silhouettes, or a combination?

4. **Symmetry requirement**: Should ALL layouts be perfectly symmetrical, or should some be intentionally asymmetric for variety?

5. **Adinkra-inspired silhouettes**: How important are Adinkra-symbol-inspired shapes (e.g., Gye Nyame shaped board)? These would be unique to this game but more complex to design.

6. **Coordinate precision**: If using half-tile offsets, should positions be constrained to multiples of 0.5 (half-tile grid) or 0.25 (quarter-tile grid)?

7. **Maximum layers**: Should we increase the maximum layers from 3 to 4 or 5 for more dramatic vertical stacking?

---

## Addendum: Odd-Coordinate Verification Results (2026-07-12)

### Finding: Odd integer coordinates already work as half-tile offsets

The overlap detection logic uses range-based checks:
```dart
bool _axisOverlaps(int startA, int startB) {
  const tileSpan = 2;
  return startA < startB + tileSpan && startB < startA + tileSpan;
}
```

This means a tile at `col=1` (spanning [1, 3)) overlaps both `col=0` ([0, 2)) and `col=2` ([2, 4)). No code path enforces even-only coordinates. The system already supports half-tile positioning using odd integer values.

### Verified across all systems:

| System | Odd-coordinate support | Notes |
|--------|----------------------|-------|
| `TilePosition` | Works | Stores any `int` |
| `TileModel` | Works | Stores any `int` |
| `BoardSolver._axisOverlaps` | Works | Range-based, handles any int |
| `BoardSolver.isTileFree` | Works | Cover detection uses range overlap; side-blocking uses exact adjacency (correct behaviour) |
| `BoardLayoutGeometry.projectX/projectY` | Works | Multiplies by float constants |
| `BoardLayoutGeometry.fromPositions` | Works | Finds min/max of projected values |
| `BoardFit` centring | Works | Uses projected bounds |
| Reverse-solved generator | Works | Iterates positions, doesn't inspect values |
| Shuffle logic | Works | Shuffles (row, col, layer) triples |
| Campaign validator | Works | Updated with structural support check |
| `namedLayout()` factory | Works | Accepts any `List<TilePosition>` |
| `TileLayoutBuilder` | Works | Rejects duplicates by equality |
| Developer tester | Works | Updated with layout library preview |

### Side-blocking behaviour with odd coordinates:

Side-blocking uses exact adjacency (`other.col + 2 == tile.col`), which is correct:
- Tile at `col=1` has neighbours at `col=-1` (left) and `col=3` (right).
- Tiles at `col=0` and `col=1` on the SAME layer are NOT side-neighbours (they would visually overlap, which is a layout design error, not a blocking issue).
- A tile at `col=1` on layer 1 correctly bridges tiles at `col=0` and `col=2` on layer 0.

### Selected coordinate strategy: Integer half-grid

- Keep `row` and `col` as `int`
- Keep `tileSpan = 2`
- Even coordinates = full-tile alignment
- Odd coordinates = half-tile offset
- No `double` coordinates needed
- No `visualOffsetX`/`visualOffsetY` needed
- No saved-game migration needed
- Gameplay and visual geometry remain identical

### Pilot layout: `pilotSmallDiamondLayout`

- 30 tiles (15 pairs), 3 layers
- Left-right symmetrical diamond silhouette
- Layer 1 uses odd-col half-tile bridging
- Layer 2 provides a 3-tile top cap
- Passes all validations: solvability, support, viewport fit, unique coords
- Accessible from the developer tester's new Layout Library section
- Not assigned to any production campaign level

### Test results:

- 29 new tests in `test/odd_coordinate_layout_test.dart` — all passing
- 153 total tests — all passing
- Structural support validation added to `campaign_validator.dart`
- Layout library preview section added to developer tester

### Files modified:

| File | Change |
|------|--------|
| `lib/core/constants/layout_data.dart` | Added `pilotSmallDiamondLayout` to `kLayoutLibrary` |
| `lib/core/utils/campaign_validator.dart` | Added structural support (floating tile) validation |
| `lib/screens/developer/developer_level_tester_screen.dart` | Added Layout Library preview section with stats |
| `test/odd_coordinate_layout_test.dart` | 29 new tests covering overlap, cover, side-blocking, projection, bounds, reverse-solved generation, bridging, support validation, duplicate detection, and pilot solvability |

### Recommendation for first five production levels:

Replace levels 1-5 with polished, symmetrical templates using the odd-coordinate pattern:

1. **Level 1** — Simple pyramid (24 tiles, 2 layers, no odd coords — entry level)
2. **Level 2** — Small balanced diamond (30 tiles, 2 layers, odd-col staggering on layer 1)
3. **Level 3** — Bridge formation (36 tiles, 2 layers, horizontal bridging)
4. **Level 4** — Small temple (40 tiles, 3 layers, odd-coord bridging on layer 1, central tower)
5. **Level 5** — Balanced cross (48 tiles, 3 layers, deliberate negative space)

Each would follow the same proven approach: hand-authored `TilePosition` lists with deliberate symmetry, odd coordinates for half-tile staggering, and validation via the existing test suite.

---

## Three Critical Answers

### 1. Can fixed, visually designed layout coordinates be used with the current guaranteed-solvability generator?

**Yes.** The reverse-solved generator at `game_provider.dart:268` (`_buildReverseSolvedBoard`) accepts a `List<TilePosition> layout` parameter. It does not generate its own positions — it only assigns symbols to the positions it receives. Any source of `TilePosition` objects (procedural builder, hand-authored list, JSON file) works identically. The generator creates a valid removal order from the given positions and then assigns symbol pairs to create guaranteed solvability by construction.

### 2. Can symbols and matching pairs be assigned independently of the visual layout?

**Yes.** This separation already exists. The `LevelDefinition` stores a `NamedLayout` (positions) and a `SymbolCopyPlan` (how many copies of each symbol). The `startLevel()` method builds a symbol deck from the `SymbolCopyPlan`, shuffles it, and passes it alongside the layout positions to the board generator. The layout defines *where* tiles go; the symbol plan defines *what faces* they have. These are independent concerns.

### 3. What is the safest implementation path for replacing the current irregular layouts with polished, balanced and symmetrical layouts?

**Phase 1 first — add visual offset support without changing gameplay coordinates.** This is the lowest-risk approach:

1. Add `visualOffsetX`/`visualOffsetY` to `TilePosition` (default 0.0).
2. Update visual projection to use the offsets.
3. Create new layouts using these offsets for organic staggering while keeping gameplay coordinates as integers.
4. Blocking, solvability, shuffle, and saved games are completely unaffected because gameplay coordinates don't change.
5. Existing levels continue to work (offsets default to 0).
6. New layouts can be introduced incrementally, level by level.

This approach achieves the visual goal (polished, balanced, symmetrical layouts) without touching the critical gameplay systems (blocking, solvability, saved state).
