// ignore_for_file: avoid_print
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:sankofa_tiles/core/constants/levels_281_320_data.dart';

/// Assemble the actual BoardWidget renders; no drawn substitutes for tiles.
void main() {
  const path = 'artifacts/layout-previews/levels-281-320-production';
  final directory = Directory(path)..createSync(recursive: true);
  void sheet(List<CampaignBoardDesign> boards, String name, String suffix) {
    const columns = 5;
    const cardWidth = 218;
    const cardHeight = 505;
    final rows = (boards.length / columns).ceil();
    final canvas =
        img.Image(width: columns * cardWidth, height: rows * cardHeight + 48);
    img.fill(canvas, color: img.ColorRgb8(10, 24, 20));
    img.drawString(canvas,
        'Sankofa Tiles - Levels ${boards.first.level}-${boards.last.level}',
        font: img.arial24, x: 16, y: 12, color: img.ColorRgb8(245, 195, 90));
    for (var index = 0; index < boards.length; index++) {
      final board = boards[index];
      final source = File('$path/${board.layout.id}_$suffix.png');
      final rendered = img.decodePng(source.readAsBytesSync())!;
      final preview = img.copyResize(rendered, width: 208, height: 450);
      final x = (index % columns) * cardWidth + 5;
      final y = (index ~/ columns) * cardHeight + 48;
      img.compositeImage(canvas, preview, dstX: x, dstY: y);
      img.drawString(canvas, 'L${board.level}: ${board.name}',
          font: img.arial14,
          x: x + 2,
          y: y + 455,
          color: img.ColorRgb8(255, 232, 182));
      img.drawString(canvas,
          '${board.layout.stats.tileCount} tiles / 3 layers${board.isBreather ? ' / breather' : ''}',
          font: img.arial14,
          x: x + 2,
          y: y + 477,
          color: img.ColorRgb8(185, 210, 193));
    }
    File('${directory.path}/$name.png').writeAsBytesSync(img.encodePng(canvas));
  }

  for (var start = 0; start < 40; start += 10) {
    final boards = kLevels281To320Designs.sublist(start, start + 10);
    sheet(
        boards,
        'levels-${boards.first.level}-${boards.last.level}-contact-sheet',
        '390x844');
    sheet(
        boards,
        'levels-${boards.first.level}-${boards.last.level}-silhouettes',
        'silhouette');
  }
  sheet(
      kLevels281To320Designs.sublist(0, 20), 'chapter-15-overview', '390x844');
  sheet(kLevels281To320Designs.sublist(20), 'chapter-16-overview', '390x844');
  print(
      'Wrote four contact sheets, four silhouette sheets, and two chapter overviews.');
}
