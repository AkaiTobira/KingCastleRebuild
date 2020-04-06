extends Node2D

func update_D():
	print(get_child_count())
	for i in range( get_child_count()):
		get_child(i).visible = i + 1 <= Util.destroy_level
		print( get_child(i).visible, i + 1 <= Util.destroy_level )
