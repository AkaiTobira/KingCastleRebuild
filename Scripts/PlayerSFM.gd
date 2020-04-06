extends Node

var stack = []

func _init(): 
	stack.push_front( Idle.new(stack) )

func _player_get_hit( state ):
	if stack[0].get_class() == "Dead" : return
	_exit_tree()
	stack = []
	stack.push_front(Idle.new(stack))
	match (state) :
		"Hit1"  :  stack.push_front( Hit1.new(stack) )
		"Hit2"  :  stack.push_front( Hit2.new(stack) )
		"Hit3"  :  stack.push_front( Hit3.new(stack) )
		"Dead"  :  stack.push_front( Dead.new(stack) )

func _exit_tree(): #FOR GOD SAKE THIS GODOT SHOULD DO!!!
	while len(stack):
		stack[0].stack = null
		stack.pop_front()

func _process(delta):
	
#	var restr = "["
#	for elem in stack:
#		restr += elem.get_class() + ","
#	restr += "]"
#	print( restr )
#	if Flow.world_is_paused or Utilities.player.pause: return
	while stack[0].is_over : stack.pop_front()
	stack[0].update(delta)
	stack[0].handle_input()

class State:
# warning-ignore:unused_class_variable
	var is_over            = false
	var stack              = null
	var active_animation   = "Idle"

	func _init(s_stack): 
		stack            = s_stack

class Dead extends State:
	func get_class():
		return "Dead"

	func _init(s_stack).(s_stack): pass
	func update(_delta): 
		Util.player.play_anim("Dead")
	func handle_input(): pass

class Hit3 extends AttackBase:

	func get_class():
		return "Hit3"

	func _init(s_stack).(s_stack, "Hit3", 0.90):
		Util.PLAYER_GRAVITY_ENABLER = false

	func push_next_attack(): pass
	func handle_input(): pass

class Hit1 extends AttackBase:

	func get_class():
		return "Hit1"

	func _init(s_stack).(s_stack, "Hit1", 0.90):
		Util.PLAYER_GRAVITY_ENABLER = false

	func push_next_attack(): pass

	func handle_input(): pass

class Hit2 extends AttackBase:

	func get_class():
		return "Hit2"

	func _init(s_stack).(s_stack, "Hit2", 0.90):
		Util.PLAYER_GRAVITY_ENABLER = false

	func push_next_attack(): pass

	func handle_input(): pass


class BlockOpen extends AttackBase:

	func get_class():
		return "BlockOpen"

	func _init(s_stack).(s_stack, "BlokStart", 1):
		Util.PLAYER_GRAVITY_ENABLER = false

	func push_next_attack():
		is_over = true
		stack.push_front( BlockIdle.new(stack))

	func handle_input():
		if Input.is_action_just_released("mouse_rigth") : 
			is_over = true
			stack.push_front( BlockClose.new(stack)) 


class BlockBlocked extends AttackBase:

	func get_class():
		return "BlockBlocked"

	func _init(s_stack).(s_stack, "BlokStartBlock", 0.90):
		Util.PLAYER_GRAVITY_ENABLER = false

	func push_next_attack(): 
		is_over = true

	func handle_input(): pass

class BlockIdle extends AttackBase:

	func get_class():
		return "BlockClose"

	func _init(s_stack).(s_stack, "BlokStartIdle", 2):
		Util.PLAYER_GRAVITY_ENABLER = false

	func push_next_attack(): pass

	func handle_input():
		if Input.is_action_just_released("mouse_rigth") : 
			is_over = true
			stack.push_front( BlockClose.new(stack))


class BlockClose extends AttackBase:

	func get_class():
		return "BlockClose"

	func _init(s_stack).(s_stack, "BlokClose", 0.9):
		Util.PLAYER_GRAVITY_ENABLER = false

	func push_next_attack():
		is_over = true

	func handle_input(): pass


class Move extends State:
	var jump_counter = 0
	
	func get_class():
		return "Move" + Util.player.dir
	
	func _init(s_stack, direction).(s_stack): 
		Util.player.change_direction(direction)

	func update(_delta):
		Util.player.play_anim("Walk")
		Util.PLAYER_GRAVITY_ENABLER = true
		if Util.player.motion.y > Util.SPEED/2: stack.push_front( Fall.new(stack) )
		if Util.player.dir == "R" : update_move_right()
		if Util.player.dir == "L" : update_move_left()

	func update_move_left():
		Util.player.motion.x = -Util.SPEED
		if !Input.is_action_pressed("ui_left") : is_over = true

	func update_move_right():
		Util.player.motion.x = Util.SPEED
		if !Input.is_action_pressed("ui_right") : is_over = true

	func handle_input(): 
		handel_input_left()
		handel_input_right()
		if   Input.is_action_just_pressed("mouse_left") : stack.push_front( Attack1.new(stack) )
		elif Input.is_action_pressed("ui_up") or jump_counter > 0 : handle_jump()
		elif Input.is_action_just_pressed("mouse_rigth") and Util.ENABLED_SKILLS["Block"] : stack.push_front( BlockOpen.new(stack)) 


	func handle_jump():
		if Input.is_action_pressed("ui_up"): jump_counter = 10
		if jump_counter > 0:
			jump_counter -= 1
			if Util.player.is_on_floor():
				stack.push_front( Jump.new(stack) )
				jump_counter = 0

	func handel_input_left(): pass
	func handel_input_right(): pass

class Jump extends State:
	var start_combo_once = true
	
	func get_class():
		return "Jump"
	
	func _init(s_stack).(s_stack):
		Util.PLAYER_IN_AIR_ENABLED = true
		Util.player.motion.y = -Util.SPEED_JUMP 

	func update(_delta):
		Util.player.play_anim("Jump")
		Util.PLAYER_GRAVITY_ENABLER = true
		if Util.player.is_on_ceiling(): Util.player.motion.y = 0
		if Util.player.motion.y < 0  : return
		if Util.player.motion.y > Util.SPEED/2: stack.push_front( Fall.new(stack) )
		if Util.player.is_on_floor() : is_over = true

	func handle_input():
		if   Input.is_action_pressed("ui_right"): stack.push_front( SlightAirMove.new(stack, "R", start_combo_once) )
		elif Input.is_action_pressed("ui_left") : stack.push_front( SlightAirMove.new(stack, "L", start_combo_once) )
		elif Input.is_action_just_pressed("ui_up") and Util.ENABLED_SKILLS["Jump2"] and Util.PLAYER_SECOND_JUMP :  
			Util.player.play_anim("Fall")
			Util.PLAYER_SECOND_JUMP = false
			stack.push_front( Jump.new(stack) )
		if   Input.is_action_just_pressed("mouse_left") and Util.ENABLED_SKILLS["JumpAttack1"] and Util.PLAYER_IN_AIR_ENABLED : 
			stack.push_front( JumpAttack1.new(stack) )

class Fall extends State:
	var start_combo_once = true
	
	func get_class():
		return "Fall"
	
	func _init(s_stack).(s_stack):
		Util.PLAYER_IN_AIR_ENABLED = true

	func update(_delta):
		Util.player.play_anim("Fall")
		Util.PLAYER_GRAVITY_ENABLER = true
		if Util.player.motion.y < 0  : return
		if Util.player.is_on_floor() : is_over = true

	func handle_input():
		if   Input.is_action_pressed("ui_right"): stack.push_front( SlightAirMove.new(stack, "R", start_combo_once) )
		elif Input.is_action_pressed("ui_left") : stack.push_front( SlightAirMove.new(stack, "L", start_combo_once) )
		elif Input.is_action_just_pressed("ui_up") and Util.ENABLED_SKILLS["Jump2"] and Util.PLAYER_SECOND_JUMP :   
			Util.PLAYER_SECOND_JUMP = false
			Util.player.play_anim("Fall")
			stack.push_front( Jump.new(stack) )
		if   Input.is_action_just_pressed("mouse_left") and Util.ENABLED_SKILLS["JumpAttack1"] and Util.PLAYER_IN_AIR_ENABLED : 
			stack.push_front( JumpAttack1.new(stack) )

class AttackBase extends State:
	var dir              = null
	var animation_status = 0
	var animation_name   = ""
	var next_key_presed  = ""
	var change_r         = 1.0

	func _init(s_stack, a_name, change_rate).(s_stack):
		change_r = change_rate
		animation_name  = a_name
	
	func update(_delta):
		Util.player.play_anim(animation_name)
		animation_status = Util.player.get_animation_status()
		Util.player.motion.x = (-Util.SPEED if Util.player.dir == "L" else Util.SPEED)  * ((1.0 - animation_status))*0.2
		if( animation_status > 0.9): 
			is_over = true
			Util.PLAYER_GRAVITY_ENABLER = false
		elif( animation_status > change_r):
	#		print(change_r, next_key_presed)
			if next_key_presed != "":
				is_over = true
				push_next_attack()
				Util.PLAYER_GRAVITY_ENABLER = false

	func push_next_attack(): pass
	func handle_input(): pass

class Attack1 extends AttackBase:

	func get_class():
		return "Attack1"

	func _init(s_stack).(s_stack,"Attack1", 3.0/4.0):
		Util.PLAYER_GRAVITY_ENABLER = false

	func push_next_attack():
		is_over = true
		match next_key_presed:
			"MouseL" : stack.push_front( Attack2.new(stack) )
			"E"      : stack.push_front( Magic2.new(stack) )
			_ : return
	
	func handle_input():
		if animation_status > 0.2:
			if Input.is_action_just_pressed("mouse_left") and Util.ENABLED_SKILLS["Attack2"] : next_key_presed = "MouseL"
			if Input.is_action_just_pressed("ui_magic")   and Util.ENABLED_SKILLS["Magic2"]  : next_key_presed = "E"

class JumpAttack1 extends AttackBase:

	func get_class():
		return "JumpAttack1"

	func _init(s_stack).(s_stack,"JumpAttack1", 0.45):
		Util.PLAYER_IN_AIR_ENABLED  = false
		Util.PLAYER_GRAVITY_ENABLER = false

	func push_next_attack():
		is_over = true
		match next_key_presed:
			"MouseL" : stack.push_front( JumpAttack2.new(stack) )
			_ : return
	
	func handle_input():
		if animation_status > 0.2:
			if Input.is_action_just_pressed("mouse_left") and Util.ENABLED_SKILLS["JumpAttack2"] : next_key_presed = "MouseL"

class JumpAttack2 extends AttackBase:
	func get_class():
		return "JumpAttack2"

	func _init(s_stack).(s_stack, "JumpAttack2", 0.96):
		Util.PLAYER_GRAVITY_ENABLER = false

	func push_next_attack(): pass
	func handle_input(): pass


class Magic2 extends AttackBase:

	func get_class():
		return "Magic2"

	func _init(s_stack).(s_stack,"Magic2", 2.31/3.3):
		Util.PLAYER_GRAVITY_ENABLER = false
	
	func push_next_attack():
		match next_key_presed:
			"MouseL" : stack.push_front( Attack4.new(stack) )
			"E"      : stack.push_front( Magic4.new(stack) )
			_ : return
	
	func handle_input():
		if animation_status > 0.2:
			if Input.is_action_just_pressed("mouse_left") and Util.ENABLED_SKILLS["Attack4"] : next_key_presed = "MouseL"
			if Input.is_action_just_pressed("ui_magic")   and Util.ENABLED_SKILLS["Magic4"]  : next_key_presed = "E"

class Attack2 extends AttackBase:

	func get_class():
		return "Attack2"

	func _init(s_stack).(s_stack,"Attack2", 3.0/4.0):
		Util.PLAYER_GRAVITY_ENABLER = false
	
	func push_next_attack():
		match next_key_presed:
			"MouseL" : stack.push_front( Attack3.new(stack) )
			"E"      : stack.push_front( Magic3.new(stack) )
			_ : return
	
	func handle_input():
		if animation_status > 0.2:
			if Input.is_action_just_pressed("mouse_left") and Util.ENABLED_SKILLS["Attack3"]: next_key_presed = "MouseL"
			if Input.is_action_just_pressed("ui_magic")   and Util.ENABLED_SKILLS["Magic3"] : next_key_presed = "E"

class Magic4 extends AttackBase:

	func get_class():
		return "Magic4"

	func _init(s_stack).(s_stack, "Magic4", 0.96):
		Util.PLAYER_GRAVITY_ENABLER = false

	func push_next_attack(): pass
	func handle_input(): pass

class Attack4 extends AttackBase:

	func get_class():
		return "Attack4"

	func _init(s_stack).(s_stack, "Attack4", 0.96):
		Util.PLAYER_GRAVITY_ENABLER = false

	func push_next_attack(): pass
	func handle_input(): pass

class Magic3 extends AttackBase:

	func get_class():
		return "Magic3"

	func _init(s_stack).(s_stack, "Magic3", 0.96):
		Util.PLAYER_GRAVITY_ENABLER = false
		
	func push_next_attack(): pass
	func handle_input(): pass

class Attack3 extends AttackBase:

	func get_class():
		return "Attack3"

	func _init(s_stack).(s_stack,"Attack3", 0.96):
		Util.PLAYER_GRAVITY_ENABLER = false
		
	func push_next_attack(): pass
	func handle_input(): pass

class SlightAirMove extends State:
	var dir = null

	func get_class():
		return "SlightAirMove" + dir

	func _init(s_stack, direction, start_combo_once).(s_stack): 
		dir = direction

	func update(_delta):
		Util.PLAYER_GRAVITY_ENABLER = true
		if Util.player.is_on_ceiling(): Util.player.motion.y = 0
		if Util.player.motion.y > Util.SPEED/2: 
			if stack[1].get_class() != "Fall":
				stack.push_front( Fall.new(stack) )
		if Util.player.is_on_floor():
			is_over = true
			return
		if dir == "R" : update_move_right()
		if dir == "L" : update_move_left()

	func update_move_left():
		Util.player.motion.x = max( -Util.SPEED, Util.player.motion.x -Util.IN_AIR_SPEED )
		if( Util.player.motion.x < 0) : Util.player.change_direction("L")
		if !Input.is_action_pressed("ui_left") : is_over = true

	func update_move_right():
		Util.player.motion.x = min( +Util.SPEED, Util.player.motion.x +Util.IN_AIR_SPEED )
		if( Util.player.motion.x > 0) : Util.player.change_direction("R")
		if !Input.is_action_pressed("ui_right") : is_over = true

	func handle_input(): 
		
		if Input.is_action_just_pressed("mouse_left") and Util.ENABLED_SKILLS["JumpAttack1"] and Util.PLAYER_IN_AIR_ENABLED : 
			stack.push_front( JumpAttack1.new(stack) )
		elif Input.is_action_just_pressed("ui_up") and Util.ENABLED_SKILLS["Jump2"] and Util.PLAYER_SECOND_JUMP :  
			Util.player.play_anim("Fall")
			Util.PLAYER_SECOND_JUMP = false
			stack.push_front( Jump.new(stack) )

class Idle extends State:

	var jump_counter = 0
	var jump_pressed = false

	func get_class():
		return "Idle"

	func _init(s_stack).(s_stack): pass

	func update(_delta): 
		Util.player.play_anim("Idle")
		Util.PLAYER_GRAVITY_ENABLER = true
		Util.PLAYER_SECOND_JUMP     = true
		Util.player.motion.x = 0
		if Util.player.motion.y > Util.SPEED/2: stack.push_front( Fall.new(stack) )

	func handle_input(): 
		if   Input.is_action_just_pressed("mouse_left") : stack.push_front( Attack1.new(stack) )
		elif Input.is_action_pressed("ui_right"): stack.push_front( Move.new(stack, "R") )
		elif Input.is_action_pressed("ui_left") : stack.push_front( Move.new(stack, "L") )
		elif Input.is_action_pressed("ui_up") or jump_counter > 0 : handle_jump()
		elif Input.is_action_just_pressed("mouse_rigth") and Util.ENABLED_SKILLS["Block"] : stack.push_front( BlockOpen.new(stack)) 

	func handle_jump():
		if Input.is_action_pressed("ui_up"): jump_counter = 10
		if jump_counter > 0:
			jump_counter -= 1
			if Util.player.is_on_floor():
				stack.push_front( Jump.new(stack) )
				jump_counter = 0

