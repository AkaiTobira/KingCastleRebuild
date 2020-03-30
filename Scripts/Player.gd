extends KinematicBody2D

export var GRAVITY = 200
export var SPEED = 1000
export var SPEED_JUMP = 3000
var UP = Vector2(0,-1)


const WORLD_LIMIT = 6000;

var motion = Vector2(0,0)

var max_health = 100
var current_health = 100
var score = 0

var GRAPLING_HOOK_ENABLED   = true #for test
var grapling_shooted        = false
var grapling_hooked         = false
var grapling_lenght         = 750
var grapling_lenght_current = 0
var grapling_speed          = 1500
var grapling_direction      = Vector2(0,0)
var grapling_hit_point      = Vector2(0,0)
var grampling_cd_timer      = 0
var grampling_cd            = 0.25

var WALL_HOLDER_ENABLED     = true
var wall_holding            = false
var once_jumped             = true

func _ready(): pass

func increase_HP( amount ):
	max_health += amount

# warning-ignore:unused_argument
func _process(delta): pass

# warning-ignore:unused_argument
func _physics_process(delta):
	_gravity()
	_movement()
	_jump()
# warning-ignore:return_value_discarded
	move_and_slide(motion, UP)

func _jump():
	if Input.is_action_pressed("ui_up") and is_on_floor():
		motion.y -= SPEED_JUMP 

func _movement():
	if wall_holding: return

	if Input.is_action_pressed("ui_left"):
		play_anim_if_not_played("MoveLeft")
	#	Music.play_sfx( "Wheels2" )
		motion.x = -SPEED
	elif Input.is_action_pressed("ui_right"):
		play_anim_if_not_played("MoveRight")
#		Music.play_sfx( "Wheels2" )
		motion.x = SPEED
	else:
#		Music.stop_sfx( "Wheels2" )
		motion.x = 0

func _gravity():
	if position.y > WORLD_LIMIT:
		_endgame()
	if is_on_floor():
		motion.y = 0 
	elif is_on_ceiling():
		motion.y = 100
	else:
		motion.y += GRAVITY/2 if grapling_shooted else  GRAVITY 
		if wall_holding : motion.y = 80

func _endgame(): pass

# warning-ignore:unused_argument
func play_anim_if_not_played(anim_name): pass
#	if $AnimationPlayer.current_animation == anim_name : return
#	$AnimationPlayer.play(anim_name)

