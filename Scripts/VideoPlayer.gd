extends Control

func _on_VideoPlayer_finished():
	get_tree().change_scene("res://Scenes/Game.tscn")

func _on_Control_finished():
	get_tree().change_scene("res://Scenes/Game.tscn")


func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
			get_tree().change_scene("res://Scenes/Game.tscn")

