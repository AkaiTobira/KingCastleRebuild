extends Node2D

var state = "open"

func close_gate():
	if state == "open":
		state = "closed"
		$AnimationPlayer.play("Close")

func open_gate():
	if state == "closed":
		state = "open"
		$AnimationPlayer.play_backwards("Close")

