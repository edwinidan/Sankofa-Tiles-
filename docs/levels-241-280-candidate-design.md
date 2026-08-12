# Levels 241–280 candidate design

Status: complete developer-only human-review package. Production remains
Levels 1–240 and `getLevelById(241)` remains `null`.

## Roadmap interpretation

Chapter 13, **Rivers of Counsel**, uses forked routes, deltas, stepping stones,
canoe bridges, river gates, council chambers, and controlled asymmetry.
Negative space reads as channels, crossings, and confluences. Level 260 is the
River Council confluence finale.

Chapter 14, **Forest of Ancestors**, uses canopies, roots, clearings, groves,
guardian animals, sacred vessels, masks, and rooted fortresses. Negative space
reads as clearings, trunk chambers, and branch windows. Level 280 is the Great
Ancestral Tree sanctuary finale.

The ten Stage-A anchors are 241, 245, 250, 255, 260, 261, 265, 270, 275, and
280. The remaining thirty candidates were authored only after the anchors
passed structure, viewport, envelope, fullness, and similarity checks.

## Final visual distribution

- Authored fullness: 0 thin, 9 open-medium, 14 full, and 17 bulky.
- Analysis classification: 0 thin, 8 medium, and 32 bulky.
- Width occupancy: 8 below 70%, 15 at approximately 70–76%, and 17 at
  approximately 76–82%.
- Height occupancy: 7 at 65–72%, 20 at 72–77%, and 13 at 77–80%.
- No exact width/height envelope is used more than six times.
- Effective tile size at 390×844 is 64×85 px for every candidate.
- Mean internal empty area is 15.3%; the batch contains 101 enclosed holes and
  8 detected large openings.
- Solid rectangles and ultra-thin boards: zero.

Breathers are 241, 246, 252, 257, 263, 269, and 275. Showcases are 245, 250,
255, 260, 265, 270, 275, and 280.

Level 241 is a 48-tile welcoming delta gate with a major readable route
opening. Across 100 deterministic seeds it starts with 4–5 legal and safe
pairs.

Level 260 is an 80-tile controlled-asymmetric River Council confluence with
three-stream hierarchy, multiple channel breaks, and a broad foundation. It
starts with at least five legal and safe pairs.

Level 280 is an 80-tile single-apex ancestral tree sanctuary with a broad
canopy, paired branch windows, a large central sanctuary, guardian roots, and a
five-wide foundation. It was visually rebuilt after the initial finale sheet
showed excessive resemblance to Level 260. The final 260/280 coarse similarity
is below the 0.750 offset gate and the two silhouettes are plainly distinct.

## Technical result

- 4,000/4,000 deterministic generations.
- 4,000/4,000 deterministic solutions.
- Legal and safe opening range: 3–11 pairs.
- Zero forced-opening seeds.
- Maximum reverse-removal attempts: 16 of the 250-attempt bound.
- All candidates have exactly three layers, even tile totals, unique half-grid
  coordinates, immediate lower-layer support, valid symbol plans, and safe
  projected bounds.
- Compact 360×640, standard 390×844, and tall 430×932 previews fit without
  clipping. Alternate-size previews exist for every candidate.
- Maximum adjacent coarse similarity is 0.771; maximum 20-level-offset
  similarity is 0.749.
- Maximum exact silhouette score against production Levels 1–240 is 0.763,
  below the 0.900 near-clone gate.

The existing collection schedule would place milestones at Levels 243, 248,
253, 257, 262, 266, 271, 276, and 280. These remain inactive because the
levels are not production content. No tile face, migration, entitlement,
monetisation, solver, projection, or saved-progress logic changed.

Final repository verification:

- Full Flutter suite: 1,564 tests passed in 6:12.
- `flutter analyze --no-pub`: no issues found.
- `git diff --check`: clean.
- Implemented production boundary: 240.
- Planned campaign and collection horizons: 400.
- Levels 241–280: developer-only; Levels 281–400: unavailable.

## Review artifacts

The detailed matrix, symbol plans, seed ranges, metrics, warnings/resolutions,
and every coordinate grouped by layer are in
`artifacts/layout-previews/levels-241-280-candidates/levels-241-280-candidate-report.md`.
The same directory contains per-level clean, diagnostic, silhouette, 360×640,
and 430×932 renders plus all contact sheets, chapter overviews, distributions,
cross-batch comparisons, boundary comparison, and finale comparison.
