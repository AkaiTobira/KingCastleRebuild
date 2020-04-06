extends Node2D

func _ready():
	Util.player   = $Player
	Util.GUI      = $CanvasLayer/Control
	Util.darkness = $CanvasLayer/Control/Sprite
	Util.info     = $CanvasLayer/Control/Control
	
	set_player_in_level()

func set_player_in_level():
	$Player.position = $LevelStructure.get_start_point()
	Util.player.fit_camera_to_world(  $LevelStructure.get_current_world_begin(), $LevelStructure.get_current_world_value() )
	$LevelStructure.change_style()

func _process(delta): pass
#	print($Player.position )
var damage = 20
func on_hit( va ) : pass
