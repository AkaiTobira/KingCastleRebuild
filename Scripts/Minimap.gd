extends TileMap

var tileset = {
	"UDLR" :  0,
	"UDR"  :  1,
	"R"    : 10,
	"DR"   : 11,
	"UD"   : 12,
	"LR"   : 13,
	"UDL"  : 14,
	""     : 15,
	"UR"   :  2,
	"U"    :  3,
	"ULR"  :  4,
	"UL"   :  5,
	"L"    :  6,
	"DLR"  :  7,
	"DL"   :  8,
	"D"    :  9
}

func fill():
	scale = Vector2(4 / Util.MAZE_SIZE.x,4/ Util.MAZE_SIZE.x)
	for key in Util.labirynth.keys():
		set_cell(key.x, key.y, tileset[ Util.sort_enter(Util.labirynth[key]) ])
