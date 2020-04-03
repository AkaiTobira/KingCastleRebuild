extends Node2D


export var valid_enter = { "U" :false, "D": false, "L":false, "R":false }

func close_gates():
	for child in $Gates.get_children():
		child.close_gate()
		
func open_gates():
	for child in $Gates.get_children():
		child.open_gate()


onready var placeholder_tile_set_id = {
	$TileMap.tile_set.find_tile_by_name("A") : "A",
	$TileMap.tile_set.find_tile_by_name("B") : "B",
	$TileMap.tile_set.find_tile_by_name("C") : "C",
	$TileMap.tile_set.find_tile_by_name("D") : "D",
	$TileMap.tile_set.find_tile_by_name("E") : "E",
	$TileMap.tile_set.find_tile_by_name("F") : "F",
	$TileMap.tile_set.find_tile_by_name("G") : "G",
	$TileMap.tile_set.find_tile_by_name("H") : "H",
	$TileMap.tile_set.find_tile_by_name("I") : "I"
}

func generate_enemies():
	for child in $EnemiesMarker.get_children():
		var instance = Util.get_enemy_instance()
		instance.position = child.position
		$EnemiesMarker.add_child(instance)

func _ready():
	print(placeholder_tile_set_id)
	print($TileMap.tile_set.get_tiles_ids())
	generate_enemies()
	var sss = ""

func switch_style(tilesetName):
	
	
	var new_tileset = Util.get_tileset(tilesetName)
	var tilest_info = Util.get_tileset_info(tilesetName)
	#$TileMap.tile_set = new_tileset
	
	var size  = $TileMap.get_used_rect().size 
	var p     = $TileMap.get_used_rect().position
	print($TileMap.tile_set.get_tiles_ids())
#	print(placeholder_tile_set_id)
	#print(tilest_info.get_tiles_ids())
	
	var sss = ""
	
	print( p.x, size.x - p.x, range( p.x, size.x -  p.x, 1))
	print( p.y, size.y - p.y, range( p.y, size.y -  p.y, 1))
	
	for j in range( p.x, size.x -  p.x, 1):
		for i in range( p.y, size.y -  p.y, 1):
			var cell_id = $TileMap.get_cell( i, j)
			sss += "%2s" % str(cell_id) + " "
			
			
			if cell_id in placeholder_tile_set_id.keys():
				
				
				
				var possible_marks = tilest_info[placeholder_tile_set_id[cell_id]]
				var new_tile_id    = possible_marks[ randi()%len(possible_marks)]
				
			#	print( cell_id, placeholder_tile_set_id[cell_id], possible_marks, new_tile_id )
				
				$TileMap.set_cell(i, j, 
				new_tile_id, 
				$TileMap.is_cell_x_flipped(i,j),
				$TileMap.is_cell_y_flipped(i,j),
				$TileMap.is_cell_transposed(i,j))
			elif cell_id != -1 : print( cell_id )
	$TileMap.tile_set = new_tileset
		#sss += "\n"
#	print( sss)
	
