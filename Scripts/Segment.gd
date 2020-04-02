extends Node2D


export var valid_enter = { "U" :false, "D": false, "L":false, "R":false }

func generate_enemies():
	for child in $EnemiesMarker.get_children():
		var instance = Util.get_enemy_instance()
		instance.position = child.position
		$EnemiesMarker.add_child(instance)


func _ready():
	generate_enemies()
	pass # Replace with function body.
