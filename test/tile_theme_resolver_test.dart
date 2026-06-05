import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/theme/tile_theme_resolver.dart';
import 'package:sankofa_tiles/core/theme/tile_theme_type.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/providers/settings_provider.dart';
import 'package:sankofa_tiles/providers/tile_theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const classicResolver = TileThemeResolver(TileThemeType.classic);
  const tileV2PngResolver = TileThemeResolver(TileThemeType.tileV2Png);
  const christmasResolver = TileThemeResolver(TileThemeType.christmas);

  TileDefinition tile(String id) => kAllTiles.firstWhere((def) => def.id == id);

  Future<StorageService> createStorage(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    final storage = StorageService();
    await storage.init();
    return storage;
  }

  test('classic theme preserves the definition asset path', () {
    final def = tile('mate_masie');

    expect(classicResolver.getAssetPath(def), def.assetPath);
  });

  test('christmas theme uses an available override', () {
    expect(
      christmasResolver.getAssetPath(tile('gye_nyame')),
      'assets/tiles/themes/christmas/gye_nyame.png',
    );
  });

  test('christmas theme falls back to the classic asset path', () {
    final def = tile('mate_masie');

    expect(christmasResolver.getAssetPath(def), def.assetPath);
  });

  test('tile V2 PNG theme uses a confident override', () {
    expect(
      tileV2PngResolver.getAssetPath(tile('gye_nyame')),
      'assets/Tile V2 png/gye_nyame-removebg-preview.png',
    );
  });

  test('tile V2 PNG theme falls back for missing or ambiguous assets', () {
    final missingDef = tile('mate_masie');
    final ambiguousDef = tile('akofena');

    expect(tileV2PngResolver.getAssetPath(missingDef), missingDef.assetPath);
    expect(
      tileV2PngResolver.getAssetPath(ambiguousDef),
      ambiguousDef.assetPath,
    );
  });

  test('tile V2 PNG stored name parses correctly', () {
    expect(tileThemeFromName('tile_v2_png'), TileThemeType.tileV2Png);
  });

  test('theme provider uses TILE_THEME when there is no saved selection',
      () async {
    const environmentTheme = String.fromEnvironment(
      'TILE_THEME',
      defaultValue: 'classic',
    );
    final expectedTheme =
        tileThemeFromName(environmentTheme) ?? TileThemeType.classic;
    final storage = await createStorage({});
    final container = ProviderContainer(overrides: [
      storageServiceProvider.overrideWithValue(storage),
    ]);
    addTearDown(container.dispose);

    expect(container.read(tileThemeProvider), expectedTheme);
  });

  test('saved theme takes priority over TILE_THEME', () async {
    final storage = await createStorage({'tile_theme': 'christmas'});
    final container = ProviderContainer(overrides: [
      storageServiceProvider.overrideWithValue(storage),
    ]);
    addTearDown(container.dispose);

    expect(container.read(tileThemeProvider), TileThemeType.christmas);
  });

  test('changing theme updates provider state and persists the choice',
      () async {
    final storage = await createStorage({});
    final container = ProviderContainer(overrides: [
      storageServiceProvider.overrideWithValue(storage),
    ]);
    addTearDown(container.dispose);

    await container
        .read(tileThemeProvider.notifier)
        .setTheme(TileThemeType.tileV2Png);

    expect(container.read(tileThemeProvider), TileThemeType.tileV2Png);
    expect(storage.getTileTheme(), TileThemeType.tileV2Png);
  });

  test('tile V2 PNG persists using tile_v2_png under tile_theme', () async {
    final storage = await createStorage({});

    await storage.setTileTheme(TileThemeType.tileV2Png);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('tile_theme'), 'tile_v2_png');
  });

  test('invalid saved theme falls back to TILE_THEME or classic', () async {
    const environmentTheme = String.fromEnvironment(
      'TILE_THEME',
      defaultValue: 'classic',
    );
    final expectedTheme =
        tileThemeFromName(environmentTheme) ?? TileThemeType.classic;
    final storage = await createStorage({'tile_theme': 'invalid'});
    final container = ProviderContainer(overrides: [
      storageServiceProvider.overrideWithValue(storage),
    ]);
    addTearDown(container.dispose);

    expect(container.read(tileThemeProvider), expectedTheme);
  });

  test('theme display names are user-facing', () {
    expect(TileThemeType.classic.displayName, 'Classic');
    expect(TileThemeType.tileV2Png.displayName, 'Tile V2');
    expect(TileThemeType.christmas.displayName, 'Christmas Preview');
  });
}
