# Levels 201–240 bulky-portrait redesign

## Outcome

All 40 isolated candidates were rebuilt before production assignment. The
redesign keeps the existing level numbers, layout IDs, names, families, symbol
plans, difficulty bands, milestone roles, and developer-only boundary, while
replacing every former footprint with a fuller three-layer layout.

After the final Level 240 refinement and production gate, the approved source
catalogue is assigned exactly to production. Production now ends temporarily at
Level 240; the planned campaign and collection horizons remain Level 400.

## Old vs new envelope

| Measure | Previous candidates | Bulky redesign |
|---|---:|---:|
| Thin / medium / bulky | 15 / 14 / 11 | 0 / 8 / 32 |
| Mean width occupancy at 390×844 | 64.0% | 77.2% |
| Mean height occupancy at 390×844 | 74.5% | 77.2% |
| Mean internal empty area | 24.7% | 14.0% |
| Detected enclosed holes | 42 | 111 |

The width distribution is now 0 narrow, 8 medium, and 32 wide. The height
distribution is 3 compact, 4 balanced, and 33 tall. Internal empty area fell,
but the number of enclosed holes increased: the layouts gained body mass while
also gaining deliberate internal patterning instead of becoming solid slabs.
No candidate is classified as a solid rectangle.

## Visual roles

- Breathers: 201, 206, 212, 217, 223, 229, 234.
- Showcase boards: 205, 210, 215, 220, 225, 230, 235, 240.
- Chapter finales: 220 and 240. Both are bulky, tall, broad-shouldered boards
  with full lower bases and layered central mass.

## Validation

- 40/40 footprints changed; candidate identities and progression metadata were
  preserved.
- 3 layers, even tile counts, unique coordinates, immediate support, half-grid
  compatibility, and viewport fit pass for every candidate.
- 4,000/4,000 deterministic boards generated and solved (100 seeds per level).
- Standard levels retain at least three legal and three safe opening pairs;
  Levels 220 and 240 retain at least five of each.
- Adjacent coarse silhouette similarity peaks at 0.778, below the 0.780 gate.
- No exact candidate duplicates, obvious production clones, or solid-rectangle
  classifications remain.

## Review artifacts

Generated files are under
`artifacts/layout-previews/levels-201-240-candidates/`:

- `levels-201-240-candidate-report.md` — per-level old/new change matrix,
  coordinates, envelope metrics, opening quality, and seed results.
- `levels-201-240-bulky-portrait-overview.png` — clean rendered overview.
- `levels-201-240-bulky-silhouette-overview.png` — silhouette overview.
- `old-vs-new-bulk-silhouette-comparison.png` — paired legacy/current review.
- `bulk-fullness-distribution.png` — thin/medium/bulky distribution.
- `breather-boards.png` and `showcase-boards.png` — explicit role sheets.
- `finale-comparison-levels-200-220-240.png` — production and expansion finale
  comparison.
- Four ten-level contact sheets and chapter overviews.
