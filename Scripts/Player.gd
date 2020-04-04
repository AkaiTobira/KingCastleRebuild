extends KinematicBody2D

const WORLD_LIMIT = 6000;

var motion = Vector2(0,0)

var max_health = 100
var current_health = 100
var score = 0

var WALL_HOLDER_ENABLED     = true
var wall_holding            = false
var once_jumped             = true

var FSM = preload("res://Scripts/PlayerSFM.gd").new()

func _ready():
	motion.y += 1000

func fit_camera_to_world( world_begin, world_size ):
	$Camera2D.limit_left   = world_begin.x
	$Camera2D.limit_top    = world_begin.y
	$Camera2D.limit_right  = world_begin.x + world_size.x  
	$Camera2D.limit_bottom = world_begin.y + world_size.y

# warning-ignore:unused_argument


func _process(delta):
	FSM._process(delta)
	
	shake_camera()
	
func shake_camera():
	if not Util.SHAKE_CAMERA: return
	var shake_amount = 10.0
	$Camera2D.set_offset(Vector2( 
		rand_range(-1.0, 1.0) * shake_amount, 
		rand_range(-1.0, 1.0) * shake_amount ))

# warning-ignore:unused_argument
func _physics_process(delta):
	_gravity()
	move_and_slide(motion, Vector2(0,-1))

var dir = "R"

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

func get_animation_status():
	return float($AnimationPlayer.get_current_animation_position())/float($AnimationPlayer.get_current_animation_length())

func create_fireball():
	var instance = Util.get_project_tile("FBall")
	instance.dir = sign(scale.x)
	instance.position = position + instance.dir * 50 * Vector2(1, 0)
	get_parent().add_child(instance)
	pass

func create_enegrySphere():
	var instance = Util.get_project_tile("EBall")
	instance.dir = sign(scale.x)
	instance.position = position + instance.dir * 50 * Vector2(1, 0)
	get_parent().add_child(instance)

func play_anim(anim_name): 
	if $AnimationPlayer.current_animation == anim_name : return
	#var nodes = $Sprites
	#for node in nodes.get_children():
	#	node.visible = false
	$AnimationPlayer.play(anim_name)

func should_land():
	if test_move( get_transform(), Vector2(0, 20) ): return true
	return false

func _on_AttackBox_area_entered(_area):
	pass # Replace with function body.

func _on_HitBox1_body_entered():
	pass # Replace with function body.

func _on_HitBox2_body_entered():
	pass # Replace with function body.

func _on_HitBox3_body_entered():
	pass # Replace with function body.

func _on_AttakBox_area_entered(area):
	pass # Replace with function body.
