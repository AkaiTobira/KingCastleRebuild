extends Node



var player   = null
var GUI      = null
var darkness = null

var PLAYER_GRAVITY_ENABLER = true
var PLAYER_IN_AIR_ENABLED  = false
var PLAYER_SECOND_JUMP     = true
var SHAKE_CAMERA           = false

var ENABLED_SKILLS = {
	"Attack1"     : true,
	"Jump"        : true,
	"JumpAttack1" : true,
	"JumpAttack2" : true,
	"Jump2"       : true,
	"Attack2"     : true,
	"Attack3"     : true,
	"Magic2"      : true,
	"Magic3"      : true,
	"Magic4"      : true,
	"Attack4"     : true
}

var GRAVITY      = 50
var IN_AIR_SPEED = 60
var SPEED        = 400
var SPEED_JUMP   = 1050

var MAZE_SIZE = Vector2(4, 4)

var labirynth    = {}
var done_segment = 0

var SEGMENT_SIZE = Vector2(64 * 28, 64 * 17)

func _ready():
	load_segments()

var project_tiles = {
	"FBall" : preload("res://Scenes/Fireball.tscn"),
	"EBall" : preload("res://Scenes/EnegryBall.tscn")
}

func get_project_tile( tile_name ):
	return project_tiles[tile_name].instance()

var enemies = [
	preload("res://Scenes/Enemies/EnemyTemplate.tscn"),
	preload("res://Scenes/Enemies/Glut.tscn"),
	preload("res://Scenes/Enemies/Krzysiek.tscn"),
	preload("res://Scenes/Enemies/Krzysiek2.tscn"),
	preload("res://Scenes/Enemies/Krzysiek3.tscn"),
	preload("res://Scenes/Enemies/Krzysiek4.tscn"),
	preload("res://Scenes/Enemies/Bat.tscn")
]

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
		"R"    : [],
		"TR"   : preload("res://Scenes/TronPlayerR.tscn"),
		"TD"   : preload("res://Scenes/TronPlayerD.tscn"),
		"TDR"  : preload("res://Scenes/TronPlayerDR.tscn"),
		"AR"   : preload("res://Scenes/TronAR.tscn"),
		"AL"   : preload("res://Scenes/TronAL.tscn"),
		"AU"   : preload("res://Scenes/TronAU.tscn"),
		"AD"   : preload("res://Scenes/TronAD.tscn")
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

func get_Atron_room(dir):
	return segments["angles"][dir].instance()

func get_tron_room( dir ):
	return segments["angles"]["T" + sort_enter(dir)].instance()

func get_segment( enters ):
	var sorted = sort_enter(enters)
	return segments["angles"][sorted][ randi()%len(segments["angles"][sorted]) ].instance()
