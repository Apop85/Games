extends KinematicBody2D


var target_position = Vector2()
var current_position = Vector2.ZERO
var target_cell = Vector2.ZERO
var delta_position = Vector2.ZERO
var motion = Vector2()
var target_direction
var type
var speed = 0
var grid
var is_moving = false
var diagonal_moving = false


const MAX_SPEED = 200
# Called when the node enters the scene tree for the first time.
func _ready():
	grid = get_parent()
	type = grid.ENTITY_TYPES.PLAYER
	set_physics_process(true)

func _get_direction(delta_position):
	var x_movement = delta_position.x
	var y_movement = delta_position.y
	
	if x_movement != 0 and y_movement == 0:
		if x_movement < 0:
			return Vector2(-1 ,0)
		else:
			return Vector2(1 ,0)
			
	elif y_movement != 0 and x_movement == 0:
		if y_movement < 0:
			return Vector2(0, -1)
		else:
			return Vector2(0, 1)
			
	elif abs(x_movement) == abs(y_movement):
		if x_movement < 0 and y_movement < 0:
			return Vector2(-1, -1)
		elif x_movement > 0 and y_movement > 0:
			return Vector2(1, 1)
		elif x_movement > 0 and y_movement < 0:
			return Vector2(1, -1)
		else:
			return Vector2(-1, 1)
	else:
		return Vector2.ZERO


func _physics_process(delta):
	speed = 0
	current_position = grid.world_to_map(position)
	if not is_moving and Input.is_mouse_button_pressed(BUTTON_LEFT):
		target_cell = grid.world_to_map(get_viewport().get_mouse_position())
		delta_position = target_cell - current_position # Get delta between current and target position based on grid
		target_direction = _get_direction(delta_position) # Returns the direction vector 
		
#		Check if path is free
		var path_is_free = grid._is_path_free(delta_position, current_position, target_direction)
		if path_is_free:
			target_position = grid.update_child_pos(position, delta_position, type)
			is_moving = true
	
	elif is_moving:
		speed = MAX_SPEED
		motion = speed * (target_direction).normalized()
		var abs_motion = motion * target_direction # Get absolute motion 
		var distance = (target_position-position) * target_direction # Get absolute distance
		# Check if the player hits the target position on the next frame
		if abs_motion.x*delta >= distance.x and abs_motion.y*delta >= distance.y:
			position = target_position
			is_moving = false
		else:
			move_and_slide(motion)

	
