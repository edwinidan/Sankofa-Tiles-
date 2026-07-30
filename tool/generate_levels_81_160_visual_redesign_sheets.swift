import AppKit
import Foundation

struct Item {
  let level: Int
  let id: String
  let name: String
  let family: String
  let declaredClass: String
  let detectedClass: String
  let tiles: String
  let width: Double
  let height: Double
  let tile: String
  let empty: String
  let holes: String
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let directory = root.appendingPathComponent(
  "artifacts/layout-previews/levels-81-160-visual-redesign-pass-2"
)
let pass1Directory = root.appendingPathComponent(
  "artifacts/layout-previews/levels-81-160-visual-redesign-pass-1"
)
func readItems(_ source: URL) throws -> [Item] {
  let lines = try String(
    contentsOf: source.appendingPathComponent("metrics.csv"),
    encoding: .utf8
  ).split(separator: "\n").dropFirst()
  return lines.map {
  let fields = $0.split(separator: ",", omittingEmptySubsequences: false)
  return Item(
    level: Int(fields[0])!,
    id: String(fields[1]),
    name: String(fields[2]).replacingOccurrences(of: "\"", with: ""),
    family: String(fields[3]).replacingOccurrences(of: "\"", with: ""),
    declaredClass: String(fields[4]).replacingOccurrences(of: "\"", with: ""),
    detectedClass: String(fields[5]).replacingOccurrences(of: "\"", with: ""),
    tiles: String(fields[6]),
    width: Double(fields[9])!,
    height: Double(fields[10])!,
    tile: String(fields[11]),
    empty: String(fields[12]),
    holes: String(fields[13])
  )
  }
}
let items = try readItems(directory)
let pass1Items = try readItems(pass1Directory)
let allItems = pass1Items.map { old in
  items.first(where: { $0.level == old.level }) ?? old
}
func previewURL(_ item: Item, _ suffix: String) -> URL {
  let source = items.contains(where: { $0.level == item.level }) ? directory : pass1Directory
  return source.appendingPathComponent("\(item.id)_\(suffix).png")
}

let background = NSColor(deviceRed: 0.025, green: 0.055, blue: 0.045, alpha: 1)
let gold = NSColor(deviceRed: 0.86, green: 0.66, blue: 0.25, alpha: 1)

func save(_ canvas: NSImage, name: String) throws {
  let bitmap = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
  try bitmap.representation(using: .png, properties: [:])!
    .write(to: directory.appendingPathComponent(name))
}

func drawLabel(
  _ text: String,
  rect: NSRect,
  size: CGFloat = 11,
  color: NSColor = .white,
  bold: Bool = false
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

func writeSheet(
  _ selected: [Item],
  name: String,
  suffix: String = "390x844",
  columns: Int = 5,
  classLabels: Bool = false
) throws {
  let previewWidth: CGFloat = 220
  let previewHeight: CGFloat = 476
  let labelHeight: CGFloat = 98
  let gap: CGFloat = 12
  let rows = Int(ceil(Double(selected.count) / Double(columns)))
  let size = NSSize(
    width: gap + CGFloat(columns) * (previewWidth + gap),
    height: gap + CGFloat(rows) * (previewHeight + labelHeight + gap)
  )
  let canvas = NSImage(size: size)
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: size).fill()
  for (index, item) in selected.enumerated() {
    let column = index % columns
    let row = index / columns
    let x = gap + CGFloat(column) * (previewWidth + gap)
    let y = size.height - gap
      - CGFloat(row + 1) * (previewHeight + labelHeight + gap) + labelHeight
    let url = previewURL(item, suffix)
    guard let preview = NSImage(contentsOf: url) else {
      throw NSError(
        domain: "MissingPreview",
        code: item.level,
        userInfo: [NSLocalizedDescriptionKey: url.path]
      )
    }
    preview.draw(in: NSRect(x: x, y: y, width: previewWidth, height: previewHeight))
    let heading = classLabels ? item.declaredClass : item.name
    drawLabel(
      "L\(item.level) · \(heading)\n\(item.family) · \(item.id)\n"
        + "\(item.tiles) tiles · \(String(format: "%.1f", item.width))%W · "
        + "\(String(format: "%.1f", item.height))%H · \(item.tile)px\n"
        + "\(item.empty)% empty · \(item.holes) holes · detected \(item.detectedClass)",
      rect: NSRect(x: x, y: y - labelHeight, width: previewWidth, height: labelHeight),
      size: 9.5
    )
  }
  canvas.unlockFocus()
  try save(canvas, name: name)
}

try writeSheet(
  allItems,
  name: "levels-81-160-visual-redesign-pass-2-overview.png"
)
try writeSheet(
  allItems,
  name: "levels-81-160-visual-redesign-pass-2-silhouette-overview.png",
  suffix: "silhouette"
)
for chapter in 0..<4 {
  try writeSheet(
    Array(allItems[chapter * 5..<chapter * 5 + 5]),
    name: "chapter-\(chapter + 5)-anchor-overview.png"
  )
}
try writeSheet(
  allItems,
  name: "coarse-silhouette-classification.png",
  suffix: "silhouette",
  classLabels: true
)

func writeOldVersusNew() throws {
  let previewWidth: CGFloat = 205
  let previewHeight: CGFloat = 444
  let labelHeight: CGFloat = 76
  let gap: CGFloat = 10
  let pairsPerRow = 4
  let rows = Int(ceil(Double(items.count) / Double(pairsPerRow)))
  let size = NSSize(
    width: gap + CGFloat(pairsPerRow * 2) * (previewWidth + gap),
    height: gap + CGFloat(rows) * (previewHeight + labelHeight + gap)
  )
  let canvas = NSImage(size: size)
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: size).fill()
  for (index, item) in items.enumerated() {
    let pairColumn = index % pairsPerRow
    let row = index / pairsPerRow
    for variant in 0..<2 {
      let column = pairColumn * 2 + variant
      let x = gap + CGFloat(column) * (previewWidth + gap)
      let y = size.height - gap
        - CGFloat(row + 1) * (previewHeight + labelHeight + gap) + labelHeight
      let source = variant == 0 ? pass1Directory : directory
      let url = source.appendingPathComponent("\(item.id)_silhouette.png")
      guard let preview = NSImage(contentsOf: url) else {
        throw NSError(domain: "MissingComparison", code: item.level)
      }
      preview.draw(in: NSRect(x: x, y: y, width: previewWidth, height: previewHeight))
      drawLabel(
        "L\(item.level) · \(variant == 0 ? "OLD" : "NEW")\n"
          + "\(item.family)\n\(String(format: "%.1f", item.width))%W · "
          + "\(String(format: "%.1f", item.height))%H",
        rect: NSRect(x: x, y: y - labelHeight, width: previewWidth, height: labelHeight),
        size: 10,
        color: variant == 0 ? .lightGray : gold,
        bold: true
      )
    }
  }
  canvas.unlockFocus()
  try save(canvas, name: "old-vs-new-anchor-comparison.png")
}

func writeFinales() throws {
  let levels = [20, 40, 60, 80, 100, 120, 140, 160]
  let previewWidth: CGFloat = 220
  let previewHeight: CGFloat = 476
  let labelHeight: CGFloat = 70
  let gap: CGFloat = 12
  let size = NSSize(
    width: gap + CGFloat(levels.count) * (previewWidth + gap),
    height: gap + previewHeight + labelHeight + gap
  )
  let canvas = NSImage(size: size)
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: size).fill()
  for (index, level) in levels.enumerated() {
    let x = gap + CGFloat(index) * (previewWidth + gap)
    let url: URL
    let label: String
    if level <= 80 {
      url = root.appendingPathComponent(
        "artifacts/layout-previews/levels-1-80-silhouettes/level_\(level)_silhouette.png"
      )
      label = "L\(level) · frozen production finale"
    } else {
      let item = allItems.first { $0.level == level }!
      url = previewURL(item, "silhouette")
      label = "L\(level) · \(item.family)\n\(item.tiles) tiles · "
        + "\(String(format: "%.1f", item.width))%W × "
        + "\(String(format: "%.1f", item.height))%H"
    }
    guard let preview = NSImage(contentsOf: url) else {
      throw NSError(domain: "MissingFinale", code: level)
    }
    preview.draw(in: NSRect(x: x, y: labelHeight, width: previewWidth, height: previewHeight))
    drawLabel(
      label,
      rect: NSRect(x: x, y: 8, width: previewWidth, height: labelHeight - 8),
      size: 10,
      color: level > 80 ? gold : .white,
      bold: true
    )
  }
  canvas.unlockFocus()
  try save(canvas, name: "finale-comparison-levels-20-160.png")
}

func writeComparison(_ levels: [Int], name: String) throws {
  let previewWidth: CGFloat = 260
  let previewHeight: CGFloat = 562
  let labelHeight: CGFloat = 62
  let gap: CGFloat = 12
  let size = NSSize(
    width: gap + CGFloat(levels.count) * (previewWidth + gap),
    height: gap + previewHeight + labelHeight + gap
  )
  let canvas = NSImage(size: size)
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: size).fill()
  for (index, level) in levels.enumerated() {
    let item = allItems.first { $0.level == level }!
    let x = gap + CGFloat(index) * (previewWidth + gap)
    guard let preview = NSImage(contentsOf: previewURL(item, "silhouette")) else {
      throw NSError(domain: "MissingComparison", code: level)
    }
    preview.draw(in: NSRect(x: x, y: labelHeight, width: previewWidth, height: previewHeight))
    drawLabel(
      "L\(level) · \(item.family)\n\(item.tiles) tiles · \(String(format: "%.1f", item.width))%W × \(String(format: "%.1f", item.height))%H",
      rect: NSRect(x: x, y: 8, width: previewWidth, height: labelHeight - 8),
      size: 10,
      color: gold,
      bold: true
    )
  }
  canvas.unlockFocus()
  try save(canvas, name: name)
}

func writeEnvelopeDistribution() throws {
  let size = NSSize(width: 1400, height: 900)
  let plot = NSRect(x: 120, y: 110, width: 1160, height: 690)
  let canvas = NSImage(size: size)
  canvas.lockFocus()
  background.setFill()
  NSRect(origin: .zero, size: size).fill()
  NSColor(deviceWhite: 1, alpha: 0.18).setStroke()
  let grid = NSBezierPath()
  for width in stride(from: 50, through: 85, by: 5) {
    let x = plot.minX + CGFloat(width - 50) / 35 * plot.width
    grid.move(to: NSPoint(x: x, y: plot.minY))
    grid.line(to: NSPoint(x: x, y: plot.maxY))
    drawLabel("\(width)%", rect: NSRect(x: x - 30, y: 70, width: 60, height: 28), size: 10)
  }
  for height in stride(from: 55, through: 85, by: 5) {
    let y = plot.minY + CGFloat(height - 55) / 30 * plot.height
    grid.move(to: NSPoint(x: plot.minX, y: y))
    grid.line(to: NSPoint(x: plot.maxX, y: y))
    drawLabel("\(height)%", rect: NSRect(x: 45, y: y - 12, width: 65, height: 24), size: 10)
  }
  grid.lineWidth = 1
  grid.stroke()
  var occurrence: [String: Int] = [:]
  for item in allItems {
    let key = "\(item.width)-\(item.height)"
    let offsetIndex = occurrence[key, default: 0]
    occurrence[key] = offsetIndex + 1
    let angle = Double(offsetIndex) * 0.9
    let radius = CGFloat(offsetIndex) * 15
    let x = plot.minX + CGFloat((item.width - 50) / 35) * plot.width
      + cos(angle) * radius
    let y = plot.minY + CGFloat((item.height - 55) / 30) * plot.height
      + sin(angle) * radius
    gold.setFill()
    NSBezierPath(ovalIn: NSRect(x: x - 17, y: y - 17, width: 34, height: 34)).fill()
    drawLabel(
      "\(item.level)",
      rect: NSRect(x: x - 22, y: y - 8, width: 44, height: 18),
      size: 9,
      color: .black,
      bold: true
    )
  }
  drawLabel(
    "20-anchor width and height occupancy distribution · 390×844",
    rect: NSRect(x: 160, y: 825, width: 1080, height: 40),
    size: 20,
    color: gold,
    bold: true
  )
  drawLabel("Width occupancy", rect: NSRect(x: 560, y: 25, width: 300, height: 32), size: 14)
  canvas.unlockFocus()
  try save(canvas, name: "envelope-distribution.png")
}

try writeOldVersusNew()
try writeFinales()
try writeComparison([110, 155], name: "level-110-vs-level-155.png")
try writeComparison([120, 140], name: "level-120-vs-level-140.png")
try writeComparison([100, 120, 140, 160], name: "finale-progression-100-160.png")
try writeEnvelopeDistribution()
