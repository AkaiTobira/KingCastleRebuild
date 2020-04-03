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

var base_image = Vector2(0,0)

func _ready():
	base_image = $Sprite.position

func fill():
	scale = Vector2(4 / Util.MAZE_SIZE.x,4/ Util.MAZE_SIZE.x)
	for key in Util.labirynth.keys():
		set_cell(key.x, key.y, tileset[ Util.sort_enter(Util.labirynth[key]) ])

func _process(_elta):
	var i = int(Util.player.position.x / Util.SEGMENT_SIZE.x)
	var j = int(Util.player.position.y / Util.SEGMENT_SIZE.y)
	$Sprite.position = Vector2(i * 64, j * 64) + base_image
