extends Node

const GRAVITY = 400
const SPEED = 80 
const RUNSPEED = 2
const JUMP_POWER = 180
const UP_VECTOR = Vector2(0,-1)
const FLOOR = Vector2.UP
const ATMOSPHERIC_RESISTANCE = 0.988
const SOLID_RESISTANCE = 0.95
const SLOPE_STOP = 20
const SWIM_UP_SPEED = -3 * 16
const PASSIVE_SWIM_UP_SPEED = -3 * 16
const SWIM_DOWN_SPEED = 3 * 16
const SWIM_SPEED = 3 * 16
const JUMP_OUT_WATER_SPEED = -160

#const LEVEL = 1 << 0
const WATER = 1 << 1

var AudioPlayer = AudioStreamPlayer.new()
var next_level = 0
var level_now = 0
var portal = null
var ressource = null

# Create audio player


# Called when the node enters the scene tree for the first time.
func _ready():
#	AudioPlayer.play()
	AudioPlayer.volume_db = -20
	AudioPlayer.pitch_scale = 0
	add_child(AudioPlayer)
	pass # Replace with function body.
	
func play_sound(ressource):
	var stream = load(ressource)
	AudioPlayer.set_stream(stream)
	AudioPlayer.play()
	
	
