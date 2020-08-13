extends Node
class_name StateMachine


var state = null setget set_state
var prev_state = null
var states = {}

onready var fader = self.get_parent().get_parent().find_node("Fader")



onready var parent = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	var animation
	GlobalVariable.level_now = GlobalVariable.next_level

	if fader != null:
#		var fader = self.get_parent().get_parent().find_node("Fader")
		animation = fader.fade_in()
		yield(animation, "animation_finished")
#		fader.visible = false
	

func _physics_process(delta):
#	Call state logic and check for animation transitions 
	if state != null:
		_state_logic(delta)
		var transition = _get_transition(delta)
		if transition != null:
			set_state(transition)
			
func _state_logic(delta):
	pass

func _get_transition(delta):
	return null
	
func _enter_state(new_state, old_state):
	pass
	
func _exit_state(old_state, new_state):
	pass
	
func set_state(new_state):
#	Set new state
	prev_state = state
	state = new_state
	if new_state != null:
		_enter_state(prev_state, new_state)
	if prev_state != null:
		_exit_state(prev_state, new_state)

func add_state(state_name):
#	Add state to the end of dictionary
	states[state_name] = states.size()
