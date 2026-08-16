# Levels 241–280 production assignment

Status: approved, assigned, and frozen.

The reviewed Levels 241–280 catalogue is assigned one-to-one into the
production registry. IDs, display names, layout IDs, coordinates, tile totals,
symbol plans, difficulty labels, and silhouettes are unchanged from approval.
Levels 1–240 are untouched by this assignment.

## Final placement and boundaries

- Chapter 13, **Rivers of Counsel**, owns Levels 241–260.
- Chapter 14, **Forest of Ancestors**, owns Levels 261–280.
- `implementedProductionLevelCount` is 280.
- `plannedCampaignLevelCount` remains 400.
- Level 280 enters **Current Journey Complete** and returns home.
- Level 281 has no production definition or navigation route;
  `getLevelById(281)` returns `null`.
- Levels 281–400 retain roadmap status and remain unavailable.

## Compatibility and collection

Progress storage remains additive. A save completed through Level 240 resolves
Level 241 as its next unfinished level without rewriting progress, stars,
scores, cowries, boosters, purchases, achievements, settings, collection
ownership, or monetization entitlements. Existing collection schedule entries
within Levels 241–280 become reachable; no tile faces were added and previously
owned faces are never cleared.

## Freeze and validation

The production regression suite freezes all 40 approved signatures and checks
exact assignment identity, contiguous transitions, chapter membership,
geometry, tile and symbol totals, viewport fit, silhouette diversity, and 100
deterministic generated/solved seeds per level (4,000 boards total). Generated
production artifacts include the assignment matrix, full and silhouette
overviews, four ten-level contact sheets, and evidence for transitions 240→241,
260→261, and the Level-280 current boundary.
