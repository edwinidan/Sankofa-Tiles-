enum TileSuit { wisdom, earth, royalty, honor }

class TileDefinition {
  final String id;
  final String name;
  final String meaning;
  final String symbol;
  final TileSuit suit;
  final int suitNumber;
  final String? assetPath;

  const TileDefinition({
    required this.id,
    required this.name,
    required this.meaning,
    required this.symbol,
    required this.suit,
    required this.suitNumber,
    this.assetPath,
  });
}

const List<TileDefinition> kAllTiles = [
  // SUIT 1 — WISDOM
  TileDefinition(id:'nyansapo',    name:'Nyansapo',      meaning:'Wisdom knot',             symbol:'✦', suit:TileSuit.wisdom,  suitNumber:1,  assetPath:'assets/tiles/symbols/asset v2/nyansapo.png'),
  TileDefinition(id:'nkyinkyim',   name:'Nkyinkyim',     meaning:'Adaptability',             symbol:'~', suit:TileSuit.wisdom,  suitNumber:2, assetPath:'assets/tiles/symbols/nkyinkyim.png'),
  TileDefinition(id:'mate_masie',  name:'Mate Masie',    meaning:'What I hear I keep',       symbol:'◈', suit:TileSuit.wisdom,  suitNumber:3,  assetPath:'assets/tiles/symbols/asset v2/matse_masie.png'),
  TileDefinition(id:'hwehwemudua', name:'Hwehwemudua',   meaning:'Excellence',               symbol:'⊞', suit:TileSuit.wisdom,  suitNumber:4,  assetPath:'assets/tiles/symbols/asset v2/hwehwemedua.png'),
  TileDefinition(id:'nea_onnim',   name:'Nea Onnim',     meaning:'He who does not know',     symbol:'?', suit:TileSuit.wisdom,  suitNumber:5, assetPath:'assets/tiles/symbols/nea_onnim.png'),
  TileDefinition(id:'ese_tekrema', name:'Ese Ne Tekrema',meaning:'Teeth and tongue',         symbol:'≋', suit:TileSuit.wisdom,  suitNumber:6,  assetPath:'assets/tiles/symbols/asset v2/ese_ne_trema.png'),
  TileDefinition(id:'nteasee',     name:'Nteasee',       meaning:'Understanding',             symbol:'◎', suit:TileSuit.wisdom,  suitNumber:8,  assetPath:'assets/tiles/symbols/asset v2/nteasee.png'),
  TileDefinition(id:'sankofa',     name:'Sankofa',       meaning:'Go back and get it',       symbol:'⟳', suit:TileSuit.wisdom,  suitNumber:9, assetPath:'assets/tiles/symbols/sankofa.png'),

  // SUIT 2 — EARTH & NATURE
  TileDefinition(id:'denkyem',     name:'Denkyem',       meaning:'Crocodile — adaptability', symbol:'≈', suit:TileSuit.earth,   suitNumber:1, assetPath:'assets/tiles/symbols/denkyem.png'),
  TileDefinition(id:'abe_dua',     name:'Abe Dua',       meaning:'Palm tree',                symbol:'♣', suit:TileSuit.earth,   suitNumber:2, assetPath:'assets/tiles/symbols/abe_dua.png'),
  TileDefinition(id:'nyame_dua',   name:'Nyame Dua',     meaning:'God\'s tree',              symbol:'✙', suit:TileSuit.earth,   suitNumber:3,  assetPath:'assets/tiles/symbols/asset v2/nyame_dua.png'),

  // SUIT 3 — ROYALTY & POWER
  TileDefinition(id:'adinkrahene', name:'Adinkrahene',   meaning:'Chief of Adinkra',         symbol:'⦾', suit:TileSuit.royalty, suitNumber:1, assetPath:'assets/tiles/symbols/adinkrahene.png'),
  TileDefinition(id:'akofena',     name:'Akofena',       meaning:'Sword of war — courage',   symbol:'†', suit:TileSuit.royalty, suitNumber:2, assetPath:'assets/tiles/symbols/akofena.png'),
  TileDefinition(id:'aban',        name:'Aban',          meaning:'The castle — authority',   symbol:'⬡', suit:TileSuit.royalty, suitNumber:3, assetPath:'assets/tiles/symbols/aban.png'),
  TileDefinition(id:'fawohodie',   name:'Fawohodie',     meaning:'Freedom',                  symbol:'☆', suit:TileSuit.royalty, suitNumber:4,  assetPath:'assets/tiles/symbols/asset v2/fawohodie-removebg-preview.png'),
  TileDefinition(id:'funtumfunefu',name:'Funtumfunefu',  meaning:'Siamese crocodiles',       symbol:'∞', suit:TileSuit.royalty, suitNumber:5, assetPath:'assets/tiles/symbols/funtumfunefu_denkyemfunefu.png'),
  TileDefinition(id:'mpuannum',    name:'Mpuannum',      meaning:'Five tufts — royalty',     symbol:'✵', suit:TileSuit.royalty, suitNumber:6,  assetPath:'assets/tiles/symbols/asset v2/mpuannum.png'),
  TileDefinition(id:'nyame_nwu',   name:'Nyame Nwu Na Mawu', meaning:'God never dies',      symbol:'⟁', suit:TileSuit.royalty, suitNumber:7,  assetPath:'assets/tiles/symbols/asset v2/nyame_nwu_na_mawu.png'),

  // HONOR TILES
  TileDefinition(id:'gye_nyame',   name:'Gye Nyame',     meaning:'Except God',              symbol:'☀', suit:TileSuit.honor,   suitNumber:1,  assetPath:'assets/tiles/symbols/gye_nyame.png'),
  TileDefinition(id:'dwennimmen',  name:'Dwennimmen',    meaning:'Strength with humility',  symbol:'⚏', suit:TileSuit.honor,   suitNumber:2,  assetPath:'assets/tiles/symbols/dwennimmen.png'),
  TileDefinition(id:'mpatapo',     name:'Mpatapo',       meaning:'Reconciliation',          symbol:'⊗', suit:TileSuit.honor,   suitNumber:3,  assetPath:'assets/tiles/symbols/asset v2/mpatapo.png'),
  TileDefinition(id:'hye_wo_nhye', name:'Hye Wo Nhye',   meaning:'Imperishability',         symbol:'◇', suit:TileSuit.honor,   suitNumber:4,  assetPath:'assets/tiles/symbols/asset v2/hye_wo_nhye.png'),
  TileDefinition(id:'akoben',      name:'Akoben',        meaning:'War horn — readiness',    symbol:'♪', suit:TileSuit.honor,   suitNumber:5,  assetPath:'assets/tiles/symbols/akoben.png'),
  TileDefinition(id:'nsoromma',    name:'Nsoromma',      meaning:'Star — child of the heavens', symbol:'★', suit:TileSuit.honor, suitNumber:9, assetPath:'assets/tiles/symbols/nsoromma.png'),
  TileDefinition(id:'adwo',        name:'Adwo',          meaning:'Peace and tranquility',   symbol:'◌', suit:TileSuit.honor,   suitNumber:10, assetPath:'assets/tiles/symbols/adwo.png'),
  TileDefinition(id:'abusua_pa',   name:'Abusua Pa',     meaning:'Good family',             symbol:'⊕', suit:TileSuit.honor,   suitNumber:11, assetPath:'assets/tiles/symbols/abusua_pa.png'),
  TileDefinition(id:'agyindawuru', name:'Agyindawuru',   meaning:'The gong — warning',      symbol:'◉', suit:TileSuit.honor,   suitNumber:12, assetPath:'assets/tiles/symbols/agyindawuru.png'),
  TileDefinition(id:'abode_santann', name:'Abode Santann', meaning:'The cosmos — universe', symbol:'⊛', suit:TileSuit.honor,   suitNumber:13, assetPath:'assets/tiles/symbols/abode_santann.png'),
  TileDefinition(id:'odo_nnyew_fie_kwan', name:'Odo Nnyew Fie Kwan', meaning:'Love never loses its way home', symbol:'♡', suit:TileSuit.honor, suitNumber:14, assetPath:'assets/tiles/symbols/odo_nnyew_fie_kwan.png'),

  // NEW TILES
  TileDefinition(id:'nsaa',                   name:'Nsaa',                    meaning:'Excellence and authenticity',           symbol:'≡', suit:TileSuit.honor, suitNumber:15, assetPath:'assets/tiles/symbols/asset v2/nsaa.png'),
  TileDefinition(id:'nyame_nti',              name:'Nyame Nti',               meaning:'By God\'s grace',                       symbol:'✞', suit:TileSuit.honor, suitNumber:16, assetPath:'assets/tiles/symbols/asset v2/Nyame_nti.png'),
  TileDefinition(id:'nyame_biribi_wo_soro',   name:'Nyame Biribi Wo Soro',    meaning:'God is in the heavens — hope',          symbol:'☁', suit:TileSuit.honor, suitNumber:17, assetPath:'assets/tiles/symbols/asset v2/nyame_biribi_wo_soro.png'),
  TileDefinition(id:'nkyemu',                 name:'Nkyemu',                  meaning:'Excellence in craftsmanship',           symbol:'✂', suit:TileSuit.honor, suitNumber:18, assetPath:'assets/tiles/symbols/asset v2/nkyemu.png'),
  TileDefinition(id:'nkotimsefo_mpua',        name:'Nkotimsefo Mpua',         meaning:'Loyalty and service',                   symbol:'⬟', suit:TileSuit.honor, suitNumber:19, assetPath:'assets/tiles/symbols/asset v2/nkotimsefo_mpua.png'),
  TileDefinition(id:'nkrabea',                name:'Nkrabea',                 meaning:'Fate and destiny',                      symbol:'◈', suit:TileSuit.honor, suitNumber:20, assetPath:'assets/tiles/symbols/asset v2/nkrabea.png'),
  TileDefinition(id:'mmeranmubere',           name:'Mmeranmubere',            meaning:'Bravery and virtue',                    symbol:'⚔', suit:TileSuit.honor, suitNumber:21, assetPath:'assets/tiles/symbols/asset v2/mmeranmubere.png'),
  TileDefinition(id:'nea_ope_se_obedi_hene',  name:'Nea Ope Se Obedi Hene',   meaning:'He who wants to be king must serve',    symbol:'♔', suit:TileSuit.honor, suitNumber:22, assetPath:'assets/tiles/symbols/asset v2/nea_ope_se_obedi_hene.png'),
  TileDefinition(id:'mmere_dane',             name:'Mmere Dane',              meaning:'Times change',                          symbol:'⌛', suit:TileSuit.honor, suitNumber:23, assetPath:'assets/tiles/symbols/asset v2/mmere_dane.png'),
  TileDefinition(id:'mako',                   name:'Mako',                    meaning:'Not all people are the same',           symbol:'✿', suit:TileSuit.honor, suitNumber:24, assetPath:'assets/tiles/symbols/asset v2/mako.png'),

  // NEW TILES — ASSET V2
  TileDefinition(id:'fafanto',                name:'Fafanto',                 meaning:'Butterfly — transformation',            symbol:'❦', suit:TileSuit.wisdom,  suitNumber:10, assetPath:'assets/tiles/symbols/asset v2/fafanto.png'),
  TileDefinition(id:'fihankra',               name:'Fihankra',                meaning:'Safety and security',                   symbol:'⌂', suit:TileSuit.earth,   suitNumber:10, assetPath:'assets/tiles/symbols/asset v2/fihankra.png'),
  TileDefinition(id:'fofo',                   name:'Fofo',                    meaning:'Warning against jealousy',              symbol:'⚘', suit:TileSuit.earth,   suitNumber:11, assetPath:'assets/tiles/symbols/asset v2/fofo.png'),
  TileDefinition(id:'kete_pa',                name:'Kete Pa',                 meaning:'Good foundation — good marriage',       symbol:'♡', suit:TileSuit.honor,   suitNumber:25, assetPath:'assets/tiles/symbols/asset v2/kete_pa.png'),
  TileDefinition(id:'kokuromotie',            name:'Kokuromotie',             meaning:'Thumbprint — uniqueness',               symbol:'⊙', suit:TileSuit.wisdom,  suitNumber:11, assetPath:'assets/tiles/symbols/asset v2/kokuromotie.png'),
  TileDefinition(id:'kramo_bone',             name:'Kramo Bone',              meaning:'Bad conduct spoils good image',         symbol:'⊡', suit:TileSuit.honor,   suitNumber:26, assetPath:'assets/tiles/symbols/asset v2/kramo_bone_amma_yeanhu_kramo_pa.png'),
  TileDefinition(id:'krapa_musuyidee',        name:'Krapa Musuyidee',         meaning:'Spiritual cleansing and sanctity',      symbol:'✦', suit:TileSuit.honor,   suitNumber:27, assetPath:'assets/tiles/symbols/asset v2/krapa__musuyidee.png'),
  TileDefinition(id:'kwatakye_atiko',         name:'Kwatakye Atiko',          meaning:'Bravery and valor',                     symbol:'⊹', suit:TileSuit.royalty, suitNumber:10, assetPath:'assets/tiles/symbols/asset v2/kwatakye_atiko.png'),
  TileDefinition(id:'kyemfere',               name:'Kyemfere',                meaning:'Creativity and artisan skill',          symbol:'◯', suit:TileSuit.wisdom,  suitNumber:12, assetPath:'assets/tiles/symbols/asset v2/kyemfere.png'),
  TileDefinition(id:'mekyea_wo',              name:'Mekyea Wo',               meaning:'Greeting and respect',                  symbol:'☸', suit:TileSuit.honor,   suitNumber:28, assetPath:'assets/tiles/symbols/asset v2/mekyea_wo-removebg-preview.png'),
  TileDefinition(id:'menso_wo_kenten',        name:'Menso Wo Kenten',         meaning:'I carry your basket — service',         symbol:'⊘', suit:TileSuit.honor,   suitNumber:29, assetPath:'assets/tiles/symbols/asset v2/menso_wo_kenten.png'),
  TileDefinition(id:'mmeremutene',            name:'Mmeremutene',             meaning:'Kindness and gentleness',               symbol:'⋆', suit:TileSuit.honor,   suitNumber:30, assetPath:'assets/tiles/symbols/asset v2/mmeremutene.png'),
  TileDefinition(id:'nea_oretwa_sa',          name:'Nea Oretwa Sa',           meaning:'Determination and independence',        symbol:'→', suit:TileSuit.wisdom,  suitNumber:13, assetPath:'assets/tiles/symbols/asset v2/nea_oretwa_sa.png'),
  TileDefinition(id:'nserewa',                name:'Nserewa',                 meaning:'Small beads — elegance and beauty',     symbol:'⋄', suit:TileSuit.honor,   suitNumber:31, assetPath:'assets/tiles/symbols/asset v2/nserewa.png'),
  TileDefinition(id:'nyame_baatanpa',         name:'Nyame Baatanpa',          meaning:'God the good parent — divine love',     symbol:'✙', suit:TileSuit.honor,   suitNumber:32, assetPath:'assets/tiles/symbols/asset v2/nyame_baatanpa.png'),
];
