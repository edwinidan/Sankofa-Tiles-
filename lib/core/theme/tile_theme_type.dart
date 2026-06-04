enum TileThemeType {
  classic,
  tileV2Png,
  christmas,
}

extension TileThemeMeta on TileThemeType {
  String get displayName {
    switch (this) {
      case TileThemeType.classic:
        return 'Classic';
      case TileThemeType.tileV2Png:
        return 'Tile V2 PNG Preview';
      case TileThemeType.christmas:
        return 'Christmas Preview';
    }
  }

  String get storedName {
    switch (this) {
      case TileThemeType.classic:
        return 'classic';
      case TileThemeType.tileV2Png:
        return 'tile_v2_png';
      case TileThemeType.christmas:
        return 'christmas';
    }
  }
}

TileThemeType? tileThemeFromName(String? name) {
  for (final theme in TileThemeType.values) {
    if (theme.name == name || theme.storedName == name) return theme;
  }
  return null;
}
