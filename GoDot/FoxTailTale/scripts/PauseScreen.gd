extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	if Input.is_action_just_pressed("pause") and GlobalVariable.level_now != 0:
		get_tree().paused = not get_tree().paused
		self.visible = not self.visible


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
