extends KinematicBody2D
 
const GRAVITY = 400
const SPEED = 60 
const RUNSPEED = 2 
const JUMP_POWER = 150
const UP_VECTOR = Vector2(0,-1)
const ATMOSPHERIC_RESISTANCE = 0.988
const SOLID_RESISTANCE = 0.95


# Get sprite and ray casts
onready var slideRay = $Sliding_Ray
onready var climbRay_edge = $Climbing_Ray_Edge
onready var climbRay_space = $Climbing_Ray_Space
onready var climbing_rays = [ climbRay_edge, climbRay_space ]

var move_speed_player = Vector2()
var temp_vector = Vector2()
var slide = false
var move_speed_now
var idle_anim = false
var climb = false
var direction = true
var target_position

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.
#
#func _apply_movement(delta):
#	# Gravity calculation
#	if is_in_air():
#		if move_speed_now < 0:
#			move_speed_now *= -1
#		if 10 < move_speed_now and move_speed_now > 0:
#			move_speed_player.x *= ATMOSPHERIC_RESISTANCE
#		elif move_speed_now <= 10:
#			move_speed_player.x = 0
#	else:
#		move_speed_player.x = 0
#
#	move_speed_player = move_and_slide(move_speed_player, UP_VECTOR)
#
#func _apply_gravity(delta):
#	move_speed_player.y += GlobalVariable.GRAVITY * delta
#
#
#func flip_ray(ray, forwards):
#	if forwards:
#		if ray.cast_to.x < 0:
#			ray.cast_to.x *= -1
#	else:
#		if ray.cast_to.x > 0:
#			ray.cast_to.x *= -1
#
#func flip_rays(list, forwards):
#	for ray in list:
#		flip_ray(ray, forwards)
#
#func can_standup():
##	Update ray
#	slideRay.force_raycast_update()
#	return slideRay.get_collider() == null
#
#func climbing_possible():
##	Update Ray
#	climbRay_edge.force_raycast_update()
#	climbRay_space.force_raycast_update()
#	if climbRay_edge.get_collider() != null and climbRay_space.get_collider() == null:
#		print (climbRay_edge.get_collider().cell)
#	return climbRay_edge.get_collider() != null and climbRay_space.get_collider() == null
#
#func is_in_air():
#	return is_on_floor() == false
#
#func _handle_move_input():
#	print("handling")
##	Key inputs are setup in project --> project preferences
#	if Input.is_action_pressed("left") and is_on_floor() and not slide:
#		move_speed_player.x = -1 * SPEED
#
#	if Input.is_action_pressed("right") and is_on_floor() and not slide:
#		move_speed_player.x = 1 * SPEED
#
#	if Input.is_action_pressed("run") and is_on_floor() and not slide:
#		move_speed_player.x *= RUNSPEED
#
#	if Input.is_action_just_pressed("down") and (move_speed_player.x < 0 or move_speed_player.x > 0) and not is_in_air() and not is_on_wall():
#		slide = true
#		$Sliding_Collision.disabled = false
#		$Standing_Collision.disabled = true
#
#	if slide and (not Input.is_action_pressed("down") or move_speed_player.x == 0) and can_standup():
#		slide = false
#		$Sliding_Collision.disabled = true
#		$Standing_Collision.disabled = false
#
#	if Input.is_action_just_pressed("jump") and GlobalVariable.portal == null:
#		if is_on_floor():
#			move_speed_player.y = -JUMP_POWER


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_speed_now = move_speed_player.x
	if is_in_air():
		if move_speed_now < 0:
			move_speed_now *= -1
		if 10 < move_speed_now and move_speed_now > 0:
			move_speed_player.x *= ATMOSPHERIC_RESISTANCE
		elif move_speed_now <= 10:
			move_speed_player.x = 0
	elif slide:
		if move_speed_now < 0:
			move_speed_now *= -1
		if 10 < move_speed_now and move_speed_now > 0:
			move_speed_player.x *= SOLID_RESISTANCE
		elif move_speed_now <= 10:
			move_speed_player.x = 0
	else:
		move_speed_player.x = 0

	# Gravity calculation
	move_speed_player.y += GRAVITY * delta

	if not climb:
		check_key_input()

	# Check collisions
	move_speed_player = move_and_slide(move_speed_player, UP_VECTOR)

	set_animation()


func check_key_input():
#	Key inputs are setup in project --> project preferences
	if Input.is_action_pressed("left") and is_on_floor() and not slide:
		move_speed_player.x = -1 * SPEED

	if Input.is_action_pressed("right") and is_on_floor() and not slide:
		move_speed_player.x = 1 * SPEED

	if Input.is_action_pressed("run") and is_on_floor() and not slide:
		move_speed_player.x *= RUNSPEED

	if Input.is_action_just_pressed("down") and (move_speed_player.x < 0 or move_speed_player.x > 0) and not is_in_air() and not is_on_wall():
		slide = true
		$Sliding_Collision.disabled = false
		$Standing_Collision.disabled = true

	if slide and (not Input.is_action_pressed("down") or move_speed_player.x == 0) and can_standup():
		slide = false
		$Sliding_Collision.disabled = true
		$Standing_Collision.disabled = false

	if Input.is_action_just_pressed("jump") and GlobalVariable.portal == null:
		if is_on_floor():
			move_speed_player.y = -JUMP_POWER

	if Input.is_action_just_pressed("action"):
#		Check if there is an overlapping area called "Car"
		for object in $HitBox.get_overlapping_bodies():
			if object.name == "Car":
#				Call enter_car function of Car
				object.enter_car(self, true)



func set_animation():
	if not climb:
	#	Play different animations depending on state
		if is_in_air() and climbing_possible():
			climb = true
			temp_vector = self.position
		elif is_in_air():
#		if is_in_air():
			move_speed_now = move_speed_player.x
			if move_speed_now < 0:
				move_speed_now *= -1 
			if move_speed_now > SPEED:
				$AnimationPlayer.play("jump_fast")
			else:
				$AnimationPlayer.play("jump_slow")
		elif not slide:
			if move_speed_player.x < SPEED * -1 - 1:
				$Sprite.flip_h = true
				direction = false
				$AnimationPlayer.play("run")
				flip_rays(climbing_rays, direction)
			elif move_speed_player.x > SPEED + 1:
				$Sprite.flip_h = false
				direction = true
				$AnimationPlayer.play("run")
				flip_rays(climbing_rays, direction)
			elif move_speed_player.x < 0:
				$Sprite.flip_h = true
				direction = false				
				$AnimationPlayer.play("walk")
				flip_rays(climbing_rays, direction)
			elif move_speed_player.x > 0:
				$Sprite.flip_h = false
				direction = true
				$AnimationPlayer.play("walk")
				flip_rays(climbing_rays, direction)
			elif move_speed_player.x == 0:
				$AnimationPlayer.play("idle")
		else:
			$AnimationPlayer.play("slide")
	else:
		climb_wall()

func climb_wall():
	$AnimationPlayer.play("climb")	
	move_speed_player.y = 0
	if direction:
		target_position = temp_vector + Vector2(8, -11)
		if self.position.y >= target_position.y:
			self.position.y -= 1.1
		elif self.position.x <= target_position.x:
			self.position.x += 1.1
		elif target_position <= self.position:
			climb = false
	else:
		target_position = temp_vector + Vector2(-8, -11)
		if self.position.y >= target_position.y:
			self.position.y -= 1.1
		elif self.position.x >= target_position.x:
			self.position.x -= 1.1
		elif target_position >= self.position:
			climb = false
#		$Standing_Collision.disabled = false
#	self.position += Vector2(8, -10)


func is_in_air():
	return is_on_floor() == false

func flip_ray(ray, forwards):
	if forwards:
		if ray.cast_to.x < 0:
			ray.cast_to.x *= -1
	else:
		if ray.cast_to.x > 0:
			ray.cast_to.x *= -1

func flip_rays(list, forwards):
	for ray in list:
		flip_ray(ray, forwards)

func can_standup():
#	Update ray
	slideRay.force_raycast_update()
	return slideRay.get_collider() == null

func climbing_possible():
#	Update Ray
	climbRay_edge.force_raycast_update()
	climbRay_space.force_raycast_update()
#	if climbRay_edge.get_collider() != null and climbRay_space.get_collider() == null:
#		print (climbRay_edge.get_collider().cell)
	return climbRay_edge.get_collider() != null and climbRay_space.get_collider() == null
