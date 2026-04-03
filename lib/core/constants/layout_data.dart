class TilePosition {
  final int row;
  final int col;
  final int layer;
  const TilePosition(this.row, this.col, this.layer);
}

// Level 1 — 16 tiles, 2 layers
// Layer 0: 4×3 = 12   Layer 1: 2×2 = 4   Total: 16
const level1Layout = [
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0),
  TilePosition(1,0,1), TilePosition(1,1,1),
  TilePosition(2,0,1), TilePosition(2,1,1),
];

// Level 2 — 20 tiles, 2 layers
// Layer 0: 4×4 = 16   Layer 1: 2×2 = 4   Total: 20
const level2Layout = [
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0), TilePosition(0,3,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0), TilePosition(1,3,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0), TilePosition(2,3,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0), TilePosition(3,3,0),
  TilePosition(1,1,1), TilePosition(1,2,1),
  TilePosition(2,1,1), TilePosition(2,2,1),
];

// Level 3 — 24 tiles, 2 layers
// Layer 0: 4×5 = 20   Layer 1: 2×2 = 4   Total: 24
const level3Layout = [
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0), TilePosition(0,3,0), TilePosition(0,4,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0), TilePosition(1,3,0), TilePosition(1,4,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0), TilePosition(2,3,0), TilePosition(2,4,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0), TilePosition(3,3,0), TilePosition(3,4,0),
  TilePosition(1,1,1), TilePosition(1,2,1),
  TilePosition(2,1,1), TilePosition(2,2,1),
];

// Level 4 — 28 tiles, 3 layers
// Layer 0: 4×6 = 24   Layer 1: 2   Layer 2: 2   Total: 28
const level4Layout = [
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0),
  TilePosition(0,3,0), TilePosition(0,4,0), TilePosition(0,5,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0),
  TilePosition(1,3,0), TilePosition(1,4,0), TilePosition(1,5,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0),
  TilePosition(2,3,0), TilePosition(2,4,0), TilePosition(2,5,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0),
  TilePosition(3,3,0), TilePosition(3,4,0), TilePosition(3,5,0),
  TilePosition(1,2,1), TilePosition(2,2,1),
  TilePosition(1,2,2), TilePosition(2,2,2),
];

// Level 5 — 36 tiles, 3 layers
// Layer 0: 5×6 = 30   Layer 1: 2×2 = 4   Layer 2: 2   Total: 36
const level5Layout = [
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0),
  TilePosition(0,3,0), TilePosition(0,4,0), TilePosition(0,5,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0),
  TilePosition(1,3,0), TilePosition(1,4,0), TilePosition(1,5,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0),
  TilePosition(2,3,0), TilePosition(2,4,0), TilePosition(2,5,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0),
  TilePosition(3,3,0), TilePosition(3,4,0), TilePosition(3,5,0),
  TilePosition(4,0,0), TilePosition(4,1,0), TilePosition(4,2,0),
  TilePosition(4,3,0), TilePosition(4,4,0), TilePosition(4,5,0),
  TilePosition(1,2,1), TilePosition(1,3,1),
  TilePosition(2,2,1), TilePosition(2,3,1),
  TilePosition(1,2,2), TilePosition(2,2,2),
];

// Level 6 — 40 tiles, 3 layers
// Layer 0: 5×6 = 30   Layer 1: 3×2 = 6   Layer 2: 2×2 = 4   Total: 40
const level6Layout = [
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0),
  TilePosition(0,3,0), TilePosition(0,4,0), TilePosition(0,5,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0),
  TilePosition(1,3,0), TilePosition(1,4,0), TilePosition(1,5,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0),
  TilePosition(2,3,0), TilePosition(2,4,0), TilePosition(2,5,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0),
  TilePosition(3,3,0), TilePosition(3,4,0), TilePosition(3,5,0),
  TilePosition(4,0,0), TilePosition(4,1,0), TilePosition(4,2,0),
  TilePosition(4,3,0), TilePosition(4,4,0), TilePosition(4,5,0),
  TilePosition(1,2,1), TilePosition(1,3,1),
  TilePosition(2,2,1), TilePosition(2,3,1),
  TilePosition(3,2,1), TilePosition(3,3,1),
  TilePosition(1,2,2), TilePosition(1,3,2),
  TilePosition(2,2,2), TilePosition(2,3,2),
];

// Level 7 — 44 tiles, 3 layers
// Layer 0: 5×7 = 35   Layer 1: 4×2 = 8   Layer 2: 1   Total: 44
const level7Layout = [
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0),
  TilePosition(0,3,0), TilePosition(0,4,0), TilePosition(0,5,0), TilePosition(0,6,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0),
  TilePosition(1,3,0), TilePosition(1,4,0), TilePosition(1,5,0), TilePosition(1,6,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0),
  TilePosition(2,3,0), TilePosition(2,4,0), TilePosition(2,5,0), TilePosition(2,6,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0),
  TilePosition(3,3,0), TilePosition(3,4,0), TilePosition(3,5,0), TilePosition(3,6,0),
  TilePosition(4,0,0), TilePosition(4,1,0), TilePosition(4,2,0),
  TilePosition(4,3,0), TilePosition(4,4,0), TilePosition(4,5,0), TilePosition(4,6,0),
  TilePosition(1,2,1), TilePosition(1,3,1),
  TilePosition(2,2,1), TilePosition(2,3,1),
  TilePosition(3,2,1), TilePosition(3,3,1),
  TilePosition(4,2,1), TilePosition(4,3,1),
  TilePosition(2,2,2),
];

// Level 8 — 48 tiles, 4 layers
// Layer 0: 5×6 = 30   Layer 1: 3×4 = 12   Layer 2: 2×2 = 4   Layer 3: 2   Total: 48
const level8Layout = [
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0),
  TilePosition(0,3,0), TilePosition(0,4,0), TilePosition(0,5,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0),
  TilePosition(1,3,0), TilePosition(1,4,0), TilePosition(1,5,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0),
  TilePosition(2,3,0), TilePosition(2,4,0), TilePosition(2,5,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0),
  TilePosition(3,3,0), TilePosition(3,4,0), TilePosition(3,5,0),
  TilePosition(4,0,0), TilePosition(4,1,0), TilePosition(4,2,0),
  TilePosition(4,3,0), TilePosition(4,4,0), TilePosition(4,5,0),
  TilePosition(1,1,1), TilePosition(1,2,1), TilePosition(1,3,1), TilePosition(1,4,1),
  TilePosition(2,1,1), TilePosition(2,2,1), TilePosition(2,3,1), TilePosition(2,4,1),
  TilePosition(3,1,1), TilePosition(3,2,1), TilePosition(3,3,1), TilePosition(3,4,1),
  TilePosition(1,1,2), TilePosition(1,2,2),
  TilePosition(2,1,2), TilePosition(2,2,2),
  TilePosition(1,1,3), TilePosition(2,1,3),
];

// Level 9 — 52 tiles, 4 layers
// Layer 0: 5×7 = 35   Layer 1: 3×4 = 12   Layer 2: 2×2 = 4   Layer 3: 1   Total: 52
const level9Layout = [
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0),
  TilePosition(0,3,0), TilePosition(0,4,0), TilePosition(0,5,0), TilePosition(0,6,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0),
  TilePosition(1,3,0), TilePosition(1,4,0), TilePosition(1,5,0), TilePosition(1,6,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0),
  TilePosition(2,3,0), TilePosition(2,4,0), TilePosition(2,5,0), TilePosition(2,6,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0),
  TilePosition(3,3,0), TilePosition(3,4,0), TilePosition(3,5,0), TilePosition(3,6,0),
  TilePosition(4,0,0), TilePosition(4,1,0), TilePosition(4,2,0),
  TilePosition(4,3,0), TilePosition(4,4,0), TilePosition(4,5,0), TilePosition(4,6,0),
  TilePosition(1,1,1), TilePosition(1,2,1), TilePosition(1,3,1), TilePosition(1,4,1),
  TilePosition(2,1,1), TilePosition(2,2,1), TilePosition(2,3,1), TilePosition(2,4,1),
  TilePosition(3,1,1), TilePosition(3,2,1), TilePosition(3,3,1), TilePosition(3,4,1),
  TilePosition(1,2,2), TilePosition(1,3,2),
  TilePosition(2,2,2), TilePosition(2,3,2),
  TilePosition(1,2,3),
];

// ─────────────────────────────────────────────────────────────────────────────
// LEVELS 11–20  (new)
// ─────────────────────────────────────────────────────────────────────────────

// Level 11 — 60 tiles, 4 layers
// Layer 0: 5×8 = 40   Layer 1: 3×4 = 12   Layer 2: 2×2 = 4   Layer 3: 2×2 = 4
const level11Layout = [
  // Layer 0 — 5×8
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0), TilePosition(0,3,0),
  TilePosition(0,4,0), TilePosition(0,5,0), TilePosition(0,6,0), TilePosition(0,7,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0), TilePosition(1,3,0),
  TilePosition(1,4,0), TilePosition(1,5,0), TilePosition(1,6,0), TilePosition(1,7,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0), TilePosition(2,3,0),
  TilePosition(2,4,0), TilePosition(2,5,0), TilePosition(2,6,0), TilePosition(2,7,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0), TilePosition(3,3,0),
  TilePosition(3,4,0), TilePosition(3,5,0), TilePosition(3,6,0), TilePosition(3,7,0),
  TilePosition(4,0,0), TilePosition(4,1,0), TilePosition(4,2,0), TilePosition(4,3,0),
  TilePosition(4,4,0), TilePosition(4,5,0), TilePosition(4,6,0), TilePosition(4,7,0),
  // Layer 1 — rows 1-3, cols 2-5
  TilePosition(1,2,1), TilePosition(1,3,1), TilePosition(1,4,1), TilePosition(1,5,1),
  TilePosition(2,2,1), TilePosition(2,3,1), TilePosition(2,4,1), TilePosition(2,5,1),
  TilePosition(3,2,1), TilePosition(3,3,1), TilePosition(3,4,1), TilePosition(3,5,1),
  // Layer 2 — rows 1-2, cols 3-4
  TilePosition(1,3,2), TilePosition(1,4,2),
  TilePosition(2,3,2), TilePosition(2,4,2),
  // Layer 3 — rows 1-2, cols 3-4
  TilePosition(1,3,3), TilePosition(1,4,3),
  TilePosition(2,3,3), TilePosition(2,4,3),
];

// Level 12 — 64 tiles, 4 layers
// Layer 0: 6×7 = 42   Layer 1: 3×4 = 12   Layer 2: 3×2 = 6   Layer 3: 2×2 = 4
const level12Layout = [
  // Layer 0 — 6×7
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0), TilePosition(0,3,0),
  TilePosition(0,4,0), TilePosition(0,5,0), TilePosition(0,6,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0), TilePosition(1,3,0),
  TilePosition(1,4,0), TilePosition(1,5,0), TilePosition(1,6,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0), TilePosition(2,3,0),
  TilePosition(2,4,0), TilePosition(2,5,0), TilePosition(2,6,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0), TilePosition(3,3,0),
  TilePosition(3,4,0), TilePosition(3,5,0), TilePosition(3,6,0),
  TilePosition(4,0,0), TilePosition(4,1,0), TilePosition(4,2,0), TilePosition(4,3,0),
  TilePosition(4,4,0), TilePosition(4,5,0), TilePosition(4,6,0),
  TilePosition(5,0,0), TilePosition(5,1,0), TilePosition(5,2,0), TilePosition(5,3,0),
  TilePosition(5,4,0), TilePosition(5,5,0), TilePosition(5,6,0),
  // Layer 1 — rows 2-4, cols 1-4
  TilePosition(2,1,1), TilePosition(2,2,1), TilePosition(2,3,1), TilePosition(2,4,1),
  TilePosition(3,1,1), TilePosition(3,2,1), TilePosition(3,3,1), TilePosition(3,4,1),
  TilePosition(4,1,1), TilePosition(4,2,1), TilePosition(4,3,1), TilePosition(4,4,1),
  // Layer 2 — rows 2-4, cols 2-3
  TilePosition(2,2,2), TilePosition(2,3,2),
  TilePosition(3,2,2), TilePosition(3,3,2),
  TilePosition(4,2,2), TilePosition(4,3,2),
  // Layer 3 — rows 2-3, cols 2-3
  TilePosition(2,2,3), TilePosition(2,3,3),
  TilePosition(3,2,3), TilePosition(3,3,3),
];

// Level 13 — 68 tiles, 4 layers
// Layer 0: 6×7 = 42   Layer 1: 4×4 = 16   Layer 2: 3×2 = 6   Layer 3: 2×2 = 4
const level13Layout = [
  // Layer 0 — 6×7
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0), TilePosition(0,3,0),
  TilePosition(0,4,0), TilePosition(0,5,0), TilePosition(0,6,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0), TilePosition(1,3,0),
  TilePosition(1,4,0), TilePosition(1,5,0), TilePosition(1,6,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0), TilePosition(2,3,0),
  TilePosition(2,4,0), TilePosition(2,5,0), TilePosition(2,6,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0), TilePosition(3,3,0),
  TilePosition(3,4,0), TilePosition(3,5,0), TilePosition(3,6,0),
  TilePosition(4,0,0), TilePosition(4,1,0), TilePosition(4,2,0), TilePosition(4,3,0),
  TilePosition(4,4,0), TilePosition(4,5,0), TilePosition(4,6,0),
  TilePosition(5,0,0), TilePosition(5,1,0), TilePosition(5,2,0), TilePosition(5,3,0),
  TilePosition(5,4,0), TilePosition(5,5,0), TilePosition(5,6,0),
  // Layer 1 — rows 1-4, cols 1-4
  TilePosition(1,1,1), TilePosition(1,2,1), TilePosition(1,3,1), TilePosition(1,4,1),
  TilePosition(2,1,1), TilePosition(2,2,1), TilePosition(2,3,1), TilePosition(2,4,1),
  TilePosition(3,1,1), TilePosition(3,2,1), TilePosition(3,3,1), TilePosition(3,4,1),
  TilePosition(4,1,1), TilePosition(4,2,1), TilePosition(4,3,1), TilePosition(4,4,1),
  // Layer 2 — rows 2-4, cols 2-3
  TilePosition(2,2,2), TilePosition(2,3,2),
  TilePosition(3,2,2), TilePosition(3,3,2),
  TilePosition(4,2,2), TilePosition(4,3,2),
  // Layer 3 — rows 2-3, cols 2-3
  TilePosition(2,2,3), TilePosition(2,3,3),
  TilePosition(3,2,3), TilePosition(3,3,3),
];

// Level 14 — 72 tiles, 5 layers
// Layer 0: 6×7=42  Layer 1: 4×4=16  Layer 2: 4×2=8  Layer 3: 2×2=4  Layer 4: 2
const level14Layout = [
  // Layer 0 — 6×7
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0), TilePosition(0,3,0),
  TilePosition(0,4,0), TilePosition(0,5,0), TilePosition(0,6,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0), TilePosition(1,3,0),
  TilePosition(1,4,0), TilePosition(1,5,0), TilePosition(1,6,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0), TilePosition(2,3,0),
  TilePosition(2,4,0), TilePosition(2,5,0), TilePosition(2,6,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0), TilePosition(3,3,0),
  TilePosition(3,4,0), TilePosition(3,5,0), TilePosition(3,6,0),
  TilePosition(4,0,0), TilePosition(4,1,0), TilePosition(4,2,0), TilePosition(4,3,0),
  TilePosition(4,4,0), TilePosition(4,5,0), TilePosition(4,6,0),
  TilePosition(5,0,0), TilePosition(5,1,0), TilePosition(5,2,0), TilePosition(5,3,0),
  TilePosition(5,4,0), TilePosition(5,5,0), TilePosition(5,6,0),
  // Layer 1 — rows 1-4, cols 1-4
  TilePosition(1,1,1), TilePosition(1,2,1), TilePosition(1,3,1), TilePosition(1,4,1),
  TilePosition(2,1,1), TilePosition(2,2,1), TilePosition(2,3,1), TilePosition(2,4,1),
  TilePosition(3,1,1), TilePosition(3,2,1), TilePosition(3,3,1), TilePosition(3,4,1),
  TilePosition(4,1,1), TilePosition(4,2,1), TilePosition(4,3,1), TilePosition(4,4,1),
  // Layer 2 — rows 1-4, cols 2-3
  TilePosition(1,2,2), TilePosition(1,3,2),
  TilePosition(2,2,2), TilePosition(2,3,2),
  TilePosition(3,2,2), TilePosition(3,3,2),
  TilePosition(4,2,2), TilePosition(4,3,2),
  // Layer 3 — rows 2-3, cols 2-3
  TilePosition(2,2,3), TilePosition(2,3,3),
  TilePosition(3,2,3), TilePosition(3,3,3),
  // Layer 4 — rows 2-3, col 2
  TilePosition(2,2,4),
  TilePosition(3,2,4),
];

// Level 15 — 76 tiles, 5 layers
// Layer 0: 6×8=48  Layer 1: 4×4=16  Layer 2: 3×2=6  Layer 3: 2×2=4  Layer 4: 2
const level15Layout = [
  // Layer 0 — 6×8
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0), TilePosition(0,3,0),
  TilePosition(0,4,0), TilePosition(0,5,0), TilePosition(0,6,0), TilePosition(0,7,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0), TilePosition(1,3,0),
  TilePosition(1,4,0), TilePosition(1,5,0), TilePosition(1,6,0), TilePosition(1,7,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0), TilePosition(2,3,0),
  TilePosition(2,4,0), TilePosition(2,5,0), TilePosition(2,6,0), TilePosition(2,7,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0), TilePosition(3,3,0),
  TilePosition(3,4,0), TilePosition(3,5,0), TilePosition(3,6,0), TilePosition(3,7,0),
  TilePosition(4,0,0), TilePosition(4,1,0), TilePosition(4,2,0), TilePosition(4,3,0),
  TilePosition(4,4,0), TilePosition(4,5,0), TilePosition(4,6,0), TilePosition(4,7,0),
  TilePosition(5,0,0), TilePosition(5,1,0), TilePosition(5,2,0), TilePosition(5,3,0),
  TilePosition(5,4,0), TilePosition(5,5,0), TilePosition(5,6,0), TilePosition(5,7,0),
  // Layer 1 — rows 1-4, cols 2-5
  TilePosition(1,2,1), TilePosition(1,3,1), TilePosition(1,4,1), TilePosition(1,5,1),
  TilePosition(2,2,1), TilePosition(2,3,1), TilePosition(2,4,1), TilePosition(2,5,1),
  TilePosition(3,2,1), TilePosition(3,3,1), TilePosition(3,4,1), TilePosition(3,5,1),
  TilePosition(4,2,1), TilePosition(4,3,1), TilePosition(4,4,1), TilePosition(4,5,1),
  // Layer 2 — rows 2-4, cols 3-4
  TilePosition(2,3,2), TilePosition(2,4,2),
  TilePosition(3,3,2), TilePosition(3,4,2),
  TilePosition(4,3,2), TilePosition(4,4,2),
  // Layer 3 — rows 2-3, cols 3-4
  TilePosition(2,3,3), TilePosition(2,4,3),
  TilePosition(3,3,3), TilePosition(3,4,3),
  // Layer 4 — rows 2-3, col 3
  TilePosition(2,3,4),
  TilePosition(3,3,4),
];

// Level 16 — 80 tiles, 5 layers
// Layer 0: 6×8=48  Layer 1: 4×4=16  Layer 2: 4×2=8  Layer 3: 2×2=4  Layer 4: 2×2=4
const level16Layout = [
  // Layer 0 — 6×8
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0), TilePosition(0,3,0),
  TilePosition(0,4,0), TilePosition(0,5,0), TilePosition(0,6,0), TilePosition(0,7,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0), TilePosition(1,3,0),
  TilePosition(1,4,0), TilePosition(1,5,0), TilePosition(1,6,0), TilePosition(1,7,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0), TilePosition(2,3,0),
  TilePosition(2,4,0), TilePosition(2,5,0), TilePosition(2,6,0), TilePosition(2,7,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0), TilePosition(3,3,0),
  TilePosition(3,4,0), TilePosition(3,5,0), TilePosition(3,6,0), TilePosition(3,7,0),
  TilePosition(4,0,0), TilePosition(4,1,0), TilePosition(4,2,0), TilePosition(4,3,0),
  TilePosition(4,4,0), TilePosition(4,5,0), TilePosition(4,6,0), TilePosition(4,7,0),
  TilePosition(5,0,0), TilePosition(5,1,0), TilePosition(5,2,0), TilePosition(5,3,0),
  TilePosition(5,4,0), TilePosition(5,5,0), TilePosition(5,6,0), TilePosition(5,7,0),
  // Layer 1 — rows 1-4, cols 2-5
  TilePosition(1,2,1), TilePosition(1,3,1), TilePosition(1,4,1), TilePosition(1,5,1),
  TilePosition(2,2,1), TilePosition(2,3,1), TilePosition(2,4,1), TilePosition(2,5,1),
  TilePosition(3,2,1), TilePosition(3,3,1), TilePosition(3,4,1), TilePosition(3,5,1),
  TilePosition(4,2,1), TilePosition(4,3,1), TilePosition(4,4,1), TilePosition(4,5,1),
  // Layer 2 — rows 1-4, cols 3-4
  TilePosition(1,3,2), TilePosition(1,4,2),
  TilePosition(2,3,2), TilePosition(2,4,2),
  TilePosition(3,3,2), TilePosition(3,4,2),
  TilePosition(4,3,2), TilePosition(4,4,2),
  // Layer 3 — rows 2-3, cols 3-4
  TilePosition(2,3,3), TilePosition(2,4,3),
  TilePosition(3,3,3), TilePosition(3,4,3),
  // Layer 4 — rows 2-3, cols 3-4
  TilePosition(2,3,4), TilePosition(2,4,4),
  TilePosition(3,3,4), TilePosition(3,4,4),
];

// Level 17 — 84 tiles, 5 layers
// Layer 0: 6×8=48  Layer 1: 5×4=20  Layer 2: 4×2=8  Layer 3: 2×2=4  Layer 4: 2×2=4
const level17Layout = [
  // Layer 0 — 6×8
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0), TilePosition(0,3,0),
  TilePosition(0,4,0), TilePosition(0,5,0), TilePosition(0,6,0), TilePosition(0,7,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0), TilePosition(1,3,0),
  TilePosition(1,4,0), TilePosition(1,5,0), TilePosition(1,6,0), TilePosition(1,7,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0), TilePosition(2,3,0),
  TilePosition(2,4,0), TilePosition(2,5,0), TilePosition(2,6,0), TilePosition(2,7,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0), TilePosition(3,3,0),
  TilePosition(3,4,0), TilePosition(3,5,0), TilePosition(3,6,0), TilePosition(3,7,0),
  TilePosition(4,0,0), TilePosition(4,1,0), TilePosition(4,2,0), TilePosition(4,3,0),
  TilePosition(4,4,0), TilePosition(4,5,0), TilePosition(4,6,0), TilePosition(4,7,0),
  TilePosition(5,0,0), TilePosition(5,1,0), TilePosition(5,2,0), TilePosition(5,3,0),
  TilePosition(5,4,0), TilePosition(5,5,0), TilePosition(5,6,0), TilePosition(5,7,0),
  // Layer 1 — rows 1-5, cols 2-5
  TilePosition(1,2,1), TilePosition(1,3,1), TilePosition(1,4,1), TilePosition(1,5,1),
  TilePosition(2,2,1), TilePosition(2,3,1), TilePosition(2,4,1), TilePosition(2,5,1),
  TilePosition(3,2,1), TilePosition(3,3,1), TilePosition(3,4,1), TilePosition(3,5,1),
  TilePosition(4,2,1), TilePosition(4,3,1), TilePosition(4,4,1), TilePosition(4,5,1),
  TilePosition(5,2,1), TilePosition(5,3,1), TilePosition(5,4,1), TilePosition(5,5,1),
  // Layer 2 — rows 1-4, cols 3-4
  TilePosition(1,3,2), TilePosition(1,4,2),
  TilePosition(2,3,2), TilePosition(2,4,2),
  TilePosition(3,3,2), TilePosition(3,4,2),
  TilePosition(4,3,2), TilePosition(4,4,2),
  // Layer 3 — rows 2-3, cols 3-4
  TilePosition(2,3,3), TilePosition(2,4,3),
  TilePosition(3,3,3), TilePosition(3,4,3),
  // Layer 4 — rows 2-3, cols 3-4
  TilePosition(2,3,4), TilePosition(2,4,4),
  TilePosition(3,3,4), TilePosition(3,4,4),
];

// Level 18 — 88 tiles, 5 layers
// Layer 0: 6×9=54  Layer 1: 4×4=16  Layer 2: 4×2=8  Layer 3: 3×2=6  Layer 4: 2×2=4
const level18Layout = [
  // Layer 0 — 6×9
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0), TilePosition(0,3,0),
  TilePosition(0,4,0), TilePosition(0,5,0), TilePosition(0,6,0), TilePosition(0,7,0), TilePosition(0,8,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0), TilePosition(1,3,0),
  TilePosition(1,4,0), TilePosition(1,5,0), TilePosition(1,6,0), TilePosition(1,7,0), TilePosition(1,8,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0), TilePosition(2,3,0),
  TilePosition(2,4,0), TilePosition(2,5,0), TilePosition(2,6,0), TilePosition(2,7,0), TilePosition(2,8,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0), TilePosition(3,3,0),
  TilePosition(3,4,0), TilePosition(3,5,0), TilePosition(3,6,0), TilePosition(3,7,0), TilePosition(3,8,0),
  TilePosition(4,0,0), TilePosition(4,1,0), TilePosition(4,2,0), TilePosition(4,3,0),
  TilePosition(4,4,0), TilePosition(4,5,0), TilePosition(4,6,0), TilePosition(4,7,0), TilePosition(4,8,0),
  TilePosition(5,0,0), TilePosition(5,1,0), TilePosition(5,2,0), TilePosition(5,3,0),
  TilePosition(5,4,0), TilePosition(5,5,0), TilePosition(5,6,0), TilePosition(5,7,0), TilePosition(5,8,0),
  // Layer 1 — rows 1-4, cols 2-5
  TilePosition(1,2,1), TilePosition(1,3,1), TilePosition(1,4,1), TilePosition(1,5,1),
  TilePosition(2,2,1), TilePosition(2,3,1), TilePosition(2,4,1), TilePosition(2,5,1),
  TilePosition(3,2,1), TilePosition(3,3,1), TilePosition(3,4,1), TilePosition(3,5,1),
  TilePosition(4,2,1), TilePosition(4,3,1), TilePosition(4,4,1), TilePosition(4,5,1),
  // Layer 2 — rows 1-4, cols 3-4
  TilePosition(1,3,2), TilePosition(1,4,2),
  TilePosition(2,3,2), TilePosition(2,4,2),
  TilePosition(3,3,2), TilePosition(3,4,2),
  TilePosition(4,3,2), TilePosition(4,4,2),
  // Layer 3 — rows 2-4, cols 3-4
  TilePosition(2,3,3), TilePosition(2,4,3),
  TilePosition(3,3,3), TilePosition(3,4,3),
  TilePosition(4,3,3), TilePosition(4,4,3),
  // Layer 4 — rows 2-3, cols 3-4
  TilePosition(2,3,4), TilePosition(2,4,4),
  TilePosition(3,3,4), TilePosition(3,4,4),
];

// Level 19 — 92 tiles, 5 layers
// Layer 0: 6×9=54  Layer 1: 5×4=20  Layer 2: 4×2=8  Layer 3: 3×2=6  Layer 4: 2×2=4
const level19Layout = [
  // Layer 0 — 6×9
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0), TilePosition(0,3,0),
  TilePosition(0,4,0), TilePosition(0,5,0), TilePosition(0,6,0), TilePosition(0,7,0), TilePosition(0,8,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0), TilePosition(1,3,0),
  TilePosition(1,4,0), TilePosition(1,5,0), TilePosition(1,6,0), TilePosition(1,7,0), TilePosition(1,8,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0), TilePosition(2,3,0),
  TilePosition(2,4,0), TilePosition(2,5,0), TilePosition(2,6,0), TilePosition(2,7,0), TilePosition(2,8,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0), TilePosition(3,3,0),
  TilePosition(3,4,0), TilePosition(3,5,0), TilePosition(3,6,0), TilePosition(3,7,0), TilePosition(3,8,0),
  TilePosition(4,0,0), TilePosition(4,1,0), TilePosition(4,2,0), TilePosition(4,3,0),
  TilePosition(4,4,0), TilePosition(4,5,0), TilePosition(4,6,0), TilePosition(4,7,0), TilePosition(4,8,0),
  TilePosition(5,0,0), TilePosition(5,1,0), TilePosition(5,2,0), TilePosition(5,3,0),
  TilePosition(5,4,0), TilePosition(5,5,0), TilePosition(5,6,0), TilePosition(5,7,0), TilePosition(5,8,0),
  // Layer 1 — rows 1-5, cols 2-5
  TilePosition(1,2,1), TilePosition(1,3,1), TilePosition(1,4,1), TilePosition(1,5,1),
  TilePosition(2,2,1), TilePosition(2,3,1), TilePosition(2,4,1), TilePosition(2,5,1),
  TilePosition(3,2,1), TilePosition(3,3,1), TilePosition(3,4,1), TilePosition(3,5,1),
  TilePosition(4,2,1), TilePosition(4,3,1), TilePosition(4,4,1), TilePosition(4,5,1),
  TilePosition(5,2,1), TilePosition(5,3,1), TilePosition(5,4,1), TilePosition(5,5,1),
  // Layer 2 — rows 1-4, cols 3-4
  TilePosition(1,3,2), TilePosition(1,4,2),
  TilePosition(2,3,2), TilePosition(2,4,2),
  TilePosition(3,3,2), TilePosition(3,4,2),
  TilePosition(4,3,2), TilePosition(4,4,2),
  // Layer 3 — rows 2-4, cols 3-4
  TilePosition(2,3,3), TilePosition(2,4,3),
  TilePosition(3,3,3), TilePosition(3,4,3),
  TilePosition(4,3,3), TilePosition(4,4,3),
  // Layer 4 — rows 2-3, cols 3-4
  TilePosition(2,3,4), TilePosition(2,4,4),
  TilePosition(3,3,4), TilePosition(3,4,4),
];

// Level 20 — 96 tiles, 6 layers
// Layer 0: 6×9=54  Layer 1: 5×4=20  Layer 2: 4×2=8  Layer 3: 3×2=6  Layer 4: 2×2=4  Layer 5: 2×2=4
const level20Layout = [
  // Layer 0 — 6×9
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0), TilePosition(0,3,0),
  TilePosition(0,4,0), TilePosition(0,5,0), TilePosition(0,6,0), TilePosition(0,7,0), TilePosition(0,8,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0), TilePosition(1,3,0),
  TilePosition(1,4,0), TilePosition(1,5,0), TilePosition(1,6,0), TilePosition(1,7,0), TilePosition(1,8,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0), TilePosition(2,3,0),
  TilePosition(2,4,0), TilePosition(2,5,0), TilePosition(2,6,0), TilePosition(2,7,0), TilePosition(2,8,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0), TilePosition(3,3,0),
  TilePosition(3,4,0), TilePosition(3,5,0), TilePosition(3,6,0), TilePosition(3,7,0), TilePosition(3,8,0),
  TilePosition(4,0,0), TilePosition(4,1,0), TilePosition(4,2,0), TilePosition(4,3,0),
  TilePosition(4,4,0), TilePosition(4,5,0), TilePosition(4,6,0), TilePosition(4,7,0), TilePosition(4,8,0),
  TilePosition(5,0,0), TilePosition(5,1,0), TilePosition(5,2,0), TilePosition(5,3,0),
  TilePosition(5,4,0), TilePosition(5,5,0), TilePosition(5,6,0), TilePosition(5,7,0), TilePosition(5,8,0),
  // Layer 1 — rows 1-5, cols 2-5
  TilePosition(1,2,1), TilePosition(1,3,1), TilePosition(1,4,1), TilePosition(1,5,1),
  TilePosition(2,2,1), TilePosition(2,3,1), TilePosition(2,4,1), TilePosition(2,5,1),
  TilePosition(3,2,1), TilePosition(3,3,1), TilePosition(3,4,1), TilePosition(3,5,1),
  TilePosition(4,2,1), TilePosition(4,3,1), TilePosition(4,4,1), TilePosition(4,5,1),
  TilePosition(5,2,1), TilePosition(5,3,1), TilePosition(5,4,1), TilePosition(5,5,1),
  // Layer 2 — rows 1-4, cols 3-4
  TilePosition(1,3,2), TilePosition(1,4,2),
  TilePosition(2,3,2), TilePosition(2,4,2),
  TilePosition(3,3,2), TilePosition(3,4,2),
  TilePosition(4,3,2), TilePosition(4,4,2),
  // Layer 3 — rows 2-4, cols 3-4
  TilePosition(2,3,3), TilePosition(2,4,3),
  TilePosition(3,3,3), TilePosition(3,4,3),
  TilePosition(4,3,3), TilePosition(4,4,3),
  // Layer 4 — rows 2-3, cols 3-4
  TilePosition(2,3,4), TilePosition(2,4,4),
  TilePosition(3,3,4), TilePosition(3,4,4),
  // Layer 5 — rows 2-3, cols 3-4
  TilePosition(2,3,5), TilePosition(2,4,5),
  TilePosition(3,3,5), TilePosition(3,4,5),
];

// ─────────────────────────────────────────────────────────────────────────────

// Level 10 — 56 tiles, 4 layers
// Layer 0: 5×7 = 35   Layer 1: 3×4 = 12   Layer 2: 3×2 = 6   Layer 3: 3   Total: 56
const level10Layout = [
  TilePosition(0,0,0), TilePosition(0,1,0), TilePosition(0,2,0),
  TilePosition(0,3,0), TilePosition(0,4,0), TilePosition(0,5,0), TilePosition(0,6,0),
  TilePosition(1,0,0), TilePosition(1,1,0), TilePosition(1,2,0),
  TilePosition(1,3,0), TilePosition(1,4,0), TilePosition(1,5,0), TilePosition(1,6,0),
  TilePosition(2,0,0), TilePosition(2,1,0), TilePosition(2,2,0),
  TilePosition(2,3,0), TilePosition(2,4,0), TilePosition(2,5,0), TilePosition(2,6,0),
  TilePosition(3,0,0), TilePosition(3,1,0), TilePosition(3,2,0),
  TilePosition(3,3,0), TilePosition(3,4,0), TilePosition(3,5,0), TilePosition(3,6,0),
  TilePosition(4,0,0), TilePosition(4,1,0), TilePosition(4,2,0),
  TilePosition(4,3,0), TilePosition(4,4,0), TilePosition(4,5,0), TilePosition(4,6,0),
  TilePosition(1,1,1), TilePosition(1,2,1), TilePosition(1,3,1), TilePosition(1,4,1),
  TilePosition(2,1,1), TilePosition(2,2,1), TilePosition(2,3,1), TilePosition(2,4,1),
  TilePosition(3,1,1), TilePosition(3,2,1), TilePosition(3,3,1), TilePosition(3,4,1),
  TilePosition(1,1,2), TilePosition(1,2,2),
  TilePosition(2,1,2), TilePosition(2,2,2),
  TilePosition(3,1,2), TilePosition(3,2,2),
  TilePosition(1,1,3), TilePosition(2,1,3), TilePosition(3,1,3),
];
