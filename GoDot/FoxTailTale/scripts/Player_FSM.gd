extends "res://StateMachine.gd"

			
func _ready():
#	Add possible states
	add_state("idle")
	add_state("run")
	add_state("walk")
	add_state("sit")
	add_state("jump_air")
	add_state("swim")
	add_state("paddle")
	call_deferred("set_state", states.idle)


func _state_logic(delta):
#	Handle input movement and gravity
	if [states.idle, states.run, states.walk, states.sit, states.jump_air].has(state):
		parent._handle_move_input()
		parent._apply_gravity(delta)
	elif [states.swim, states.paddle].has(state):
		parent._handle_move_input(GlobalVariable.SWIM_SPEED)
		parent._apply_swim_speed(delta)
		parent._handle_surfacing(delta)
	parent._apply_player_rotation()
	parent._apply_movement()
		

func _input(event):
	var angle = 0
#	Check if following states are playing to enable jump
	if [states.idle, states.walk, states.run].has(state):
#		Trigger jump
		if event.is_action_pressed("jump"): 
			if parent._is_grounded():
				parent.is_jump = true
				parent.velocity.y = -GlobalVariable.JUMP_POWER


func _get_transition(delta):
#	Get abs velocity.x
	var x_pos = parent.velocity.x if parent.velocity.x >= 0 else -parent.velocity.x 
	match state:
#		Check if a state is matching
		states.idle:
			parent.counter += 1
			if not parent._is_in_water():
	#			If in air play jump
				if parent.velocity.y != 0:
					parent.counter = 0
					return states.jump_air
	#			If on Floor
				elif parent._is_grounded():
	#				If speed slow play walk
					if parent.velocity.x != 0 and x_pos <= GlobalVariable.SPEED+1:
						parent.counter = 0
						return states.walk
	#				If speed fast play run
					elif parent.velocity.x != 0 and x_pos > GlobalVariable.SPEED+1:
						parent.counter = 0
						return states.run
	#				If idle to long play sleep
					elif parent.counter > 180:
						parent.counter = 0
						return states.sit
			else:
				return states.swim
		states.walk:
			if not parent._is_in_water():
	#			If moving on Y axis play jump
				if parent.velocity.y != 0:
					return states.jump_air
	#			If speed fast play run
				elif parent.velocity.x != 0 and x_pos > GlobalVariable.SPEED+1:
					return states.run
	#			If no speed play idle
				elif parent.velocity.x == 0:
					return states.idle
			else:
				return states.swim
		states.run:
			if not parent._is_in_water():
	#			If moving on y axis play jump
				if parent.velocity.y != 0:
					return states.jump_air
	#			If is on floor
				if parent._is_grounded():
	#				If speed slow play walk
					if parent.velocity.x != 0 and x_pos <= GlobalVariable.SPEED+1:
						return states.walk
	#				If stopped play idls
					elif parent.velocity.x == 0:
						return states.idle
			else:
				return states.swim
		states.jump_air:
			if not parent._is_in_water():
	#			If is on floow
				if parent._is_grounded():
	#				If stopped play idle
					if x_pos == 0:
						parent.is_jump = false
						return states.idle
	#				If speed slow play walk
					elif x_pos <= GlobalVariable.SPEED +1:
						parent.is_jump = false
						return states.walk
	#				If speed fast play run
					elif x_pos > GlobalVariable.SPEED +1:
						parent.is_jump = false
						return states.run
			else:
				return states.swim
		states.sit:
#			If speed slow play walk
			if x_pos > 0 and x_pos <= GlobalVariable.SPEED +1:
				return states.walk
#			If speed fast play run
			elif x_pos > GlobalVariable.SPEED +1:
				return states.run
		states.swim:
#			if parent._is_in_water():
#				print("in")
#				parent.velocity.y -= 2
#			else:
			if not parent._is_in_water():
				print("out")
				if parent._is_grounded():
		#			If speed slow play walk
					if x_pos > 0 and x_pos <= GlobalVariable.SPEED +1:
						return states.walk
		#			If speed fast play run
					elif x_pos > GlobalVariable.SPEED +1:
						return states.run
				elif not parent._is_grounded():
					if parent.velocity.y != 0:
						return states.jump_air
			elif Input.is_action_pressed("jump") and parent._can_jump_out_water():
				parent.velocity.y = GlobalVariable.JUMP_OUT_WATER_SPEED
				return states.jump_air
	return null
	
func _enter_state(old_state, new_state):
#	If there is a new state, play
	if new_state != old_state:
		match new_state:
			states.idle:
				parent.aPlayer.play("Idle")
			states.walk:
				parent.aPlayer.play("walk")
			states.run:
				parent.aPlayer.play("run")
			states.jump_air:
				parent.aPlayer.play("jump_air")
			states.sit:
				parent.aPlayer.play("sit")
			states.swim:
				parent.aPlayer.play("swim")
			states.paddle:
				parent.aPlayer.play("paddle")
				
		
	
func _exit_state(old_state, new_state):
	pass
		
