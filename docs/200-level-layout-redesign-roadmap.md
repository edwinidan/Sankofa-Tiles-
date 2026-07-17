# Sankofa Tiles — 200-Level Layout Redesign Roadmap

**Status:** Levels 1–5 assigned and verified. Levels 6–200 remain unchanged.

## Principles

- Keep integer half-grid coordinates and the existing solver architecture.
- Handcraft reusable layout families, then vary symbols, coverage, and difficulty through existing level data.
- Preserve level IDs, saved-progress keys, chapter order, and monetisation behavior.
- Require structural validation, viewport fit, projected-centre review, deterministic solvability runs, and real-widget previews before each production assignment.
- Do not advance a batch without visual approval of its clean and diagnostic previews.

## Batch plan

| Batch | Levels | Design focus | Expected layout character |
|---:|---:|---|---|
| 0 | 1–5 | Approved foundation | Open gate, open diamond, bridge, shrine, layered diamond |
| 1 | 6–20 | Novice expansion | Courtyards, small wings, shallow steps, open crosses; 26–50 tiles |
| 2 | 21–40 | Apprentice transition | Split paths, twin shrines, wider bridges; 36–64 tiles |
| 3 | 41–60 | Intermediate silhouettes | Turtles, crowns, houses, small Adinkra-inspired forms; 44–72 tiles |
| 4 | 61–80 | Layer interplay | More half-grid bridges, hollow centres, controlled islands; 52–80 tiles |
| 5 | 81–100 | Advanced readability | Denser three-layer boards with strong outer silhouettes; 60–88 tiles |
| 6 | 101–120 | Expert variety | Asymmetric-but-balanced wings, gates, multi-peak forms; 64–96 tiles |
| 7 | 121–140 | Expert constraint | Narrow openings, deeper cover chains, deliberate negative space; 72–104 tiles |
| 8 | 141–160 | Elder compositions | Fortresses, temple complexes, linked courtyards; 80–112 tiles |
| 9 | 161–180 | Legendary boards | Large recognisable silhouettes with multiple removal fronts; 88–120 tiles |
| 10 | 181–200 | Mythic finale | Grand Adinkra-inspired archives, crowns, turtles, and final complexes; 96–130 tiles |

## Workflow for every batch

1. Audit current level tile counts and symbol plans in the batch.
2. Draft layout families without changing production references.
3. Validate even counts, unique coordinates, same-layer overlap, immediate-lower-layer support, opening geometry, and viewport fit.
4. Run at least 100 deterministic generation seeds per new layout using the intended symbol-copy plan.
5. Record free tiles, legal pairs, safe pairs, attempts, search nodes, and projected layer centres.
6. Render clean previews at 360×640, 390×844, and 430×932 plus a diagnostic preview.
7. Obtain visual approval.
8. Assign only the approved batch while preserving level IDs and progress keys.
9. Run static analysis, focused layout/startup tests, the preview suite, and the full Flutter test suite.

## Difficulty curve

- Early difficulty comes primarily from tile count and gentle increases in overlap.
- Middle difficulty adds more removal fronts, negative space, and three-layer interaction.
- Late difficulty adds denser cover chains and more complex silhouettes while retaining readable edges.
- Symmetry is preferred for teaching and landmark boards; intentional asymmetry is reserved for later variety and must remain visually balanced after projection.

## Approval gates

- **Geometry gate:** all structural and viewport validators pass.
- **Generation gate:** every deterministic seed succeeds and the board is completely solvable.
- **Opening gate:** legal and safe opening quality meets the intended difficulty.
- **Visual gate:** clean previews are centred, unclipped, readable, and approved.
- **Regression gate:** `flutter analyze` and the full test suite pass.

## Next authorized step

Design and preview Batch 1 (Levels 6–20) without assigning it to production. Production assignment requires explicit approval after visual review.
