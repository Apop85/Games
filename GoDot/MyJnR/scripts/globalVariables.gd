extends Node

const GRAVITY = 400
const SPEED = 60 
const RUNSPEED = 2 
const JUMP_POWER = 150
const UP_VECTOR = Vector2(0,-1)
const ATMOSPHERIC_RESISTANCE = 0.988
const SOLID_RESISTANCE = 0.95

var next_level = 1
var portal = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
