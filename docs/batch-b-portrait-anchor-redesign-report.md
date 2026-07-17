# Batch B Portrait Anchor Redesign Report

Status: isolated Phase 1 redesign only. The seven anchor candidates were re-authored through coordinates; no production level assignment, global geometry, fitting, solver, gameplay, persistence, collection, migration, reward, or monetisation code changed.

## 1. Portrait grammar outcome

The redesign is a genuine proportional change rather than a vertical stretch. Old candidates used only 5.844 projected height units and nearly all available width. The anchors now use 9.230 height units with 4.400 width units (4.825 for the intentionally diagonal staircase), retain 63–64 px tiles, and present distinct tall courtyard, gate, pagoda, staircase, sanctuary, ceremonial gate, and finale-court silhouettes.

At 390×844, six anchors use 75.3% width and all use 73.5% height. Level 14 uses 82.6% width because its switchback requires an intentional horizontal offset; it remains portrait-shaped, uses 64 px tiles, and fits without clipping. On 360×640 the silhouettes use most of the board area but retain the safety inset and pass real-widget rendering.

## 2. Old-versus-new measurements

| Level | Projected width old → new | Projected height old → new | Width occupancy old → new | Height occupancy old → new | Tile width old → new | Old silhouette | New silhouette | Better portrait use? |
|---:|---:|---:|---:|---:|---:|---|---|---|
| 6 | 6.1 → 4.400 | 5.844 → 9.230 | 95.7% → 75.3% | 42.7% → 73.5% | 58.7 → 64.0 px | Low, nearly square courtyard | Tall open temple court with long central void and raised lintels | Yes |
| 8 | 7.235 → 4.400 | 5.844 → 9.230 | 95.7% → 75.3% | 36.0% → 73.5% | 49.5 → 64.0 px | Broad gate with side-spread | Twin-pillar temple gate with doorway, beams, and layered steps | Yes |
| 13 | 8.65 → 4.400 | 5.844 → 9.230 | 95.7% → 75.3% | 30.1% → 73.5% | 41.4 → 64.0 px | Wide stepped block | Vertical pagoda with successively rising tiers and shrine cap | Yes |
| 14 | 7.8 → 4.825 | 5.844 → 9.230 | 95.7% → 82.6% | 33.4% → 73.5% | 45.9 → 64.0 px | Short diagonal staircase | Deliberate switchback staircase with a narrow rising axis | Yes |
| 16 | 10.35 → 4.400 | 5.844 → 9.230 | 95.7% → 75.3% | 25.1% → 73.5% | 34.6 → 64.0 px | Broad horizontal ring | Tall sanctuary arch with canopy, roots, and central grove opening | Yes |
| 18 | 8.65 → 4.400 | 5.844 → 9.230 | 95.7% → 75.3% | 30.1% → 73.5% | 41.4 → 64.0 px | Wide ancestral gate | Grand multi-tier ceremonial gate with deeper layered crown | Yes |
| 20 | 10.35 → 4.400 | 5.844 → 9.230 | 95.7% → 75.3% | 25.1% → 73.5% | 34.6 → 64.0 px | Large horizontal courtyard/ring | Monumental royal court with vertical opening and four visible tiers | Yes |

All seven have height greater than width. Standard height occupancy improved by 30.8–48.4 percentage points, while effective tiles increased to the preferred 64 px maximum.

## 3. Tile size and occupancy at all preview sizes

Values show effective tile width / height followed by board occupancy. Available areas match the actual preview `BoardWidget` constraints after its surrounding inset.

| Level | 360×640 | 390×844 | 430×932 |
|---:|---|---|---|
| 6 | 63.3 / 84.1 px; 80.9% W, 97.3% H | 64.0 / 85.0 px; 75.3% W, 73.5% H | 64.0 / 85.0 px; 68.0% W, 66.2% H |
| 8 | 63.3 / 84.1 px; 80.9% W, 97.3% H | 64.0 / 85.0 px; 75.3% W, 73.5% H | 64.0 / 85.0 px; 68.0% W, 66.2% H |
| 13 | 63.3 / 84.1 px; 80.9% W, 97.3% H | 64.0 / 85.0 px; 75.3% W, 73.5% H | 64.0 / 85.0 px; 68.0% W, 66.2% H |
| 14 | 63.3 / 84.1 px; 88.7% W, 97.3% H | 64.0 / 85.0 px; 82.6% W, 73.5% H | 64.0 / 85.0 px; 74.6% W, 66.2% H |
| 16 | 63.3 / 84.1 px; 80.9% W, 97.3% H | 64.0 / 85.0 px; 75.3% W, 73.5% H | 64.0 / 85.0 px; 68.0% W, 66.2% H |
| 18 | 63.3 / 84.1 px; 80.9% W, 97.3% H | 64.0 / 85.0 px; 75.3% W, 73.5% H | 64.0 / 85.0 px; 68.0% W, 66.2% H |
| 20 | 63.3 / 84.1 px; 80.9% W, 97.3% H | 64.0 / 85.0 px; 75.3% W, 73.5% H | 64.0 / 85.0 px; 68.0% W, 66.2% H |

No viewport clips. The compact render uses approximately 97.3% of the allocated board height, but retains 63.3 px tiles and the geometry safety inset. The tall render does not inflate beyond the 64 px preferred cap.

## 4. Projected centres

Centres are production-projected `(x,y)` tile units. The final column is maximum horizontal layer-to-full-centre difference at the standard fitted tile size.

| Level | Layer 0 centre | Layer 1 centre | Layer 2 centre | Full centre | Maximum horizontal pixel difference | Visible lean |
|---:|---|---|---|---|---:|---|
| 6 | 9.372,4.897 | 9.179,3.495 | 9.145,4.350 | 9.304,4.525 | 10.2 px | No |
| 8 | 9.674,4.674 | 9.710,3.354 | 9.570,4.463 | 9.672,4.306 | 6.5 px | No |
| 13 | 9.425,5.180 | 9.285,3.999 | 9.145,3.785 | 9.358,4.719 | 13.6 px | No |
| 14 | 9.567,5.443 | 9.285,3.918 | 9.570,3.785 | 9.497,4.855 | 13.5 px | No |
| 16 | 9.850,4.615 | 9.528,3.918 | 9.570,4.914 | 9.731,4.462 | 13.0 px | No |
| 18 | 9.850,4.678 | 9.568,3.730 | 9.570,3.785 | 9.738,4.304 | 10.8 px | No |
| 20 | 9.850,4.648 | 9.710,3.805 | 9.570,4.632 | 9.769,4.374 | 12.7 px | No |

Layer coordinates were adjusted individually after the first render pass. All final stacks are below the 14 px drift threshold and show no visible lean; no global projection constant changed.

## 5. Complete coordinates

Coordinates are integer `(row,col,layer)` values. Odd rows/columns retain half-grid placement and all upper tiles have immediate-lower-layer support.

### Level 6 — `batchBOpenCourtyard01`

- Layer 0: (0,18,0) (0,20,0) (0,22,0) (0,24,0) (2,18,0) (2,20,0) (2,22,0) (4,18,0) (4,24,0) (6,18,0) (6,24,0) (8,18,0) (8,24,0) (10,18,0) (10,24,0) (12,18,0) (12,20,0) (12,22,0) (12,24,0) (14,17,0) (14,19,0) (14,21,0) (14,23,0) (14,25,0)
- Layer 1: (1,19,1) (1,21,1) (1,23,1) (3,19,1) (3,21,1) (11,19,1) (11,21,1) (11,23,1)
- Layer 2: (2,20,2) (2,22,2) (12,20,2) (12,22,2)

### Level 8 — `batchBTempleGate01`

- Layer 0: (0,19,0) (0,21,0) (0,23,0) (0,25,0) (2,18,0) (2,20,0) (2,22,0) (2,24,0) (2,26,0) (4,18,0) (4,20,0) (4,24,0) (6,18,0) (6,20,0) (6,24,0) (8,18,0) (8,24,0) (10,18,0) (10,24,0) (12,18,0) (12,20,0) (12,22,0) (12,24,0) (12,26,0) (14,18,0) (14,20,0) (14,22,0) (14,24,0) (14,26,0)
- Layer 1: (1,19,1) (1,21,1) (1,23,1) (1,25,1) (3,19,1) (3,21,1) (3,23,1) (3,25,1) (11,19,1) (11,21,1) (11,23,1) (11,25,1)
- Layer 2: (2,21,2) (2,23,2) (10,21,2) (10,23,2) (12,22,2)

### Level 13 — `batchBShrineSteps01`

- Layer 0: (0,20,0) (0,22,0) (2,19,0) (2,21,0) (2,23,0) (4,18,0) (4,20,0) (4,22,0) (4,24,0) (6,17,0) (6,19,0) (6,21,0) (6,23,0) (6,25,0) (8,17,0) (8,19,0) (8,21,0) (8,23,0) (8,25,0) (10,17,0) (10,19,0) (10,21,0) (10,23,0) (10,25,0) (12,17,0) (12,19,0) (12,21,0) (12,23,0) (12,25,0) (14,17,0) (14,19,0) (14,21,0) (14,23,0) (14,25,0)
- Layer 1: (1,20,1) (1,22,1) (3,19,1) (3,21,1) (3,23,1) (5,19,1) (5,21,1) (5,23,1) (9,19,1) (9,21,1) (9,23,1) (11,19,1) (11,21,1) (11,23,1)
- Layer 2: (2,20,2) (2,22,2) (6,20,2) (6,22,2) (10,20,2) (10,22,2)

### Level 14 — `batchBWisdomStaircase01`

- Layer 0: (0,20,0) (0,22,0) (2,20,0) (2,22,0) (4,19,0) (4,21,0) (4,23,0) (6,19,0) (6,21,0) (6,23,0) (8,18,0) (8,20,0) (8,22,0) (8,24,0) (8,26,0) (10,18,0) (10,20,0) (10,22,0) (10,24,0) (10,26,0) (12,17,0) (12,19,0) (12,21,0) (12,23,0) (12,25,0) (14,17,0) (14,19,0) (14,21,0) (14,23,0) (14,25,0)
- Layer 1: (1,21,1) (1,23,1) (3,21,1) (3,23,1) (5,20,1) (5,22,1) (7,20,1) (7,22,1) (9,19,1) (9,21,1) (11,19,1) (11,21,1)
- Layer 2: (2,22,2) (2,24,2) (6,21,2) (6,23,2) (10,20,2) (10,22,2)

### Level 16 — `batchBOpenRing01`

- Layer 0: (0,18,0) (0,20,0) (0,22,0) (0,24,0) (0,26,0) (2,18,0) (2,20,0) (2,22,0) (2,24,0) (2,26,0) (4,18,0) (4,20,0) (4,24,0) (4,26,0) (6,18,0) (6,26,0) (8,18,0) (8,26,0) (10,18,0) (10,20,0) (10,24,0) (10,26,0) (12,18,0) (12,20,0) (12,22,0) (12,24,0) (12,26,0) (14,18,0) (14,20,0) (14,22,0) (14,24,0) (14,26,0)
- Layer 1: (1,19,1) (1,21,1) (1,23,1) (1,25,1) (3,19,1) (3,21,1) (3,23,1) (9,19,1) (9,21,1) (9,23,1) (11,19,1) (11,21,1) (11,23,1) (11,25,1)
- Layer 2: (2,21,2) (2,23,2) (10,21,2) (10,23,2) (12,21,2) (12,23,2)

### Level 18 — `batchBAncestralGate01`

- Layer 0: (0,19,0) (0,21,0) (0,23,0) (0,25,0) (2,18,0) (2,20,0) (2,22,0) (2,24,0) (2,26,0) (4,18,0) (4,20,0) (4,22,0) (4,24,0) (4,26,0) (6,18,0) (6,20,0) (6,24,0) (6,26,0) (8,18,0) (8,20,0) (8,24,0) (8,26,0) (10,18,0) (10,20,0) (10,24,0) (10,26,0) (12,18,0) (12,20,0) (12,22,0) (12,24,0) (12,26,0) (14,18,0) (14,20,0) (14,22,0) (14,24,0) (14,26,0)
- Layer 1: (1,19,1) (1,21,1) (1,23,1) (1,25,1) (3,19,1) (3,21,1) (3,23,1) (3,25,1) (5,19,1) (5,21,1) (5,23,1) (9,19,1) (9,21,1) (9,23,1) (11,19,1) (11,21,1) (11,23,1) (11,25,1)
- Layer 2: (2,21,2) (2,23,2) (6,21,2) (6,23,2) (10,21,2) (10,23,2)

### Level 20 — `batchBRaisedCourtyard01`

- Layer 0: (0,19,0) (0,21,0) (0,23,0) (0,25,0) (2,18,0) (2,20,0) (2,22,0) (2,24,0) (2,26,0) (4,18,0) (4,20,0) (4,22,0) (4,24,0) (4,26,0) (6,18,0) (6,20,0) (6,24,0) (6,26,0) (8,18,0) (8,26,0) (10,18,0) (10,20,0) (10,24,0) (10,26,0) (12,18,0) (12,20,0) (12,22,0) (12,24,0) (12,26,0) (14,18,0) (14,20,0) (14,22,0) (14,24,0) (14,26,0)
- Layer 1: (1,19,1) (1,21,1) (1,23,1) (1,25,1) (3,19,1) (3,21,1) (3,23,1) (3,25,1) (5,19,1) (5,21,1) (5,23,1) (5,25,1) (9,19,1) (9,21,1) (9,23,1) (9,25,1) (11,19,1) (11,21,1) (11,23,1) (11,25,1)
- Layer 2: (2,21,2) (2,23,2) (6,21,2) (6,23,2) (10,21,2) (10,23,2) (12,21,2) (12,23,2)

## 6. 100-seed opening and solvability results

| Level | Generated | Solvable | Starting free tiles | Legal min–max / mean | Safe min–max / mean | Forced seeds | Max attempts | Max generation time |
|---:|---:|---:|---:|---|---|---:|---:|---:|
| 6 | 100/100 | 100/100 | 11 | 5–15 / 9.55 | 4–15 / 9.26 | 0 | 2 | 7.06 ms |
| 8 | 100/100 | 100/100 | 18 | 12–21 / 17.03 | 12–21 / 16.76 | 0 | 3 | 1.79 ms |
| 13 | 100/100 | 100/100 | 16 | 9–19 / 13.51 | 8–19 / 13.11 | 0 | 3 | 2.71 ms |
| 14 | 100/100 | 100/100 | 12 | 5–13 / 9.48 | 4–13 / 9.18 | 0 | 2 | 1.18 ms |
| 16 | 100/100 | 100/100 | 18 | 10–21 / 15.25 | 9–21 / 14.85 | 0 | 3 | 2.58 ms |
| 18 | 100/100 | 100/100 | 18 | 10–20 / 15.08 | 10–20 / 14.68 | 0 | 3 | 3.45 ms |
| 20 | 100/100 | 100/100 | 20 | 12–21 / 16.99 | 10–21 / 16.63 | 0 | 3 | 3.82 ms |

All 700 boards generated and solved. Every anchor exceeds the required minimum three safe pairs, has zero forced-opening seeds, and needs at most three reverse-removal attempts.

## 7. Structural and visual validation

All seven pass even counts, unique coordinates, contiguous three-layer sequences, immediate-lower support, no floating tiles, no same-layer overlaps, viewport bounds, position preservation, intended symbol-plan compatibility, and guaranteed solvability. They render through real `BoardWidget` and `TileWidget` with production artwork, background, shadows, projection, fit, and centring.

The silhouettes remain distinct:

- Level 6: open vertical court with the largest continuous doorway.
- Level 8: smaller formal gate with visible pillars and lintels.
- Level 13: solid tiered pagoda/temple progression.
- Level 14: asymmetric switchback staircase.
- Level 16: tall sacred arch with canopy and roots.
- Level 18: denser grand gate with layered ceremonial crown.
- Level 20: most substantial court, with four upper tiers and finale density.

## 8. Preview paths

Each layout has:

- `artifacts/layout-previews/batch-b-portrait-pass/<layoutId>_360x640.png`
- `artifacts/layout-previews/batch-b-portrait-pass/<layoutId>_390x844.png`
- `artifacts/layout-previews/batch-b-portrait-pass/<layoutId>_430x932.png`
- `artifacts/layout-previews/batch-b-portrait-pass/<layoutId>_diagnostic.png`

Contact sheets:

- Clean: `artifacts/layout-previews/batch-b-portrait-pass/portrait-anchor-contact-sheet.png`
- Diagnostic: `artifacts/layout-previews/batch-b-portrait-pass/portrait-anchor-diagnostic-contact-sheet.png`

## 9. Files changed in Phase 1

- Re-authored only seven entries in `lib/core/constants/batch_b_layout_data.dart`; the other eight candidates remain unchanged.
- Added portrait occupancy tests and portrait preview outputs through existing Batch B test files.
- Added `tool/generate_batch_b_portrait_contact_sheets.swift`.
- Generated the portrait-pass PNGs/contact sheets and this report.

## 10. Regression verification

Tests explicitly preserve approved Levels 1–5, snapshot production Levels 6–20, reject any `batchB` production assignment through Level 200, preserve 97-face schedule coverage, and exercise migration/collection behavior.

- Full `flutter test`: **318 tests passed** in approximately 2 minutes 56 seconds.
- Portrait anchor seed matrix: **700/700 generated and solvable**.
- Real portrait-anchor previews: **28/28 passed**.
- All 200 implemented production boards: generated successfully in the campaign startup suite.
- `flutter analyze`: **No issues found** (2.9 seconds).
- `git diff --check`: **passed with no whitespace errors**.
- No Levels 201–400, future player-facing chapters, production Batch B references, collection changes, migration changes, geometry changes, solver changes, or gameplay-rule changes were introduced.

## 11. Recommendation

The portrait grammar is ready to guide the remaining eight candidates, subject to visual approval of this anchor sheet. Use Level 6 for open vertical negative space, Levels 8/18 for small-versus-grand gate scaling, Level 13 for solid tiering, Level 14 for controlled asymmetry, Level 16 for sanctuary openings, and Level 20 for finale density. The remaining pass should not copy one outline; it should reuse these proportional rules while keeping Levels 9 and 10 as the intentional moderately wider slots.
