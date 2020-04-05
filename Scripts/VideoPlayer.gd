extends Control

func _on_VideoPlayer_finished():
	get_tree().change_scene("res://Scenes/Game.tscn")
	pass # Replace with function body.


func _on_Control_finished():
	get_tree().change_scene("res://Scenes/Game.tscn")
	pass # Replace with function body.
