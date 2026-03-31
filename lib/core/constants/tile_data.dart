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
  TileDefinition(id:'nyansapo',    name:'Nyansapo',      meaning:'Wisdom knot',             symbol:'✦', suit:TileSuit.wisdom,  suitNumber:1),
  TileDefinition(id:'nkyinkyim',   name:'Nkyinkyim',     meaning:'Adaptability',             symbol:'~', suit:TileSuit.wisdom,  suitNumber:2, assetPath:'assets/tiles/symbols/nkyinkyim.png'),
  TileDefinition(id:'mate_masie',  name:'Mate Masie',    meaning:'What I hear I keep',       symbol:'◈', suit:TileSuit.wisdom,  suitNumber:3),
  TileDefinition(id:'hwehwemudua', name:'Hwehwemudua',   meaning:'Excellence',               symbol:'⊞', suit:TileSuit.wisdom,  suitNumber:4),
  TileDefinition(id:'nea_onnim',   name:'Nea Onnim',     meaning:'He who does not know',     symbol:'?', suit:TileSuit.wisdom,  suitNumber:5, assetPath:'assets/tiles/symbols/nea_onnim.png'),
  TileDefinition(id:'ananse',      name:'Ananse Ntentan',meaning:'Spider web — creativity',  symbol:'⊛', suit:TileSuit.wisdom,  suitNumber:6),
  TileDefinition(id:'ese_tekrema', name:'Ese Ne Tekrema',meaning:'Teeth and tongue',         symbol:'≋', suit:TileSuit.wisdom,  suitNumber:7),
  TileDefinition(id:'nteasee',     name:'Nteasee',       meaning:'Understanding',             symbol:'◎', suit:TileSuit.wisdom,  suitNumber:8),
  TileDefinition(id:'sankofa',     name:'Sankofa',       meaning:'Go back and get it',       symbol:'⟳', suit:TileSuit.wisdom,  suitNumber:9, assetPath:'assets/tiles/symbols/sankofa.png'),

  // SUIT 2 — EARTH & NATURE
  TileDefinition(id:'aya',         name:'Aya',           meaning:'Fern — endurance',         symbol:'❋', suit:TileSuit.earth,   suitNumber:1),
  TileDefinition(id:'denkyem',     name:'Denkyem',       meaning:'Crocodile — adaptability', symbol:'≈', suit:TileSuit.earth,   suitNumber:2, assetPath:'assets/tiles/symbols/denkyem.png'),
  TileDefinition(id:'asase',       name:'Asase Ye Duru', meaning:'The earth is heavy',       symbol:'⊕', suit:TileSuit.earth,   suitNumber:3),
  TileDefinition(id:'mframadan',   name:'Mframadan',     meaning:'Windproof house',          symbol:'⌂', suit:TileSuit.earth,   suitNumber:4),
  TileDefinition(id:'osram',       name:'Osram Ne Nsoromma', meaning:'Moon and star',        symbol:'☽', suit:TileSuit.earth,   suitNumber:5),
  TileDefinition(id:'okuafo',      name:'Okuafo Pa',     meaning:'The good farmer',          symbol:'⚘', suit:TileSuit.earth,   suitNumber:6),
  TileDefinition(id:'abe_dua',     name:'Abe Dua',       meaning:'Palm tree',                symbol:'♣', suit:TileSuit.earth,   suitNumber:7, assetPath:'assets/tiles/symbols/abe_dua.png'),
  TileDefinition(id:'akoko_nan',   name:'Akoko Nan',     meaning:'Hen\'s foot — nurturing',  symbol:'⩕', suit:TileSuit.earth,   suitNumber:8),
  TileDefinition(id:'nyame_dua',   name:'Nyame Dua',     meaning:'God\'s tree',              symbol:'✙', suit:TileSuit.earth,   suitNumber:9),

  // SUIT 3 — ROYALTY & POWER
  TileDefinition(id:'adinkrahene', name:'Adinkrahene',   meaning:'Chief of Adinkra',         symbol:'⦾', suit:TileSuit.royalty, suitNumber:1, assetPath:'assets/tiles/symbols/adinkrahene.png'),
  TileDefinition(id:'akofena',     name:'Akofena',       meaning:'Sword of war — courage',   symbol:'†', suit:TileSuit.royalty, suitNumber:2, assetPath:'assets/tiles/symbols/akofena.png'),
  TileDefinition(id:'pempamsie',   name:'Pempamsie',     meaning:'Readiness',                symbol:'⛓', suit:TileSuit.royalty, suitNumber:3),
  TileDefinition(id:'aban',        name:'Aban',          meaning:'The castle — authority',   symbol:'⬡', suit:TileSuit.royalty, suitNumber:4, assetPath:'assets/tiles/symbols/aban.png'),
  TileDefinition(id:'fawohodie',   name:'Fawohodie',     meaning:'Freedom',                  symbol:'☆', suit:TileSuit.royalty, suitNumber:5),
  TileDefinition(id:'funtumfunefu',name:'Funtumfunefu',  meaning:'Siamese crocodiles',       symbol:'∞', suit:TileSuit.royalty, suitNumber:6, assetPath:'assets/tiles/symbols/funtumfunefu_denkyemfunefu.png'),
  TileDefinition(id:'mpuannum',    name:'Mpuannum',      meaning:'Five tufts — royalty',     symbol:'✵', suit:TileSuit.royalty, suitNumber:7),
  TileDefinition(id:'okodee',      name:'Okodee Mmowere',meaning:'Eagle talons — strength',  symbol:'⋙', suit:TileSuit.royalty, suitNumber:8),
  TileDefinition(id:'nyame_nwu',   name:'Nyame Nwu Na Mawu', meaning:'God never dies',      symbol:'⟁', suit:TileSuit.royalty, suitNumber:9),

  // HONOR TILES
  TileDefinition(id:'gye_nyame',   name:'Gye Nyame',     meaning:'Except God',              symbol:'☀', suit:TileSuit.honor,   suitNumber:1,  assetPath:'assets/tiles/symbols/gye_nyame.png'),
  TileDefinition(id:'bi_nka_bi',   name:'Bi Nka Bi',     meaning:'Peace and unity',         symbol:'◯', suit:TileSuit.honor,   suitNumber:2),
  TileDefinition(id:'dwennimmen',  name:'Dwennimmen',    meaning:'Strength with humility',  symbol:'⚏', suit:TileSuit.honor,   suitNumber:3,  assetPath:'assets/tiles/symbols/dwennimmen.png'),
  TileDefinition(id:'mpatapo',     name:'Mpatapo',       meaning:'Reconciliation',          symbol:'⊗', suit:TileSuit.honor,   suitNumber:4),
  TileDefinition(id:'hye_wo_nhye', name:'Hye Wo Nhye',   meaning:'Imperishability',         symbol:'◇', suit:TileSuit.honor,   suitNumber:5),
  TileDefinition(id:'tabono',      name:'Tabono',        meaning:'Paddle — hard work',      symbol:'⊠', suit:TileSuit.honor,   suitNumber:6),
  TileDefinition(id:'akoma',       name:'Akoma',         meaning:'Heart — patience',        symbol:'♥', suit:TileSuit.honor,   suitNumber:7),
  TileDefinition(id:'akoben',      name:'Akoben',        meaning:'War horn — readiness',    symbol:'♪', suit:TileSuit.honor,   suitNumber:8,  assetPath:'assets/tiles/symbols/akoben.png'),
  TileDefinition(id:'nsoromma',    name:'Nsoromma',      meaning:'Star — child of the heavens', symbol:'★', suit:TileSuit.honor, suitNumber:9, assetPath:'assets/tiles/symbols/nsoromma.png'),
  TileDefinition(id:'adwo',        name:'Adwo',          meaning:'Peace and tranquility',   symbol:'◌', suit:TileSuit.honor,   suitNumber:10, assetPath:'assets/tiles/symbols/adwo.png'),
  TileDefinition(id:'abusua_pa',   name:'Abusua Pa',     meaning:'Good family',             symbol:'⊕', suit:TileSuit.honor,   suitNumber:11, assetPath:'assets/tiles/symbols/abusua_pa.png'),
  TileDefinition(id:'agyindawuru', name:'Agyindawuru',   meaning:'The gong — warning',      symbol:'◉', suit:TileSuit.honor,   suitNumber:12, assetPath:'assets/tiles/symbols/agyindawuru.png'),
  TileDefinition(id:'abode_santann', name:'Abode Santann', meaning:'The cosmos — universe', symbol:'⊛', suit:TileSuit.honor,   suitNumber:13, assetPath:'assets/tiles/symbols/abode_santann.png'),
  TileDefinition(id:'odo_nnyew_fie_kwan', name:'Odo Nnyew Fie Kwan', meaning:'Love never loses its way home', symbol:'♡', suit:TileSuit.honor, suitNumber:14, assetPath:'assets/tiles/symbols/odo_nnyew_fie_kwan.png'),
];
