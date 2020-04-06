extends Node



var player   = null
var GUI      = null
var darkness = null
var info     = null

var PLAYER_GRAVITY_ENABLER = true
var PLAYER_IN_AIR_ENABLED  = false
var PLAYER_SECOND_JUMP     = true
var SHAKE_CAMERA           = false
var BOSS_ENABLED           = false

var ENABLED_SKILLS = {
	"Attack1"     : true,
	"Jump"        : true,
	"JumpAttack1" : true,
	"JumpAttack2" : false,
	"Jump2"       : false,
	"Attack2"     : false,
	"Attack3"     : false,
	"Magic2"      : false,
	"Magic3"      : false,
	"Magic4"      : false,
	"Attack4"     : false,
	"Block"       : false #Don't switch it off is bugged
}

var GRAVITY      = 50
var IN_AIR_SPEED = 60
var SPEED        = 400
var SPEED_JUMP   = 1050

var MAZE_SIZE = Vector2(4, 4)

var labirynth    = {}
var done_segment = 0
var total_cleaned = 0

var new_power_text = {
	1 : [ "",            false, false ],
	2  : [ "JumpAttack1", false, false ],
	3  : [ "Attack2",     false, false ],
	4  : [ "Magic2",      false, true  ],
	5  : [ "Jump2",       false, false ],
	6  : [ "",             true, false ],
	7  : [ "Attack3",     false, true  ],
	8  : [ "Magic3",      false, false ],
	9  : [ "JumpAttack2", false, false ],
	10  : [ "",             true, true  ],
	11 : [ "Attack4",     false, false ],
	12 : [ "Magic4",      false, false ],
	13 : [ "",             true, true  ],
	14 : [ "BossOpen",    false, false ],
}

func show_info( ):
	pass

func unlock_new_power(i):
	#print( "Unclod")
	#done_segment += 1
	
	done_segment = Util.player.get_parent().get_node("LevelStructure").cout_cleared()
	print( "SegmentCleared ", done_segment )
	if done_segment < total_cleaned: return
	total_cleaned = done_segment
	print( new_power_text[total_cleaned] )
	info.show_info(new_power_text[total_cleaned])
	if done_segment > 13: 
		BOSS_ENABLED = true
		return
	ENABLED_SKILLS[ new_power_text[total_cleaned][0]] = true
	if new_power_text[total_cleaned][1] : player.increase_max_hp()
	#IMPROVECASTLE
	
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
