extends Node2D

func _ready():
	Util.player = $Player
	Util.GUI    = $GUI
	$Player.position = Util.SEGMENT_SIZE/2
