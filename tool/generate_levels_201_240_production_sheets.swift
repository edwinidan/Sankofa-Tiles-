import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let directory = root.appendingPathComponent(
  "artifacts/layout-previews/levels-201-240-production"
)
let candidateDirectory = root.appendingPathComponent(
  "artifacts/layout-previews/levels-201-240-candidates"
)
let background = NSColor(deviceRed: 0.025, green: 0.055, blue: 0.045, alpha: 1)

func save(_ image: NSImage, _ name: String) throws {
  let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)!
  try bitmap.representation(using: .png, properties: [:])!
    .write(to: directory.appendingPathComponent(name))
}

func label(_ text: String, rect: NSRect, size: CGFloat = 10, bold: Bool = false) {
  let paragraph = NSMutableParagraphStyle()
  paragraph.alignment = .center
  paragraph.lineBreakMode = .byWordWrapping
  text.draw(
    in: rect,
    withAttributes: [
      .font: bold ? NSFont.boldSystemFont(ofSize: size) : NSFont.systemFont(ofSize: size),
      .foregroundColor: NSColor.white,
      .paragraphStyle: paragraph,
    ]
  )
}

func sheet(
  levels: [Int],
  name: String,
  suffix: String = "390x844",
  columns: Int = 5,
  title: String
) throws {
  let preview = NSSize(width: 180, height: 390)
  let labelHeight: CGFloat = 34
  let titleHeight: CGFloat = 50
  let gap: CGFloat = 10
  let rows = Int(ceil(Double(levels.count) / Double(columns)))
  let size = NSSize(
    width: gap + CGFloat(columns) * (preview.width + gap),
    height: titleHeight + gap + CGFloat(rows) * (preview.height + labelHeight + gap)
  )
  let canvas = NSImage(size: size)
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: size).fill()
  label(title, rect: NSRect(x: 10, y: size.height - 42, width: size.width - 20, height: 32), size: 19, bold: true)
  for (index, level) in levels.enumerated() {
    let column = index % columns
    let row = index / columns
    let x = gap + CGFloat(column) * (preview.width + gap)
    let y = size.height - titleHeight - gap
      - CGFloat(row + 1) * (preview.height + labelHeight + gap) + labelHeight
    let url = directory.appendingPathComponent("level-\(level)_\(suffix).png")
    guard let image = NSImage(contentsOf: url) else {
      fatalError("Missing production preview for Level \(level)")
    }
    image.draw(in: NSRect(x: x, y: y, width: preview.width, height: preview.height))
    label("Production Level \(level)", rect: NSRect(x: x, y: y - 28, width: preview.width, height: 24), size: 10, bold: true)
  }
  canvas.unlockFocus()
  try save(canvas, name)
}

func pairEvidence(
  leftLevel: Int,
  rightLevel: Int,
  name: String,
  title: String,
  footer: String
) throws {
  let canvas = NSImage(size: NSSize(width: 800, height: 1000))
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: canvas.size).fill()
  label(title, rect: NSRect(x: 20, y: 940, width: 760, height: 40), size: 22, bold: true)
  for (index, level) in [leftLevel, rightLevel].enumerated() {
    let image = NSImage(contentsOf: directory.appendingPathComponent("level-\(level)_390x844.png"))!
    image.draw(in: NSRect(x: 25 + index * 395, y: 105, width: 365, height: 789))
    label("Level \(level)", rect: NSRect(x: 25 + index * 395, y: 67, width: 365, height: 30), size: 15, bold: true)
  }
  label("→", rect: NSRect(x: 365, y: 440, width: 70, height: 50), size: 34, bold: true)
  label(footer, rect: NSRect(x: 30, y: 18, width: 740, height: 42), size: 12)
  canvas.unlockFocus()
  try save(canvas, name)
}

try sheet(
  levels: Array(201...210),
  name: "levels-201-210-contact-sheet.png",
  title: "Production Levels 201–210"
)
try sheet(
  levels: Array(211...220),
  name: "levels-211-220-contact-sheet.png",
  title: "Production Levels 211–220"
)
try sheet(
  levels: Array(221...230),
  name: "levels-221-230-contact-sheet.png",
  title: "Production Levels 221–230"
)
try sheet(
  levels: Array(231...240),
  name: "levels-231-240-contact-sheet.png",
  title: "Production Levels 231–240"
)
try sheet(
  levels: Array(201...220),
  name: "chapter-11-production-overview.png",
  title: "Chapter 11 · The Journey Reopens · Levels 201–220"
)
try sheet(
  levels: Array(221...240),
  name: "chapter-12-production-overview.png",
  title: "Chapter 12 · Living Memory · Levels 221–240"
)
try sheet(
  levels: Array(201...240),
  name: "levels-201-240-production-overview.png",
  title: "Levels 201–240 · Production Board Overview"
)
try sheet(
  levels: Array(201...240),
  name: "levels-201-240-production-silhouette-overview.png",
  suffix: "silhouette",
  title: "Levels 201–240 · Production Silhouette Overview"
)

try pairEvidence(
  leftLevel: 200,
  rightLevel: 201,
  name: "level-200-to-201-transition-evidence.png",
  title: "Implemented campaign transition · Level 200 → 201",
  footer: "A schema-v4 Level-200 veteran resolves Level 201 as the next playable level."
)
try pairEvidence(
  leftLevel: 220,
  rightLevel: 221,
  name: "level-220-to-221-transition-evidence.png",
  title: "Chapter transition · Level 220 → 221",
  footer: "Completing Chapter 11 unlocks Chapter 12 without renumbering progress."
)
try pairEvidence(
  leftLevel: 220,
  rightLevel: 240,
  name: "level-220-vs-240-finale-comparison.png",
  title: "Finale hierarchy · Level 220 vs Level 240",
  footer: "Level 240 uses twin archive wings, a ceremonial opening, crown tiers, and a broad foundation."
)

func level240OldNew() throws {
  let canvas = NSImage(size: NSSize(width: 800, height: 1000))
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: canvas.size).fill()
  label("The Living Archive · final Level 240 refinement", rect: NSRect(x: 20, y: 940, width: 760, height: 40), size: 22, bold: true)
  let oldImage = NSImage(contentsOf: candidateDirectory.appendingPathComponent("level-240-before-final-refinement_390x844.png"))!
  let newImage = NSImage(contentsOf: directory.appendingPathComponent("level-240_390x844.png"))!
  oldImage.draw(in: NSRect(x: 25, y: 105, width: 365, height: 789))
  newImage.draw(in: NSRect(x: 410, y: 105, width: 365, height: 789))
  label("Before · dense block", rect: NSRect(x: 25, y: 67, width: 365, height: 30), size: 15, bold: true)
  label("Final · archive sanctuary", rect: NSRect(x: 410, y: 67, width: 365, height: 30), size: 15, bold: true)
  label("Twin wings · major opening · secondary voids · tiered crown · broad foundation", rect: NSRect(x: 30, y: 18, width: 740, height: 42), size: 12)
  canvas.unlockFocus()
  try save(canvas, "level-240-old-vs-new-comparison.png")
}

func finaleComparison() throws {
  let levels = [200, 220, 240]
  let canvas = NSImage(size: NSSize(width: 590, height: 475))
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: canvas.size).fill()
  for (index, level) in levels.enumerated() {
    let image = NSImage(contentsOf: directory.appendingPathComponent("level-\(level)_390x844.png"))!
    image.draw(in: NSRect(x: 10 + index * 195, y: 65, width: 180, height: 390))
    label("Level \(level)", rect: NSRect(x: 10 + index * 195, y: 15, width: 180, height: 40), size: 13, bold: true)
  }
  canvas.unlockFocus()
  try save(canvas, "production-finale-comparison-levels-200-220-240.png")
}

try level240OldNew()
try finaleComparison()
