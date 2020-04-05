extends Sprite

func _ready():
	$AnimationPlayer.play_backwards("Darkness")
	#position = Vector2( 892-800, 586)

var game_over = false

func show_game_over():
	game_over = true
	$AnimationPlayer.play("Darkness")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Darkness" and game_over: 
		get_tree().reload_current_scene()
