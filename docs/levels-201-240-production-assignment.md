# Levels 201–240 production assignment

Status: assigned, verified, and frozen at the current implemented-content
boundary. The planned campaign and collection horizons remain Level 400.

## Final Level 240 refinement

Only Level 240 changed after human review. Levels 201–239 retain their exact
approved candidate signatures and geometry.

|Measure|Reviewed candidate|Production final|
|---|---:|---:|
|Tiles|84|80|
|Layers|3|3|
|Width occupancy at 390×844|80.1%|80.1%|
|Height occupancy at 390×844|79.0%|79.0%|
|Effective tile width|64.0 px|64.0 px|
|Opening free tiles|24|17|
|Detected enclosed holes|5|3|

The production layout replaces the earlier dense mass with twin archive wings,
a large central ceremonial opening, two smaller upper openings, a tiered crown,
and a broad two-row foundation. Its coarse similarity to Level 220 is 0.762,
below the 0.780 distinctness gate. The exact frozen signature is `1142337356`.

Final Level 240 coordinates:

- Layer 0 (30): `(0,14) (0,16) (0,18) (2,12) (2,14) (2,16) (2,18) (2,20) (4,12) (4,16) (4,20) (6,12) (6,14) (6,16) (6,18) (6,20) (8,12) (8,20) (10,12) (10,20) (12,12) (12,14) (12,16) (12,18) (12,20) (14,12) (14,14) (14,16) (14,18) (14,20)`
- Layer 1 (30): `(1,14) (1,16) (1,18) (3,12) (3,14) (3,16) (3,18) (3,20) (5,12) (5,16) (5,20) (7,12) (7,14) (7,16) (7,18) (7,20) (9,12) (9,20) (11,12) (11,20) (13,12) (13,14) (13,16) (13,18) (13,20) (15,12) (15,14) (15,16) (15,18) (15,20)`
- Layer 2 (20): `(0,14) (0,16) (0,18) (2,12) (2,14) (2,16) (2,18) (2,20) (4,12) (4,16) (4,20) (6,12) (6,14) (6,16) (6,18) (6,20) (8,12) (8,20) (10,12) (10,20)`

## Production assignment and boundaries

- `kLevels` contains the contiguous IDs 1–240.
- `kImplementedCampaignLevelCount` and `kImplementedFinalLevelId` resolve to
  240 from the production registry.
- `kPlannedCampaignLevelCount` and `kCollectionScheduleFinalLevel` remain 400.
- `getLevelById(241)` returns `null`; Levels 241–400 have no production route.
- Production definitions 201–240 exactly match the frozen candidate IDs,
  names, coordinates, tile totals, symbol-plan totals, and chapter membership.
- Chapter 11, **The Journey Reopens**, contains Levels 201–220.
- Chapter 12, **Living Memory**, contains Levels 221–240.

The exact level-by-level production assignment matrix is generated at
`artifacts/layout-previews/levels-201-240-production/production-assignment-matrix.csv`
and repeated in the generated production report in that directory.

## Validation

- Levels 201–240: 4,000/4,000 deterministic generations and 4,000/4,000
  solver successes across 100 seeds per level.
- Every seed passed the legal and safe opening gates; zero seeds required a
  forced opening. Levels 220 and 240 retained at least five legal and five safe
  opening pairs.
- All boards passed structural validity, immediate support, half-grid,
  symbol-plan, production-clone, and portrait viewport gates.
- Levels 201–239 matched their pre-refinement stable signatures exactly.
- Final exact-assignment tests freeze all Levels 201–240.
- Full Flutter suite: 1,475 tests passed.
- `flutter analyze --no-pub`: no issues found.
- `git diff --check`: clean.

## Existing-player and collection behavior

A schema-v4 save that completed Level 200 resolves Level 201 as the next
unfinished playable level. Stable level IDs and storage keys preserve completed
levels, stars/scores, cowries, statistics, purchases, ad-removal entitlement,
settings, collection ownership, achievements, and claimed transactions. The
collection migration remains an additive union.

The active milestones in this range are 202 Kyemfere, 207 Mako, 211 Mate
Masie, 216 Mekyea Wo, 220 Menso Wo Kenten, 225 Mframadan, 230 Mmeramubere,
234 Mmeramutene, and 239 Mmere Dane. Existing ownership is idempotent and does
not create repeated unlocks. The release continues to use the existing 97 tile
faces; no new face was added.

Verified transitions are 199→200, 200→201, 219→220, 220→221, and 239→240.
After Level 240 the UI shows **Current Journey Complete** and offers no Level
241 navigation. The permanent 400-level campaign achievement remains tied to
the planned horizon.

## Production visual evidence

All images below use the real production `LevelDefinition`,
`GameNotifier.startLevel()`, `BoardWidget`, `TileWidget`, Adinkra assets,
shadows, background, and production scaling/centering.

- `levels-201-210-contact-sheet.png`
- `levels-211-220-contact-sheet.png`
- `levels-221-230-contact-sheet.png`
- `levels-231-240-contact-sheet.png`
- `chapter-11-production-overview.png`
- `chapter-12-production-overview.png`
- `levels-201-240-production-overview.png`
- `levels-201-240-production-silhouette-overview.png`
- `level-200-to-201-transition-evidence.png`
- `level-220-to-221-transition-evidence.png`
- `level-240_current-boundary.png`
- `level-240-old-vs-new-comparison.png`
- `level-220-vs-240-finale-comparison.png`
- `production-finale-comparison-levels-200-220-240.png`

No Level 241–280 design work was performed, no tile faces were added, and no
commit or push was made.
