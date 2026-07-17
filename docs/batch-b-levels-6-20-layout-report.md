# Batch B: Isolated Layout Design and Preview Report (Levels 6–20)

Status: candidate design only, 2026-07-12. No candidate is referenced by `kLevels`; production assignments for Levels 1–200 remain unchanged. No level, solver, projection, collection schedule, migration, save key, monetisation, or reward implementation was changed.

## 1. Progression smoke test

Focused real-service/widget tests passed. A fresh profile receives exactly 10 starter faces. Level 1 grants zero faces rather than the legacy batch; Levels 2 and 3 grant zero; Level 4 grants exactly `nea_onnim`. Persistence leaves 11 unlocked and 86 locked. Reconstructing services and replaying Level 4 produces no duplicate unlock and no reveal queue.

The schema-v4 representative legacy profile retained an explicitly unlocked late face, every frozen v1 entitlement through its saved highest level, all new-schedule entitlements through union/backfill, 777 cowries, level completion, remove-ads entitlement, and purchase record. Repeating migration produced the identical set. Migration itself writes flags but does not return reward summaries, so it cannot queue dozens of reveal cards.

## 2. Frozen production verification and Levels 6–20 audit

Levels 1–5 still map to `earlyOpenDiamond01`, `earlyOpenDiamond02`, `earlyBridge01`, `earlyShrine01`, and `earlyLayeredDiamond01`. The candidate-isolation test snapshots every existing Level 6–20 layout ID and checks that no Level 6–200 production reference starts with `batchB`.

The opening ranges below use 20 deterministic reverse-solved audit seeds with each production level's real symbol plan. The roadmap's future 20-level chapter structure conflicts with today's production data: Levels 6–10 are currently Accra and 11–20 are Kumasi. This batch treats 1–20 as the proposed future Chapter 1 but does not change chapter data or reward boundaries.

| Level | Existing name | Current chapter | Production layout | Tiles / pairs | Symbols | Copies | Difficulty | Layers | Free | Legal range | Safe range | Name/silhouette | Milestones |
|---:|---|---|---|---:|---:|---|---|---:|---:|---|---|---|---|
| 6 | Open Courtyard | Accra | openCourtyard | 38 / 19 | 12 | 7x4 + 5x2 | Novice | 3 | 16 | 12–18 | 11–18 | courtyard: yes | no collection face; normal |
| 7 | River Lesson | Accra | riverPath | 44 / 22 | 12 | 10x4 + 2x2 | Novice | 3 | 20 | 17–22 | 17–22 | path: yes | no collection face; normal |
| 8 | Wisdom House | Accra | wisdomHouse | 36 / 18 | 13 | 5x4 + 8x2 | Novice | 3 | 20 | 18–24 | 16–24 | house suggests architecture; gate variant proposed | no collection face; normal |
| 9 | Gathering Wings | Accra | gatheringWings | 50 / 25 | 14 | 11x4 + 3x2 | Novice | 3 | 24 | 21–31 | 21–31 | wings: yes | collection: nkyinkyim; normal |
| 10 | Elder Bridge | Accra | elderBridge | 42 / 21 | 15 | 6x4 + 9x2 | Novice | 3 | 22 | 18–28 | 17–28 | bridge: yes | no collection face; 5-level+10-level |
| 11 | Heritage Turtle | Kumasi | heritageTurtle | 56 / 28 | 16 | 12x4 + 4x2 | Apprentice | 3 | 18 | 14–22 | 13–22 | turtle: yes | no collection face; normal |
| 12 | Butterfly Path | Kumasi | butterfly | 66 / 33 | 17 | 16x4 + 1x2 | Apprentice | 3 | 28 | 20–33 | 20–33 | butterfly/path: yes | no collection face; normal |
| 13 | Temple Steps | Kumasi | templeSteps | 56 / 28 | 18 | 10x4 + 8x2 | Apprentice | 3 | 18 | 14–22 | 13–22 | steps: yes | collection: nsoromma; normal |
| 14 | Wisdom Staircase | Kumasi | wisdomStaircase | 46 / 23 | 18 | 5x4 + 13x2 | Apprentice | 3 | 16 | 11–18 | 10–18 | staircase: yes | no collection face; normal |
| 15 | Ancestral Crown | Kumasi | crown | 56 / 28 | 19 | 9x4 + 10x2 | Apprentice | 3 | 18 | 13–22 | 12–22 | crown: yes | no collection face; 5-level |
| 16 | Sacred Grove | Kumasi | sacredGrove | 46 / 23 | 20 | 3x4 + 17x2 | Apprentice | 3 | 16 | 9–18 | 9–18 | grove supports open ring | no collection face; normal |
| 17 | Golden Stool | Kumasi | royalStool | 64 / 32 | 21 | 11x4 + 10x2 | Apprentice | 3 | 18 | 10–18 | 8–18 | stool: yes | no collection face; normal |
| 18 | Ancestral Gate | Kumasi | ancestralGate | 50 / 25 | 22 | 3x4 + 19x2 | Apprentice | 3 | 24 | 15–22 | 15–22 | gate: yes | collection: odo_nnyew_fie_kwan; normal |
| 19 | Twin Houses | Kumasi | twinTowers | 48 / 24 | 23 | 1x4 + 22x2 | Apprentice | 3 | 12 | 4–9 | 3–9 | houses support twin towers | no collection face; normal |
| 20 | Raised Courtyard | Kumasi | raisedCourtyard | 56 / 28 | 24 | 4x4 + 20x2 | Apprentice | 3 | 18 | 11–19 | 10–19 | courtyard: yes | no collection face; 5-level+10-level+chapter-proposed |

## 3. Proposed layout matrix

| Level | Candidate ID | Family | Variant | Display proposal | Tiles / pairs | Layers | Free | Milestone awareness | State |
|---:|---|---|---|---|---:|---:|---:|---|---|
| 6 | batchBOpenCourtyard01 | Open courtyard | open stepped | Open Courtyard | 32 / 16 | 3 | 19 | normal | isolated candidate |
| 7 | batchBRiverPath01 | River path | single bend | River Lesson | 36 / 18 | 3 | 13 | normal | isolated candidate |
| 8 | batchBTempleGate01 | Temple gate | open gate | Wisdom Gate | 42 / 21 | 3 | 12 | normal | isolated candidate |
| 9 | batchBGatheringWings01 | Wings | gathered | Gathering Wings | 44 / 22 | 3 | 17 | face nkyinkyim | isolated candidate |
| 10 | batchBTwinBridge01 | Twin bridge | elder crossing | Elder Twin Bridge | 48 / 24 | 3 | 12 | 5-level + 10-level | isolated candidate |
| 11 | batchBSmallTurtle01 | Small turtle | open shell | Heritage Turtle | 52 / 26 | 3 | 14 | normal | isolated candidate |
| 12 | batchBButterfly01 | Butterfly | open wings | Butterfly Path | 50 / 25 | 3 | 14 | normal | isolated candidate |
| 13 | batchBShrineSteps01 | Shrine steps | broad steps | Temple Steps | 52 / 26 | 3 | 12 | face nsoromma | isolated candidate |
| 14 | batchBWisdomStaircase01 | Shrine steps | rising diagonal | Wisdom Staircase | 46 / 23 | 3 | 10 | normal | isolated candidate |
| 15 | batchBCrown01 | Crown | three point | Ancestral Crown | 52 / 26 | 3 | 14 | 5-level | isolated candidate |
| 16 | batchBOpenRing01 | Open ring | four gate | Sacred Grove | 46 / 23 | 3 | 16 | normal | isolated candidate |
| 17 | batchBRoyalStool01 | Royal stool | wide base | Golden Stool | 56 / 28 | 3 | 11 | normal | isolated candidate |
| 18 | batchBAncestralGate01 | Temple gate | ancestral arch | Ancestral Gate | 58 / 29 | 3 | 12 | face odo_nnyew_fie_kwan | isolated candidate |
| 19 | batchBTwinTowers01 | Twin towers | paired houses | Twin Houses | 62 / 31 | 3 | 17 | normal | isolated candidate |
| 20 | batchBRaisedCourtyard01 | Open courtyard | chapter showcase | Raised Courtyard | 62 / 31 | 3 | 11 | 5-level + 10-level + chapter proposal | isolated candidate |

Levels 11 and 16 are the two lighter breathers. Level 20 uses an open raised perimeter and split upper accents rather than a dense rectangle. The batch establishes ten families; courtyard, temple-gate, and shrine-step families already demonstrate geometry-changing variants.

## 4. Family and reuse plan

- Open courtyard: Levels 6 and 20; beginner open-stepped versus wide chapter-showcase perimeter.
- River path: Level 7 single-bend base, suitable for later twin-bend/wide-bank variants.
- Temple gate: Levels 8 and 18; open beginner gate versus larger ancestral arch.
- Wings/butterfly: Levels 9 and 12, distinct gathered-wing and open-wing geometries.
- Twin bridge: Level 10, reusable through bridge position/gap changes.
- Turtle: Level 11, reusable through shell opening/head-tail changes.
- Shrine steps: Levels 13 and 14, broad symmetric steps versus rising diagonal.
- Crown/open ring/royal stool/twin towers: Levels 15–19, each establishing a reusable silhouette grammar.

All fifteen coordinate hashes are unique. No symbol-only variant is counted, and none duplicates an adjacent or production assignment.

## 5. Complete candidate coordinates

Coordinates are integer `(row,col,layer)` values; odd values are genuine half-grid positions. Tile span remains two.

### Level 6 — `batchBOpenCourtyard01`

- Layer 0: (0,16,0) (0,18,0) (0,20,0) (0,22,0) (0,24,0) (2,14,0) (2,16,0) (2,24,0) (2,26,0) (4,14,0) (4,16,0) (4,24,0) (4,26,0) (6,16,0) (6,18,0) (6,20,0) (6,22,0) (6,24,0) (8,18,0) (8,20,0) (8,22,0)
- Layer 1: (1,18,1) (1,20,1) (1,22,1) (5,18,1) (5,20,1) (5,22,1) (7,20,1) (7,22,1)
- Layer 2: (4,18,2) (4,20,2) (4,22,2)

### Level 7 — `batchBRiverPath01`

- Layer 0: (0,14,0) (0,16,0) (0,18,0) (0,20,0) (0,22,0) (0,24,0) (2,22,0) (2,24,0) (2,26,0) (2,28,0) (4,14,0) (4,16,0) (4,18,0) (4,20,0) (4,22,0) (4,24,0) (6,14,0) (6,16,0) (6,18,0) (6,20,0) (8,18,0) (8,20,0) (8,22,0) (8,24,0) (8,26,0)
- Layer 1: (1,17,1) (1,19,1) (1,21,1) (3,19,1) (3,21,1) (3,23,1) (5,17,1) (5,19,1) (5,21,1)
- Layer 2: (3,20,2) (3,22,2)

### Level 8 — `batchBTempleGate01`

- Layer 0: (0,14,0) (0,16,0) (0,18,0) (0,24,0) (0,26,0) (0,28,0) (2,14,0) (2,16,0) (2,18,0) (2,24,0) (2,26,0) (2,28,0) (4,14,0) (4,16,0) (4,18,0) (4,20,0) (4,22,0) (4,24,0) (4,26,0) (4,28,0) (6,16,0) (6,18,0) (6,20,0) (6,22,0) (6,24,0) (6,26,0) (8,18,0) (8,20,0) (8,22,0) (8,24,0)
- Layer 1: (1,15,1) (1,17,1) (1,19,1) (1,25,1) (1,27,1) (1,29,1) (5,17,1) (5,19,1) (5,21,1) (5,23,1)
- Layer 2: (4,20,2) (4,22,2)

### Level 9 — `batchBGatheringWings01`

- Layer 0: (0,18,0) (0,20,0) (0,22,0) (0,24,0) (2,12,0) (2,14,0) (2,16,0) (2,18,0) (2,24,0) (2,26,0) (2,28,0) (2,30,0) (4,10,0) (4,12,0) (4,14,0) (4,16,0) (4,18,0) (4,24,0) (4,26,0) (4,28,0) (4,30,0) (4,32,0) (6,14,0) (6,16,0) (6,18,0) (6,20,0) (6,22,0) (6,24,0) (6,26,0) (8,18,0) (8,20,0) (8,22,0)
- Layer 1: (3,13,1) (3,15,1) (3,17,1) (3,23,1) (3,25,1) (3,27,1) (5,17,1) (5,19,1) (5,21,1) (5,23,1)
- Layer 2: (5,19,2) (5,21,2)

### Level 10 — `batchBTwinBridge01`

- Layer 0: (0,12,0) (0,14,0) (0,16,0) (0,18,0) (0,24,0) (0,26,0) (0,28,0) (0,30,0) (2,12,0) (2,14,0) (2,16,0) (2,18,0) (2,24,0) (2,26,0) (2,28,0) (2,30,0) (4,14,0) (4,16,0) (4,18,0) (4,20,0) (4,22,0) (4,24,0) (4,26,0) (6,16,0) (6,18,0) (6,20,0) (6,22,0) (6,24,0) (6,26,0) (8,18,0) (8,20,0) (8,22,0) (8,24,0)
- Layer 1: (1,13,1) (1,15,1) (1,17,1) (1,19,1) (1,23,1) (1,25,1) (1,27,1) (1,29,1) (5,17,1) (5,19,1) (5,21,1) (5,23,1)
- Layer 2: (4,19,2) (4,21,2) (4,23,2)

### Level 11 — `batchBSmallTurtle01`

- Layer 0: (0,18,0) (0,20,0) (0,22,0) (0,24,0) (2,14,0) (2,16,0) (2,18,0) (2,20,0) (2,22,0) (2,24,0) (2,26,0) (2,28,0) (4,12,0) (4,14,0) (4,16,0) (4,18,0) (4,20,0) (4,22,0) (4,24,0) (4,26,0) (4,28,0) (4,30,0) (6,14,0) (6,16,0) (6,18,0) (6,20,0) (6,22,0) (6,24,0) (6,26,0) (6,28,0) (8,18,0) (8,20,0) (8,22,0) (8,24,0)
- Layer 1: (1,17,1) (1,19,1) (1,21,1) (1,23,1) (3,15,1) (3,17,1) (3,19,1) (3,21,1) (3,23,1) (3,25,1) (5,17,1) (5,19,1) (5,21,1) (5,23,1)
- Layer 2: (3,18,2) (3,20,2) (3,22,2) (3,24,2)

### Level 12 — `batchBButterfly01`

- Layer 0: (0,16,0) (0,18,0) (0,20,0) (0,22,0) (0,24,0) (0,26,0) (2,10,0) (2,12,0) (2,14,0) (2,16,0) (2,18,0) (2,24,0) (2,26,0) (2,28,0) (2,30,0) (2,32,0) (4,12,0) (4,14,0) (4,16,0) (4,18,0) (4,20,0) (4,22,0) (4,24,0) (4,26,0) (4,28,0) (4,30,0) (6,16,0) (6,18,0) (6,20,0) (6,22,0) (6,24,0) (6,26,0) (8,18,0) (8,20,0) (8,22,0) (8,24,0)
- Layer 1: (1,13,1) (1,15,1) (1,17,1) (1,19,1) (1,23,1) (1,25,1) (1,27,1) (1,29,1) (5,17,1) (5,19,1) (5,21,1) (5,23,1)
- Layer 2: (4,20,2) (4,22,2)

### Level 13 — `batchBShrineSteps01`

- Layer 0: (0,18,0) (0,20,0) (0,22,0) (0,24,0) (2,16,0) (2,18,0) (2,20,0) (2,22,0) (2,24,0) (2,26,0) (4,14,0) (4,16,0) (4,18,0) (4,20,0) (4,22,0) (4,24,0) (4,26,0) (4,28,0) (6,12,0) (6,14,0) (6,16,0) (6,18,0) (6,20,0) (6,22,0) (6,24,0) (6,26,0) (6,28,0) (6,30,0) (8,16,0) (8,18,0) (8,20,0) (8,22,0) (8,24,0) (8,26,0)
- Layer 1: (1,17,1) (1,19,1) (1,21,1) (1,23,1) (3,15,1) (3,17,1) (3,19,1) (3,21,1) (3,23,1) (3,25,1) (5,17,1) (5,19,1) (5,21,1) (5,23,1)
- Layer 2: (3,18,2) (3,20,2) (3,22,2) (3,24,2)

### Level 14 — `batchBWisdomStaircase01`

- Layer 0: (0,12,0) (0,14,0) (0,16,0) (0,18,0) (0,20,0) (2,14,0) (2,16,0) (2,18,0) (2,20,0) (2,22,0) (2,24,0) (4,16,0) (4,18,0) (4,20,0) (4,22,0) (4,24,0) (4,26,0) (4,28,0) (6,18,0) (6,20,0) (6,22,0) (6,24,0) (6,26,0) (6,28,0) (8,20,0) (8,22,0) (8,24,0) (8,26,0) (8,28,0)
- Layer 1: (1,15,1) (1,17,1) (1,19,1) (1,21,1) (3,17,1) (3,19,1) (3,21,1) (3,23,1) (3,25,1) (5,19,1) (5,21,1) (5,23,1) (5,25,1)
- Layer 2: (4,19,2) (4,21,2) (4,23,2) (4,25,2)

### Level 15 — `batchBCrown01`

- Layer 0: (0,12,0) (0,14,0) (0,16,0) (0,19,0) (0,21,0) (0,23,0) (0,26,0) (0,28,0) (0,30,0) (2,12,0) (2,14,0) (2,16,0) (2,18,0) (2,20,0) (2,22,0) (2,24,0) (2,26,0) (2,28,0) (4,14,0) (4,16,0) (4,18,0) (4,20,0) (4,22,0) (4,24,0) (4,26,0) (4,28,0) (6,16,0) (6,18,0) (6,20,0) (6,22,0) (6,24,0) (6,26,0) (8,18,0) (8,20,0) (8,22,0) (8,24,0)
- Layer 1: (1,13,1) (1,15,1) (1,17,1) (1,20,1) (1,22,1) (1,24,1) (1,27,1) (1,29,1) (1,31,1) (5,17,1) (5,19,1) (5,21,1) (5,23,1)
- Layer 2: (4,19,2) (4,21,2) (4,23,2)

### Level 16 — `batchBOpenRing01`

- Layer 0: (0,16,0) (0,18,0) (0,20,0) (0,22,0) (0,24,0) (0,26,0) (2,12,0) (2,14,0) (2,16,0) (2,26,0) (2,28,0) (2,30,0) (4,10,0) (4,12,0) (4,14,0) (4,16,0) (4,26,0) (4,28,0) (4,30,0) (4,32,0) (6,12,0) (6,14,0) (6,16,0) (6,26,0) (6,28,0) (6,30,0) (8,16,0) (8,18,0) (8,20,0) (8,22,0) (8,24,0) (8,26,0)
- Layer 1: (1,17,1) (1,19,1) (1,21,1) (1,23,1) (7,17,1) (7,19,1) (7,21,1) (7,23,1) (3,15,1) (3,17,1) (3,27,1) (3,29,1)
- Layer 2: (4,15,2) (4,27,2)

### Level 17 — `batchBRoyalStool01`

- Layer 0: (0,14,0) (0,16,0) (0,18,0) (0,20,0) (0,22,0) (0,24,0) (0,26,0) (0,28,0) (2,16,0) (2,18,0) (2,20,0) (2,22,0) (2,24,0) (2,26,0) (4,18,0) (4,20,0) (4,22,0) (4,24,0) (6,14,0) (6,16,0) (6,18,0) (6,20,0) (6,22,0) (6,24,0) (6,26,0) (6,28,0) (8,12,0) (8,14,0) (8,16,0) (8,18,0) (8,20,0) (8,22,0) (8,24,0) (8,26,0) (8,28,0) (8,30,0)
- Layer 1: (1,15,1) (1,17,1) (1,19,1) (1,21,1) (1,23,1) (1,25,1) (5,15,1) (5,17,1) (5,19,1) (5,21,1) (5,23,1) (5,25,1) (7,17,1) (7,19,1) (7,21,1) (7,23,1)
- Layer 2: (4,18,2) (4,20,2) (4,22,2) (4,24,2)

### Level 18 — `batchBAncestralGate01`

- Layer 0: (0,12,0) (0,14,0) (0,16,0) (0,18,0) (0,24,0) (0,26,0) (0,28,0) (0,30,0) (2,12,0) (2,14,0) (2,16,0) (2,18,0) (2,24,0) (2,26,0) (2,28,0) (2,30,0) (4,12,0) (4,14,0) (4,16,0) (4,18,0) (4,20,0) (4,22,0) (4,24,0) (4,26,0) (4,28,0) (4,30,0) (6,14,0) (6,16,0) (6,18,0) (6,20,0) (6,22,0) (6,24,0) (6,26,0) (6,28,0) (8,16,0) (8,18,0) (8,20,0) (8,22,0) (8,24,0) (8,26,0)
- Layer 1: (1,13,1) (1,15,1) (1,17,1) (1,19,1) (1,23,1) (1,25,1) (1,27,1) (1,29,1) (5,15,1) (5,17,1) (5,19,1) (5,21,1) (5,23,1) (5,25,1)
- Layer 2: (4,18,2) (4,20,2) (4,22,2) (4,24,2)

### Level 19 — `batchBTwinTowers01`

- Layer 0: (0,12,0) (0,14,0) (0,16,0) (0,18,0) (0,24,0) (0,26,0) (0,28,0) (0,30,0) (2,12,0) (2,14,0) (2,16,0) (2,18,0) (2,24,0) (2,26,0) (2,28,0) (2,30,0) (4,12,0) (4,14,0) (4,16,0) (4,18,0) (4,24,0) (4,26,0) (4,28,0) (4,30,0) (6,14,0) (6,16,0) (6,18,0) (6,20,0) (6,22,0) (6,24,0) (6,26,0) (6,28,0) (8,16,0) (8,18,0) (8,20,0) (8,22,0) (8,24,0) (8,26,0)
- Layer 1: (1,13,1) (1,15,1) (1,17,1) (1,19,1) (1,23,1) (1,25,1) (1,27,1) (1,29,1) (3,13,1) (3,15,1) (3,17,1) (3,19,1) (3,23,1) (3,25,1) (3,27,1) (3,29,1) (7,17,1) (7,19,1) (7,21,1) (7,23,1)
- Layer 2: (3,15,2) (3,17,2) (3,25,2) (3,27,2)

### Level 20 — `batchBRaisedCourtyard01`

- Layer 0: (0,12,0) (0,14,0) (0,16,0) (0,18,0) (0,20,0) (0,22,0) (0,24,0) (0,26,0) (0,28,0) (2,12,0) (2,14,0) (2,16,0) (2,26,0) (2,28,0) (2,30,0) (4,10,0) (4,12,0) (4,14,0) (4,16,0) (4,26,0) (4,28,0) (4,30,0) (4,32,0) (6,12,0) (6,14,0) (6,16,0) (6,26,0) (6,28,0) (6,30,0) (8,12,0) (8,14,0) (8,16,0) (8,18,0) (8,20,0) (8,22,0) (8,24,0) (8,26,0) (8,28,0)
- Layer 1: (1,13,1) (1,15,1) (1,17,1) (1,19,1) (1,21,1) (1,23,1) (1,25,1) (7,13,1) (7,15,1) (7,17,1) (7,19,1) (7,21,1) (7,23,1) (7,25,1) (3,11,1) (3,13,1) (3,15,1) (5,27,1) (5,29,1) (5,31,1)
- Layer 2: (4,12,2) (4,14,2) (4,28,2) (4,30,2)

## 6. Symbol-plan compatibility

Each candidate uses its intended production Level 6–20 `SymbolCopyPlan` during seed testing. `copyCountsForTileCount(candidateTileCount)` succeeded, every copy count was even, totals exactly equalled candidate tile counts, symbol pool size did not exceed pair count, and symbol assignment preserved the coordinate set. Gameplay generation remains independent of collection ownership.

## 7. 100-seed opening-quality and generation results

| Level | Generated | Solvable | Free tiles | Legal min–max / mean | Safe min–max / mean | Forced seeds | Max attempts | Max generation |
|---:|---:|---:|---:|---|---|---:|---:|---:|
| 6 | 100/100 | 100/100 | 19 | 13–24 / 18.43 | 11–24 / 18.20 | 0 | 3 | 6.54 ms |
| 7 | 100/100 | 100/100 | 13 | 7–15 / 11.38 | 6–15 / 11.21 | 0 | 2 | 0.86 ms |
| 8 | 100/100 | 100/100 | 12 | 5–15 / 9.54 | 5–15 / 9.30 | 0 | 1 | 0.61 ms |
| 9 | 100/100 | 100/100 | 17 | 9–21 / 15.60 | 8–21 / 15.38 | 0 | 2 | 1.95 ms |
| 10 | 100/100 | 100/100 | 12 | 5–15 / 9.49 | 5–15 / 9.34 | 0 | 2 | 3.39 ms |
| 11 | 100/100 | 100/100 | 14 | 6–15 / 11.38 | 5–15 / 11.18 | 0 | 1 | 1.14 ms |
| 12 | 100/100 | 100/100 | 14 | 7–18 / 12.18 | 7–18 / 11.95 | 0 | 1 | 2.12 ms |
| 13 | 100/100 | 100/100 | 12 | 4–13 / 9.25 | 3–13 / 9.02 | 0 | 1 | 1.09 ms |
| 14 | 100/100 | 100/100 | 10 | 4–13 / 7.84 | 4–13 / 7.56 | 0 | 1 | 0.84 ms |
| 15 | 100/100 | 100/100 | 14 | 6–16 / 11.04 | 5–16 / 10.81 | 0 | 2 | 1.57 ms |
| 16 | 100/100 | 100/100 | 16 | 6–19 / 12.06 | 5–19 / 11.85 | 0 | 2 | 1.46 ms |
| 17 | 100/100 | 100/100 | 11 | 5–13 / 8.74 | 4–13 / 8.38 | 0 | 1 | 3.95 ms |
| 18 | 100/100 | 100/100 | 12 | 4–13 / 8.99 | 3–13 / 8.72 | 0 | 1 | 2.06 ms |
| 19 | 100/100 | 100/100 | 17 | 8–21 / 14.06 | 7–20 / 13.78 | 0 | 2 | 2.62 ms |
| 20 | 100/100 | 100/100 | 11 | 4–12 / 8.25 | 3–12 / 7.78 | 0 | 2 | 2.48 ms |

All 1,500 boards generated and solved. Every candidate exceeded its band minimum: the lowest observed legal count was 4 and lowest safe count was 3. There were zero forced-opening seeds and maximum reverse-removal attempts were two. Safe-move evaluation used the production solver with a 25,000-node per-move audit budget; guaranteed whole-board solvability was checked independently.

## 8. Projected visual-centre analysis

Centres are `(x,y)` in real `BoardLayoutGeometry` projected tile units, including layer offsets. Maximum difference is horizontal layer-to-full-centre distance; pixel difference uses the real 390×844 preview fit area. Candidate coordinates—not global projection—were adjusted for visible horizontal balance.

| Level | Layer 0 | Layer 1 | Layer 2 | Full board | Max Δx | Pixel Δ | Visible lean |
|---:|---|---|---|---|---:|---:|---|
| 6 | 9.000,2.761 | 8.966,2.789 | 8.720,2.656 | 8.965,2.758 | 0.245 | 14.4 px | No |
| 7 | 9.102,2.832 | 8.718,2.225 | 9.145,2.092 | 9.008,2.639 | 0.290 | 14.9 px | No |
| 8 | 9.425,2.771 | 9.370,1.999 | 9.145,2.656 | 9.399,2.582 | 0.254 | 12.5 px | No |
| 9 | 9.292,2.816 | 8.860,2.676 | 8.720,3.221 | 9.168,2.803 | 0.448 | 15.5 px | No |
| 10 | 9.335,2.580 | 9.143,1.848 | 9.145,2.656 | 9.275,2.402 | 0.132 | 5.5 px | No |
| 11 | 9.425,2.922 | 8.860,2.225 | 9.145,2.092 | 9.251,2.670 | 0.391 | 16.2 px | No |
| 12 | 9.425,2.671 | 9.143,1.848 | 9.145,2.656 | 9.346,2.473 | 0.203 | 7.0 px | No |
| 13 | 9.425,3.188 | 8.860,2.225 | 9.145,2.092 | 9.251,2.844 | 0.391 | 16.2 px | No |
| 14 | 9.381,2.922 | 9.023,2.225 | 9.570,2.656 | 9.296,2.702 | 0.274 | 12.6 px | No |
| 15 | 9.319,2.514 | 9.448,1.790 | 9.145,2.656 | 9.341,2.341 | 0.196 | 7.9 px | No |
| 16 | 9.425,2.922 | 9.143,2.601 | 9.145,2.656 | 9.339,2.827 | 0.196 | 6.8 px | No |
| 17 | 9.425,3.110 | 8.860,2.789 | 9.145,2.656 | 9.244,2.986 | 0.384 | 15.9 px | No |
| 18 | 9.425,2.809 | 9.103,2.063 | 9.145,2.656 | 9.328,2.618 | 0.225 | 9.3 px | No |
| 19 | 9.425,2.803 | 9.200,2.225 | 9.145,2.092 | 9.334,2.571 | 0.189 | 7.8 px | No |
| 20 | 9.224,2.922 | 8.690,2.789 | 9.145,2.656 | 9.046,2.862 | 0.356 | 12.3 px | No |

Rows marked Review are retained for human visual judgment, not automatically rejected: their contact-sheet renders remain balanced in overall mass, while their layer centres intentionally differ. Level 16's initially detected top-layer lean was corrected and its preview/metrics regenerated.

## 9. Structural and viewport validation

All candidates pass even-count, unique-coordinate, contiguous-layer, immediate-lower-support, no-floating-tile, no same-layer overlap, projected-bounds, and minimum-four-free-tile validation. All render successfully at 360×640, 390×844, and 430×932 through `BoardWidget`/`TileWidget` with production artwork, shadows, projection, background, fit, and centring.

## 10. Collection and reward awareness

- Level 9: `nkyinkyim` face milestone.
- Level 10: planned 5-level + 10-level reward.
- Level 13: `nsoromma` face milestone.
- Level 15: planned 5-level reward.
- Level 18: `odo_nnyew_fie_kwan` face milestone.
- Level 20: planned 5-level + 10-level + future 20-level chapter reward.

No reward code changed. Levels 9, 13, and 18 have generous opening margins; no beginner reward coincides with a forced opening.

## 11. Display-name review

| Level | Current | Proposal | Layout | Recommendation | Reason |
|---:|---|---|---|---|---|
| 1 | First Symbols | First Symbols | earlyOpenDiamond01 | Optional retain | Neutral onboarding name fits. |
| 2 | New Roots | New Roots | earlyOpenDiamond02 | Optional retain | Cultural progression name need not describe geometry. |
| 3 | Side Paths | First Bridge | earlyBridge01 | Optional | Bridge silhouette is clearer. |
| 4 | Small Turtle | Early Shrine | earlyShrine01 | Strong | Current name conflicts with the approved shrine silhouette. |
| 5 | Shrine Steps | Layered Diamond | earlyLayeredDiamond01 | Optional | Geometry is a layered diamond, though the current progression name remains usable. |
| 8 | Wisdom House | Wisdom Gate | batchBTempleGate01 | Strong if approved | Candidate is an unmistakable open gate. |
| 10 | Elder Bridge | Elder Twin Bridge | batchBTwinBridge01 | Optional | Clarifies the paired crossing. |

All other Level 6–20 current names are retained as proposals. Display names are not persistence keys; changing them later cannot alter numeric level progress.

## 12. Preview and contact-sheet paths

For every candidate:

- Clean: `artifacts/layout-previews/batch-b/<layoutId>_390x844.png`
- Diagnostic: `artifacts/layout-previews/batch-b/<layoutId>_diagnostic.png`
- Additional compact/tall: `<layoutId>_360x640.png` and `<layoutId>_430x932.png`

Contact sheets:

- `artifacts/layout-previews/batch-b/contact-sheet-a-levels-6-10.png`
- `artifacts/layout-previews/batch-b/contact-sheet-b-levels-11-15.png`
- `artifacts/layout-previews/batch-b/contact-sheet-c-levels-16-20.png`
- `artifacts/layout-previews/batch-b/diagnostic-summary-levels-6-20.png`

Supporting CSVs: `metrics.csv` and `production-audit.csv` in the same directory.

## 13. Developer-only catalogue

The developer tester now has an isolated Batch B section showing intended level, ID, family, variant, proposed name, tiles/pairs/layers/free count, 100-seed minimums, half-grid use, structural/solvability state, and collection/reward milestone. Normal player screens do not import or render this catalogue, and candidate layouts are not added to `kLevels`.

## 14. Files modified or added

- Added `lib/core/constants/batch_b_layout_data.dart`.
- Updated developer-only catalogue in `lib/screens/developer/developer_level_tester_screen.dart`.
- Added candidate structural/100-seed/isolation tests in `test/batch_b_layout_candidates_test.dart`.
- Extended `test/pilot_layout_preview_test.dart` for Batch B real-widget captures.
- Extended `test/collection_migration_test.dart` with the requested fresh Level 1–4 flow and purchase preservation.
- Added `tool/report_batch_b_layouts.dart`, `tool/audit_batch_b_production_levels.dart`, and `tool/generate_batch_b_contact_sheets.swift`.
- Added this report and generated non-bundle preview artifacts.

No production `LevelDefinition`, chapter, reward, migration, collection schedule, solver, coordinate rule, save key, or monetisation implementation was changed in Batch B.

## 15. Validation results

- Progression smoke tests: passed.
- Candidate structure/isolation: passed.
- 1,500 deterministic candidate generations: 100% generated and solvable.
- Real Flutter Batch B preview renders: 60/60 passed.
- Production campaign: all 200 levels checked by the full startup suite.
- Collection coverage: 97 unique faces remains intact.
- Full `flutter test`: **289 tests passed** in approximately 2 minutes.
- `flutter analyze`: **No issues found** (2.8 seconds).
- `git diff --check`: **passed with no whitespace errors**.

## 16. Recommended visual-review order

1. Contact sheet A, then inspect Levels 7, 9, and 10 individually for silhouette readability.
2. Contact sheet B, focusing on Level 12's butterfly negative space and Level 14's deliberate diagonal mass.
3. Contact sheet C, comparing the Level 16 breather against the Level 20 showcase and checking that Levels 18–20 feel progressively stronger.
4. Diagnostic summary for support, half-grid, bounds, and centre overlays.
5. Compact 360×640 renders for Levels 12, 18, 19, and 20 before any production approval.

## 17. Candidates requiring visual refinement decisions

No candidate requires technical repair. Human review should decide whether Level 7 reads strongly enough as a river, Level 9 as gathered wings, Level 12 as a butterfly, and Level 14's asymmetric staircase is desirable. These are silhouette/art-direction questions; the candidates remain isolated until explicit approval. The approved roadmap rows 6–20 were not rewritten because these candidates are still awaiting visual approval.
