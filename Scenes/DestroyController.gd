extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func update_D():
	print(get_child_count())
	for i in range( get_child_count()):
		get_child(i).visible = i + 1 <= Util.destroy_level
		print( get_child(i).visible, i + 1 <= Util.destroy_level )


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
