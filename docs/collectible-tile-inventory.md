# Collectible Tile Inventory and Unlock Schedule

Verified 2026-07-12 against `lib/core/constants/tile_data.dart`. The catalogue contains exactly **97 IDs and 97 definitions**. Both sets are unique and identical. All 97 are displayed by the collection UI and all are collectible. There are no tutorial-only, placeholder, deprecated, duplicate, hidden, theme-specific, reserved, or excluded definitions. Tutorial boards reuse ordinary catalogue entries. The earlier approximate count of 98 was an audit counting error; the 10 + 87 roadmap omitted nothing.

Before this change the shipped schedule had no true first-launch defaults: its first ten faces unlocked together after Level 1. The new schedule makes those ten a Level-0 starter collection.

| Tile ID | Display name | Collectible | Current default-unlocked | Proposed milestone | Exclusion reason |
|---|---|---|---|---:|---|
| aban | Aban | Yes | Yes | Starter (Level 0) | — |
| abe_dua | Abe Dua | Yes | Yes | Starter (Level 0) | — |
| abode_santann | Abode Santann | Yes | Yes | Starter (Level 0) | — |
| abusua_pa | Abusua Pa | Yes | Yes | Starter (Level 0) | — |
| adinkrahene | Adinkrahene | Yes | Yes | Starter (Level 0) | — |
| agyindawuru | Agyindawuru | Yes | Yes | Starter (Level 0) | — |
| akoben | Akoben | Yes | Yes | Starter (Level 0) | — |
| denkyem | Denkyem | Yes | Yes | Starter (Level 0) | — |
| dwennimmen | Dwennimmen | Yes | Yes | Starter (Level 0) | — |
| gye_nyame | Gye Nyame | Yes | Yes | Starter (Level 0) | — |
| nea_onnim | Nea Onnim | Yes | No | 4 | — |
| nkyinkyim | Nkyinkyim | Yes | No | 9 | — |
| nsoromma | Nsoromma | Yes | No | 13 | — |
| odo_nnyew_fie_kwan | Odo Nnyew Fie Kwan | Yes | No | 18 | — |
| akoma | Akoma | Yes | No | 22 | — |
| akoma_ntoaso | Akoma Ntoaso | Yes | No | 27 | — |
| ananse_ntentan | Ananse Ntentan | Yes | No | 32 | — |
| ani_bere_a_enso_gya | Ani Bere A Enso Gya | Yes | No | 36 | — |
| anyi_me_aye_a | Anyi Me Aye A | Yes | No | 41 | — |
| aponkyerene_wu_a | Aponkyerene Wu A | Yes | No | 45 | — |
| asaawa | Asaawa | Yes | No | 50 | — |
| asae_ye_duru | Asase Ye Duru | Yes | No | 55 | — |
| asetena_pa | Asetena Pa | Yes | No | 59 | — |
| aya | Aya | Yes | No | 64 | — |
| bese_saka | Bese Saka | Yes | No | 68 | — |
| bi_nka_bi | Bi Nka Bi | Yes | No | 73 | — |
| boa_me_na_me_mmoa_wo | Boa Me Na Me Mmoa Wo | Yes | No | 78 | — |
| boafo_ye_na | Boafo Ye Na | Yes | No | 82 | — |
| dame_dame | Dame Dame | Yes | No | 87 | — |
| dono | Dono | Yes | No | 91 | — |
| dono_ntoaso | Dono Ntoaso | Yes | No | 96 | — |
| duafe | Duafe | Yes | No | 101 | — |
| dwantire | Dwantire | Yes | No | 105 | — |
| eban | Eban | Yes | No | 110 | — |
| akofena | Akofena | Yes | No | 115 | — |
| akoko_nan | Akoko Nan | Yes | No | 119 | — |
| funtumfunefu_denkyemfunefu | Funtumfunefu Denkyemfunefu | Yes | No | 124 | — |
| sankofa2 | Sankofa | Yes | No | 128 | — |
| fawohodie | Fawohodie | Yes | No | 133 | — |
| fafanto | Fafanto | Yes | No | 138 | — |
| fihankra | Fihankra | Yes | No | 142 | — |
| fofo | Fofo | Yes | No | 147 | — |
| epa | Epa | Yes | No | 151 | — |
| ese_ne_tekrema | Ese Ne Tekrema | Yes | No | 156 | — |
| esono_anatam | Esono Anatam | Yes | No | 161 | — |
| gyamu_atiko | Gyamu Atiko | Yes | No | 165 | — |
| hwehwemudua | Hwehwemudua | Yes | No | 170 | — |
| hye_wo_nhye | Hye Wo Nhye | Yes | No | 174 | — |
| kete_pa | Kete Pa | Yes | No | 179 | — |
| kokuromotie | Kokuromotie | Yes | No | 184 | — |
| kramo_bone_amma_yeanhu_kramo_pa | Kramo Bone Amma Yeanhu Kramo Pa | Yes | No | 188 | — |
| krapa | Krapa | Yes | No | 193 | — |
| kuronti_ne_akwamu | Kuronti Ne Akwamu | Yes | No | 197 | — |
| kyemfere | Kyemfere | Yes | No | 202 | — |
| mako | Mako | Yes | No | 207 | — |
| mate_masie | Mate Masie | Yes | No | 211 | — |
| mekyea_wo | Mekyea Wo | Yes | No | 216 | — |
| menso_wo_kenten | Menso Wo Kenten | Yes | No | 220 | — |
| mframadan | Mframadan | Yes | No | 225 | — |
| mmeramubere | Mmeramubere | Yes | No | 230 | — |
| mmeramutene | Mmeramutene | Yes | No | 234 | — |
| mmere_dane | Mmere Dane | Yes | No | 239 | — |
| mpatapo | Mpatapo | Yes | No | 243 | — |
| mpuannum | Mpuannum | Yes | No | 248 | — |
| nea_oretwa_sa | Nea Oretwa Sa | Yes | No | 253 | — |
| neo_ope_se_obedi_hene | Neo Ope Se Obedi Hene | Yes | No | 257 | — |
| nkonsonkonson | Nkonsonkonson | Yes | No | 262 | — |
| nkotimsefo_mpua | Nkotimsefo Mpua | Yes | No | 266 | — |
| nkrabea | Nkrabea | Yes | No | 271 | — |
| nkyemu | Nkyemu | Yes | No | 276 | — |
| nnamfo_pa_baanu | Nnamfo Pa Baanu | Yes | No | 280 | — |
| nsaa | Nsaa | Yes | No | 285 | — |
| nserewa | Nserewa | Yes | No | 289 | — |
| nteasee | Nteasee | Yes | No | 294 | — |
| nyame_baatanpa | Nyame Baatanpa | Yes | No | 299 | — |
| nyame_biribi_wo_soro | Nyame Biribi Wo Soro | Yes | No | 303 | — |
| nyame_dua | Nyame Dua | Yes | No | 308 | — |
| nyame_nti | Nyame Nti | Yes | No | 313 | — |
| nyame_nwa_na_mawu | Nyame Nwa Na Mawu | Yes | No | 317 | — |
| nyansapo | Nyansapo | Yes | No | 322 | — |
| obohemaa | Obohemaa | Yes | No | 326 | — |
| okodee_mmowere | Okodee Mmowere | Yes | No | 331 | — |
| okuafo_pa | Okuafo Pa | Yes | No | 336 | — |
| osram_ne_nsoromma | Osram Ne Nsoromma | Yes | No | 340 | — |
| owo_foro_adobe | Owo Foro Adobe | Yes | No | 345 | — |
| owuo_atwedee | Owuo Atwedee | Yes | No | 349 | — |
| pempamsie | Pempamsie | Yes | No | 354 | — |
| sepow | Sepow | Yes | No | 359 | — |
| sesa_wo_suban | Sesa Wo Suban | Yes | No | 363 | — |
| som_onyankopon | Som Onyankopon | Yes | No | 368 | — |
| sunsum | Sunsum | Yes | No | 372 | — |
| tabono | Tabono | Yes | No | 377 | — |
| tamfo_bebre | Tamfo Bebre | Yes | No | 382 | — |
| uac_nkanea | UAC Nkanea | Yes | No | 386 | — |
| wawa_aba | Wawa Aba | Yes | No | 391 | — |
| wo_nsa_da_mu_a | Wo Nsa Da Mu A | Yes | No | 395 | — |
| woforo_dua_pa_a | Woforo Dua Pa A | Yes | No | 400 | — |
