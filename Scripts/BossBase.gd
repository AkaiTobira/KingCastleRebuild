extends KinematicBody2D

var parent_segment = null
var motion = Vector2(0,0)
var UP     = Vector2(0,-1)
var dir    = "R"

var op_dir = { "R" : "L", "L" : "R"}

func _ready():
	change_direction("R" if randi()%2 == 0 else "L")

func _physics_process(_delta):
	_gravity()
	move_and_slide(motion, UP)

func change_direction(new_dir):
	if dir == new_dir : return
	dir      = new_dir
	scale.x *= -1

func _gravity():
	if not gravity_enabled: return
	#if not Util.PLAYER_GRAVITY_ENABLER: 
	#	motion.y = 0
	#	return 
	if is_on_floor(): 
		motion.y = min( motion.y, Util.SPEED/2 )
		return
	motion.y += Util.GRAVITY 

var is_waked = false
export var patrol_behaviour = true
export var teleport_skill   = false
export var attack_action    = false
export var gravity_enabled  = true
export var MONSTER_SPEED    = 200
export var damage           = 5
export var hp               = 100

var timer1 = 1
var timerl = 0.25

var need_dir_change = false
var attack          = false
var disable_action  = false

var animation_queue = []

func patrol_move(delta):
	if disable_action : return
	
	play_anim("Walk")
	
	need_dir_change = false
	motion.x = MONSTER_SPEED * (-1 if dir == "L" else 1)
	timer1 += delta
	if timer1 < timerl : return
	if $RayCast2D3.is_colliding(): 
		var collider = $RayCast2D3.get_collider()
		if len(collider.get_groups()) != 0 : 
			if "Player" in collider.get_groups() and attack_action: 
				attack = true
				generate_animation_queue()
	if $RayCast2D2.is_colliding():    need_dir_change = true
	if not $RayCast2D.is_colliding():  need_dir_change = true
	if need_dir_change :
		timer1 = 0
		change_direction(op_dir[dir])

func generate_animation_queue():
	var iiii = 3#randi()%5
	
	match(iiii):
		0 : 
			animation_queue.push_back("Jump")
			animation_queue.push_back("JumpAttack1")
			animation_queue.push_back("JumpAttack2")
		1 :
			animation_queue.push_back("Attack1")
			animation_queue.push_back("Attack2")
			animation_queue.push_back("Attack3")
		2  :
			animation_queue.push_back("Attack1")
			animation_queue.push_back("Magic2")
			animation_queue.push_back("Attack4")
		3  : 
			animation_queue.push_back("Attack1")
			animation_queue.push_back("Magic2")
			animation_queue.push_back("Magic3")
		4  :
			animation_queue.push_back("Attack1")
			animation_queue.push_back("Attack2")
			animation_queue.push_back("Attack4")
	
	animation_queue.push_back("Idle")
	animation_queue.push_back("Idle")
	motion.x = 50 * (-1 if dir == "L" else 1)
	play_anim(animation_queue[0])
	animation_queue.remove(0)

func _process(delta):
	if attack : return
	elif ( patrol_behaviour ): patrol_move(delta)

var is_ready = true

func add_player_hp():
	Util.player.current_health = min( Util.player.current_health + 33, Util.player.max_health)

func on_hit( val, direction ):
	current_health -= val
	
	#change_direction( ("R" if direction == 1 else "L"))
	
	#disable_action = true

	if current_health < 0 :
		attack = true
		motion.x = 0
		play_anim("Dead")
		return
	
#	if $AnimationPlayer.current_animation != "Idle" or $AnimationPlayer.current_animation != "Walk" : return
	#var iii = randi()%3
	#if iii == 0: play_anim("Hit1")
#	if iii == 1: play_anim("Hit3")
	#if iii == 2: play_anim("Hit2")
	#animation_queue = []
	#attack = false


func on_dead():
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	$HitBox/CollisionShape2D.set_deferred("disabled", true)
	disable_action = true
	attack = false
	patrol_behaviour = false
	play_if_n_player("Dead")

	if parent_segment.has_method("increase_counter"): 
		parent_segment.increase_counter()

func play_if_n_player(anim):
	if $AnimationPlayer.current_animation == anim: return
	$AnimationPlayer.play(anim)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Dead": 
		Util.darknesse.play( "Darkness")
		return
	if "Hit" in anim_name: 
		disable_action = false
	if len(animation_queue) != 0:
		if animation_queue[0] == "Idle" : motion.x = 0
		play_anim(animation_queue[0])
		animation_queue.remove(0)
	else : attack = false


var max_health     = 300
var current_health = 400
var score = 0

var once_jumped             = true
var block_animation         = false
var last_hit_by             = null

func reload(): pass


func shake_camera():
	if not Util.SHAKE_CAMERA: return
	var shake_amount = 10.0
	$Camera2D.set_offset(Vector2( 
		rand_range(-1.0, 1.0) * shake_amount, 
		rand_range(-1.0, 1.0) * shake_amount ))


func get_animation_status():
	return float($AnimationPlayer.get_current_animation_position())/float($AnimationPlayer.get_current_animation_length())

func create_fireball():
	var instance = Util.get_project_tile("FBall")
	instance.dir = -1 if dir == "L" else 1
	instance.position = position + instance.dir * 50 * Vector2(1, 0)
	get_parent().add_child(instance)

func create_enegrySphere():
	var instance = Util.get_project_tile("DBall")
	instance.dir = -1 if dir == "L" else 1
	instance.position = position + instance.dir * 50 * Vector2(1, 0)
	get_parent().add_child(instance)

func play_anim(anim_name): 
	if block_animation :
		$AnimationPlayer.stop()
		return
	if $AnimationPlayer.current_animation == anim_name : return
	$AnimationPlayer.play(anim_name)


func _on_AttakBox_area_entered(area):
	pass # Replace with function body.

func _on_HitBox1_area_entered(area):
	if not area.get("damage") == null:
		current_health -= area.damage
	elif not area.get_parent().get("damage") == null:
		current_health -= area.get_parent().damage
	if current_health < 0 : 
		motion.x = 0
		play_anim("Dead")
	if $AnimationPlayer.current_animation != "Idle" or $AnimationPlayer.current_animation != "Walk" : return
	var iii = randi()%3
	if iii == 0: play_anim("Hit1")
	if iii == 1: play_anim("Hit3")
	if iii == 2: play_anim("Hit2")
	animation_queue = []
	attack = false
#	print( current_health )
