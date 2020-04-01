extends KinematicBody2D

var motion = Vector2(0,0)
var UP     = Vector2(0,-1)
var dir    = "R"

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	_gravity()
	move_and_slide(motion, UP)

func change_direction(new_dir):
	if dir == new_dir : return
	dir      = new_dir
	scale.x *= -1

func _gravity():
	if is_on_floor(): 
		motion.y = 0
		return
	motion.y += Util.GRAVITY 
