extends KinematicBody2D

export var GRAVITY = 200
export var SPEED = 1000
export var SPEED_JUMP = 3000
var UP = Vector2(0,-1)

signal _animate

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

func _ready():
#	var tilemap_rect = get_parent().get_node("TileMap").get_used_rect()
#	var tilemap_cell_size = get_parent().get_node("TileMap").cell_size
	OnHit(0)
	current_health = max_health

func OnHit(damage):
	current_health = min( max( current_health - damage, 0 ), max_health )
#	GUI.get_node("TextureProgress").value     = int(current_health)
#	GUI.get_node("TextureProgress").max_value = max_health
#	GUI.get_node("Label2").text               = str(int(current_health) ) + "/" + str( max_health )
	if current_health <= 0 : _endgame()

func increase_HP( amount ):
	max_health += amount
	OnHit(0)
#	var ap = GUI.get_node( "TextureProgress/AnimationPlayer" )
#	var anim = ap.get_animation( "Increase" )
#	var rec_scale_index = anim.find_track( ".:rect_scale" )
#	anim.track_set_key_value( rec_scale_index, 1, anim.track_get_key_value(rec_scale_index, 1) + Vector2((amount/150.0), 0 ) )
#	ap.play( "Increase" )

func activate_GramplingHook():
	if Input.is_mouse_button_pressed(BUTTON_RIGHT) and not ( grapling_shooted or  grapling_hooked) :
#		Music.play_sfx("Hook1")
		OnHit( 1.5 )
		$Skills/GraplingHook/Line2D.visible      = true
		$Skills/GraplingHook/Line2D/Hook.visible = true
		var target_point    = get_viewport().get_mouse_position()
		var origin_position = get_global_transform_with_canvas().origin
		grapling_direction  = (target_point  - origin_position).normalized()
		grapling_shooted    = true

func process_targeting_GramplingHook(delta):
	if grapling_shooted and not grapling_hooked:
		grapling_lenght_current = min( grapling_lenght_current + grapling_speed * delta, grapling_lenght )
		var point     = grapling_direction * grapling_lenght_current
		$Skills/GraplingHook.cast_to              = point 
		$Skills/GraplingHook/Line2D.points[1]     = point
		$Skills/GraplingHook/Line2D/Hook.position = point
		$Skills/GraplingHook/Line2D.visible      = true
		
		if grapling_lenght_current == grapling_lenght : 
			grapling_shooted        = false
			grapling_lenght_current = 0
			$Skills/GraplingHook.cast_to = Vector2(0,0)
			$Skills/GraplingHook/Line2D.visible = false

		if $Skills/GraplingHook.is_colliding() :
#			Music.play_sfx("Catch")
			$Skills/GraplingHook/Line2D/Hook.visible = false
			grapling_hit_point =  $Skills/GraplingHook.get_collision_point()
			grapling_hooked = true

func process_pull_GramplingHook(delta):
	if grapling_hooked: 
		motion = grapling_direction * SPEED
		grapling_lenght_current = max( grapling_lenght_current - SPEED * delta, 0 )
		var point     = grapling_direction * grapling_lenght_current
		$Skills/GraplingHook.cast_to = point 
		$Skills/GraplingHook/Line2D.points[1] = point
		
		var hit_the_wall     = test_move( get_transform(), motion * delta )
		var going_into_space = not test_move( get_transform(), motion * SPEED  * delta )
		
		if hit_the_wall or going_into_space:
			grapling_hooked  = false
			grapling_lenght_current = 0
			grapling_shooted = false
			$Skills/GraplingHook/Line2D.visible = false
			grampling_cd_timer = grampling_cd

func _process(delta): pass
#	GUI.get_node("Label").text = "x " + str(score)
#	OnHit(0.3*delta)

func _grapling_hook(delta):
	if not GRAPLING_HOOK_ENABLED: return
	grampling_cd_timer -= delta
	if grampling_cd_timer > 0 : return
	activate_GramplingHook()
	process_targeting_GramplingHook(delta)
	process_pull_GramplingHook(delta)

func _physics_process(delta):
	_gravity()
	_movement()
	_jump()
	#_grapling_hook(delta)
	#_wall_holder(delta)
	move_and_slide(motion, UP)

func _animate():
	emit_signal("_animate", motion)

func _wall_holder(delta):
	if not WALL_HOLDER_ENABLED: return
	
	if Input.is_action_just_pressed("wall_hold"): 
		wall_holding = true
	#	once_jumped  = true
	
	if Input.is_action_pressed("wall_hold"):
		wall_holding = true
		var distance = 100
		var close_wall_left  = test_move( get_transform(), Vector2( -distance, 0 ) * delta ) 
		var close_wall_right = test_move( get_transform(), Vector2( distance, 0 ) * delta )
		
		if close_wall_left:  play_anim_if_not_played("HoldLeft")
		if close_wall_right: play_anim_if_not_played("HoldRight")
		
		if not (close_wall_left or close_wall_right) : 
		
			if $AnimationPlayer.current_animation == "HoldLeft":  $AnimationPlayer.play("IdleLeft")
			if $AnimationPlayer.current_animation == "HoldRight": $AnimationPlayer.play("IdleRight")
			wall_holding = false
		#	once_jumped  = true
	else: 
		if $AnimationPlayer.current_animation == "HoldLeft":  $AnimationPlayer.play("IdleLeft")
		if $AnimationPlayer.current_animation == "HoldRight": $AnimationPlayer.play("IdleRight")
		wall_holding = false
		#once_jumped = true

func _jump():
	
	if Input.is_action_pressed("ui_up") and wall_holding: #and once_jumped:
		motion.y -= SPEED_JUMP * 2
	#	once_jumped = false
	
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
#	get_tree().change_scene("res://Scenes/EndGame.tscn")
#	GUI.get_node( "TextureProgress" ).rect_scale.x = 0.25
	

func add_to_score(amount):
	score += amount

func play_anim_if_not_played(anim_name): pass
#	if $AnimationPlayer.current_animation == anim_name : return
#	$AnimationPlayer.play(anim_name)

func heal_cost( premium ):
	match( premium ):
		"G" : GRAPLING_HOOK_ENABLED = true

func _hurt():
#	Music.play_sfx("BipBop")
	position.y -= -1
	motion.y -= SPEED_JUMP 
	OnHit(20)
	if current_health < 0:
#		GUI.get_node("TextureProgress").visible = false
		_endgame()
