import AppKit
import Foundation

struct Item {
  let level: Int
  let id: String
  let name: String
  let family: String
  let tiles: String
  let layers: String
  let width: String
  let height: String
  let tile: String
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let directory = root.appendingPathComponent("artifacts/layout-previews/levels-81-160-candidates")
let lines = try String(contentsOf: directory.appendingPathComponent("metrics.csv"), encoding: .utf8)
  .split(separator: "\n").dropFirst()
let items: [Item] = lines.map {
  let fields = $0.split(separator: ",", omittingEmptySubsequences: false)
  return Item(
    level: Int(fields[0])!,
    id: String(fields[1]),
    name: String(fields[2]).replacingOccurrences(of: "\"", with: ""),
    family: String(fields[3]).replacingOccurrences(of: "\"", with: ""),
    tiles: String(fields[4]),
    layers: String(fields[6]),
    width: String(fields[8]),
    height: String(fields[9]),
    tile: String(fields[10])
  )
}

func writeSheet(
  _ selected: [Item],
  name: String,
  suffix: String = "390x844",
  familyLabels: Bool = false,
  columns: Int = 5
) throws {
  let previewWidth: CGFloat = 180
  let previewHeight: CGFloat = 390
  let labelHeight: CGFloat = 72
  let gap: CGFloat = 10
  let rows = Int(ceil(Double(selected.count) / Double(columns)))
  let size = NSSize(
    width: gap + CGFloat(columns) * (previewWidth + gap),
    height: gap + CGFloat(rows) * (previewHeight + labelHeight + gap)
  )
  let canvas = NSImage(size: size)
  canvas.lockFocus()
  NSColor(deviceRed: 0.03, green: 0.06, blue: 0.05, alpha: 1).setFill()
  NSRect(origin: .zero, size: size).fill()
  for (index, item) in selected.enumerated() {
    let column = index % columns
    let row = index / columns
    let x = gap + CGFloat(column) * (previewWidth + gap)
    let y = size.height - gap - CGFloat(row + 1) * (previewHeight + labelHeight + gap) + labelHeight
    let url = directory.appendingPathComponent("\(item.id)_\(suffix).png")
    guard let image = NSImage(contentsOf: url) else {
      throw NSError(domain: "MissingPreview", code: item.level, userInfo: [NSLocalizedDescriptionKey: url.path])
    }
    image.draw(in: NSRect(x: x, y: y, width: previewWidth, height: previewHeight))
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let middle = familyLabels ? item.family : item.name
    let label = "L\(item.level) · \(middle)\n\(item.id)\n\(item.tiles) tiles · \(item.layers)L · \(item.width)%W · \(item.height)%H · \(item.tile)px"
    label.draw(
      in: NSRect(x: x, y: y - labelHeight, width: previewWidth, height: labelHeight),
      withAttributes: [
        .font: NSFont.systemFont(ofSize: 8.5),
        .foregroundColor: NSColor.white,
        .paragraphStyle: paragraph,
      ]
    )
  }
  canvas.unlockFocus()
  let bitmap = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
  try bitmap.representation(using: .png, properties: [:])!
    .write(to: directory.appendingPathComponent(name))
}

for start in stride(from: 0, to: 80, by: 10) {
  try writeSheet(
    Array(items[start..<start + 10]),
    name: "levels-\(start + 81)-\(start + 90)-contact-sheet.png"
  )
}
for chapter in 0..<4 {
  try writeSheet(
    Array(items[chapter * 20..<chapter * 20 + 20]),
    name: "chapter-\(chapter + 5)-overview.png"
  )
}
try writeSheet(items, name: "levels-81-160-overview.png")
try writeSheet(items, name: "levels-81-160-silhouette-overview.png", suffix: "silhouette")
try writeSheet(items, name: "levels-81-160-diagnostic-overview.png", suffix: "diagnostic")
try writeSheet(items, name: "levels-81-160-family-classification.png", familyLabels: true)
let chapterComparison = [items[0], items[4], items[9], items[14], items[19],
                         items[20], items[24], items[29], items[34], items[39],
                         items[40], items[44], items[49], items[54], items[59],
                         items[60], items[64], items[69], items[74], items[79]]
try writeSheet(chapterComparison, name: "chapters-5-8-comparison.png")
let finales = [items[19], items[39], items[59], items[79]]
try writeSheet(finales, name: "candidate-finale-comparison.png", columns: 4)

func writeCrossCampaignSilhouettes() throws {
  let columns = 10
  let width: CGFloat = 90
  let height: CGFloat = 195
  let label: CGFloat = 18
  let gap: CGFloat = 5
  let rows = 16
  let size = NSSize(
    width: gap + CGFloat(columns) * (width + gap),
    height: gap + CGFloat(rows) * (height + label + gap)
  )
  let canvas = NSImage(size: size)
  canvas.lockFocus()
  NSColor(deviceRed: 0.03, green: 0.06, blue: 0.05, alpha: 1).setFill()
  NSRect(origin: .zero, size: size).fill()
  for level in 1...160 {
    let index = level - 1
    let column = index % columns
    let row = index / columns
    let x = gap + CGFloat(column) * (width + gap)
    let y = size.height - gap - CGFloat(row + 1) * (height + label + gap) + label
    let url: URL
    if level <= 80 {
      url = root.appendingPathComponent(
        "artifacts/layout-previews/levels-1-80-silhouettes/level_\(level)_silhouette.png"
      )
    } else {
      let item = items[level - 81]
      url = directory.appendingPathComponent("\(item.id)_silhouette.png")
    }
    guard let image = NSImage(contentsOf: url) else {
      throw NSError(domain: "MissingSilhouette", code: level)
    }
    image.draw(in: NSRect(x: x, y: y, width: width, height: height))
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    "L\(level)".draw(
      in: NSRect(x: x, y: y - label, width: width, height: label),
      withAttributes: [
        .font: NSFont.boldSystemFont(ofSize: 8),
        .foregroundColor: NSColor.white,
        .paragraphStyle: paragraph,
      ]
    )
  }
  canvas.unlockFocus()
  let bitmap = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
  try bitmap.representation(using: .png, properties: [:])!
    .write(to: directory.appendingPathComponent("levels-1-160-silhouette-comparison.png"))
}

func writeAllFinales() throws {
  let levels = [20, 40, 60, 80, 100, 120, 140, 160]
  let size = NSSize(width: 8 * 190 + 10, height: 470)
  let canvas = NSImage(size: size)
  canvas.lockFocus()
  NSColor(deviceRed: 0.03, green: 0.06, blue: 0.05, alpha: 1).setFill()
  NSRect(origin: .zero, size: size).fill()
  for (index, level) in levels.enumerated() {
    let url: URL
    if level <= 80 {
      url = root.appendingPathComponent(
        "artifacts/layout-previews/levels-1-80-silhouettes/level_\(level)_silhouette.png"
      )
    } else {
      url = directory.appendingPathComponent("\(items[level - 81].id)_silhouette.png")
    }
    let image = NSImage(contentsOf: url)!
    image.draw(in: NSRect(x: 10 + CGFloat(index) * 190, y: 65, width: 180, height: 390))
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    "Level \(level) finale".draw(
      in: NSRect(x: 10 + CGFloat(index) * 190, y: 15, width: 180, height: 40),
      withAttributes: [
        .font: NSFont.boldSystemFont(ofSize: 10),
        .foregroundColor: NSColor.white,
        .paragraphStyle: paragraph,
      ]
    )
  }
  canvas.unlockFocus()
  let bitmap = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
  try bitmap.representation(using: .png, properties: [:])!
    .write(to: directory.appendingPathComponent("finale-comparison-levels-20-160.png"))
}

try writeCrossCampaignSilhouettes()
try writeAllFinales()
