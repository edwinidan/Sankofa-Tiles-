import AppKit
import Foundation

struct Item {
  let level: Int
  let id: String
  let name: String
  let family: String
  let classification: String
  let tiles: String
  let width: Double
  let height: Double
  let tile: String
  let bulk: String
  let fullness: Double
  let centerDensity: Double
  let hullFill: Double
  let emptyArea: Double
  let holes: Int
  let oldBulk: String
  let oldTiles: String
  let oldWidth: Double
  let oldHeight: Double
  let oldFullness: Double
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let directory = root.appendingPathComponent(
  "artifacts/layout-previews/levels-201-240-candidates"
)
let rows = try String(
  contentsOf: directory.appendingPathComponent("metrics.csv"),
  encoding: .utf8
).split(separator: "\n").dropFirst()
let items = rows.map { row -> Item in
  let fields = row.split(separator: ",", omittingEmptySubsequences: false)
  return Item(
    level: Int(fields[0])!,
    id: String(fields[1]),
    name: String(fields[2]).replacingOccurrences(of: "\"", with: ""),
    family: String(fields[3]).replacingOccurrences(of: "\"", with: ""),
    classification: String(fields[4]).replacingOccurrences(of: "\"", with: ""),
    tiles: String(fields[5]),
    width: Double(fields[9])!,
    height: Double(fields[10])!,
    tile: String(fields[11]),
    bulk: String(fields[23]),
    fullness: Double(fields[24])!,
    centerDensity: Double(fields[25])!,
    hullFill: Double(fields[26])!,
    emptyArea: Double(fields[27])!,
    holes: Int(fields[28])!,
    oldBulk: String(fields[29]),
    oldTiles: String(fields[30]),
    oldWidth: Double(fields[31])!,
    oldHeight: Double(fields[32])!,
    oldFullness: Double(fields[33])!
  )
}

let background = NSColor(deviceRed: 0.025, green: 0.055, blue: 0.045, alpha: 1)
let gold = NSColor(deviceRed: 0.98, green: 0.72, blue: 0.24, alpha: 1)

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
  _ selected: [Item],
  name: String,
  suffix: String = "390x844",
  columns: Int = 5,
  classLabels: Bool = false
) throws {
  let preview = NSSize(width: 180, height: 390)
  let labelHeight: CGFloat = 78
  let gap: CGFloat = 10
  let rowCount = Int(ceil(Double(selected.count) / Double(columns)))
  let size = NSSize(
    width: gap + CGFloat(columns) * (preview.width + gap),
    height: gap + CGFloat(rowCount) * (preview.height + labelHeight + gap)
  )
  let canvas = NSImage(size: size)
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: size).fill()
  for (index, item) in selected.enumerated() {
    let column = index % columns
    let row = index / columns
    let x = gap + CGFloat(column) * (preview.width + gap)
    let y = size.height - gap
      - CGFloat(row + 1) * (preview.height + labelHeight + gap) + labelHeight
    guard let image = NSImage(
      contentsOf: directory.appendingPathComponent("\(item.id)_\(suffix).png")
    ) else { fatalError("Missing preview for \(item.level)") }
    image.draw(in: NSRect(x: x, y: y, width: preview.width, height: preview.height))
    let heading = classLabels ? item.classification : item.name
    label(
      "L\(item.level) · \(heading)\n\(item.family)\n"
        + "\(item.bulk) · \(item.tiles) tiles · \(String(format: "%.1f", item.width))%W · "
        + "\(String(format: "%.1f", item.height))%H · \(item.tile)px",
      rect: NSRect(x: x, y: y - labelHeight, width: preview.width, height: labelHeight),
      size: 8.5
    )
  }
  canvas.unlockFocus()
  try save(canvas, name)
}

for start in stride(from: 0, to: 40, by: 10) {
  try sheet(
    Array(items[start..<start + 10]),
    name: "levels-\(201 + start)-\(210 + start)-contact-sheet.png"
  )
}
try sheet(Array(items[0..<20]), name: "chapter-11-overview.png")
try sheet(Array(items[20..<40]), name: "chapter-12-overview.png")
try sheet(items, name: "levels-201-240-visual-overview.png")
try sheet(items, name: "levels-201-240-silhouette-overview.png", suffix: "silhouette")
try sheet(items, name: "levels-201-240-bulky-portrait-overview.png")
try sheet(items, name: "levels-201-240-bulky-silhouette-overview.png", suffix: "silhouette")
try sheet(
  items,
  name: "coarse-classification-overview.png",
  suffix: "silhouette",
  classLabels: true
)

func comparison() throws {
  let columns = 10
  let preview = NSSize(width: 117, height: 253)
  let labelHeight: CGFloat = 22
  let gap: CGFloat = 5
  let size = NSSize(
    width: gap + CGFloat(columns) * (preview.width + gap),
    height: gap + 6 * (preview.height + labelHeight + gap)
  )
  let canvas = NSImage(size: size)
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: size).fill()
  for level in 181...240 {
    let index = level - 181
    let x = gap + CGFloat(index % columns) * (preview.width + gap)
    let y = size.height - gap
      - CGFloat(index / columns + 1) * (preview.height + labelHeight + gap)
      + labelHeight
    let url: URL
    if level <= 200 {
      url = directory.appendingPathComponent("production-level-\(level)_silhouette.png")
    } else {
      url = directory.appendingPathComponent("\(items[level - 201].id)_silhouette.png")
    }
    NSImage(contentsOf: url)!.draw(in: NSRect(x: x, y: y, width: preview.width, height: preview.height))
    label("L\(level)", rect: NSRect(x: x, y: y - labelHeight, width: preview.width, height: labelHeight), size: 9, bold: true)
  }
  canvas.unlockFocus()
  try save(canvas, "levels-181-240-comparison.png")
}

func finales() throws {
  let levels = [200, 220, 240]
  let canvas = NSImage(size: NSSize(width: 590, height: 475))
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: canvas.size).fill()
  for (index, level) in levels.enumerated() {
    let url = level == 200
      ? directory.appendingPathComponent("production-level-200_390x844.png")
      : directory.appendingPathComponent("\(items[level - 201].id)_390x844.png")
    NSImage(contentsOf: url)!.draw(in: NSRect(x: 10 + index * 195, y: 65, width: 180, height: 390))
    label("Level \(level) finale", rect: NSRect(x: 10 + index * 195, y: 15, width: 180, height: 40), size: 13, bold: true)
  }
  canvas.unlockFocus()
  try save(canvas, "finale-comparison-levels-200-220-240.png")
}

func envelopes() throws {
  let canvas = NSImage(size: NSSize(width: 1200, height: 760))
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: canvas.size).fill()
  label("Levels 201–240 envelope distribution", rect: NSRect(x: 20, y: 700, width: 1160, height: 40), size: 22, bold: true)
  for (index, item) in items.enumerated() {
    let x = 35 + CGFloat(index % 10) * 116
    let row = index / 10
    let baseline = 635 - CGFloat(row) * 160
    let widthHeight: CGFloat = CGFloat(item.width) * 0.85
    let heightHeight: CGFloat = CGFloat(item.height) * 0.85
    gold.setFill()
    NSRect(x: x, y: baseline - widthHeight, width: 38, height: widthHeight).fill()
    NSColor(deviceRed: 0.35, green: 0.72, blue: 0.58, alpha: 1).setFill()
    NSRect(x: x + 43, y: baseline - heightHeight, width: 38, height: heightHeight).fill()
    label("L\(item.level)\nW \(Int(item.width)) · H \(Int(item.height))", rect: NSRect(x: x - 8, y: baseline - 130, width: 105, height: 35), size: 8)
  }
  canvas.unlockFocus()
  try save(canvas, "envelope-distribution-overview.png")
}

try comparison()
try finales()
try envelopes()

func oldNewComparison() throws {
  let columns = 5
  let pairSize = NSSize(width: 224, height: 279)
  let preview = NSSize(width: 105, height: 227)
  let gap: CGFloat = 8
  let rows = 8
  let size = NSSize(
    width: gap + CGFloat(columns) * (pairSize.width + gap),
    height: 52 + CGFloat(rows) * (pairSize.height + gap)
  )
  let canvas = NSImage(size: size)
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: size).fill()
  label("Levels 201–240 · old thin-portrait vs new bulky-portrait silhouettes", rect: NSRect(x: 10, y: size.height - 44, width: size.width - 20, height: 34), size: 19, bold: true)
  for (index, item) in items.enumerated() {
    let column = index % columns
    let row = index / columns
    let x = gap + CGFloat(column) * (pairSize.width + gap)
    let y = size.height - 52 - CGFloat(row + 1) * (pairSize.height + gap) + 48
    let oldURL = directory.appendingPathComponent("legacy-level-\(item.level)_silhouette.png")
    let newURL = directory.appendingPathComponent("\(item.id)_silhouette.png")
    NSImage(contentsOf: oldURL)!.draw(in: NSRect(x: x, y: y, width: preview.width, height: preview.height))
    NSImage(contentsOf: newURL)!.draw(in: NSRect(x: x + 111, y: y, width: preview.width, height: preview.height))
    label(
      "L\(item.level) · \(item.oldBulk) → \(item.bulk)\n"
        + "W \(String(format: "%.0f", item.oldWidth))→\(String(format: "%.0f", item.width))% · "
        + "full \(String(format: "%.0f", item.oldFullness))→\(String(format: "%.0f", item.fullness))",
      rect: NSRect(x: x, y: y - 46, width: pairSize.width, height: 42),
      size: 8.5,
      bold: true
    )
  }
  canvas.unlockFocus()
  try save(canvas, "old-vs-new-bulk-silhouette-comparison.png")
}

func bulkDistribution() throws {
  let categories = ["thin", "medium", "bulky"]
  let oldCounts = categories.map { category in items.filter { $0.oldBulk == category }.count }
  let newCounts = categories.map { category in items.filter { $0.bulk == category }.count }
  let canvas = NSImage(size: NSSize(width: 900, height: 540))
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: canvas.size).fill()
  label("Bulk / fullness distribution · Levels 201–240", rect: NSRect(x: 20, y: 480, width: 860, height: 40), size: 22, bold: true)
  let colors = [NSColor.systemRed, NSColor.systemOrange, NSColor.systemGreen]
  for index in 0..<3 {
    let x = 95 + CGFloat(index) * 270
    let oldHeight = CGFloat(oldCounts[index]) * 10
    let newHeight = CGFloat(newCounts[index]) * 10
    colors[index].withAlphaComponent(0.45).setFill()
    NSRect(x: x, y: 90, width: 78, height: oldHeight).fill()
    colors[index].setFill()
    NSRect(x: x + 92, y: 90, width: 78, height: newHeight).fill()
    label("old \(oldCounts[index])", rect: NSRect(x: x, y: 55, width: 78, height: 25), size: 11)
    label("new \(newCounts[index])", rect: NSRect(x: x + 92, y: 55, width: 78, height: 25), size: 11)
    label(categories[index], rect: NSRect(x: x, y: 25, width: 170, height: 25), size: 14, bold: true)
  }
  canvas.unlockFocus()
  try save(canvas, "bulk-fullness-distribution.png")
}

try oldNewComparison()
try bulkDistribution()
try sheet(items.filter { [201, 206, 212, 217, 223, 229, 234].contains($0.level) }, name: "breather-boards.png", columns: 4)
try sheet(items.filter { [205, 210, 215, 220, 225, 230, 235, 240].contains($0.level) }, name: "showcase-boards.png", columns: 4)
