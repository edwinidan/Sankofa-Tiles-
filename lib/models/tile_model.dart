import 'package:uuid/uuid.dart';
import '../core/constants/tile_data.dart';

class TileModel {
  final String uid;
  final TileDefinition def;
  final bool isMatched;
  final bool isSelected;
  final bool isHinted;
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
    String? uid,
  }) : uid = uid ?? const Uuid().v4();

  bool get isAvailable => !isMatched;

  TileModel copyWith({
    bool? isMatched,
    bool? isSelected,
    bool? isHinted,
  }) => TileModel(
    uid: uid,
    def: def,
    row: row,
    col: col,
    layer: layer,
    isMatched: isMatched ?? this.isMatched,
    isSelected: isSelected ?? this.isSelected,
    isHinted: isHinted ?? this.isHinted,
  );
}
