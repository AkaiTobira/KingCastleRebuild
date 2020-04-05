extends KinematicBody2D

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

func patrol_move(delta):
	if disable_action : return
	
	
	need_dir_change = false
	motion.x = MONSTER_SPEED * (-1 if dir == "L" else 1)
	timer1 += delta
	if timer1 < timerl : return
	if $RayCast2D3.is_colliding(): 
		var collider = $RayCast2D3.get_collider()
		if len(collider.get_groups()) != 0 : 
			if "Player" in collider.get_groups() and attack_action: 
				motion.x = 0
				$AnimationPlayer.play("Atak")
				attack = true
				return
			elif "Enemy" in collider.get_groups():
				need_dir_change = true
	if $RayCast2D2.is_colliding():    need_dir_change = true
	if not $RayCast2D.is_colliding(): need_dir_change = true
	if need_dir_change :
		timer1 = 0
		change_direction(op_dir[dir])
		
func _process(delta):
	if attack : return
	elif ( patrol_behaviour ): patrol_move(delta)

var is_ready = true

func on_hit( val ):
	disable_action = true
	play_if_n_player("Hit")
	motion.x = 50 
	hp -= val
	if hp < 0 : on_dead()

func on_dead():
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	$HitBox/CollisionShape2D.set_deferred("disabled", true)
	disable_action = true
	attack = false
	patrol_behaviour = false
	play_if_n_player("Dead")
	var node = get_parent().get_parent()
	if node.has_method("increase_counter"): 
		node.increase_counter()

func play_if_n_player(anim):
	if $AnimationPlayer.current_animation == anim: return
	$AnimationPlayer.play(anim)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Atak":
		attack = false
		timer1 = 0
		$AnimationPlayer.play("Walk")
	if anim_name == "Dead":
		call_deferred("queue_free")
	if anim_name == "Hit":
		$AnimationPlayer.play("Walk")
		disable_action = false
		motion.x = 0
