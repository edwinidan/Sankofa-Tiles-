import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/tile_theme_resolver.dart';
import '../core/theme/tile_theme_type.dart';
import '../core/utils/storage_service.dart';
import 'settings_provider.dart';

const _tileThemeEnvironment = String.fromEnvironment(
  'TILE_THEME',
  defaultValue: 'classic',
);

final _environmentTileTheme =
    tileThemeFromName(_tileThemeEnvironment) ?? TileThemeType.classic;

class TileThemeNotifier extends StateNotifier<TileThemeType> {
  final StorageService _storage;

  TileThemeNotifier(this._storage) : super(_initialTheme(_storage));

  static TileThemeType _initialTheme(StorageService storage) {
    try {
      return storage.getTileTheme() ?? _environmentTileTheme;
    } catch (_) {
      return TileThemeType.classic;
    }
  }

  Future<void> setTheme(TileThemeType theme) async {
    state = theme;
    await _storage.setTileTheme(theme);
  }
}

final tileThemeProvider =
    StateNotifierProvider<TileThemeNotifier, TileThemeType>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return TileThemeNotifier(storage);
});

final tileThemeResolverProvider = Provider<TileThemeResolver>((ref) {
  return TileThemeResolver(ref.watch(tileThemeProvider));
});
