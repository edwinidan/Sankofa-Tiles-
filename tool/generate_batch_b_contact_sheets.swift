import AppKit
import Foundation

struct Candidate {
  let level: Int
  let id: String
  let name: String
  let tiles: Int
  let layers: Int
}

let candidates = [
  Candidate(level: 6, id: "batchBOpenCourtyard01", name: "Open Courtyard", tiles: 32, layers: 3),
  Candidate(level: 7, id: "batchBRiverPath01", name: "River Lesson", tiles: 36, layers: 3),
  Candidate(level: 8, id: "batchBTempleGate01", name: "Wisdom Gate", tiles: 42, layers: 3),
  Candidate(level: 9, id: "batchBGatheringWings01", name: "Gathering Wings", tiles: 44, layers: 3),
  Candidate(level: 10, id: "batchBTwinBridge01", name: "Elder Twin Bridge", tiles: 48, layers: 3),
  Candidate(level: 11, id: "batchBSmallTurtle01", name: "Heritage Turtle", tiles: 52, layers: 3),
  Candidate(level: 12, id: "batchBButterfly01", name: "Butterfly Path", tiles: 50, layers: 3),
  Candidate(level: 13, id: "batchBShrineSteps01", name: "Temple Steps", tiles: 52, layers: 3),
  Candidate(level: 14, id: "batchBWisdomStaircase01", name: "Wisdom Staircase", tiles: 46, layers: 3),
  Candidate(level: 15, id: "batchBCrown01", name: "Ancestral Crown", tiles: 52, layers: 3),
  Candidate(level: 16, id: "batchBOpenRing01", name: "Sacred Grove", tiles: 46, layers: 3),
  Candidate(level: 17, id: "batchBRoyalStool01", name: "Golden Stool", tiles: 56, layers: 3),
  Candidate(level: 18, id: "batchBAncestralGate01", name: "Ancestral Gate", tiles: 58, layers: 3),
  Candidate(level: 19, id: "batchBTwinTowers01", name: "Twin Houses", tiles: 62, layers: 3),
  Candidate(level: 20, id: "batchBRaisedCourtyard01", name: "Raised Courtyard", tiles: 62, layers: 3),
]

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let previewDir = root.appendingPathComponent("artifacts/layout-previews/batch-b")
let thumbWidth: CGFloat = 180
let thumbHeight: CGFloat = 390
let labelHeight: CGFloat = 72
let gap: CGFloat = 12

func makeSheet(_ items: [Candidate], name: String, diagnostic: Bool = false, columns: Int = 5) throws {
  let rows = Int(ceil(Double(items.count) / Double(columns)))
  let width = gap + CGFloat(columns) * (thumbWidth + gap)
  let height = gap + CGFloat(rows) * (thumbHeight + labelHeight + gap)
  let canvas = NSImage(size: NSSize(width: width, height: height))
  canvas.lockFocus()
  NSColor(calibratedRed: 0.055, green: 0.08, blue: 0.07, alpha: 1).setFill()
  NSRect(x: 0, y: 0, width: width, height: height).fill()

  for (index, item) in items.enumerated() {
    let col = index % columns
    let row = index / columns
    let x = gap + CGFloat(col) * (thumbWidth + gap)
    let top = height - gap - CGFloat(row) * (thumbHeight + labelHeight + gap)
    let imageY = top - thumbHeight
    let suffix = diagnostic ? "diagnostic" : "390x844"
    let path = previewDir.appendingPathComponent("\(item.id)_\(suffix).png").path
    guard let image = NSImage(contentsOfFile: path) else {
      throw NSError(domain: "BatchBContactSheet", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing \(path)"])
    }
    NSColor(calibratedRed: 0.055, green: 0.27, blue: 0.24, alpha: 1).setFill()
    NSRect(x: x, y: imageY, width: thumbWidth, height: thumbHeight).fill()
    image.draw(in: NSRect(x: x, y: imageY, width: thumbWidth, height: thumbHeight),
               from: .zero, operation: .sourceOver, fraction: 1)
    let label = "L\(item.level) · \(item.id)\n\(item.name)\n\(item.tiles) tiles · \(item.layers) layers"
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    let attributes: [NSAttributedString.Key: Any] = [
      .font: NSFont.systemFont(ofSize: 10, weight: .medium),
      .foregroundColor: NSColor(calibratedWhite: 0.93, alpha: 1),
      .paragraphStyle: style,
    ]
    label.draw(in: NSRect(x: x, y: imageY - labelHeight, width: thumbWidth, height: labelHeight - 4), withAttributes: attributes)
  }
  canvas.unlockFocus()
  guard let tiff = canvas.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let png = bitmap.representation(using: .png, properties: [:]) else { return }
  try png.write(to: previewDir.appendingPathComponent(name))
}

try makeSheet(Array(candidates[0..<5]), name: "contact-sheet-a-levels-6-10.png")
try makeSheet(Array(candidates[5..<10]), name: "contact-sheet-b-levels-11-15.png")
try makeSheet(Array(candidates[10..<15]), name: "contact-sheet-c-levels-16-20.png")
try makeSheet(candidates, name: "diagnostic-summary-levels-6-20.png", diagnostic: true, columns: 5)
