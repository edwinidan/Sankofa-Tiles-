# Adinkra Tiles — Campaign Layout Research

## Current System

Adinkra Tiles now uses named Mahjong-solitaire layout archetypes, derived layout statistics, configured symbol-copy distributions, and a 50-level campaign split into five chapters.

The layout positions remain `(row, col, layer)` triples so the renderer, free-tile rule, and solvability checker keep the same core model. The important change is that level metadata no longer repeats facts that can be derived from the layout.

## Single Source Of Truth

For every level:

- Tile count is `layout.length`.
- Pair count is `tileCount ~/ 2`.
- Layer count, bounds, board width, board height, max layer, and starting free tile count come from `LayoutStats`.
- Star thresholds are computed from actual layout complexity and symbol pool size.
- Symbol variety is configured separately from tile count.

This prevents the old mismatch where documented tile counts and layer counts drifted away from generated board geometry.

## Layout Architecture

Layouts are defined in `lib/core/constants/layout_data.dart`.

The new builder system supports:

- centered pyramid rows
- explicit coordinates
- rectangles and courtyards
- split islands
- bridges
- wings
- towers
- translated upper platforms
- composed multi-part layouts

There are 35 named layout archetypes in `kLayoutLibrary`, including compact diamonds, bridges, turtles, courtyards, wings, split islands, fortresses, crowns, shrines, temple complexes, and archive finales.

## Campaign Progression

The campaign is now 200 levels:

- Chapter 1: First Symbols, levels 1-10
- Chapter 2: Paths of Wisdom, levels 11-20
- Chapter 3: Heritage, levels 21-30
- Chapter 4: Ancestral Trials, levels 31-40
- Chapter 5: Grand Archive, levels 41-50
- Chapters 6-20: Extended Chapters, levels 51-200

Late levels are no longer a run of flat 12-column grids. Most late boards use stacked layouts with raised centers, towers, crowns, courtyards, bridges, and strategic choke points. Flat or flatter boards are reserved as occasional change-of-pace layouts.

## Symbol Distribution

Symbol variety is handled by `SymbolCopyPlan` in `lib/core/constants/level_data.dart`.

Levels now build an even symbol multiset such as:

- `7x4` for 28 tiles
- `15x4 + 4x2` for 68 tiles
- `30x4` for 120 tiles

If a configured symbol pool is larger than the board can support, it is clamped to the actual pair capacity. This keeps every symbol count even and guarantees the symbol deck equals the layout tile count.

## Solvability

Board generation still uses two strategies:

- Small boards try randomized assignment plus a solver check.
- Larger boards use reverse-solved generation.

Reverse-solved generation now works from a full symbol deck, groups symbols into removable pairs, and supports symbols that appear 4, 6, or more times.

## Progress Preservation

Saved progress is keyed by stable numeric level IDs:

- `best_score_<levelId>`
- `stars_<levelId>`

Because levels 1-25 retain their IDs, existing progress is preserved. A campaign schema marker is stored during initialization, but no existing score or star keys are rewritten.

## Validation

Automated coverage now checks:

- all 200 levels exist with sequential IDs
- every layout has an even tile count
- no duplicate layout coordinates exist
- every symbol distribution sums to the layout tile count
- every symbol count is even
- all referenced symbols exist
- every layout has opening free-tile geometry
- late chapters are not accidentally flat
- every campaign level can be generated and solved
- progress migration preserves existing results

Run the campaign report with:

```bash
dart run tool/campaign_report.dart
```
