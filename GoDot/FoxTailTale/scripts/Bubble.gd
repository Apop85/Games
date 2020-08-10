extends Area2D

onready var bodies = null
var in_water = true
var first_frame = true
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if not first_frame: 
		in_water = _is_in_water()
		if in_water:
			self.position.y -= 16 * delta
		else:
			queue_free()
	else:
		first_frame = not first_frame
		
func _is_in_water():
#	if counter > 60:
#		counter += 1
#	else:
		bodies = self.get_overlapping_bodies()
		for body in bodies:
#			print(body.name)
			if body.name == "Water":
				return true
		return false
	
#	if bodies == null:
#		print(null)
#		if body.name != "Water":

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
