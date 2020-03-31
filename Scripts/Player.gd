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

var FSM = preload("res://Scripts/PlayerSFM.gd").new()

func _ready(): pass

# warning-ignore:unused_argument
func _process(delta): 
	FSM._process(delta)

# warning-ignore:unused_argument
func _physics_process(delta):
	_gravity()
#	_movement()
#	_jump()
# warning-ignore:return_value_discarded
	move_and_slide(motion, UP)

var dir = "R"

func change_direction(new_dir):
	if dir == new_dir : return
	dir = new_dir
	scale.x    *= -1

func _jump():
	if Input.is_action_pressed("ui_up") and is_on_floor():
		motion.y -= SPEED_JUMP 

func _gravity():
	motion.y += GRAVITY/2 if grapling_shooted else  GRAVITY 

func get_animation_status():
	return float($AnimationPlayer.get_current_animation_position())/float($AnimationPlayer.get_current_animation_length())

func play_anim(anim_name): 
	if $AnimationPlayer.current_animation == anim_name : return
	$AnimationPlayer.play(anim_name)

