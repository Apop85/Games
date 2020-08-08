extends "res://StateMachine.gd"

			
func _ready():
#	Add possible states
	add_state("idle")
	add_state("run")
	add_state("walk")
	add_state("sit")
	add_state("jump_air")
	call_deferred("set_state", states.idle)


func _state_logic(delta):
#	Handle input movement and gravity
	parent._handle_move_input()
	parent._apply_movement()
	parent._apply_gravity(delta)

func _input(event):
	var angle = 0
#	Check if following states are playing to enable jump
	if [states.idle, states.walk, states.run].has(state):
#		Trigger jump
		if event.is_action_pressed("jump") and parent._is_grounded():
			parent.velocity.y = -GlobalVariable.JUMP_POWER
			parent.is_jump = true


func _get_transition(delta):
#	Get abs velocity.x
	var x_pos = parent.velocity.x if parent.velocity.x >= 0 else -parent.velocity.x 
	match state:
#		Check if a state is matching
		states.idle:
			parent.counter += 1
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
		states.walk:
#			If moving on Y axis play jump
			if parent.velocity.y != 0:
				return states.jump_air
#			If speed fast play run
			elif parent.velocity.x != 0 and x_pos > GlobalVariable.SPEED+1:
				return states.run
#			If no speed play idle
			elif parent.velocity.x == 0:
				return states.idle
		states.run:
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
		states.jump_air:
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
		states.sit:
#			If speed slow play walk
			if x_pos > 0 and x_pos <= GlobalVariable.SPEED +1:
				return states.walk
#			If speed fast play run
			elif x_pos > GlobalVariable.SPEED +1:
				return states.run
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
		
	
func _exit_state(old_state, new_state):
	pass
		
