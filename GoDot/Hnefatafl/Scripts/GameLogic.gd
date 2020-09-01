extends Node2D


# TODO: Enemy KI, Update sprite quality, Center board to screen, online mp?, 
# background music, extended chess mate pattern, win/loose screen, 
# ui overhaul (show figure for turn), options (sound)
# new game screen (board size, first player, choose color, choose who's ki)
# Redo background to match viking art style


# Vectors
var direction = Vector2()
var target_position = Vector2()
var target_position_glob = Vector2()
var mouse_position_glob = Vector2()
# Object containers
var active_figure = null
var selected_figure = null
# Boolean variables
var is_moving = false
var highlighted = false

var debug_check = false

# Counter
var waiting = 0
# Special variables
var rng = RandomNumberGenerator.new()
# Onready variables
onready var grid = $Board
onready var delta_vector = Vector2(grid.position.x, grid.position.y)
onready var text_label = $UI/GameInterface/InfoBox/CurrentPlayer
onready var turn_label = $UI/GameInterface/InfoBox/Turn
onready var main_interface = $UI/MainMenu
onready var game_interface = $UI/GameInterface
onready var background_music = $MainAudio
onready var enemy_ai = $Board/AILogic
onready var debug_text = $UI/GameInterface/InfoBox/DEBUG

var players = ["White", "Black"]
var player_turn = 0
var player_start = 0
var turn = 1


func _ready():
	debug_text.text = ""
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var mouse_position = Vector2()
	if GlobalVariables.winner == null and grid.visible: # and not player_turn in GlobalVariables.ai_player
		if not is_moving:
	#		Iterate waiting counter up to 0.5
			if highlighted and waiting < 0.25:
				waiting += delta
			if not debug_check and player_turn == 1:
				debug_check = true
				enemy_ai._check_options(player_turn)
			if Input.is_mouse_button_pressed(BUTTON_LEFT) and not highlighted:
	#			Get Mouse position
				mouse_position_glob = get_viewport().get_mouse_position() - delta_vector
				mouse_position = grid.world_to_map(mouse_position_glob)
				if grid._is_inside_grid(mouse_position):
		#			Get cell content
					var cell = grid.grid[mouse_position.x][mouse_position.y]
					if cell == grid.ENTITY_TYPES.KING:
						cell = grid.ENTITY_TYPES.WHITE
		#			Check if cell is selectable
					if not cell in [null, grid.ENTITY_TYPES.THRONE, grid.ENTITY_TYPES.GOAL] and cell == player_turn:
		#				Get selected figure
						selected_figure = grid.figures[str(mouse_position)]
		#				Save active figure
						active_figure = mouse_position
		#				Enable path highlighting
						grid._highlight_paths(selected_figure)
						highlighted = true
	
	#		If mouse is pressed, highlights is on and waited is done 
			elif Input.is_mouse_button_pressed(BUTTON_LEFT) and highlighted and waiting > 0.25:
				waiting = 0
	#			Get mouse position
				mouse_position_glob = get_viewport().get_mouse_position() - delta_vector
				mouse_position = grid.world_to_map(mouse_position_glob)
				
				if grid._is_inside_grid(mouse_position):
		#			Check if figure can move to place
					if grid.grid[mouse_position.x][mouse_position.y] == grid.ENTITY_TYPES.READY:
		#				Set target position
						target_position = mouse_position
						target_position_glob = grid.map_to_world(mouse_position)
		#				Get direction vector
						direction = get_direction(mouse_position - grid.world_to_map(selected_figure.position))
					
	#			Remove highlighting
				grid._remove_highlights()
	#			Check if direction is not zero
				if direction != Vector2():
	#				Update arrays
					grid._update_child_pos(selected_figure, target_position)
					rotate_figure(direction, selected_figure)
					is_moving = true
					selected_figure.get_node("AnimationPlayer").play("walk")
					if GlobalVariables.play_music:
						$MarchingSound.play()
				highlighted = false
		else:
	#		Calculate speed per frame
			var velocity = GlobalVariables.SPEED * direction * delta * grid.scaling
	#		Calculate distance to target cell
			var distance = selected_figure.position - target_position_glob - grid.half_tile_size
	#		Check if distance is lower than move speed 
			if abs(distance.x) <= abs(velocity.x) and abs(distance.y) <= abs(velocity.y):
				selected_figure.get_node("AnimationPlayer").play("idle")
				$MarchingSound.stop()
				
				if target_position in grid.goal_pos:
					GlobalVariables.game_over = true
					GlobalVariables.winner = grid.ENTITY_TYPES.WHITE
	#			Set new position of figure
				selected_figure.position = target_position_glob + grid.half_tile_size
	#			Reset variables
				is_moving = false
				active_figure = null
				direction = Vector2()
				grid._can_jail(target_position)
				player_turn = int(!player_turn)
				
				if player_turn == player_start:
					turn += 1
				
				if not GlobalVariables.game_over:
					text_label.text = players[player_turn]
					turn_label.text = "Round: " + str(turn)
					debug_check = false
				else: 
					GlobalVariables.play_game = false
					text_label.text = str(players[GlobalVariables.winner] + " won!")
					main_interface.get_node("Buttons").get_node("Continue").visible = false
			else:
	#			Move figure
				selected_figure.position += velocity
#	else:
#		grid.ai.validate_options(player_turn)

func _new_game():
	#	Select random player to begin
	rng.randomize()
	player_turn = rng.randi_range(0,1)
	player_start = player_turn
	turn = 1
	text_label.text = players[player_turn]
	turn_label.text = "Round: " + str(turn)
	
	is_moving = false
	active_figure = null
	direction = Vector2()
	main_interface.visible = false
	main_interface.get_node("Buttons").get_node("Continue").visible = true

	GlobalVariables.winner = null

func get_direction(delta_position):
	var x_movement = delta_position.x
	var y_movement = delta_position.y
	
	if x_movement != 0 and y_movement == 0:
		if x_movement < 0:
			return Vector2(-1 ,0)
		else:
			return Vector2(1 ,0)
			
	elif y_movement != 0 and x_movement == 0:
		if y_movement < 0:
			return Vector2(0, -1)
		else:
			return Vector2(0, 1)
	else:
		return Vector2.ZERO

func rotate_figure(dir, child):
	if dir == Vector2(0, 1):
		child.rotation_degrees = 0

	if dir == Vector2(-1, 0):
		child.rotation_degrees = 90
		
	if dir == Vector2(0, -1):
		child.rotation_degrees = 180
		
	if dir == Vector2(1, 0):
		child.rotation_degrees = 270
