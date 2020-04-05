extends Area2D

export var SPEED = 0
var dir = 1

func _process(delta):
	if dir == -1: $Sprite.flip_h = true
	position.x += dir * SPEED * delta
	pass

func _on_Area2D_area_entered(area):
	area.get_parent().on_hit(20)
	call_deferred("queue_free")

