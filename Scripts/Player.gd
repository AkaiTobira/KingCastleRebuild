extends KinematicBody2D

const WORLD_LIMIT = 6000;

var motion = Vector2(0,0)

var max_health     = 100
var current_health = 100
var score = 0

var WALL_HOLDER_ENABLED     = true
var wall_holding            = false
var once_jumped             = true
var block_animation         = false
var last_hit_by             = null

var start_block  = true

var FSM = preload("res://Scripts/PlayerSFM.gd").new()

func _ready():
	$AnimationPlayer.play("Start")
	motion.y += 1000
	$HitBox/CollisionShape2D.disabled  = false

func fit_camera_to_world( world_begin, world_size ):
	$Camera2D.limit_left   = world_begin.x
	$Camera2D.limit_top    = world_begin.y
	$Camera2D.limit_right  = world_begin.x + world_size.x  
	$Camera2D.limit_bottom = world_begin.y + world_size.y

func reload(): pass

var damage         = 15
var heart_unlocked = 0

func increase_max_hp():
	if heart_unlocked == 3: return
	Util.GUI.get_node("TextureProgress").rect_position.x += 65
	heart_unlocked = min(   3, heart_unlocked + 1 )
	max_health     = min( 200, max_health     + 33.4)
	current_health = min( 200, current_health + 33.4)

# warning-ignore:unused_argument
func _process(delta):
	if start_block: return
	FSM._process(delta)
	Util.GUI.get_node("TextureProgress").value = current_health * 3 + 100 * (3 - heart_unlocked)
	shake_camera()

func shake_camera():
	if not Util.SHAKE_CAMERA: return
	var shake_amount = 10.0
	$Camera2D.set_offset(Vector2( 
		rand_range(-1.0, 1.0) * shake_amount, 
		rand_range(-1.0, 1.0) * shake_amount ))

# warning-ignore:unused_argument
func _physics_process(delta):
#	get_hit_in_this_frame = false
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
	instance.dir = -1 if dir == "L" else 1
	instance.position = position + instance.dir * 50 * Vector2(1, 0)
	get_parent().add_child(instance)

func create_enegrySphere():
	var instance = Util.get_project_tile("EBall")
	instance.dir = -1 if dir == "L" else 1
	instance.position = position + instance.dir * 50 * Vector2(1, 0)
	get_parent().add_child(instance)

func play_anim(anim_name): 
	if block_animation :
		$AnimationPlayer.stop()
		return
	if $AnimationPlayer.current_animation == anim_name : return
	$AnimationPlayer.play(anim_name)

func should_land():
	if test_move( get_transform(), Vector2(0, 20) ): return true
	return false

func on_hit( _o): pass

func _on_AttakBox_area_entered(area):
	if not "Enemy" in area.get_parent().get_groups(): return
	var direction = -1 if position.x < area.get_parent().position.x else 1
	area.get_parent().on_hit( 15, direction )

func _on_HitBox1_area_entered(area):
	#if "Block" in FSM.stack[0].get_class():
	#	FSM.stack.push_front( FSM.BlockBlocked.new(FSM.stack))
	current_health -= area.get_parent().damage
	if current_health < 0: FSM._player_get_hit("Dead")
	else: FSM._player_get_hit("Hit1")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Dead" and current_health < 0:
		block_animation = true
		Util.darkness.show_game_over()
	if anim_name == "Start": 
	#	Util.info.get_node("TextureRect/Welcomer")
		Util.info.get_node("AnimationPlayer").play("Show")
		start_block = false
