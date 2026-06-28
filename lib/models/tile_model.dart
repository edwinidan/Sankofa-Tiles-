import 'package:uuid/uuid.dart';
import '../core/constants/tile_data.dart';

enum TileVisibility {
  hidden,
  covered,
  revealed,
}

class TileModel {
  final String uid;
  final TileDefinition def;
  final bool isMatched;
  final bool isSelected;
  final bool isHinted;
  final bool isMismatched;
  final bool isPeeked;
  final TileVisibility visibility;
  final int row;
  final int col;
  final int layer;

  TileModel({
    required this.def,
    required this.row,
    required this.col,
    this.layer = 0,
    this.isMatched = false,
    this.isSelected = false,
    this.isHinted = false,
    this.isMismatched = false,
    this.isPeeked = false,
    this.visibility = TileVisibility.revealed,
    String? uid,
  }) : uid = uid ?? const Uuid().v4();

  bool get isHidden => visibility == TileVisibility.hidden;
  bool get isCovered => visibility == TileVisibility.covered;
  bool get isRevealed => visibility == TileVisibility.revealed;
  bool get isAvailable => !isMatched && isRevealed;

  TileModel copyWith({
    bool? isMatched,
    bool? isSelected,
    bool? isHinted,
    bool? isMismatched,
    bool? isPeeked,
    TileVisibility? visibility,
  }) =>
      TileModel(
        uid: uid,
        def: def,
        row: row,
        col: col,
        layer: layer,
        isMatched: isMatched ?? this.isMatched,
        isSelected: isSelected ?? this.isSelected,
        isHinted: isHinted ?? this.isHinted,
        isMismatched: isMismatched ?? this.isMismatched,
        isPeeked: isPeeked ?? this.isPeeked,
        visibility: visibility ?? this.visibility,
      );
}
