import AppKit
import Foundation

struct Item { let level: Int; let id: String; let name: String; let tiles: String }

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let source = root.appendingPathComponent("artifacts/layout-previews/levels-41-80-candidates")
let output = root.appendingPathComponent("artifacts/layout-previews/levels-41-80-production")
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
let lines = try String(contentsOf: source.appendingPathComponent("metrics.csv")).split(separator: "\n").dropFirst()
let items: [Item] = lines.map {
  let fields = $0.split(separator: ",", omittingEmptySubsequences: false)
  return Item(level: Int(fields[0])!, id: String(fields[1]), name: String(fields[2]).replacingOccurrences(of: "\"", with: ""), tiles: String(fields[5]))
}

func sheet(_ selected: [Item], _ name: String) throws {
  let columns = 5, tileWidth: CGFloat = 180, tileHeight: CGFloat = 390, label: CGFloat = 58, gap: CGFloat = 10
  let rows = Int(ceil(Double(selected.count) / Double(columns)))
  let size = NSSize(width: gap + CGFloat(columns) * (tileWidth + gap), height: gap + CGFloat(rows) * (tileHeight + label + gap))
  let canvas = NSImage(size: size); canvas.lockFocus()
  NSColor(deviceRed: 0.03, green: 0.06, blue: 0.05, alpha: 1).setFill(); NSRect(origin: .zero, size: size).fill()
  for (index, item) in selected.enumerated() {
    let column = index % columns, row = index / columns
    let x = gap + CGFloat(column) * (tileWidth + gap)
    let y = size.height - gap - CGFloat(row + 1) * (tileHeight + label + gap) + label
    let image = NSImage(contentsOf: output.appendingPathComponent("level_\(item.level)_390x844.png"))!
    image.draw(in: NSRect(x: x, y: y, width: tileWidth, height: tileHeight))
    let style = NSMutableParagraphStyle(); style.alignment = .center
    "Level \(item.level) · \(item.name)\n\(item.id) · \(item.tiles) tiles".draw(in: NSRect(x: x, y: y - label, width: tileWidth, height: label), withAttributes: [.font: NSFont.systemFont(ofSize: 9), .foregroundColor: NSColor.white, .paragraphStyle: style])
  }
  canvas.unlockFocus()
  let representation = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
  try representation.representation(using: .png, properties: [:])!.write(to: output.appendingPathComponent(name))
}

for start in stride(from: 0, to: 40, by: 10) { try sheet(Array(items[start..<start + 10]), "levels-\(start + 41)-\(start + 50)-contact-sheet.png") }
try sheet(Array(items[0..<20]), "chapter-3-overview.png")
try sheet(Array(items[20..<40]), "chapter-4-overview.png")
try sheet(items, "levels-41-80-overview.png")
