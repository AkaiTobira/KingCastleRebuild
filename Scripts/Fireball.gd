extends Area2D

export var SPEED = 0
var dir = 1

func _process(delta):
	if dir == -1: $Sprite.flip_h = true
	position.x += dir * SPEED * delta

func _on_Area2D_area_entered(area):
	if "Player" in area.get_parent().get_groups(): return
	if "Enemy"  in area.get_parent().get_groups():
		area.get_parent().on_hit(20, dir)
		call_deferred("queue_free")
