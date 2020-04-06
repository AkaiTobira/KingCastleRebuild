extends Node2D


var dir_to_op_dir ={
	"U" : "D",
	"L" : "R",
	"R" : "L",
	"D" : "U"
}

var lab        = {}

func get_random_dir():
	randomize()
	var dir = [ "U", "L", "R", "D"]
	return dir[ randi()%4 ]

func step_in_dir( dir, curr_position):
	match dir:
		"U" : return curr_position + Vector2( 0,-1) 
		"D" : return curr_position + Vector2( 0, 1)
		"R" : return curr_position + Vector2( 1, 0)
		"L" : return curr_position + Vector2(-1, 0)

func in_range(curr_pos):
	if curr_pos.x < 0 or curr_pos.x >= Util.MAZE_SIZE.x: return false
	if curr_pos.y < 0 or curr_pos.y >= Util.MAZE_SIZE.y: return false
	return true

func is_dir_valid( dir, curr_pos ):
	match dir:
		"U" : return in_range( step_in_dir("U", curr_pos) )
		"D" : return in_range( step_in_dir("D", curr_pos) )
		"L" : return in_range( step_in_dir("L", curr_pos) )
		"R" : return in_range( step_in_dir("R", curr_pos) )

func _init():
	for i in range( Util.MAZE_SIZE.x ):
		for j in range( Util.MAZE_SIZE.y ):
			lab[Vector2(i,j)] = ""
	
	var Origin    = Vector2( 0,0 )
	var direction = get_random_dir()
	while( !is_dir_valid( direction, Origin )): direction = get_random_dir()
	var couter    = 1 

	while( true ):
		if couter == (Util.MAZE_SIZE.x * Util.MAZE_SIZE.y): break
		
		var new_Origin = step_in_dir(direction, Origin)
		if lab[new_Origin] == "" : 
			lab[Origin]     += direction
			couter += 1
			if couter == (Util.MAZE_SIZE.x * Util.MAZE_SIZE.y): lab[new_Origin] += "A" 
			lab[new_Origin] += dir_to_op_dir[direction]

		Origin = new_Origin
		direction = get_random_dir()
		while( !is_dir_valid( direction, Origin )): direction = get_random_dir()

func print_maze():
		var sss = "|"
		for i in range( Util.MAZE_SIZE.y ):
			for j in range( Util.MAZE_SIZE.x ):
				sss += ("%05s" % lab[Vector2(j,i)] ) + "|"
			sss += "\n|"
		print(sss)

func cout_cleared():
	var couters = 0
	for chid in get_children():
		if chid.is_cleaned : couters += 1
	return couters

func change_style(): pass
	#for segment in get_children():
	#	segment.switch_style("K1")

func get_current_world_begin():
	return Vector2(0,0)

func get_current_world_value():
	return Util.SEGMENT_SIZE*Util.MAZE_SIZE

func _ready():
	randomize()
	generate()
	Util.labirynth = lab
	get_parent().get_node("CanvasLayer/Control/TileMap").fill()

func get_start_point():
	return Vector2( 892, 586)

func generate(): 
	for i in range( Util.MAZE_SIZE.y ):
		for j in range( Util.MAZE_SIZE.x ):
			if i == 0 and j == 0 :
				
				var segment = Util.get_tron_room( lab[Vector2(i,j)] )
				Util.king_room = segment
				segment.position = Vector2(i,j) * Util.SEGMENT_SIZE
				segment.int_position = Vector2(i,j)
				add_child(segment)
			
				continue
			elif "A" in lab[Vector2(i,j)]:
				var segment = Util.get_Atron_room( lab[Vector2(i,j)] )
				get_parent().get_node("CanvasLayer/Control/TileMap").mark_as_boss(Vector2(i,j))
				segment.position = Vector2(i,j) * Util.SEGMENT_SIZE
				segment.int_position = Vector2(i,j)
				add_child(segment)
				continue
				
			var segment = Util.get_segment( lab[Vector2(i,j)] )
			segment.position = Vector2(i,j) * Util.SEGMENT_SIZE
			segment.int_position = Vector2(i,j)
			add_child(segment)
			
