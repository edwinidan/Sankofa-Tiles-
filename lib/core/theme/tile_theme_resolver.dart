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
    'akoma': 'assets/Tile V2 png.2/akoma-removebg-preview.png',
    'akoma_ntoaso': 'assets/Tile V2 png.2/akoma_ntoaso-removebg-preview.png',
    'ananse_ntentan':
        'assets/Tile V2 png.2/ananse_ntentan-removebg-preview.png',
    'ani_bere_a_enso_gya':
        'assets/Tile V2 png.2/ani_bere_a_enso_gya-removebg-preview.png',
    'anyi_me_aye_a': 'assets/Tile V2 png.2/anyi_me_aye_a-removebg-preview.png',
    'aponkyerene_wu_a':
        'assets/Tile V2 png.2/aponkyerene_wu_a-removebg-preview.png',
    'asaawa': 'assets/Tile V2 png.2/asaawa-removebg-preview.png',
    'asae_ye_duru': 'assets/Tile V2 png.2/asae_ye_duru-removebg-preview.png',
    'asetena_pa': 'assets/Tile V2 png.2/asetena_pa_-removebg-preview.png',
    'aya': 'assets/Tile V2 png.2/aya-removebg-preview.png',
    'bese_saka': 'assets/Tile V2 png.2/bese_saka-removebg-preview.png',
    'bi_nka_bi': 'assets/Tile V2 png.2/bi_nka_bi-removebg-preview.png',
    'boa_me_na_me_mmoa_wo':
        'assets/Tile V2 png.2/boa_me_na_me_mmoa_wo-removebg-preview.png',
    'boafo_ye_na': 'assets/Tile V2 png.2/boafo_ye_na-removebg-preview.png',
    'dame_dame': 'assets/Tile V2 png.2/dame_dame_-removebg-preview.png',
    'dono': 'assets/Tile V2 png.2/dono-removebg-preview.png',
    'dono_ntoaso': 'assets/Tile V2 png.2/dono_ntoaso-removebg-preview.png',
    'duafe': 'assets/Tile V2 png.2/duafe-removebg-preview.png',
    'dwantire': 'assets/Tile V2 png.2/dwantire-removebg-preview.png',
    'eban': 'assets/Tile V2 png.2/eban-removebg-preview.png',
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
