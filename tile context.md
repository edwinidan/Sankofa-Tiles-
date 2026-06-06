# Tile Theme Resolver — Context Audit & Implementation Plan

## 1. Current Asset Situation

### 1.1 File Counts

| Directory | PNG Count | Notes |
|---|---|---|
| `assets/tiles/symbols/` | 18 | v1, mostly 1686×2528 |
| `assets/tiles/symbols/asset v2/` | 36 | v2, all 408×612 |
| **Total** | **54** | Matches the 54 `TileDefinition` entries exactly |

### 1.2 Full Tile Audit Table

All 54 tiles have `assetPath` set. All referenced files exist on disk. **Zero missing files. Zero orphan files.**

| # | tileId | assetPath | File Exists? | Canvas | Notes |
|---|---|---|---|---|---|
| 1 | `nyansapo` | `assets/tiles/symbols/asset v2/nyansapo.png` | Yes | 408×612 | v2 |
| 2 | `nkyinkyim` | `assets/tiles/symbols/nkyinkyim.png` | Yes | 1686×2528 | v1 |
| 3 | `mate_masie` | `assets/tiles/symbols/asset v2/matse_masie.png` | Yes | 408×612 | Filename mismatch: `matse` vs `mate` |
| 4 | `hwehwemudua` | `assets/tiles/symbols/asset v2/hwehwemedua.png` | Yes | 408×612 | Filename mismatch: `mudua` vs `medua` |
| 5 | `nea_onnim` | `assets/tiles/symbols/nea_onnim.png` | Yes | 1686×2528 | v1 |
| 6 | `ese_tekrema` | `assets/tiles/symbols/asset v2/ese_ne_trema.png` | Yes | 408×612 | v2 |
| 7 | `nteasee` | `assets/tiles/symbols/asset v2/nteasee.png` | Yes | 408×612 | v2 |
| 8 | `sankofa` | `assets/tiles/symbols/sankofa.png` | Yes | 1684×2528 | v1 |
| 9 | `denkyem` | `assets/tiles/symbols/denkyem.png` | Yes | 1686×2528 | v1 |
| 10 | `abe_dua` | `assets/tiles/symbols/abe_dua.png` | Yes | 1686×2528 | v1 |
| 11 | `nyame_dua` | `assets/tiles/symbols/asset v2/nyame_dua.png` | Yes | 408×612 | v2 |
| 12 | `adinkrahene` | `assets/tiles/symbols/adinkrahene.png` | Yes | 1684×2528 | v1 |
| 13 | `akofena` | `assets/tiles/symbols/akofena.png` | Yes | 1686×2528 | v1 |
| 14 | `aban` | `assets/tiles/symbols/aban.png` | Yes | 1686×2528 | v1 |
| 15 | `fawohodie` | `assets/tiles/symbols/asset v2/fawohodie-removebg-preview.png` | Yes | 408×612 | Has `-removebg-preview` suffix |
| 16 | `funtumfunefu` | `assets/tiles/symbols/funtumfunefu_denkyemfunefu.png` | Yes | 1686×2528 | v1, extra suffix in filename |
| 17 | `mpuannum` | `assets/tiles/symbols/asset v2/mpuannum.png` | Yes | 408×612 | v2 |
| 18 | `nyame_nwu` | `assets/tiles/symbols/asset v2/nyame_nwu_na_mawu.png` | Yes | 408×612 | Extra suffix `_na_mawu` |
| 19 | `gye_nyame` | `assets/tiles/symbols/gye_nyame.png` | Yes | 408×612 | v1 dir but v2-size canvas |
| 20 | `dwennimmen` | `assets/tiles/symbols/dwennimmen.png` | Yes | 1686×2528 | v1 |
| 21 | `mpatapo` | `assets/tiles/symbols/asset v2/mpatapo.png` | Yes | 408×612 | v2 |
| 22 | `hye_wo_nhye` | `assets/tiles/symbols/asset v2/hye_wo_nhye.png` | Yes | 408×612 | v2 |
| 23 | `akoben` | `assets/tiles/symbols/akoben.png` | Yes | 1686×2528 | v1 |
| 24 | `nsoromma` | `assets/tiles/symbols/nsoromma.png` | Yes | 1686×2528 | v1 |
| 25 | `adwo` | `assets/tiles/symbols/adwo.png` | Yes | 1686×2528 | v1 |
| 26 | `abusua_pa` | `assets/tiles/symbols/abusua_pa.png` | Yes | 1686×2528 | v1 |
| 27 | `agyindawuru` | `assets/tiles/symbols/agyindawuru.png` | Yes | 1686×2528 | v1 |
| 28 | `abode_santann` | `assets/tiles/symbols/abode_santann.png` | Yes | 1686×2528 | v1 |
| 29 | `odo_nnyew_fie_kwan` | `assets/tiles/symbols/odo_nnyew_fie_kwan.png` | Yes | 1684×2528 | v1 |
| 30 | `nsaa` | `assets/tiles/symbols/asset v2/nsaa.png` | Yes | 408×612 | v2 |
| 31 | `nyame_nti` | `assets/tiles/symbols/asset v2/Nyame_nti.png` | Yes | 408×612 | Capitalization mismatch: `Nyame` vs `nyame` |
| 32 | `nyame_biribi_wo_soro` | `assets/tiles/symbols/asset v2/nyame_biribi_wo_soro.png` | Yes | 408×612 | v2 |
| 33 | `nkyemu` | `assets/tiles/symbols/asset v2/nkyemu.png` | Yes | 408×612 | v2 |
| 34 | `nkotimsefo_mpua` | `assets/tiles/symbols/asset v2/nkotimsefo_mpua.png` | Yes | 408×612 | v2 |
| 35 | `nkrabea` | `assets/tiles/symbols/asset v2/nkrabea.png` | Yes | 408×612 | v2 |
| 36 | `mmeranmubere` | `assets/tiles/symbols/asset v2/mmeranmubere.png` | Yes | 408×612 | v2 |
| 37 | `nea_ope_se_obedi_hene` | `assets/tiles/symbols/asset v2/nea_ope_se_obedi_hene.png` | Yes | 408×612 | v2 |
| 38 | `mmere_dane` | `assets/tiles/symbols/asset v2/mmere_dane.png` | Yes | 408×612 | v2 |
| 39 | `mako` | `assets/tiles/symbols/asset v2/mako.png` | Yes | 408×612 | v2 |
| 40 | `fafanto` | `assets/tiles/symbols/asset v2/fafanto.png` | Yes | 408×612 | v2 |
| 41 | `fihankra` | `assets/tiles/symbols/asset v2/fihankra.png` | Yes | 408×612 | v2 |
| 42 | `fofo` | `assets/tiles/symbols/asset v2/fofo.png` | Yes | 408×612 | v2 |
| 43 | `kete_pa` | `assets/tiles/symbols/asset v2/kete_pa.png` | Yes | 408×612 | v2 |
| 44 | `kokuromotie` | `assets/tiles/symbols/asset v2/kokuromotie.png` | Yes | 408×612 | v2 |
| 45 | `kramo_bone` | `assets/tiles/symbols/asset v2/kramo_bone_amma_yeanhu_kramo_pa.png` | Yes | 408×612 | Extra suffix |
| 46 | `krapa_musuyidee` | `assets/tiles/symbols/asset v2/krapa__musuyidee.png` | Yes | 408×612 | Double underscore in filename |
| 47 | `kwatakye_atiko` | `assets/tiles/symbols/asset v2/kwatakye_atiko.png` | Yes | 408×612 | v2 |
| 48 | `kyemfere` | `assets/tiles/symbols/asset v2/kyemfere.png` | Yes | 408×612 | v2 |
| 49 | `mekyea_wo` | `assets/tiles/symbols/asset v2/mekyea_wo-removebg-preview.png` | Yes | 408×612 | Has `-removebg-preview` suffix |
| 50 | `menso_wo_kenten` | `assets/tiles/symbols/asset v2/menso_wo_kenten.png` | Yes | 408×612 | v2 |
| 51 | `mmeremutene` | `assets/tiles/symbols/asset v2/mmeremutene.png` | Yes | 408×612 | v2 |
| 52 | `nea_oretwa_sa` | `assets/tiles/symbols/asset v2/nea_oretwa_sa.png` | Yes | 408×612 | v2 |
| 53 | `nserewa` | `assets/tiles/symbols/asset v2/nserewa.png` | Yes | 408×612 | v2 |
| 54 | `nyame_baatanpa` | `assets/tiles/symbols/asset v2/nyame_baatanpa.png` | Yes | 408×612 | v2 |

### 1.3 Filename Inconsistency Issues (9 total)

These don't cause bugs — the `assetPath` string is hardcoded per tile. But they matter for a resolver that constructs paths from `tileId + theme`:

| tileId | Expected convention (`tileId.png`) | Actual filename | Issue |
|---|---|---|---|
| `mate_masie` | `mate_masie.png` | `matse_masie.png` | Spelling: `matse` vs `mate` |
| `hwehwemudua` | `hwehwemudua.png` | `hwehwemedua.png` | Spelling: `medua` vs `mudua` |
| `funtumfunefu` | `funtumfunefu.png` | `funtumfunefu_denkyemfunefu.png` | Extra suffix |
| `nyame_nwu` | `nyame_nwu.png` | `nyame_nwu_na_mawu.png` | Extra suffix |
| `kramo_bone` | `kramo_bone.png` | `kramo_bone_amma_yeanhu_kramo_pa.png` | Extra suffix |
| `fawohodie` | `fawohodie.png` | `fawohodie-removebg-preview.png` | `-removebg-preview` suffix |
| `mekyea_wo` | `mekyea_wo.png` | `mekyea_wo-removebg-preview.png` | `-removebg-preview` suffix |
| `nyame_nti` | `nyame_nti.png` | `Nyame_nti.png` | Capitalization: `N` vs `n` |
| `krapa_musuyidee` | `krapa_musuyidee.png` | `krapa__musuyidee.png` | Double underscore |

**Recommendation:** A theme resolver should NOT construct filenames from `tileId`. Instead, it should use an explicit map or accept that these 9 tiles have non-standard filenames and handle them as overrides. The cleanest approach: keep the classic theme using the existing `assetPath` values as-is, and require new themes to follow the `tileId.png` convention.

---

## 2. Current Rendering Dependency

### 2.1 Data Flow

```
tile_data.dart          → Defines TileDefinition with assetPath
game_provider.dart      → Creates TileModel instances (TileModel.def = TileDefinition)
board_widget.dart       → Passes TileModel to TileWidget (no assetPath access)
tile_widget.dart        → Reads tile.def.assetPath, passes to Image.asset()
```

### 2.2 Every Place `assetPath` Is Used Directly

| File | Lines | Usage |
|---|---|---|
| `tile_data.dart` | 25–88 | Defined in all 54 `TileDefinition` constants |
| `tile_widget.dart` | 263, 271, 349, 354 | **Image tile path** (263–271) and **Fallback content path** (349, 354) — both read `tile.def.assetPath` |
| `tile_preview_screen.dart` | 43, 45, 80 | Large preview image and "PNG asset" label |

**Total: 2 files (7 lines) access `assetPath` at runtime.** All rendering is mediated through `TileWidget` and `TilePreviewScreen`.

### 2.3 What Does NOT Use `assetPath`

- `board_widget.dart` — only passes `TileModel`, never reads `def.assetPath`
- `game_provider.dart` — uses `def.id` for matching, never touches `assetPath`
- `board_solver.dart` — free-tile detection uses position only, not definition
- `level_data.dart` — references tiles by `tileId` strings, not asset paths
- `tile_model.dart` — holds `TileDefinition` reference but doesn't read `assetPath`
- `tile_back.dart` — hardcoded to `assets/tiles/tile_back.svg`, no per-tile path

**Key insight:** Matching logic uses `def.id` (not `assetPath`). The resolver affects zero game logic.

---

## 3. Resolver Readiness Assessment

| Question | Answer |
|---|---|
| Can we add `TileThemeResolver` without changing game logic? | **Yes.** Matching uses `tile.def.id`, not `assetPath` |
| Will it affect matching logic? | **No.** `game_provider.dart:276` checks `firstTile.def.id == secondTile.def.id` |
| Will it affect solvability logic? | **No.** `BoardSolver` works on positions, not tile appearances |
| Will it affect level data? | **No.** Levels reference tiles by `tileId` strings |
| Will it affect board layout? | **No.** Layout is purely positional |
| Will it affect tile preview screen? | **Yes.** `tile_preview_screen.dart` directly uses `def.assetPath` — needs updating |
| Will it affect fallback rendering when `assetPath` is null? | **No.** The fallback path in `tile_widget.dart:279-318` is only hit when `assetPath` is null, which never happens currently. The resolver would always return a path |

### Verdict

**The project is well-prepared for a resolver system.** The separation between "what a tile is" (`id`) and "how it looks" (`assetPath`) already exists in the data model. Adding a resolver just moves the "how it looks" decision from a hardcoded field to a theme-aware function.

---

## 4. Recommended Architecture

### 4.1 File Layout

```text
lib/
  core/
    theme/
      tile_theme_type.dart      ← enum + theme metadata
      tile_theme_resolver.dart  ← maps (tileId, theme) → assetPath
  providers/
    tile_theme_provider.dart    ← state notifier for active theme
```

### 4.2 `TileThemeType` (`lib/core/theme/tile_theme_type.dart`)

```dart
enum TileThemeType {
  classic,
  // Future: christmas, gold, halloween, etc.
}

extension TileThemeMeta on TileThemeType {
  String get displayName => switch (this) {
    TileThemeType.classic => 'Classic',
  };

  String get assetSubdirectory => switch (this) {
    TileThemeType.classic => '', // uses existing paths
    // Future themes: 'themes/christmas/', 'themes/gold/', etc.
  };
}
```

### 4.3 `TileThemeResolver` (`lib/core/theme/tile_theme_resolver.dart`)

```dart
class TileThemeResolver {
  final TileThemeType theme;

  const TileThemeResolver(this.theme);

  /// Returns the asset path for a tile under the active theme.
  /// Falls back gracefully: new theme → theme-specific file → classic file.
  String getAssetPath(TileDefinition def) {
    switch (theme) {
      case TileThemeType.classic:
        return def.assetPath!; // existing behavior, unchanged

      // Future themes:
      // case TileThemeType.christmas:
      //   return 'assets/tiles/themes/christmas/${def.id}.png';
    }
  }
}
```

### 4.4 `TileThemeProvider` (`lib/providers/tile_theme_provider.dart`)

```dart
final tileThemeProvider = StateProvider<TileThemeType>((ref) {
  return TileThemeType.classic;
});

final tileThemeResolverProvider = Provider<TileThemeResolver>((ref) {
  final theme = ref.watch(tileThemeProvider);
  return TileThemeResolver(theme);
});
```

### 4.5 Asset Directory Convention for Future Themes

```text
assets/tiles/
  symbols/            ← classic theme (existing, unchanged)
  symbols/asset v2/   ← classic theme v2 (existing, unchanged)
  themes/             ← new directory for future themes
    christmas/        ← e.g., gye_nyame.png, sankofa.png, ...
    gold/
    halloween/
```

New theme PNGs should:
- Be named `{tileId}.png` (clean convention, unlike the current 9 mismatches)
- Be 408×612 canvas with padding matching the v2 style (so `scale: 1.634` works consistently)
- Have transparent backgrounds

New themes don't need to provide all 54 tiles — the resolver can fall back to the classic asset for any missing file.

---

## 5. Existing PNG Considerations

### 5.1 Canvas Size Breakdown

| Group | Count | Canvas | Aspect Ratio |
|---|---|---|---|
| v1 large | 17 | 1686×2528 | 0.667 |
| v1 small | 1 (`gye_nyame.png`) | 408×612 | 0.667 |
| v2 | 36 | 408×612 | 0.667 |

All 54 PNGs share the same aspect ratio (0.667). The v1 files are just ~4x higher resolution.

### 5.2 What `scale: 1.634` Does

Tile rendering dimensions: **64×85** (aspect ratio = 0.753)

The PNGs are 0.667 aspect ratio, which is narrower than the tile face. The symbols within the PNGs occupy roughly 61% of the canvas width/height (centered with transparent padding).

- `1 / 0.61 ≈ 1.639` → very close to the actual `1.634` scale factor

**Conclusion:** `Transform.scale(1.634)` exists to crop out transparent padding built into the PNGs, making the symbol fill the tile face. The `ClipRect` then cuts anything that overflows.

### 5.3 Implications for New Theme PNGs

| Requirement | Detail |
|---|---|
| **Canvas size** | 408×612 is the canonical size (36 of 54 tiles use it). New themes should match this |
| **Aspect ratio** | Must be 0.667 (408÷612) — same as all existing PNGs |
| **Symbol placement** | Centered with ~39% transparent padding around it (to work with the existing `scale: 1.634`) |
| **Background** | Transparent (the tile face color #F5E6C8 is rendered behind the PNG) |
| **Keep scale: 1.634 for now** | It's a workaround for the padding convention. Remove it later only if new PNGs are created without padding and fill the full 408×612 |

### 5.4 v1 Migration Consideration

The 17 v1 tiles at 1686×2528 are oversized (1–1.6 MB each vs v2's ~200 KB). They work fine because Flutter downscales, but they bloat the app bundle (~23 MB just for these 17 files). A future optimization could replace them with 408×612 versions, but **do not do this as part of the resolver work** — it's a separate asset cleanup task.

---

## 6. Phased Implementation Plan

### Phase 1: Add resolver infrastructure (no visual change)

**Files:**
- NEW: `lib/core/theme/tile_theme_type.dart`
- NEW: `lib/core/theme/tile_theme_resolver.dart`
- NEW: `lib/providers/tile_theme_provider.dart`

**Risk:** Zero. New files only, nothing wired in.

**Test:** `flutter analyze` passes. Unit test for resolver returns correct paths.

**Expected behavior:** No change. Resolver exists but nothing calls it.

---

### Phase 2: Wire TileWidget to use resolver

**Files:**
- MODIFY: `lib/screens/game/widgets/tile_widget.dart` (lines 263, 271, 349, 354)
  - Replace `tile.def.assetPath!` with `resolver.getAssetPath(tile.def)`
  - Inject resolver via Riverpod `ref.watch(tileThemeResolverProvider)`

**Risk:** Low. Only rendering path changes, and resolver returns the same values.

**Test:** Play a level. Tiles look identical. `flutter analyze` passes.

**Expected behavior:** Game looks exactly the same. `assetPath` is still the source of truth for the classic theme.

---

### Phase 3: Update tile preview screen

**Files:**
- MODIFY: `lib/screens/preview/tile_preview_screen.dart` (lines 43–45, 80)
  - Use resolver for the large preview image
  - The "PNG asset" label logic stays (just checks resolver result is non-null)

**Risk:** Low.

**Test:** Open tile preview from lobby. All 54 tiles display correctly.

**Expected behavior:** Preview looks identical to current.

---

### Phase 4: Add fallback safety

**Files:**
- MODIFY: `lib/core/theme/tile_theme_resolver.dart`
  - Add try/catch or asset-existence check
  - If theme PNG doesn't exist, fall back to classic `assetPath`

**Risk:** Low.

**Test:** Hardcode a bogus theme, verify it gracefully falls back.

**Expected behavior:** Missing theme files silently fall back to classic.

---

### Phase 5: Add sample alternate theme (1–3 tiles)

**Files:**
- NEW: `assets/tiles/themes/christmas/` (1–3 test PNGs)
- MODIFY: `pubspec.yaml` (register the new directory)
- MODIFY: `lib/core/theme/tile_theme_type.dart` (add `christmas` enum value)
- MODIFY: `lib/core/theme/tile_theme_resolver.dart` (add christmas path logic)
- MODIFY: `lib/providers/tile_theme_provider.dart` (add theme toggle for testing)

**Risk:** Low–Medium. First time real alternative PNGs render.

**Test:** Toggle to christmas theme. The 1–3 tiles with christmas PNGs show the new face. All other tiles show classic face (fallback). Toggle back. `flutter analyze` passes.

**Expected behavior:** Partial theme coverage works. Fallback is seamless.

---

### Phase 6: Settings/theme selector (future)

**Files:**
- MODIFY: Settings screen
- MODIFY: `lib/providers/settings_provider.dart` (persist theme choice)
- MODIFY: `lib/providers/tile_theme_provider.dart` (read from settings)

**Risk:** Medium (UI change, persistence).

**Do not implement now.** This is noted for planning purposes.

---

## 7. Minimal First Implementation (Phase 1 Only)

### What to create

Three new files. Zero modifications to existing files.

#### File 1: `lib/core/theme/tile_theme_type.dart`

```dart
enum TileThemeType {
  classic,
}

extension TileThemeMeta on TileThemeType {
  String get displayName => switch (this) {
    TileThemeType.classic => 'Classic',
  };
}
```

#### File 2: `lib/core/theme/tile_theme_resolver.dart`

```dart
import '../constants/tile_data.dart';

class TileThemeResolver {
  final TileThemeType theme;

  const TileThemeResolver(this.theme);

  String getAssetPath(TileDefinition def) {
    switch (theme) {
      case TileThemeType.classic:
        return def.assetPath!;
    }
  }
}
```

#### File 3: `lib/providers/tile_theme_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/tile_theme_type.dart';
import '../core/theme/tile_theme_resolver.dart';

final tileThemeProvider = StateProvider<TileThemeType>((ref) {
  return TileThemeType.classic;
});

final tileThemeResolverProvider = Provider<TileThemeResolver>((ref) {
  final theme = ref.watch(tileThemeProvider);
  return TileThemeResolver(theme);
});
```

### Verification

- `flutter analyze` — no issues
- `flutter test` — existing tests pass
- No visual change to the app
- Resolver is ready for Phase 2 wiring

---

## 8. Risks & Prerequisites Before Holiday Themes

| Risk | Severity | Mitigation |
|---|---|---|
| **9 filename inconsistencies** | Medium | Resolver must use the existing `assetPath` for classic theme, not construct from `tileId`. New themes should use clean `tileId.png` convention |
| **`scale: 1.634` padding assumption** | Medium | Document the ~39% padding requirement. New theme PNGs must match the 408×612 canvas with centered symbol and padding |
| **`-removebg-preview` suffixes** | Low | These 2 files work fine. No action needed unless renaming, which is out of scope |
| **v1 vs v2 canvas sizes** | Low | Both work because Flutter handles scaling. v1 files are just larger on disk |
| **Two rendering paths in `tile_widget.dart`** | Low | The Image path (263–271) and fallback Content path (349–354) both use `assetPath`. Both must be updated together in Phase 2 |
| **`tile_preview_screen.dart` direct access** | Low | Must be updated in Phase 3 |
| **`TileBackWidget` hardcoded SVG** | None | Tile back is theme-independent. No change needed |

---

## 9. Verification Results

```
flutter analyze  → No issues found! (2.5s)
flutter test     → All tests passed! (1 test)
```

- 0 analysis errors
- 0 analysis warnings
- 1/1 tests passing (placeholder widget test)
- All 54 assetPath values resolve to existing files on disk
- All 54 PNGs follow the same aspect ratio (0.667)
- Matching logic (`def.id`) is completely separate from rendering (`def.assetPath`)

---

## 10. Summary

| Finding | Answer |
|---|---|
| Is the project ready for a resolver? | **Yes.** Data model separates identity from appearance |
| Will it break game logic? | **No.** Matching uses `tile.def.id`, not `assetPath` |
| How many files touch `assetPath`? | **2 files, 7 lines** (`tile_widget.dart`, `tile_preview_screen.dart`) |
| Are assets consistent? | **54/54 files match, 9 have filename quirks** — all manageable |
| Does `scale: 1.634` matter? | **Yes.** Keep it. It compensates for PNG padding |
| What canvas size for new themes? | **408×612** with centered symbol and ~39% transparent padding |
| Safest first step? | **Create 3 new files** (type, resolver, provider). Touch nothing existing |
