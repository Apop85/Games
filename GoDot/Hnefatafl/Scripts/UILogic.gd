extends Control

onready var grid = self.get_parent().get_node("Board") 
onready var game_logic = self.get_parent()



# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalVariables.viewport.connect("size_changed", self, "resize_ui")
	resize_ui()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func resize_ui():
	var current_window_size = OS.get_window_size()
	var target_size = Vector2()

	if current_window_size.x > GlobalVariables.MAX_SIZE.x:
		target_size.x = GlobalVariables.MAX_SIZE.x
	if current_window_size.y > GlobalVariables.MAX_SIZE.y:
		target_size.y = GlobalVariables.MAX_SIZE.y
	var scaling = 1/GlobalVariables.game_size.x * current_window_size.x
	if scaling < 1:
		scaling = 1
#	if game_logic.grid != null:
##		game_logic.grid.scale.x = scaling
##		game_logic.grid.scale.y = scaling
#		game_logic.grid.resize_board()

	if target_size.x > GlobalVariables.game_size.x:
		$MainMenu.rect_size.x = target_size.x - 30
		$GameInterface.rect_size.x = target_size.x
		

	if target_size.y > GlobalVariables.game_size.y:
		$MainMenu.rect_size.y = target_size.y - 30
		$GameInterface.rect_size.y = target_size.y

func _on_NewGame_button_down():
	grid._setup_new_game()
	game_logic._new_game()
	grid.visible = true
	GlobalVariables.winner = null
	GlobalVariables.game_over = false
	$BackgroundLayers.visible = false
	$GameInterface/Exit.visible = true
	$GameInterface/InfoBox.visible = true
#	$MainMenu/Buttons/Continue.visible = true


func _on_Exit_button_down():
	$MainMenu.visible = true
	grid.visible = false
	$GameInterface/Exit.visible = false
	$BackgroundLayers.visible = true
	$GameInterface/InfoBox.visible = false
	GlobalVariables.winner = 99


func _on_Continue_button_down():
	$MainMenu.visible = false
	grid.visible = true
	$BackgroundLayers.visible = false
	$GameInterface/Exit.visible = true
	$GameInterface/InfoBox.visible = true
	GlobalVariables.winner = null


func _on_Mute_button_down():
	if not GlobalVariables.play_music:
		game_logic.background_music.play()
	else:
		game_logic.background_music.stop()
	GlobalVariables.play_music = not GlobalVariables.play_music
