import AppKit
import Foundation

struct Item { let level: Int; let id: String; let name: String; let tiles: Int }

let chapter1: [Item] = [
  (1,"earlyOpenDiamond01","First Symbols",26),(2,"earlyOpenDiamond02","New Roots",30),
  (3,"earlyBridge01","Side Paths",36),(4,"earlyShrine01","Small Turtle",32),
  (5,"earlyLayeredDiamond01","Shrine Steps",40),(6,"batchBOpenCourtyard01","Open Courtyard",36),
  (7,"batchBRiverPath01","River Lesson",40),(8,"batchBTempleGate01","Wisdom Gate",46),
  (9,"batchBGatheringWings01","Gathering Wings",48),(10,"batchBTwinBridge01","Elder Bridge",52),
  (11,"batchBSmallTurtle01","Heritage Turtle",54),(12,"batchBButterfly01","Butterfly Path",54),
  (13,"batchBShrineSteps01","Temple Steps",54),(14,"batchBWisdomStaircase01","Wisdom Staircase",48),
  (15,"batchBCrown01","Ancestral Crown",56),(16,"batchBOpenRing01","Sacred Grove",52),
  (17,"batchBRoyalStool01","Golden Stool",60),(18,"batchBAncestralGate01","Ancestral Gate",60),
  (19,"batchBTwinTowers01","Twin Houses",64),(20,"batchBRaisedCourtyard01","Raised Courtyard",64),
].map { Item(level:$0.0,id:$0.1,name:$0.2,tiles:$0.3) }

let chapter2: [Item] = [
  (21,"chapter2VerticalTurtle01","Grand Turtle",50),(22,"chapter2SplitSanctuary01","Split Islands",52),
  (23,"chapter2LayeredCrown01","Royal Assembly",60),(24,"chapter2WindingRiver01","Winding Path",42),
  (25,"chapter2CeremonialMask01","Ancestral Mask",60),(26,"chapter2TwinTowers02","Fortress Spirits",52),
  (27,"chapter2HollowTemple01","Hidden Center",60),(28,"chapter2PortraitButterfly01","Butterfly Path",62),
  (29,"chapter2RoyalStool02","Golden Foundation",70),(30,"chapter2StackedBridge01","Sacred Crossing",70),
  (31,"chapter2SacredArch01","Path of Renewal",50),(32,"chapter2Hourglass01","Hidden Wisdom",66),
  (33,"chapter2WingedEmblem01","Gathered Emblem",58),(34,"chapter2GrandStaircase01","Elders Assembly",34),
  (35,"chapter2OpenRing01","Sacred Grove",46),(36,"chapter2TallFortress01","Fortress Gate",74),
  (37,"chapter2AdinkraFormation01","Steadfast Spirits",52),(38,"chapter2SplitIslands01","Twin Shrines",44),
  (39,"chapter2AncestralPillar01","Ancestral Pillar",56),(40,"chapter2GrandTemple01","Ancestral Trial",76),
].map { Item(level:$0.0,id:$0.1,name:$0.2,tiles:$0.3) }

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
func writeSheet(items: [Item], previewDir: URL, name: String, diagnostic: Bool, columns: Int, suffixOverride: String? = nil) throws {
  let tw: CGFloat = 180, th: CGFloat = 390, lh: CGFloat = 62, gap: CGFloat = 12
  let rows = Int(ceil(Double(items.count) / Double(columns)))
  let size = NSSize(width: gap + CGFloat(columns)*(tw+gap), height: gap + CGFloat(rows)*(th+lh+gap))
  let canvas = NSImage(size:size); canvas.lockFocus()
  NSColor(calibratedRed:0.055,green:0.08,blue:0.07,alpha:1).setFill(); NSRect(origin:.zero,size:size).fill()
  for (i,item) in items.enumerated() {
    let col=i%columns,row=i/columns,x=gap+CGFloat(col)*(tw+gap)
    let top=size.height-gap-CGFloat(row)*(th+lh+gap), y=top-th
    let suffix=suffixOverride ?? (diagnostic ? "diagnostic" : "390x844")
    let file = previewDir.appendingPathComponent(diagnostic || item.level > 20 ? "\(item.id)_\(suffix).png" : "level_\(item.level)_390x844.png")
    guard let image=NSImage(contentsOf:file) else { throw NSError(domain:"sheet",code:1,userInfo:[NSLocalizedDescriptionKey:file.path]) }
    image.draw(in:NSRect(x:x,y:y,width:tw,height:th),from:.zero,operation:.sourceOver,fraction:1)
    let p=NSMutableParagraphStyle();p.alignment = .center
    "L\(item.level) · \(item.name)\n\(item.id) · \(item.tiles) tiles · 3 layers".draw(in:NSRect(x:x,y:y-lh,width:tw,height:lh),withAttributes:[.font:NSFont.systemFont(ofSize:9),.foregroundColor:NSColor.white,.paragraphStyle:p])
  }
  canvas.unlockFocus(); let rep=NSBitmapImageRep(data:canvas.tiffRepresentation!)!; try rep.representation(using:.png,properties:[:])!.write(to:previewDir.appendingPathComponent(name))
}

func writeSilhouetteSheet(items: [Item], previewDir: URL, name: String, columns: Int) throws {
  let tw = 180, th = 390, gap = 12
  let rows = Int(ceil(Double(items.count) / Double(columns)))
  let canvas = NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:gap+columns*(tw+gap),pixelsHigh:gap+rows*(th+gap),bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
  let black = NSColor(deviceRed:0,green:0,blue:0,alpha:1)
  let white = NSColor(deviceRed:1,green:1,blue:1,alpha:1)
  for y in 0..<canvas.pixelsHigh { for x in 0..<canvas.pixelsWide { canvas.setColor(black,atX:x,y:y) } }
  for (index,item) in items.enumerated() {
    let source = NSBitmapImageRep(data:NSImage(contentsOf:previewDir.appendingPathComponent("\(item.id)_390x844.png"))!.tiffRepresentation!)!
    let ox=gap+(index%columns)*(tw+gap), oy=gap+(rows-1-index/columns)*(th+gap)
    for y in 0..<th { for x in 0..<tw {
      let sx=x*source.pixelsWide/tw, sy=y*source.pixelsHigh/th
      if let color=source.colorAt(x:sx,y:sy)?.usingColorSpace(.deviceRGB),
         color.redComponent > 0.45, color.redComponent > color.greenComponent * 1.25 {
        canvas.setColor(white,atX:ox+x,y:oy+y)
      }
    } }
  }
  try canvas.representation(using:.png,properties:[:])!.write(to:previewDir.appendingPathComponent(name))
}

let c1=root.appendingPathComponent("artifacts/layout-previews/chapter-1-production")
let c2=root.appendingPathComponent("artifacts/layout-previews/chapter-2-diversity-pass")
for start in stride(from:0,to:20,by:5) {
  try writeSheet(items:Array(chapter1[start..<start+5]),previewDir:c1,name:"levels-\(start+1)-\(start+5)-contact-sheet.png",diagnostic:false,columns:5)
  try writeSheet(items:Array(chapter2[start..<start+5]),previewDir:c2,name:"levels-\(start+21)-\(start+25)-contact-sheet.png",diagnostic:false,columns:5)
}
try writeSheet(items:chapter1,previewDir:c1,name:"chapter-1-overview.png",diagnostic:false,columns:5)
try writeSheet(items:chapter2,previewDir:c2,name:"chapter-2-overview.png",diagnostic:false,columns:5)
try writeSheet(items:chapter2,previewDir:c2,name:"chapter-2-diagnostic-overview.png",diagnostic:true,columns:5)
try writeSheet(items:chapter2,previewDir:c2,name:"chapter-2-silhouette-only-overview.png",diagnostic:false,columns:5,suffixOverride:"silhouette")
try? FileManager.default.removeItem(at:c2.appendingPathComponent("chapter-2-family-classification-overview.png"))
try FileManager.default.copyItem(at:c2.appendingPathComponent("chapter-2-overview.png"),to:c2.appendingPathComponent("chapter-2-family-classification-overview.png"))
