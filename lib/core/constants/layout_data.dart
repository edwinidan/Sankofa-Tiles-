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
