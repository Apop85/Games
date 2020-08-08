extends Node2D


const IDLE_DURATION = 1.0

export var move_to = Vector2.RIGHT * 192
export var speed = 3.0

onready var platform = $Platform
onready var tween = $Moving_Tween

var follow = Vector2.ZERO


func _ready():
#	Setup tween method
	_init_tween()

func _init_tween():
#	Calculate duratin on length
	var duration = move_to.length() / float(speed * 16)
	
#	Start from zero and go to target position after an idle duration
	tween.interpolate_property(self, "follow", Vector2.ZERO, move_to, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, IDLE_DURATION)
#	Start from target position and move to zero after duration + idle duration*2
	tween.interpolate_property(self, "follow", move_to, Vector2.ZERO, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, duration + IDLE_DURATION * 2)
	tween.start()


func _physics_process(delta):
#	Interpolate position of platform for smooth movement
	platform.position = platform.position.linear_interpolate(follow, 0.075)
