extends Node

var stack = []

func _init(): 
	stack.push_front( Idle.new(stack) )

func _exit_tree(): #FOR GOD SAKE THIS GODOT SHOULD DO!!!
	while len(stack):
		stack[0].stack = null
		stack.pop_front()

func _process(delta):
	print( stack )
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

class Move extends State:
	

	func _init(s_stack, direction).(s_stack): 
		Util.player.change_direction(direction)
	
	func update(delta):
	
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
		elif Input.is_action_pressed("ui_up") and Util.player.is_on_floor(): stack.push_front( Jump.new(stack) )

	func handel_input_left(): pass
	func handel_input_right(): pass


class Jump extends State:
	func _init(s_stack).(s_stack):
		Util.player.motion.y -= Util.SPEED_JUMP 

	func update(delta):
		if Util.player.motion.y < 0 : return
		if Util.player.is_on_floor() : is_over = true

	func handle_input():
		if   Input.is_action_pressed("ui_right"): stack.push_front( SlightAirMove.new(stack, "R") )
		elif Input.is_action_pressed("ui_left") : stack.push_front( SlightAirMove.new(stack, "L") )


class AttackBase extends State:
	var dir              = null
	var animation_status = 0
	var animation_name   = ""
	var next_key_presed  = ""

	func _init(s_stack, a_name).(s_stack):
		animation_name  = a_name
		var mouse_position = Util.GUI.get_global_mouse_position()- Util.player.position
		dir = "L" if mouse_position.x < 0 else "R"
		Util.player.change_direction(dir)
	
	func update(delta):
		Util.player.play_anim(animation_name)
		animation_status = Util.player.get_animation_status()
		if( animation_status > 0.95):
			is_over = true
			push_next_attack()
	
	func push_next_attack(): pass
	func handle_input(): pass

class Attack1 extends AttackBase:

	func _init(s_stack).(s_stack,"Attack1"): pass

	func push_next_attack():
		match next_key_presed:
			"MouseL" : stack.push_front( Attack2.new(stack) )
			_ : return
	
	func handle_input():
		if animation_status > 0.3:
			if Input.is_action_just_pressed("mouse_left") : next_key_presed = "MouseL"


class Attack2 extends AttackBase:
	
	func _init(s_stack).(s_stack,"Attack2"): pass
	
	func push_next_attack():
		match next_key_presed:
			"MouseL" : stack.push_front( Attack3.new(stack) )
			_ : return
	
	func handle_input():
		if animation_status > 0.3:
			if Input.is_action_just_pressed("mouse_left") : next_key_presed = "MouseL"

class Attack3 extends AttackBase:
	
	func _init(s_stack).(s_stack,"Attack3"): pass
	
	func push_next_attack(): pass
	
	func handle_input(): pass

class SlightAirMove extends State:
	var dir = null

	func _init(s_stack, direction).(s_stack): 
		dir = direction

	func update(delta):
		if Util.player.is_on_floor() : is_over = true
		if dir == "R" : update_move_right()
		if dir == "L" : update_move_left()

	func update_move_left():
		Util.player.motion.x = -Util.IN_AIR_SPEED
		if !Input.is_action_pressed("ui_left") : is_over = true

	func update_move_right():
		Util.player.motion.x = Util.IN_AIR_SPEED
		if !Input.is_action_pressed("ui_right") : is_over = true

	func handle_input(): pass

class Idle extends State:

	func _init(s_stack).(s_stack): pass

	func update(delta): 
		Util.player.motion = Vector2(0,0)

	func handle_input(): 
		if   Input.is_action_just_pressed("mouse_left") : stack.push_front( Attack1.new(stack) )
		elif Input.is_action_pressed("ui_right"): stack.push_front( Move.new(stack, "R") )
		elif Input.is_action_pressed("ui_left") : stack.push_front( Move.new(stack, "L") )
		elif Input.is_action_pressed("ui_up") and Util.player.is_on_floor(): stack.push_front( Jump.new(stack) )
