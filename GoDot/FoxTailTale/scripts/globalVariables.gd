extends Node

const GRAVITY = 400
const SPEED = 60 
const RUNSPEED = 3
const JUMP_POWER = 180
const UP_VECTOR = Vector2(0,-1)
const FLOOR = Vector2.UP
const ATMOSPHERIC_RESISTANCE = 0.988
const SOLID_RESISTANCE = 0.95
const SLOPE_STOP = 20

var next_level = 0
var portal = null

# Create audio player
var AudioPlayer = AudioStreamPlayer.new()
var stream = load("res://sounds/coin.wav")


# Called when the node enters the scene tree for the first time.
func _ready():
	AudioPlayer.set_stream(stream)
	AudioPlayer.volume_db = -20
	AudioPlayer.pitch_scale = 0
#	AudioPlayer.play()
	add_child(AudioPlayer)
	pass # Replace with function body.
