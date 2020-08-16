extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const SPEED = 100
const MAX_SIZE = Vector2(500, 680)

var winner = 99
var game_over = false
var play_music = false


onready var viewport = get_viewport()
onready var game_size = Vector2(
	ProjectSettings.get_setting("display/window/size/width"),
	ProjectSettings.get_setting("display/window/size/height"))

func _ready():
	viewport.connect("size_changed", self, "resize_viewport")
	resize_viewport()

func resize_viewport():
	var new_size = OS.get_window_size()
	var scale_factor

	if new_size.x < game_size.x:
		scale_factor = game_size.x/new_size.x
		new_size = Vector2(new_size.x*scale_factor, new_size.y)
#		new_size = Vector2(new_size.x*scale_factor, new_size.y*scale_factor)
	if new_size.y < game_size.y:
		scale_factor = game_size.y/new_size.y
		new_size = Vector2(new_size.x*scale_factor, new_size.y)
#		new_size = Vector2(new_size.x*scale_factor, new_size.y*scale_factor)
	
	if new_size.x > MAX_SIZE.x:
		new_size.x = MAX_SIZE.x
	if new_size.y > MAX_SIZE.y:
		new_size.y = MAX_SIZE.y
	
	viewport.set_size_override(true, new_size)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
