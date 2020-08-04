extends Node2D


onready var game_scene = $GameScene
onready var cam = $Camera2D
onready var fader = $Fader

var level = null
var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
#	Main loop
	add_level()
#	connect_doors()
#	check_4_doors()
	put_cam_2_player()
#	set_fader_position()
#	fader.fade_in()


#func set_fader_position():
##	Move fader position to camera position
#	fader.rect_position = cam.get_camera_screen_center()
#	fader.rect_position -= Vector2(80,45)	
#
#
#func _process(delta):
##	Update fader position every frame
#	set_fader_position()
#
#
#
func add_level():
#	Get global variable to load level in an instance
	level = load(str("res://scenes/levels/Level", GlobalVariable.next_level,  ".tscn")).instance()
#	Add level as child of in_game
	game_scene.add_child(level)

#	Set player position to level default
	player = level.find_node("Player")
#
#
func put_cam_2_player():
#	Remove camera from parent
	remove_child(cam)
#	Add new camera position to parent
	player.add_child(cam)
#
#
#func check_4_doors():
##	Is there a door aviable?
#	if GlobalVar.next_level_door != null:
##		Load door as variable from level
#		var door = level.find_node(GlobalVar.next_level_door)
##		Set new player position
#		player.position = door.position
##		Reset global variable
#		GlobalVar.next_level_door = null
#
#
#func connect_doors():
##	Iterate trough all Objects of level
#	for child in level.find_node(\"Objects\").get_children():
##		Is there a object starting with Door?
#		if child.name.begins_with(\"Door\"):
##			Connect current door with target door and signal
#			child.connect(\"enter_door\", self, \"_on_enter_door\")
#
#
#func _on_enter_door():
##	Start fading out animation 
#	var animation_player = fader.fade_out()
##	Wait until animation ended
#	yield(animation_player, \"animation_finished\")
#
##	Get current door
#	var door = level.find_node(GlobalVar.next_level_door)
##	Get current level
#	var current_level = door.level_number
#
##	If target in same level --> teleport
#	if current_level == GlobalVar.next_level:
##		Set new position
#		player.position = door.position
##		Fade in
#		animation_player = fader.fade_in()
#		yield(animation_player, \"animation_finished\")
#	else:
##		Load new level
#		get_tree().reload_current_scene()
#
#	#	Reset global variable
#	GlobalVar.next_level_door = null
#	GlobalVar.next_level = null
##	Undo pause state
#	get_tree().paused == false
