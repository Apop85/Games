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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

	
func _apply_gravity(delta):
	var angle = 0
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
	
#		Calculate angle of player
		angle = (atan2(x_pos, velocity.y) - PI/2) * -1
#		Adjust angle to direction to max of 45°
		if angle >= PI/4:
			angle = PI/4
		elif angle <= -PI/4:
			angle = -PI/4
#		Set angle
		angle *= move_direction

#	Block rotation if on wall in air or grounded
	if not is_on_wall() and not _is_grounded(): 
		$Body.rotation = angle
	elif _is_grounded():
		$Body.rotation = 0


func _apply_movement():
#	Stop if speed is lower than SLOPE_SPEED
	if abs(velocity.x) < GlobalVariable.SLOPE_STOP and move_direction == 0:
		velocity.x = 0
#	Check for collisions	
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)


func _handle_move_input():
#	Creates negative integer if moves to left and positive integer if move to right
	move_direction = -int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right"))
#	Rotate body to movement direction
	if move_direction != 0:
		$Body.scale.x = move_direction
#	If run pressed increase speed
	if Input.is_action_pressed("run"):
#		Continously increase speed to target velocity
		velocity.x = lerp(velocity.x, GlobalVariable.SPEED * GlobalVariable.RUNSPEED * move_direction, _get_weight())
#	Normal speed if not running
	else:
#		Continously increase speed to target velocity
		velocity.x = lerp(velocity.x, GlobalVariable.SPEED * move_direction, _get_weight())

func _get_weight():
	if _is_grounded():
		return 0.2
	else:
		return 0.1
		
func _is_grounded():
#	Check if collision rays touches the tilemap
	var count = 0
	for ray in floor_rays.get_children():
		ray.force_raycast_update()
		if ray.get_collider():
#			print("true")
			return true
#	print("false")
	return false
			

