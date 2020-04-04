extends Area2D

export var SPEED = 0
var dir = 1

func _process(delta):
	position.x += dir * SPEED
	pass

func _on_Area2D_area_entered(area):
	call_deferred("queue_free")

