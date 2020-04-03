extends Node


var player = null
var GUI    = null
var PLAYER_GRAVITY_ENABLER = true
var PLAYER_IN_AIR_ENABLED  = false

var GRAVITY      = 50
var IN_AIR_SPEED = 20
var SPEED        = 400
var SPEED_JUMP   = 1650

var MAZE_SIZE = Vector2( 5, 5)

var labirynth    = {}

var SEGMENT_SIZE = Vector2(64 * 33, 64 * 19)

func _ready():
	load_segments()

var enemies = [
	preload("res://Scenes/EnemyTemplate.tscn"),
	preload("res://Scenes/Glut.tscn"),
	preload("res://Scenes/Krzysiek.tscn"),
]

func get_current_world_value():
	return SEGMENT_SIZE*MAZE_SIZE

func get_enemy_instance():
	return enemies[randi()%len(enemies)].instance()

var segments = {
	"angles" : 
	{
		"UDLR" : [],
		"UDL"  : [],
		"UDR"  : [],
		"ULR"  : [],
		"DLR"  : [],
		"UD"   : [],
		"UL"   : [],
		"UR"   : [],
		"DL"   : [],
		"DR"   : [],
		"LR"   : [],
		"U"    : [],
		"L"    : [],
		"D"    : [],
		"R"    : []
	}
}

func get_resource_list(resource):
	var resources = []
	var dir = Directory.new()
	if dir.open(resource) == OK:
		dir.list_dir_begin()
		var name = dir.get_next()
		while name != "":
			if !name.ends_with(".tscn"): 
				name = dir.get_next()
				continue
			resources.append( resource + name )
			name = dir.get_next()
	return resources

func load_segments():
	var list_of_segments = get_resource_list("res://Scenes/Segments/")
	for seg in range(len(list_of_segments)):
		
		print( list_of_segments[seg] )
		
		var loaded = load(list_of_segments[seg])
		var instance = loaded.instance()
		
		var nameString = ""
		for key in instance.valid_enter.keys():
			if  instance.valid_enter[key] : nameString += key
		if nameString == "" : 
			print( list_of_segments[seg], " ENTERS NOT SET" )
			assert( false )
		segments["angles"][sort_enter(nameString)].append(loaded)

func sort_enter(enters):
	var sorted = ""
	for letter in "UDLR":
		if letter in enters:
			sorted += letter
	return sorted

func get_segment( enters ):
	var sorted = sort_enter(enters)
	return segments["angles"][sorted][ randi()%len(segments["angles"][sorted]) ].instance()



