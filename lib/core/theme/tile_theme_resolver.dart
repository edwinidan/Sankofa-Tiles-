import '../constants/tile_data.dart';
import 'tile_theme_type.dart';

class TileThemeResolver {
  final TileThemeType theme;

  const TileThemeResolver(this.theme);

  static const _christmasOverrides = <String, String>{
    'gye_nyame': 'assets/tiles/themes/christmas/gye_nyame.png',
    'sankofa': 'assets/tiles/themes/christmas/sankofa.png',
    'akofena': 'assets/tiles/themes/christmas/akofena.png',
  };

  static const _tileV2PngOverrides = <String, String>{
    'aban': 'assets/Tile V2 png/aban-removebg-preview.png',
    'abe_dua': 'assets/Tile V2 png/abe_dua-removebg-preview.png',
    'abode_santann': 'assets/Tile V2 png/abode_santann-removebg-preview.png',
    'abusua_pa': 'assets/Tile V2 png/abusua_pa_-removebg-preview.png',
    'adinkrahene': 'assets/Tile V2 png/adinkrahene-removebg-preview.png',
    'agyindawuru': 'assets/Tile V2 png/agyin_dawuru-removebg-preview.png',
    'akoben': 'assets/Tile V2 png/akoben-removebg-preview.png',
    'denkyem': 'assets/Tile V2 png/denkyem-removebg-preview.png',
    'dwennimmen': 'assets/Tile V2 png/dwennimmen-removebg-preview.png',
    'gye_nyame': 'assets/Tile V2 png/gye_nyame-removebg-preview.png',
    'nea_onnim': 'assets/Tile V2 png/nea_onnim-removebg-preview.png',
    'nkyinkyim': 'assets/Tile V2 png/nkyinkyim-removebg-preview.png',
    'nsoromma': 'assets/Tile V2 png/nsoromma-removebg-preview.png',
    'odo_nnyew_fie_kwan':
        'assets/Tile V2 png/odo_nnyew_fie_kwan-removebg-preview.png',
  };

  String getAssetPath(TileDefinition def) {
    switch (theme) {
      case TileThemeType.classic:
        return def.assetPath!;
      case TileThemeType.tileV2Png:
        return _tileV2PngOverrides[def.id] ?? def.assetPath!;
      case TileThemeType.christmas:
        return _christmasOverrides[def.id] ?? def.assetPath!;
    }
  }
}
