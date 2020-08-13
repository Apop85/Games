extends KinematicBody2D

var velocity = Vector2()
var is_grounded
var move_direction = 0
var is_jump = false
var counter = 0
var UI = null
var cam = null


onready var aPlayer = $AnimationPlayer
onready var floor_rays = $Collision_Floor
onready var swim_level = $SwimLevel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

	
func _apply_gravity(delta):
	if not _is_grounded(): 
#		Apply gravity
		velocity.y += GlobalVariable.GRAVITY *delta
		
#		Get abs velocity.x
		var x_pos = -velocity.x if velocity.x < 0 else velocity.x
#		Calculate min speed to push while jump
		var min_speed = GlobalVariable.SPEED * GlobalVariable.RUNSPEED / 5 * 4
#		Push while jump
		if x_pos > min_speed and x_pos < GlobalVariable.SPEED * GlobalVariable.RUNSPEED:
			if velocity.x > 0:
				velocity.x += 20
			elif velocity.x < 0:
				velocity.x -= 20
	


func _apply_player_rotation():
	var angle = 0
#	Calculate angle of player
	angle = (atan2(abs(velocity.x), velocity.y) - PI/2) * -1
#	Adjust angle to direction to max of 45°
	if angle >= PI/4:
		angle = PI/4
	elif angle <= -PI/4:
		angle = -PI/4
#		Set angle
	angle *= move_direction
	
#	Block rotation if on wall in air or grounded of if is in water
	if (not is_on_wall() and not _is_grounded()) or _is_in_water(): 
		$Body.rotation = angle
	elif _is_grounded():
		$Body.rotation = 0

func _apply_movement():
#	Stop if speed is lower than SLOPE_SPEED
	if abs(velocity.x) < GlobalVariable.SLOPE_STOP and move_direction == 0:
		velocity.x = 0
#	Check for collisions	
	if not _is_in_water():
#		On Floor enable snap
		velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	else:
#		Disable snap in water
		velocity = move_and_slide(velocity, Vector2.DOWN)

func _can_jump_out_water():
	var needed_distance_to_surface = 5
#	????????
	var space_state = get_world_2d().direct_space_state
#	Find intersectionpoint to the water surface
	var result = space_state.intersect_point(swim_level.global_position + Vector2.UP * needed_distance_to_surface, 1, [], GlobalVariable.WATER)
	return velocity.y <= 0 and result.size() == 0

func _handle_move_input(var move_speed = GlobalVariable.SPEED):
#	Creates negative integer if moves to left and positive integer if move to right
	move_direction = -int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right"))
#	Rotate body to movement direction
	if move_direction != 0:
		$Body.scale.x = move_direction
#	If run pressed increase speed
	if Input.is_action_pressed("run"):
#		Continously increase speed to target velocity
		velocity.x = lerp(velocity.x, move_speed * GlobalVariable.RUNSPEED * move_direction, _get_weight())
	else:
	#	Normal speed if not running
#		Continously increase speed to target velocity
		velocity.x = lerp(velocity.x, move_speed * move_direction, _get_weight())

func _get_weight():
	if _is_in_water():
		return 0.02
	elif _is_grounded():
		return 0.2
	else:
		return 0.1

func _is_in_water():
	var space_state = get_world_2d().direct_space_state
#	Find water surface to determine if player is in water
	var result = space_state.intersect_point(swim_level.global_position, 1, [], GlobalVariable.WATER)
	return result.size() != 0


func _apply_swim_speed(delta):
#	Handle input inside water
	var input = -int(Input.is_action_pressed("jump")) + int(Input.is_action_pressed("down"))
	var y_speed = GlobalVariable.PASSIVE_SWIM_UP_SPEED
	if input < 0:
		y_speed = GlobalVariable.SWIM_UP_SPEED
	elif input > 0:
		y_speed = GlobalVariable.SWIM_DOWN_SPEED
	
	velocity.y = lerp(velocity.y, y_speed, 0.075 * delta / (1/60.0))
	
func _handle_surfacing(delta):
	if velocity.y < 0:
		var space_state = get_world_2d().direct_space_state
#		Find intersectionpoint from water surface
		var surface_level = swim_level.global_position + Vector2.DOWN * velocity.y * delta
		var result = space_state.intersect_point(surface_level, 1, [], GlobalVariable.WATER)
#		if not inside water:
		if not result:
#			Adjust speed on surfacing
			var ray_result = space_state.intersect_ray(surface_level, swim_level.global_position, [], GlobalVariable.WATER)
			if ray_result:
				velocity.y = (ray_result.position.y - swim_level.global_position.y) / delta
	
func _is_grounded():
#	Check if collision rays touches the tilemap
	if not _is_in_water():
		for ray in floor_rays.get_children():
			ray.force_raycast_update()
			if ray.get_collider():
				return true
	return false
			

