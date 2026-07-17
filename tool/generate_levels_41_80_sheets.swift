import AppKit
import Foundation

struct Item { let level:Int; let id:String; let name:String }
let root=URL(fileURLWithPath:FileManager.default.currentDirectoryPath)
let dir=root.appendingPathComponent("artifacts/layout-previews/levels-41-80-candidates")
let lines=try String(contentsOf:dir.appendingPathComponent("metrics.csv")).split(separator:"\n").dropFirst()
let items:[Item]=lines.map {
  let fields=$0.split(separator:",",omittingEmptySubsequences:false)
  return Item(level:Int(fields[0])!,id:String(fields[1]),name:String(fields[2]).replacingOccurrences(of:"\"",with:""))
}

func sheet(_ selected:[Item],_ name:String,_ suffix:String) throws {
  let columns=5, tw:CGFloat=180, th:CGFloat=390, label:CGFloat=46, gap:CGFloat=10
  let rows=Int(ceil(Double(selected.count)/Double(columns)))
  let size=NSSize(width:gap+CGFloat(columns)*(tw+gap),height:gap+CGFloat(rows)*(th+label+gap))
  let canvas=NSImage(size:size); canvas.lockFocus()
  NSColor(deviceRed:0.03,green:0.06,blue:0.05,alpha:1).setFill(); NSRect(origin:.zero,size:size).fill()
  for (i,item) in selected.enumerated() {
    let col=i%columns,row=i/columns,x=gap+CGFloat(col)*(tw+gap)
    let y=size.height-gap-CGFloat(row+1)*(th+label+gap)+label
    let image=NSImage(contentsOf:dir.appendingPathComponent("\(item.id)_\(suffix).png"))!
    image.draw(in:NSRect(x:x,y:y,width:tw,height:th))
    let p=NSMutableParagraphStyle();p.alignment = .center
    "L\(item.level) · \(item.name)\n\(item.id)".draw(in:NSRect(x:x,y:y-label,width:tw,height:label),withAttributes:[.font:NSFont.systemFont(ofSize:9),.foregroundColor:NSColor.white,.paragraphStyle:p])
  }
  canvas.unlockFocus()
  let rep=NSBitmapImageRep(data:canvas.tiffRepresentation!)!
  try rep.representation(using:.png,properties:[:])!.write(to:dir.appendingPathComponent(name))
}

for start in stride(from:0,to:40,by:10) {
  try sheet(Array(items[start..<start+10]),"levels-\(start+41)-\(start+50)-contact-sheet.png","390x844")
}
try sheet(items,"levels-41-80-overview.png","390x844")
try sheet(items,"levels-41-80-diagnostic-overview.png","diagnostic")
try sheet(items,"levels-41-80-family-classification-overview.png","390x844")
try sheet(items,"levels-41-80-silhouette-only-overview.png","silhouette")
