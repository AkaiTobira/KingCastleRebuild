extends KinematicBody2D

var motion = Vector2(0,0)
var UP     = Vector2(0,-1)
var dir    = "R"

var op_dir = { "R" : "L", "L" : "R"}

func _ready():
	change_direction("R" if randi()%2 == 0 else "L")

func _physics_process(delta):
	_gravity()
	move_and_slide(motion, UP)

func change_direction(new_dir):
	if dir == new_dir : return
	dir      = new_dir
	scale.x *= -1

func _gravity():
	if not Util.PLAYER_GRAVITY_ENABLER: 
		motion.y = 0
		return 
	if is_on_floor(): 
		motion.y = min( motion.y, Util.SPEED/2 )
		return
	motion.y += Util.GRAVITY 

var is_waked = false
export var patrol_behaviour = true
export var MONSTER_SPEED    = 200

var timer1 = 0
var timerl = 0.5

func patrol_move(delta):
	motion.x = MONSTER_SPEED * (-1 if dir == "L" else 1)
	timer1 += delta
	if timer1 < timerl : return
	if $RayCast2D2.is_colliding(): 
		timer1 = 0
		change_direction(op_dir[dir])
	elif not $RayCast2D.is_colliding():
		timer1 = 0
		change_direction(op_dir[dir])
	 

func _process(delta):
	if is_waked : pass
	elif ( patrol_behaviour ): patrol_move(delta)
