# Batch B Portrait-Optimization Review

This review applies the revised portrait-mobile direction to the isolated, still-unapproved Batch B candidates. No layout coordinates or production assignments were changed.

## Measurement basis

Measurements use the production `BoardLayoutGeometry` projection and fitting constants at the 390×844 preview size. The effective board area is approximately 374×804 px before the geometry safety inset. Projected width and height are expressed in tile-width units. Effective tile size is the fitted tile width.

The new target is 60–80% gameplay-height occupancy, 45–65% width occupancy, and preferably 52–64 px tiles on the standard portrait preview. A compact-device hard floor of 44 px remains appropriate.

## Candidate review

| Level | Candidate | Projected W × H | Effective tile | Width / height occupancy | Portrait-friendly? | Horizontally stretched? | Redesign? | Suggested replacement silhouette |
|---:|---|---:|---:|---:|---|---|---|---|
| 6 | `batchBOpenCourtyard01` | 6.100 × 5.844 | 58.7 px | 95.7% / 42.7% | No; square and low | Moderately | Yes | Tall courtyard with a narrow central void, stacked lintel, and 3 vertical tiers |
| 7 | `batchBRiverPath01` | 6.950 × 5.844 | 51.5 px | 95.7% / 37.4% | No | Yes | Yes | Vertical river path with alternating left/right bends and a narrow shrine cap |
| 8 | `batchBTempleGate01` | 7.235 × 5.844 | 49.5 px | 95.7% / 36.0% | No | Yes | Yes | Stacked gate or pagoda: narrow base, two rising lintels, small crown |
| 9 | `batchBGatheringWings01` | 10.350 × 5.844 | 34.6 px | 95.7% / 25.1% | No | Strongly | Yes | Vertical wings folded around a tall central body; preserve as one expressive family |
| 10 | `batchBTwinBridge01` | 8.650 × 5.844 | 41.4 px | 95.7% / 30.1% | No | Strongly | Yes | Compact twin bridge with crossings stacked at two heights instead of side-by-side |
| 11 | `batchBSmallTurtle01` | 8.650 × 5.844 | 41.4 px | 95.7% / 30.1% | No | Strongly | Yes | Upright turtle with tall oval shell, small head/tail, and layered shell ridge |
| 12 | `batchBButterfly01` | 10.350 × 5.844 | 34.6 px | 95.7% / 25.1% | No | Strongly | Yes | Vertical butterfly with compact folded wings and a long central body |
| 13 | `batchBShrineSteps01` | 8.650 × 5.844 | 41.4 px | 95.7% / 30.1% | No | Strongly | Yes | Tall temple steps rising through 5–6 narrower rows to a layered shrine crown |
| 14 | `batchBWisdomStaircase01` | 7.800 × 5.844 | 45.9 px | 95.7% / 33.4% | Closest, but still too low | Yes | Yes | Taller zig-zag staircase or hourglass staircase using 8–10 vertical rows |
| 15 | `batchBCrown01` | 8.935 × 5.844 | 40.1 px | 95.7% / 29.1% | No | Strongly | Yes | Tall crown/mask hybrid with narrow shoulders and three vertically staggered points |
| 16 | `batchBOpenRing01` | 10.350 × 5.844 | 34.6 px | 95.7% / 25.1% | No | Strongly | Yes | Hourglass shrine or tall open mask; keep a central void without a broad ring |
| 17 | `batchBRoyalStool01` | 8.650 × 5.844 | 41.4 px | 95.7% / 30.1% | No | Strongly | Yes | Stacked royal stool: compact seat, narrow carved support, stable vertical base |
| 18 | `batchBAncestralGate01` | 8.650 × 5.844 | 41.4 px | 95.7% / 30.1% | No | Strongly | Yes | Tall ancestral gate with twin pillars, two lintels, and a small upper shrine |
| 19 | `batchBTwinTowers01` | 8.650 × 5.844 | 41.4 px | 95.7% / 30.1% | No | Strongly | Yes | Close-set paired towers joined vertically by staggered bridges; avoid distant islands |
| 20 | `batchBRaisedCourtyard01` | 10.350 × 5.844 | 34.6 px | 95.7% / 25.1% | No | Strongly | Yes | Chapter-showcase pagoda or monumental tall courtyard with a vertical inner opening |

## Batch B recommendation

All fifteen candidates should be reworked before production approval. Their silhouettes are handcrafted and technically sound, but they share essentially the same short projected height and consume nearly the full available width. That common geometry explains the excessive empty space above and below.

Levels 9 and 10 may remain the deliberate wider minority for Chapter 1, preserving wings and bridge variety, but they still need narrower, taller geometry and larger tiles. Level 12 should become a vertical butterfly rather than serving as a second very-wide wing board. Levels 6, 8, 13, 14, 16, 18, and 20 are the strongest opportunities to establish the new portrait language.

## Revised visual policy for future batches

### 1. Chapter-level distribution

For each 20-level chapter:

- 14–16 layouts should be portrait-leaning (70–80%).
- 2–4 may be neutral or moderately wide.
- At most 2 should be deliberately broad showcase layouts.
- Avoid adjacent broad layouts.
- Include at least two tall breather layouts; low difficulty does not require a flat board.

Track this distribution in roadmap metadata rather than relying on visual memory.

### 2. Geometry and occupancy gates

Measure every candidate after the real layer projection and responsive fit:

- Portrait target: 60–80% gameplay height and 45–65% gameplay width.
- Neutral allowance: 50–70% height and up to 75% width.
- Deliberately wide exception: at least 45% height and normally no more than 85% width.
- Anything above 90% width or below 45% height requires explicit visual justification and approval.
- Standard-preview target tile width: 52–64 px.
- Compact-device hard floor: 44 px.
- Prefer projected height/width ratios around 1.2–1.8 for portrait layouts.

Occupancy should be measured against the actual `BoardWidget` constraints at 360×640, 390×844, and 430×932, not the full physical screen.

### 3. Vertical construction language

- Use more distinct row elevations, typically extending through roughly 8–12 visual tile steps where support permits.
- Narrow the base before adding tiles; do not achieve difficulty by extending long horizontal rows.
- Stack bridges, lintels, crowns, and openings vertically.
- Use upper layers to reinforce height, not merely add a flat central cap.
- Alternate narrow and wider tiers to produce shrine, pagoda, mask, hourglass, stool, and tower silhouettes.
- Preserve negative space as vertical doors, windows, channels, and waist openings.
- Keep projected layer centres aligned; intentional asymmetry must not make the rendered stack lean.

### 4. Preferred and restricted families

Default families: shrine, stacked/temple gate, layered diamond, staircase, turtle, stool, crown, tower, pagoda, pillar, mask, hourglass, tall courtyard, vertical butterfly, and temple steps.

Restricted families: wide wings, long bridges, broad rings, long horizontal rivers, and separated twin islands/towers. A restricted family should occupy one of the chapter's explicit wide slots and must still pass tile-size and minimum-height gates.

### 5. Quality score and approval order

Evaluate in this order:

1. Effective tile size and compact-device readability.
2. Width and height occupancy on all required viewports.
3. Overall portrait balance and projected centre.
4. Recognisable silhouette and meaningful negative space.
5. Layer readability and immediate-lower support.
6. Opening quality across deterministic seeds.
7. Guaranteed solvability and generation performance.

A technically valid or attractive silhouette is not production-ready if it shrinks tiles or leaves most portrait height unused.

### 6. Roadmap metadata

Add planning fields for projected width, projected height, fitted tile size per required viewport, width occupancy, height occupancy, aspect classification (`portrait`, `neutral`, `wide`), and wide-slot justification. Chapter validators should enforce the intended 70–80% portrait mix before production assignment.

## Next design pass

Rework Batch B from silhouettes and family intent—not by stretching the current coordinates vertically. Start with Levels 6, 8, 13, 14, 16, 18, and 20 to establish the portrait grammar, then rebuild the remaining candidates around those proportions. Keep Levels 9 and 10 as the likely wide-variation slots. Repeat structural, centre, 100-seed, and real-widget preview validation after geometry changes.
