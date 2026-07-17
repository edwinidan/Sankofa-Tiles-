# Batch B portrait redesign — pass 2

All measurements use the shared production geometry at the 390×844 review viewport (374×780 gameplay area). All nine layouts use three layers, 64 px effective tiles, and 75.7% gameplay-height occupancy.

|Level|Layout|Tiles|Width occupancy|Final decision|
|---:|---|---:|---:|---|
|7|`batchBRiverPath01`|40|68.0%|Approved; portrait switchback river|
|9|`batchBGatheringWings01`|48|82.6%|Approved wider variation; vertical body and wings|
|10|`batchBTwinBridge01`|52|75.3%|Approved; stacked ceremonial spans|
|11|`batchBSmallTurtle01`|54|77.7%|Approved; head, shell, limbs and tail read vertically|
|12|`batchBButterfly01`|54|82.6%|Approved wider variation; vertical body and paired wings|
|15|`batchBCrown01`|56|82.6%|Approved; tall ceremonial crown|
|17|`batchBRoyalStool01`|60|82.6%|Approved; seat, supports and pedestal|
|19|`batchBTwinTowers01`|64|85.0%|Approved widest variation; twin upper structures and shared base|
|20|`batchBRaisedCourtyard01`|64|77.7%|Approved finale; central void, raised court and lower foundation|

Each layout passed structural validation and 100 deterministic generation/solver seeds with zero forced-opening seeds. The complete Batch B production matrix and opening-quality data are in `artifacts/layout-previews/portrait-campaign-report.md` and `artifacts/layout-previews/batch-b/metrics.csv`.

The portrait policy for future batches is: target 65–80% height, 55–78% width, 60–64 px tiles at 390×844, reserve roughly one quarter of a batch for justified wider silhouettes, and score every board on tile size, occupancy, readability, silhouette, layering, opening quality and solvability. On the 360×640 compact preset, portrait layouts use a documented 40 px validation floor; standard and tall gameplay presets retain the existing 44 px floor.
