import AppKit
import Foundation

struct PortraitCandidate {
  let level: Int
  let id: String
  let name: String
  let tiles: Int
  let heightOccupancy: String
  let widthOccupancy: String
  let tileWidth: String
}

let candidates = [
  PortraitCandidate(level: 6, id: "batchBOpenCourtyard01", name: "Open Courtyard", tiles: 36, heightOccupancy: "73.5%", widthOccupancy: "75.3%", tileWidth: "64 px"),
  PortraitCandidate(level: 8, id: "batchBTempleGate01", name: "Wisdom Gate", tiles: 46, heightOccupancy: "73.5%", widthOccupancy: "75.3%", tileWidth: "64 px"),
  PortraitCandidate(level: 13, id: "batchBShrineSteps01", name: "Temple Steps", tiles: 54, heightOccupancy: "73.5%", widthOccupancy: "75.3%", tileWidth: "64 px"),
  PortraitCandidate(level: 14, id: "batchBWisdomStaircase01", name: "Wisdom Staircase", tiles: 48, heightOccupancy: "73.5%", widthOccupancy: "82.6%", tileWidth: "64 px"),
  PortraitCandidate(level: 16, id: "batchBOpenRing01", name: "Sacred Grove", tiles: 52, heightOccupancy: "73.5%", widthOccupancy: "75.3%", tileWidth: "64 px"),
  PortraitCandidate(level: 18, id: "batchBAncestralGate01", name: "Ancestral Gate", tiles: 60, heightOccupancy: "73.5%", widthOccupancy: "75.3%", tileWidth: "64 px"),
  PortraitCandidate(level: 20, id: "batchBRaisedCourtyard01", name: "Raised Courtyard", tiles: 62, heightOccupancy: "73.5%", widthOccupancy: "75.3%", tileWidth: "64 px"),
]

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let previewDir = root.appendingPathComponent("artifacts/layout-previews/batch-b-portrait-pass")
let thumbWidth: CGFloat = 180
let thumbHeight: CGFloat = 390
let labelHeight: CGFloat = 84
let gap: CGFloat = 12

func makeSheet(name: String, diagnostic: Bool) throws {
  let columns = 4
  let rows = 2
  let width = gap + CGFloat(columns) * (thumbWidth + gap)
  let height = gap + CGFloat(rows) * (thumbHeight + labelHeight + gap)
  let canvas = NSImage(size: NSSize(width: width, height: height))
  canvas.lockFocus()
  NSColor(calibratedRed: 0.055, green: 0.08, blue: 0.07, alpha: 1).setFill()
  NSRect(x: 0, y: 0, width: width, height: height).fill()
  for (index, item) in candidates.enumerated() {
    let col = index % columns
    let row = index / columns
    let x = gap + CGFloat(col) * (thumbWidth + gap)
    let top = height - gap - CGFloat(row) * (thumbHeight + labelHeight + gap)
    let imageY = top - thumbHeight
    let suffix = diagnostic ? "diagnostic" : "390x844"
    let path = previewDir.appendingPathComponent("\(item.id)_\(suffix).png").path
    guard let image = NSImage(contentsOfFile: path) else {
      throw NSError(domain: "PortraitSheet", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing \(path)"])
    }
    NSColor(calibratedRed: 0.055, green: 0.27, blue: 0.24, alpha: 1).setFill()
    NSRect(x: x, y: imageY, width: thumbWidth, height: thumbHeight).fill()
    image.draw(in: NSRect(x: x, y: imageY, width: thumbWidth, height: thumbHeight),
               from: .zero, operation: .sourceOver, fraction: 1)
    let label = "L\(item.level) · \(item.id)\n\(item.name) · \(item.tiles) tiles\nH \(item.heightOccupancy) · W \(item.widthOccupancy) · tile \(item.tileWidth)"
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    label.draw(
      in: NSRect(x: x, y: imageY - labelHeight, width: thumbWidth, height: labelHeight - 4),
      withAttributes: [
        .font: NSFont.systemFont(ofSize: 9.5, weight: .medium),
        .foregroundColor: NSColor(calibratedWhite: 0.94, alpha: 1),
        .paragraphStyle: paragraph,
      ]
    )
  }
  canvas.unlockFocus()
  guard let tiff = canvas.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let png = bitmap.representation(using: .png, properties: [:]) else { return }
  try png.write(to: previewDir.appendingPathComponent(name))
}

try makeSheet(name: "portrait-anchor-contact-sheet.png", diagnostic: false)
try makeSheet(name: "portrait-anchor-diagnostic-contact-sheet.png", diagnostic: true)
