# Ghana Heritage tiles

Eight portrait tiles join the existing 97 Adinkra definitions. Matching remains
by identical tile ID, with no additional powers or scoring rules.

| First appearance and collection reward | Portrait |
| --- | --- |
| 21 | Kwame Nkrumah |
| 41 | Yaa Asantewaa |
| 61 | Naa Dedei |
| 81 | J. B. Danquah |
| 101 | Edward Akufo-Addo |
| 121 | Ebenezer Ako-Adjei |
| 141 | Emmanuel Obetsebi-Lamptey |
| 161 | William Ofori Atta |

One heritage pair appears on levels 21, 26, 31, 36, 41 and every five levels
thereafter. Each portrait is guaranteed on its debut; subsequent appearances
rotate among eligible portraits. All other boards retain their original decks.
Board layouts, tile totals and symbol-pool sizes remain unchanged. Where needed,
extra copies of the replaced Adinkra face move to another Adinkra face so the
heritage portrait has exactly two copies.

The collection reward is granted on completing the debut level. Existing
progress receives eligible portraits through the collection's normal additive
backfill. Existing Adinkra milestone levels and frozen legacy entitlements are
preserved. Saved boards retain their serialized faces; newly started boards use
the new schedule.

## Artwork

Runtime assets are in `assets/tiles/heritage/`. They are copied from the approved
transparent PNG samples in `output/imagegen/`; the original samples remain there.
Yaa Asantewaa uses `yaa-asantewaa-tile-v3.png`, the head-to-waist adaptation of
the user's chosen reference. Names and short descriptions appear in the shared
Tile Collection, with Ghana Heritage labels and portrait unlock cards.

Reference-photo credits and the mapping to approved samples are bundled in
`assets/tiles/heritage/credits.json`. The Big Six sample manifest records the
individual photographic references in
`output/imagegen/big-six/generation-manifest.json`.

Biographical descriptions use the [Bank of Ghana's Big Six listing](https://www.bog.gov.gh/bank-notes-coins/features-of-currency-notes/)
and [Encyclopaedia Africana's Yaa Asantewaa entry](https://encyclopaediaafricana.com/asantewaa-yaa/).
The coin-inspired Naa Dedei artwork is an artistic tribute; the Bank of Ghana
describes the coin motif as a market woman. The user-selected Yaa Asantewaa
reference is treated as an artistic interpretation, not a verified photograph.

## Validation

`test/heritage_tiles_test.dart` checks the full campaign's heritage cadence,
exact pair counts, all eight debut gates, asset decoding, runtime board
solvability, saved-game round trips and additive veteran unlocks.
`test/heritage_collection_ui_test.dart` checks collection discovery and all eight
portrait reveal cards. `test/tile_unlock_rules_test.dart` also verifies that
all original Adinkra milestone levels and legacy entitlements stay unchanged.
