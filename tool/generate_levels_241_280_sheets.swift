import AppKit
import Foundation

struct Item {
  let level: Int
  let id: String
  let name: String
  let chapter: Int
  let family: String
  let coarseClass: String
  let fullness: String
  let tiles: Int
  let width: Double
  let height: Double
  let tileWidth: Double
  let emptyArea: Double
  let holes: Int
  let largeOpenings: Int
  let breather: Bool
  let showcase: Bool
  let anchor: Bool
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let directory = root.appendingPathComponent(
  "artifacts/layout-previews/levels-241-280-production"
)
let productionDirectory = root.appendingPathComponent(
  "artifacts/layout-previews/levels-201-240-production"
)
let previousCandidateDirectory = root.appendingPathComponent(
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
    chapter: Int(fields[3])!,
    family: String(fields[4]).replacingOccurrences(of: "\"", with: ""),
    coarseClass: String(fields[32]).replacingOccurrences(of: "\"", with: ""),
    fullness: String(fields[6]),
    tiles: Int(fields[7])!,
    width: Double(fields[20])!,
    height: Double(fields[21])!,
    tileWidth: Double(fields[22])!,
    emptyArea: Double(fields[26])!,
    holes: Int(fields[27])!,
    largeOpenings: Int(fields[28])!,
    breather: fields[33] == "true",
    showcase: fields[34] == "true",
    anchor: fields[35] == "true"
  )
}

let background = NSColor(deviceRed: 0.025, green: 0.055, blue: 0.045, alpha: 1)
let gold = NSColor(deviceRed: 0.98, green: 0.72, blue: 0.24, alpha: 1)
let green = NSColor(deviceRed: 0.35, green: 0.72, blue: 0.58, alpha: 1)

func save(_ image: NSImage, _ name: String) throws {
  let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)!
  try bitmap.representation(using: .png, properties: [:])!
    .write(to: directory.appendingPathComponent(name))
}

func label(
  _ text: String,
  rect: NSRect,
  size: CGFloat = 10,
  bold: Bool = false,
  color: NSColor = .white
) {
  let paragraph = NSMutableParagraphStyle()
  paragraph.alignment = .center
  paragraph.lineBreakMode = .byWordWrapping
  text.draw(
    in: rect,
    withAttributes: [
      .font: bold ? NSFont.boldSystemFont(ofSize: size) : NSFont.systemFont(ofSize: size),
      .foregroundColor: color,
      .paragraphStyle: paragraph,
    ]
  )
}

func sheet(
  _ selected: [Item],
  name: String,
  title: String,
  suffix: String = "390x844",
  columns: Int = 5,
  classificationLabels: Bool = false
) throws {
  let preview = NSSize(width: 180, height: 390)
  let labelHeight: CGFloat = 84
  let titleHeight: CGFloat = 54
  let gap: CGFloat = 10
  let rowCount = Int(ceil(Double(selected.count) / Double(columns)))
  let size = NSSize(
    width: gap + CGFloat(columns) * (preview.width + gap),
    height: titleHeight + gap + CGFloat(rowCount) * (preview.height + labelHeight + gap)
  )
  let canvas = NSImage(size: size)
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: size).fill()
  label(
    title,
    rect: NSRect(x: 12, y: size.height - 46, width: size.width - 24, height: 34),
    size: 19,
    bold: true,
    color: gold
  )
  for (index, item) in selected.enumerated() {
    let column = index % columns
    let row = index / columns
    let x = gap + CGFloat(column) * (preview.width + gap)
    let y = size.height - titleHeight - gap
      - CGFloat(row + 1) * (preview.height + labelHeight + gap) + labelHeight
    guard let image = NSImage(
      contentsOf: directory.appendingPathComponent("\(item.id)_\(suffix).png")
    ) else { fatalError("Missing preview for \(item.level)") }
    image.draw(in: NSRect(x: x, y: y, width: preview.width, height: preview.height))
    let heading = classificationLabels ? item.coarseClass : item.name
    let flags = [
      item.anchor ? "anchor" : nil,
      item.breather ? "breather" : nil,
      item.showcase ? "showcase" : nil,
    ].compactMap { $0 }.joined(separator: " · ")
    label(
      "L\(item.level) · \(heading)\n\(item.family)\n"
        + "\(item.fullness) · \(item.tiles)t · \(String(format: "%.1f", item.width))%W · "
        + "\(String(format: "%.1f", item.height))%H\n\(flags)",
      rect: NSRect(x: x, y: y - labelHeight, width: preview.width, height: labelHeight),
      size: 8.2
    )
  }
  canvas.unlockFocus()
  try save(canvas, name)
}

for start in stride(from: 0, to: 40, by: 10) {
  try sheet(
    Array(items[start..<start + 10]),
    name: "levels-\(241 + start)-\(250 + start)-contact-sheet.png",
    title: "Production · Levels \(241 + start)–\(250 + start)"
  )
}
try sheet(
  Array(items[0..<20]),
  name: "chapter-13-overview.png",
  title: "Chapter 13 · Rivers of Counsel · Levels 241–260"
)
try sheet(
  Array(items[20..<40]),
  name: "chapter-14-overview.png",
  title: "Chapter 14 · Forest of Ancestors · Levels 261–280"
)
try sheet(
  items,
  name: "levels-241-280-visual-overview.png",
  title: "Levels 241–280 · production overview"
)
try sheet(
  items,
  name: "levels-241-280-silhouette-overview.png",
  title: "Levels 241–280 · silhouette overview",
  suffix: "silhouette"
)
try sheet(
  items,
  name: "coarse-classification-overview.png",
  title: "Levels 241–280 · dominant coarse classes",
  suffix: "silhouette",
  classificationLabels: true
)
try sheet(
  items.filter { $0.breather },
  name: "breather-overview.png",
  title: "Seven substantial breather boards",
  suffix: "silhouette",
  columns: 4
)
try sheet(
  items.filter { $0.showcase },
  name: "showcase-overview.png",
  title: "Eight showcase boards",
  columns: 4
)

func distributionChart() throws {
  let categories = ["open-medium", "full", "bulky"]
  let counts = categories.map { category in items.filter { $0.fullness == category }.count }
  let canvas = NSImage(size: NSSize(width: 900, height: 560))
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: canvas.size).fill()
  label(
    "Levels 241–280 · bulk / fullness distribution",
    rect: NSRect(x: 20, y: 500, width: 860, height: 40),
    size: 22,
    bold: true,
    color: gold
  )
  let colors = [NSColor.systemTeal, NSColor.systemOrange, NSColor.systemGreen]
  for index in 0..<categories.count {
    let x = 115 + CGFloat(index) * 260
    let height = CGFloat(counts[index]) * 20
    colors[index].setFill()
    NSRect(x: x, y: 100, width: 150, height: height).fill()
    label("\(counts[index])", rect: NSRect(x: x, y: 110 + height, width: 150, height: 35), size: 20, bold: true)
    label(categories[index], rect: NSRect(x: x - 10, y: 50, width: 170, height: 35), size: 14, bold: true)
  }
  label("0 ultra-thin · 0 solid slabs", rect: NSRect(x: 100, y: 12, width: 700, height: 30), size: 13)
  canvas.unlockFocus()
  try save(canvas, "bulk-fullness-distribution.png")
}

func envelopeChart() throws {
  let canvas = NSImage(size: NSSize(width: 1220, height: 780))
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: canvas.size).fill()
  label(
    "Levels 241–280 · width / height envelope distribution",
    rect: NSRect(x: 20, y: 720, width: 1180, height: 40),
    size: 22,
    bold: true,
    color: gold
  )
  for (index, item) in items.enumerated() {
    let x = 30 + CGFloat(index % 10) * 119
    let row = index / 10
    let baseline = 660 - CGFloat(row) * 160
    let widthHeight = CGFloat(item.width) * 0.85
    let heightHeight = CGFloat(item.height) * 0.85
    gold.setFill()
    NSRect(x: x, y: baseline - widthHeight, width: 40, height: widthHeight).fill()
    green.setFill()
    NSRect(x: x + 45, y: baseline - heightHeight, width: 40, height: heightHeight).fill()
    label(
      "L\(item.level)\nW \(String(format: "%.0f", item.width)) · H \(String(format: "%.0f", item.height))",
      rect: NSRect(x: x - 8, y: baseline - 132, width: 108, height: 36),
      size: 8
    )
  }
  canvas.unlockFocus()
  try save(canvas, "envelope-distribution.png")
}

func comparison(
  levels: [Int],
  name: String,
  title: String,
  silhouette: Bool
) throws {
  let columns = 10
  let preview = NSSize(width: 117, height: 253)
  let labelHeight: CGFloat = 25
  let titleHeight: CGFloat = 48
  let gap: CGFloat = 5
  let rows = Int(ceil(Double(levels.count) / Double(columns)))
  let size = NSSize(
    width: gap + CGFloat(columns) * (preview.width + gap),
    height: titleHeight + gap + CGFloat(rows) * (preview.height + labelHeight + gap)
  )
  let canvas = NSImage(size: size)
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: size).fill()
  label(title, rect: NSRect(x: 10, y: size.height - 40, width: size.width - 20, height: 30), size: 18, bold: true, color: gold)
  for (index, level) in levels.enumerated() {
    let x = gap + CGFloat(index % columns) * (preview.width + gap)
    let y = size.height - titleHeight - gap
      - CGFloat(index / columns + 1) * (preview.height + labelHeight + gap)
      + labelHeight
    let url: URL
    if level <= 240 {
      if silhouette {
        url = productionDirectory.appendingPathComponent("level-\(level)_silhouette.png")
      } else {
        url = productionDirectory.appendingPathComponent("level-\(level)_390x844.png")
      }
    } else {
      let item = items[level - 241]
      url = directory.appendingPathComponent("\(item.id)_\(silhouette ? "silhouette" : "390x844").png")
    }
    guard let image = NSImage(contentsOf: url) else { fatalError("Missing comparison L\(level): \(url.path)") }
    image.draw(in: NSRect(x: x, y: y, width: preview.width, height: preview.height))
    label("L\(level)", rect: NSRect(x: x, y: y - labelHeight, width: preview.width, height: labelHeight), size: 9, bold: true)
  }
  canvas.unlockFocus()
  try save(canvas, name)
}

func boundaryComparison() throws {
  let canvas = NSImage(size: NSSize(width: 410, height: 500))
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: canvas.size).fill()
  label("Production transition · Level 240 → 241", rect: NSRect(x: 10, y: 460, width: 390, height: 30), size: 18, bold: true, color: gold)
  let images = [
    productionDirectory.appendingPathComponent("level-240_390x844.png"),
    directory.appendingPathComponent("\(items[0].id)_390x844.png"),
  ]
  for index in 0..<2 {
    NSImage(contentsOf: images[index])!.draw(in: NSRect(x: 10 + index * 200, y: 58, width: 190, height: 390))
    label(index == 0 ? "L240 · Living Memory finale" : "L241 · Rivers opens", rect: NSRect(x: 10 + index * 200, y: 15, width: 190, height: 35), size: 11, bold: true)
  }
  canvas.unlockFocus()
  try save(canvas, "level-240-to-241-comparison.png")
}

func chapterTransition() throws {
  let canvas = NSImage(size: NSSize(width: 410, height: 500))
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: canvas.size).fill()
  label("Production transition · Level 260 → 261", rect: NSRect(x: 10, y: 460, width: 390, height: 30), size: 18, bold: true, color: gold)
  for (index, level) in [260, 261].enumerated() {
    let item = items[level - 241]
    let url = directory.appendingPathComponent("\(item.id)_390x844.png")
    NSImage(contentsOf: url)!.draw(in: NSRect(x: 10 + index * 200, y: 58, width: 190, height: 390))
    label(index == 0 ? "L260 · Rivers finale" : "L261 · Forest threshold", rect: NSRect(x: 10 + index * 200, y: 15, width: 190, height: 35), size: 11, bold: true)
  }
  canvas.unlockFocus()
  try save(canvas, "level-260-to-261-comparison.png")
}

func currentBoundary() throws {
  let canvas = NSImage(size: NSSize(width: 620, height: 500))
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: canvas.size).fill()
  label("Current production boundary · Level 280", rect: NSRect(x: 10, y: 460, width: 600, height: 30), size: 18, bold: true, color: gold)
  let item = items[39]
  let url = directory.appendingPathComponent("\(item.id)_390x844.png")
  NSImage(contentsOf: url)!.draw(in: NSRect(x: 20, y: 58, width: 190, height: 390))
  label("L280 · Great Ancestral Tree", rect: NSRect(x: 20, y: 15, width: 190, height: 35), size: 11, bold: true)
  label("CURRENT JOURNEY COMPLETE\n\nRETURN HOME\n\nLevel 281 unavailable\ngetLevelById(281) = null\n\n400 levels remain planned", rect: NSRect(x: 240, y: 110, width: 350, height: 250), size: 17, bold: true, color: gold)
  canvas.unlockFocus()
  try save(canvas, "level-280-current-boundary.png")
}

func finaleComparison() throws {
  let levels = [200, 220, 240, 260, 280]
  let canvas = NSImage(size: NSSize(width: 1000, height: 510))
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: canvas.size).fill()
  label("Finale silhouettes · Levels 200, 220, 240, 260, 280", rect: NSRect(x: 15, y: 466, width: 970, height: 34), size: 20, bold: true, color: gold)
  for (index, level) in levels.enumerated() {
    let url: URL
    if level <= 240 {
      url = productionDirectory.appendingPathComponent("level-\(level)_390x844.png")
    } else {
      let item = items[level - 241]
      url = directory.appendingPathComponent("\(item.id)_390x844.png")
    }
    NSImage(contentsOf: url)!.draw(in: NSRect(x: 10 + index * 198, y: 62, width: 188, height: 390))
    label("Level \(level)", rect: NSRect(x: 10 + index * 198, y: 18, width: 188, height: 34), size: 12, bold: true)
  }
  canvas.unlockFocus()
  try save(canvas, "finale-comparison-levels-200-220-240-260-280.png")
}

try distributionChart()
try envelopeChart()
try comparison(
  levels: Array(221...280),
  name: "levels-221-280-comparison.png",
  title: "Production continuity · Levels 221–280",
  silhouette: false
)
try comparison(
  levels: Array(201...280),
  name: "levels-201-280-silhouette-comparison.png",
  title: "Bulky-portrait silhouette continuity · Levels 201–280",
  silhouette: true
)
try boundaryComparison()
try chapterTransition()
try currentBoundary()
try finaleComparison()
