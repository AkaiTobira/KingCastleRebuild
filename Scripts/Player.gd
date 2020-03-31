extends KinematicBody2D

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

func _ready(): motion.y += 1000

# warning-ignore:unused_argument
func _process(delta): 
	FSM._process(delta)
	

# warning-ignore:unused_argument
func _physics_process(delta):
	#print(motion)
	_gravity()
	move_and_slide(motion, Vector2(0,-1))

var dir = "R"

func change_direction(new_dir):
	if dir == new_dir : return
	dir = new_dir
	scale.x    *= -1

var saved_gravity = 0
func _gravity():
	if not Util.PLAYER_GRAVITY_ENABLER: 
		motion.y = 0
		return 
	if is_on_floor(): return
	motion.y += Util.GRAVITY/2 if grapling_shooted else Util.GRAVITY 

func get_animation_status():
	return float($AnimationPlayer.get_current_animation_position())/float($AnimationPlayer.get_current_animation_length())

func play_anim(anim_name): 
	if $AnimationPlayer.current_animation == anim_name : return
	$AnimationPlayer.play(anim_name)

func _on_HitBox_body_entered(body):
	pass # Replace with function body.

func _on_AttackBox_area_entered(area):
	pass # Replace with function body.
