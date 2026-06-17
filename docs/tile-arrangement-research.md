# Sankofa Tiles — Tile Arrangement Research

## Overview

Sankofa Tiles uses **hardcoded positional layouts** combined with **randomized symbol assignment**. Every level has a fixed spatial arrangement of tile slots (the "shape"), but which Adinkra symbol lands in which slot is randomized at the start of each game — constrained by a solvability check to ensure every board is completable.

There are **32 layout definitions** in total. **25 are assigned to the game's 25 levels**, and **7 are unused building blocks**.

---

## How the Layout System Works

### The core data structure

A layout is just a list of `(row, col, layer)` triples — every slot where a tile will be placed:

```dart
class TilePosition {
  final int row;
  final int col;
  final int layer;
}
```

All layouts are defined in `lib/core/constants/layout_data.dart`.

### How layouts are generated (procedural, not JSON)

Layouts are **not stored as giant JSON lists**. Instead, a compact procedural function builds them at compile time.

The function `_mahjongLayout()` takes a list of lists of integers. Each inner list is one **layer**, and each integer is the **number of tiles in a row** within that layer. For example:

```dart
level9Layout = _mahjongLayout([
  [2, 4, 6, 8, 8, 6, 4],   // layer 0: 7 rows (widest: 8)
  [2, 4, 4],                // layer 1: 3 rows
  [2, 2],                   // layer 2: 2 rows
]);
```

The `_layer()` helper then expands each row spec into actual positions:

```
centerCol = 10

For each row: tiles run from (centerCol - (count - 1)) to (centerCol + (count - 1)), stepping by 2
Rows increment by 2 vertically (half-cell staggering)
Higher layers get a higher rowStart (shifts them up visually)
```

This creates the classic Mahjong-style diamond/pyramid staggering where tiles on one row nest between the gaps of the row below.

---

## Layout Patterns: Two Distinct Families

The game has two fundamentally different layout families:

### Family A: Multi-Layer Pyramids (Levels 1–14)

These follow **traditional Mahjong solitaire stacking patterns** — multiple layers of tiles where upper-layer tiles cover lower-layer tiles, adding strategic depth (you must uncover buried tiles before you can match them).

All use the centered-pyramid shape with varying width, height, and number of layers. Tile counts range from 28 (14 pairs) in Level 1 to 102 (51 pairs) in Level 14.

### Family B: Single-Layer Grids / "Archive" Levels (Levels 15–25)

These are broad flat displays built by `_archiveGridLayout()` — 12 columns wide, as many rows as needed. There is **no stacking at all**; every tile is immediately visible and playable from the start.

These levels are about endurance and symbol variety rather than uncovering buried tiles. Tile counts range from 110 (55 pairs) in Level 15 to 194 (97 pairs) in Level 25.

---

## Complete Level-by-Level Layout Catalog

### Multi-Layer Pyramid Levels (1–14)

| Level | Name | Tile Count | Layers | Layout Shape (row tile counts per layer) | Visual Form |
|-------|------|-----------|--------|------------------------------------------|-------------|
| 1 | First Look | 28 | 2 | `[2,4,6,6,4] / [2,2] / [2]` | Small 3-layer diamond |
| 2 | New Roots | 30 | 3 | `[2,4,6,6,6,4] / [2,2,2] / [2]` | Wider 3-layer stepped pyramid |
| 3 | Council | 34 | 3 | `[2,4,6,8,8,4,2] / [2,4,2] / [2]` | Broad council diamond |
| 4 | Heritage | 36 | 3 | `[2,4,6,8,8,6,4] / [2,4,4] / [2,2]` | Elongated ancestor diamond |
| 5 | Legacy | 42 | 4 | `[2,4,6,8,8,8,4,2] / [4,4,4] / [2,2] / [2]` | Long turtle with centered spine |
| 6 | Complete Set | 46 | 4 | `[2,4,6,8,10,8,6,2] / [4,6,4] / [2,2,2] / [2]` | Shrine diamond with broad shoulders |
| 7 | New Symbols | 50 | 4 | `[2,4,6,8,8,8,8,4] / [4,6,4] / [2,2,2] / [2,2]` | Elder turtle with flat center |
| 8 | Gathering | 54 | 4 | `[2,4,6,8,10,10,6,4] / [4,4,4,4] / [2,2,2] / [2,2]` | Oracle pyramid |
| 9 | Deep Roots | 58 | 4 | `[2,4,6,8,10,10,8,4] / [4,4,4,4] / [2,4,2] / [2,2]` | Throne turtle with stacked crown |
| 10 | Living Archive | 64 | 4 | `[2,4,6,8,10,10,8,6] / [4,6,4,4] / [2,4,2] / [2,2]` | Tall genesis diamond |
| 11 | Ancestral Map | 70 | 5 | `[2,4,6,8,10,10,8,6,2] / [4,6,4,4] / [2,4,2] / [2,2] / [2]` | Cosmos tower (5 layers) |
| 12 | Many Voices | 74 | 5 | `[2,4,6,8,10,10,8,6,4] / [4,6,6,4] / [2,4,2] / [2,2] / [2]` | Triumph turtle with high crown |
| 13 | Long Memory | 78 | 5 | `[2,4,6,8,10,10,8,6,4,2] / [4,6,6,4] / [2,4,4] / [2,2] / [2]` | Final eternal pyramid |
| 14 | Full Archive | 86 | 4 | `[2,4,6,8,10,10,10,8,6,4,2] / [4,6,6,4] / [2,4,4] / [2]` | Wide full-archive diamond |

### Single-Layer Grid / "Archive" Levels (15–25)

All use a simple 12-column grid with single-layer flat arrangement. No stacking — every pair is immediately accessible.

| Level | Name | Tile Count | Pairs |
|-------|------|-----------|-------|
| 15 | Open Courtyard | 110 | 55 |
| 16 | Wisdom House | 118 | 59 |
| 17 | Golden Stool | 126 | 63 |
| 18 | Shared Path | 134 | 67 |
| 19 | Sacred Grove | 142 | 71 |
| 20 | Elders Assembly | 150 | 75 |
| 21 | Enduring Chain | 158 | 79 |
| 22 | Complete Heritage | 168 | 84 |
| 23 | Steadfast Spirits | 176 | 88 |
| 24 | Path of Renewal | 184 | 92 |
| 25 | Ancestral Treasury | 194 | 97 |

---

## How Levels Differ From Each Other

Levels vary across **five dimensions**, not just one:

### 1. Spatial Complexity (layers)
- Levels 1–4: 2 or 3 layers
- Levels 5–14: 3, 4, or 5 layers  
- Levels 15–25: single layer (no stacking)

More layers = deeper Mahjong stacking = more blocked tiles you must strategically uncover.

### 2. Tile Count
- Starts at 28 (Level 1), scales to 194 (Level 25)
- Multi-layer levels: 28–102 tiles
- Archive levels: 110–194 tiles

### 3. Symbol Variety
- Early levels use subsets of the 121-symbol catalog
- Levels 14, 22, and 25 use the full symbol set
- More symbols = harder pattern recognition (less repetition)

### 4. Star Thresholds
- Level 1: 700 / 1100 / 1400 points for 1/2/3 stars
- Level 25: 7000 / 10300 / 12800 points
- Thresholds scale progressively based on tile count and complexity

### 5. Unlock Progression
Linear chain: Level N requires at least 1 star on Level N-1.

---

## Patterns: Are They Like Traditional Mahjong?

**Yes — the multi-layer levels (1–14) follow traditional Mahjong solitaire stacking patterns**, but with original naming rather than the classic Chinese names.

### What matches traditional Mahjong:
- **Centered pyramid/diamond shapes** — equivalent to traditional "Turtle" or "Pyramid" formations
- **Multi-layer stacking** with half-cell staggering — tiles on upper layers sit between the tiles below, same as traditional Mahjong
- **The "free tile" rule** — a tile is free only if it's not covered and has at least one open side (left or right) on its own layer. This is the standard Mahjong solitaire rule.

### What's different:
- **Ghanaian/Adinkra naming** — instead of "Dragon," "Turtle," "Cat," "Fortress," layouts have names like "Legacy," "Council," "Ancestral Map," "Living Archive"
- **No complex figurative shapes** — traditional Mahjong has layouts shaped like actual turtles, dragons, crabs, etc. Sankofa Tiles sticks to diamond/pyramid variants (simpler geometry)
- **The archive levels (15–25)** have no traditional equivalent — flat single-layer grids are unique to this game, designed for endurance play with full symbol sets
- **Symbol randomization** — in traditional Mahjong, specific tiles are always in specific positions. Sankofa randomizes symbol placement (within solvability constraints)

### Layout evolution across the game:

```
Levels 1-4:   Small pyramids, 2-3 layers (tutorial-like difficulty)
Levels 5-10:  Medium pyramids, 4 layers (core game experience)
Levels 11-14: Large pyramids, 4-5 layers (hardest stacking puzzles)
Levels 15-25: Flat grids, 1 layer (endurance — no stacking, maximum symbols)
```

---

## Unused Layouts (Available Building Blocks)

Seven layout variables are defined but not currently assigned to any level:

| Variable | Shape |
|----------|-------|
| `level1Layout` | `[2,4,4,2] / [2,2]` — compact diamond |
| `level2Layout` | `[2,4,4,4,2] / [2,2]` — small turtle base |
| `level3Layout` | `[2,4,6,4,2] / [2,2,2]` — beginner pyramid |
| `level6Layout` | `[2,4,6,6,6,4,2] / [2,4,2] / [2]` — turtle body with bridge |
| `level8Layout` | `[2,4,6,8,8,6,2] / [2,4,2] / [2,2]` — balanced heritage turtle |
| `level10Layout` | `[2,4,6,8,8,6,4,2] / [2,4,4] / [2,2] / [2]` — classic 4-tier Sankofa pyramid |
| `level12Layout` | `[2,4,6,8,8,8,6,2] / [4,4,4] / [2,2,2] / [2]` — tall covenant pyramid |

These are simpler/easier variants that could be used for future levels, tutorial modes, or rebalancing.

---

## Symbol Assignment: How Tiles Get Placed

At game start, tile symbols are assigned to layout positions using two strategies:

### Strategy A: Random Shuffle + Solvability Check (small boards, <40 tiles)
1. Pick `n` unique symbols (where `n = tileCount / 2`, so each appears exactly twice)
2. Shuffle randomly
3. Check solvability (up to 6,000 search nodes)
4. If unsolvable, re-shuffle (up to 12 attempts)
5. Falls back to Strategy B if all attempts fail

### Strategy B: Reverse-Solved (large boards, ≥40 tiles, or fallback)
1. Fill all layout positions with placeholder tiles
2. Simulate the game in **reverse**: greedily remove random free pairs, recording the order
3. Assign real symbols to the reverse of the removal order
4. Up to 100 attempts to get a clean removal

**Key insight:** The spatial layout is 100% fixed per level. Only the symbol-to-position mapping changes between sessions. Level 5 always looks like the same pyramid shape — but the specific Adinkra symbols at specific positions are different each time you play.

---

## The Current Level Progression

The data is defined in `lib/core/constants/level_data.dart`:

```
Level 1  → layout4  (First Look)       28 tiles, 2 layers
Level 2  → layout5  (New Roots)        30 tiles, 3 layers
Level 3  → layout7  (Council)          34 tiles, 3 layers
Level 4  → layout9  (Heritage)         36 tiles, 3 layers
Level 5  → layout11 (Legacy)           42 tiles, 4 layers
Level 6  → layout13 (Complete Set)     46 tiles, 4 layers
Level 7  → layout14 (New Symbols)      50 tiles, 4 layers
Level 8  → layout15 (Gathering)        54 tiles, 4 layers
Level 9  → layout16 (Deep Roots)       58 tiles, 4 layers
Level 10 → layout17 (Living Archive)   64 tiles, 4 layers
Level 11 → layout18 (Ancestral Map)    70 tiles, 5 layers
Level 12 → layout19 (Many Voices)      74 tiles, 5 layers
Level 13 → layout20 (Long Memory)      78 tiles, 5 layers
Level 14 → layout21 (Full Archive)     86 tiles, 4 layers
Level 15 → layout22 (Open Courtyard)   110 tiles, 1 layer (flat grid)
...continues to...
Level 25 → layout32 (Ancestral Treasury) 194 tiles, 1 layer (flat grid)
```

The progression is: start small → build up pyramid complexity (layers + width) → transition to flat endurance grids at level 15.

---

## Rendering: How Positions Become Pixels

The renderer in `board_widget.dart` translates `(row, col, layer)` to screen coordinates:

- `screenX = col × 0.5 − layer × 0.14`  
- `screenY = row × 0.664 − layer × 0.0664`

Higher layers shift tiles **up and right**, creating a top-down 3D pyramid perspective. The actual tile size is dynamically scaled to fit the screen (capped at 65px, minimum 24px).

---

## Summary

| Aspect | Finding |
|--------|---------|
| **Layout definition** | Procedurally generated from compact row-count specs (not giant data files) |
| **Pattern type** | Centered diamond/pyramid (classic Mahjong solitaire style) |
| **Pattern naming** | Ghanaian/Adinkra cultural names, not traditional Chinese names |
| **Shape variety** | All multi-layer levels are pyramid/diamond variants; no figurative shapes (turtle, dragon, etc.) |
| **Stacking** | Half-cell staggered rows with full Mahjong free-tile rules |
| **Distinct layouts** | 32 defined, 25 used, 7 unused |
| **Two families** | Multi-layer pyramids (levels 1–14) and single-layer grids (levels 15–25) |
| **Randomization** | Symbol-to-position mapping is randomized each session; spatial layout is fixed |
| **Solvability** | Guaranteed via reverse-solving or random shuffle with solvability check |
| **Progression** | Increasing layers, width, and tile count across levels |
