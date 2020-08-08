extends "res://scripts/StateMachine.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _input(event):
	##	Key inputs are setup in project --> project preferences
	if [states.idle, states.walk, state.run].has(state):
#	if event.is_action_pressed("left") and parent.is_on_floor() and not parent.slide:
		parent.move_speed_player.x = -1 * GlobalVariable.SPEED

	if [states.idle, states.walk, states.run].has(state):
#	if event.is_action_pressed("right") and parent.is_on_floor() and not parent.slide:
		parent.move_speed_player.x = 1 * GlobalVariable.SPEED

	if [states.idle, states.walk, states.run].has(state):
#	if event.is_action_pressed("run") and parent.is_on_floor() and not parent.slide:
		parent.move_speed_player.x *= GlobalVariable.RUNSPEED

	if [states.walk, states.run, states.slide].has(state):
#	if event.is_action_just_pressed("down") and (parent.move_speed_player.x < 0 or parent.move_speed_player.x > 0) and not parent.is_in_air() and not parent.is_on_wall():
		parent.slide = true
		parent.Sliding_Collision.disabled = false
		parent.Standing_Collision.disabled = true
		
	if [states.slide].has(state) and (not Input.is_action_pressed("down") or parent.move_speed_player.x == 0) and parent.can_standup() :
#	if parent.slide and (not event.is_action_pressed("down") or parent.move_speed_player.x == 0) and parent.can_standup():
		parent.slide = false
		parent.Sliding_Collision.disabled = true
		parent.Standing_Collision.disabled = false

	if [states.walk, states.run, states.slide].has(state) and GlobalVariable.portal == null:
#	if event.is_action_just_pressed("jump") and GlobalVariable.portal == null:
		if parent.is_on_floor():
			parent.move_speed_player.y = -GlobalVariable.JUMP_POWER

#	if Input.is_action_just_pressed("action"):
##		Check if there is an overlapping area called "Car"
#		for object in $HitBox.get_overlapping_bodies():
#			if object.name == "Car":
##				Call enter_car function of Car
#				object.enter_car(self, true)

func _ready():
	add_state("idle")
	add_state("walk")
	add_state("run")
	add_state("jump_slow")
	add_state("jump_fast")
	add_state("slide")
	add_state("climb")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	parent._handle_move_input()
	parent._apply_gravity(delta)
	parent._apply_movement()

func _get_transition(delta):
	var vert_speed = parent.movement_speed_player.y
	var hor_speed = parent.movement_speed_player.x
	if vert_speed < 0:
		vert_speed *= -1
	if hor_speed < 0:
		hor_speed *= -1
		
	match state:
		states.idle:
			if parent.is_in_air():
				if vert_speed > 0:
					return states.jump_slow
			elif hor_speed <= GlobalVariable.SPEED:
				return states.walk
			elif hor_speed > GlobalVariable.SPEED:
				return states.run
		states.walk:
			if parent.is_in_air():
				if vert_speed > 0:
					return states.jump_slow
			elif hor_speed == 0:
				return states.idle
			elif hor_speed > GlobalVariable.SPEED:
				return states.run
		states.run:
			if parent.is_in_air():
				if vert_speed > GlobalVariable.SPEED:
					return states.jump_fast
			elif hor_speed == 0:
				return states.idle
			elif hor_speed < GlobalVariable.SPEED:
				return states.walk
		states.jump:
			if parent.is_on_floor():
				return states.idle
		states.slide:
			if parent.can_standup() or hor_speed == 0:
				return states.idle

	return null

	
func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.AnimationPlayer.play("idle")
		states.walk:
			parent.AnimationPlayer.play("walk")
		states.run:
			parent.AnimationPlayer.play("run")
		states.slide:
			parent.AnimationPlayer.play("slide")
		states.climb:
			parent.AnimationPlayer.play("climb")
		states.jump_slow:
			parent.AnimationPlayer.play("jump_slow")
		states.jump_fast:
			parent.AnimationPlayer.play("jump_fast")
	
func _exit_state(old_state, new_state):
	pass
