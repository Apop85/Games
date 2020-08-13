extends Node2D


onready var game_scene = $GameScene
onready var cam = $Camera2D
onready var fader = $Fader
onready var interface = $Camera2D/Interface
onready var score_label = $UI/UI/Panel/Label
onready var paused_screen = $Overlay/PausedOverlay

var level = null
var player = null
var score = 0
var animation_player
var start_position = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
#	Main loop
	var check = add_level()
#	connect_doors()
#	check_4_doors()
	if check: 
		put_cam_2_player()
		set_fader_position()
#		animation_player = fader.fade_in()
#		yield(animation_player, "animation_finished")
		

func set_fader_position():
#	Move fader position to camera position
	fader.rect_position = cam.get_camera_screen_center()
	fader.rect_position -= Vector2(80,45)	


func _process(delta):


#	Update fader position every frame
	set_fader_position()
	if GlobalVariable.level_now != GlobalVariable.next_level:
#		fader.visible = true
		GlobalVariable.level_now = GlobalVariable.next_level
		
#		Fade out and wait until animation finished
		animation_player = fader.fade_out()
		yield(animation_player, "animation_finished")
		get_tree().reload_current_scene()
		
#		Reload scene with new level
		
	if Input.is_action_just_pressed("escape") and GlobalVariable.level_now != 0:
		GlobalVariable.next_level = 0



func add_level():
	score = 0
	score_label.text = str(score)
#	Get global variable to load level in an instance
	if GlobalVariable.next_level != 0:
		level = load(str("res://scenes/levels/Level", GlobalVariable.next_level,  ".tscn")).instance()
		$UI.find_node("UI").visible = true
	else:
		level = load(str("res://scenes/Interface/TitleScreen.tscn")).instance()
		$UI.find_node("UI").visible = false
#	Add level as child of in_game
	game_scene.add_child(level)

#	Set player position to level default
	player = level.find_node("Player")
	if GlobalVariable.next_level == 0:
		return false
	else:
		return true
#
#
func put_cam_2_player():
#	Remove camera from parent
	remove_child(cam)
#	Add new camera position to parent
	player.add_child(cam)
#	Save level start position
	start_position = player.position
	print(start_position)


#func _physics_process(delta):
#	pass



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
#	yield(animation_player, "animation_finished")
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
