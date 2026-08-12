# Levels 201–400 expansion architecture

Status: expansion foundation with Levels 1–240 assigned to production. Levels
241–400 remain roadmap-only and unavailable.

## Level-200 boundary audit

|Usage|Location / behavior|Classification|Expansion treatment|
|---|---|---|---|
|Implemented registry|`level_data.dart`: `kLevels` contains 240 contiguous IDs; `kImplementedCampaignLevelCount` and `kImplementedFinalLevelId` derive from it.|Implemented production level count|Keep derived. Append only visually approved content in a later release.|
|Long-term target|`kPlannedCampaignLevelCount = 400`, `kPlannedChapterCount = 20`, `kPlannedLevelsPerChapter = 20`.|Planned campaign horizon|Never use to index `kLevels` or enable navigation.|
|Production chapters|`chapter_data.dart`: 12 implemented 20-level definitions; Chapter 11 is 201–220 and Chapter 12 is 221–240.|Gameplay boundary / production content|Chapter totals derive from each definition instead of literal ten-level assumptions.|
|Next unfinished level|`ProgressService.nextUnfinishedLevelId` indexes the implemented registry; completed 200 resolves to 201 and completed 240 returns `null`.|Gameplay boundary|Level 241 cannot be exposed until a production definition exists.|
|Completion|`ProgressService.hasCompletedAllLevels`, Result actions, and Chapter Complete derive the current-content boundary from `kLevels`; the permanent `complete_campaign` achievement retains the planned Level-400 horizon.|Gameplay boundary|Level 240 is presented as current-journey completion, not permanent campaign completion.|
|Home/Journey selector|Cards, progress ratios, maximum stars, and next-level CTA derive from `kLevels` and implemented constants.|Gameplay boundary / UI|No unfinished level can appear.|
|Unlocking|`StorageService.isLevelUnlocked(n)` checks completion of `n - 1`; it has no literal cap.|Gameplay boundary|A Level-200 veteran will qualify for 201 once 201 exists.|
|Save keys|Completion, stars, scores, highest completed level, collection, economy, purchases, settings, statistics, and achievements use stable independent keys.|Save/progress model|No renumbering or destructive migration.|
|Schema-v4 migration|Legacy collection ownership uses a frozen Level-200 entitlement calculation and additive union semantics.|Collection horizon / migration fixture|The literal 200 must remain frozen; it is not the future campaign cap.|
|Collection schedule|`kCollectionScheduleFinalLevel = 400` spreads the current 87 non-starter faces through Level 400.|Collection horizon|Keep separate from implemented content.|
|Analytics|Client event methods accept an integer level ID and contain no 200 cap.|Analytics|External dashboards, Remote Config, audiences, and warehouse queries remain an operational audit item.|
|Daily/rewards|Daily rewards are campaign-independent; ordinary/chapter rewards use the completed level and chapter functions.|Unrelated / derived gameplay|No 200 replacement required.|
|Tests|Startup, board geometry, exact-assignment, signature, chapter, unlock migration, and boundary tests assert 240-level production while retaining frozen legacy behavior.|Test fixture|Levels 201–240 receive 100-seed validation and real production preview coverage.|
|Developer tools|Older reports say “all 200 production levels”; the tester iterates `kLevels`.|Implemented count / historical report copy|Current statements remain true. The new 201–240 section is explicitly isolated.|
|Repository copy|README, CONTEXT, GAME_FLOW, screen inventory, and older phase plans describe the shipped 200-level version.|UI/store-facing or historical copy|Do not globally replace. Update only when expansion is approved for production.|
|Unrelated literals|200 ms animation durations, 200 px width clamps, 200-point bonuses, and 200 px/s effects.|Unrelated numeric value|Never change as campaign work.|

There is no `level <= 200` or `level == 200` runtime navigation gate. The
implemented registry is the authoritative boundary, so a candidate catalogue
cannot accidentally open Level 201.

## Safe 400-level model

- `plannedCampaignLevelCount` is 400 and describes design intent only.
- `implementedProductionLevelCount` is derived from the contiguous approved
  production registry. It is 240 after the approved expansion assignment.
- `implementedFinalLevelId` is derived from the last approved production
  definition. Completion and next-level behavior use it, not 400.
- Candidate catalogues have no dependency from `kLevels`, chapter routing, or
  normal game launch. Candidate IDs may therefore be evaluated without being
  playable.
- The approved 201–240 boards are now appended with matching production
  chapter definitions. Completing 240 returns a safe implemented-end state;
  there is no Level-241 route or production definition.
- Before the eventual 400 release, migrate the current 10-level UI chapter
  assumptions (`/10`, 30 stars, ten-level labels) to chapter-derived lengths.
  Preserve reward transaction IDs or explicitly version them to prevent
  duplicate grants.

## Existing-player continuation

A schema-v4 player at `highest_completed_level = 200` keeps the same level IDs
and all per-level keys. With approved Level 201 appended,
`isLevelUnlocked(201)` reads `completed_200`, and `nextUnfinishedLevelId`
resolves the newly implemented ID 201. No backfill rewrites completed
levels, stars, best scores, cowries, boosters, purchases, ad removal,
collection flags, settings, statistics, achievements, or claimed transaction
IDs. All future collection migration remains a set union; it never revokes an
owned face.

## Proposed Chapters 11–20 roadmap

Chapters 11 and 12 are production `ChapterDefinition` entries. Chapters 13–20
remain documentation only.

|Chapter|Levels|Theme|Difficulty direction|Silhouette vocabulary|Breathers / finale|Tiles|Symbol pool|Rewards and collection moments|
|---:|---:|---|---|---|---|---:|---:|---|
|11|201–220|The Journey Reopens|Legendary re-entry to layered frontier play|journey bird, ancestral tree, shields, bridges, masks, courtyards, serpents, wings|Breathers at 201, 206, 212, 217; Horizon Palace at 220|32–80|48–58|Welcome-back reward at 201; discoveries around 205/210/215; chapter chest and prestigious face moment at 220.|
|12|221–240|Living Memory|Legendary into Mythic; more split mass and central blocking|Sankofa wings, masks, groves, causeways, keys, sanctuaries, open treasuries, arches, palace islands|Breathers at 223, 229, 234; Living Archive at 240|30–80|58–68|Royal-path reward at 225; sanctuary discovery near 230; major chest and collection moment at 240.|
|13|241–260|Rivers of Counsel|Mythic route choice and controlled asymmetry|forked rivers, stepping stones, delta islands, canoe-like bridges|Two early breathers and one late reset; River Council confluence at 260|48–86|62–70|Discovery near 248, booster cache at 250, verified-face reveal and chapter chest at 260.|
|14|261–280|Forest of Ancestors|Deeper cover with open vertical breathing lanes|towering trees, roots, canopies, sacred groves, animal guardians|Breathers after dense canopy boards; Great Ancestral Tree at 280|50–90|64–73|Collection moments at 268 and 278; canopy cosmetic/chest at 280.|
|15|281–300|Royal Roads|Broader boards and deliberate central gates|stools, shields, processional roads, pavilions, twin courts|Alternating wide/narrow reset; Golden Procession at 300|52–92|66–76|Royal cache at 290; prestigious verified face and major reward at 300.|
|16|301–320|Voices of the Drum|Rhythmic opening geometry and paired masses|drums, bells, sound waves, split circles, ceremonial fans|Short boards at 306/313; Grand Drum Assembly at 320|50–94|68–79|Discoveries at 308/316; audio-themed cosmetic and chapter chest at 320.|
|17|321–340|Sky and Spirit|More exposed top layers without brittle starts|stars, wings, birds, stepped clouds, horizon arches|Three low-depth sky breathers; Gate of the Four Skies at 340|54–96|70–82|Prestige reveals at 328/338; four-sky reward at 340.|
|18|341–360|Fortresses of Memory|High strategic pressure through courtyards and gates|open forts, tower pairs, hollow citadels, protective shields|Courtyard breathers after forts; Fortress of Shared Memory at 360|56–98|72–85|Defence cache at 350; verified face and chapter chest at 360.|
|19|361–380|Paths of Return|Late-game synthesis with winding and multi-island structures|Sankofa paths, spirals, bridges, returning birds, split monuments|Purposeful re-entry boards at 361/369/375; Monument of Return at 380|54–100|74–88|Legacy-player commemorative at 361; discoveries at 368/378; return monument reward at 380.|
|20|381–400|The Grand Living Archive|Campaign culmination: mastery without unreadable density|grand arches, ancestral trees, royal courts, four-way paths, monumental Adinkra-inspired negative space|Breathers at 386/392/396; Levels 397–399 form a rising trilogy; Level 400 is the Grand Archive finale|58–104|76–92|Prestige discoveries at 388/396; Level 400 grants the final chapter chest, campaign achievement, commemorative cosmetic, and a verified collection capstone.|

Level 400 should be a unique, portrait-readable monument with at least six
legal and safe opening pairs, major central negative space, multiple visual
axes, and a reward sequence that distinguishes campaign completion from an
ordinary chapter finish.

## Collection audit and recommendation

- Code defines 97 collectible IDs and 97 `TileDefinition` records. Every ID is
  used by both gameplay selection and collection; no definition is orphaned.
- Every definition has a named asset path and repository meaning text. The
  repository does not contain provenance or cultural-review metadata, so the
  audit can only label them “named Adinkra definition; external cultural
  verification not recorded.” It must not make a stronger authenticity claim.
- Exact-file hashing found no duplicate visual among the 97 definition paths.
  Four unused copies are byte-identical to used assets: duplicate `akofena`,
  duplicate `funtumfunefu_denkyemfunefu`, `tile edit/mpatapo`, and the
  Gemini-named tile-edit image (identical to the used `aponkyerene_wu_a`).
  These are not additional unique-face candidates.
- There are no gameplay-only or collection-only faces and no placeholder
  definitions. The Gemini-named file is unused and byte-identical to a defined
  face; it should not be counted as new cultural content.
- Current pacing is 10 starters plus 87 individual milestones: average 4.60
  levels per scheduled unlock, shortest interval 4, longest 5, final Level
  400. By 20-level design chapter the discovery counts are
  `15,4,5,4,4,5,4,3,5,4,5,4,4,5,4,4,5,4,4,5` (Chapter 1 includes the ten
  starters). Forty-four scheduled milestones lie in Levels 201–400.
- The schedule is satisfying for a fresh install, but a migrated veteran who
  earned all legacy faces by Level 200 already owns all 97. Re-spacing existing
  milestones cannot give that player new discoveries.

Recommendation: retain all current 97 and target **120 verified unique faces**.
Commission or source **23 additional culturally reviewed assets**, with
authoritative symbol name, language spelling, meaning, provenance, reviewer,
license, and final transparent production artwork. Add them only through an
additive schema-v5 union. A proposed veteran-friendly cadence is one new face
near Levels 208, 216, 220, 228, 236, 240, then roughly one at two prestigious
moments per later 20-level chapter, reserving the 23rd new face or a special
variant/reward for Level 400. Existing ownership is never revoked, and current
milestones remain valid for players who have not yet earned them.

The machine-readable per-face audit, including path, name, meaning, starter
state, and first unlock, is `tile-face-audit.csv` beside the candidate previews.
