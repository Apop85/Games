extends Node2D

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
# Counter
var waiting = 0
# Special variables
var rng = RandomNumberGenerator.new()
# Onready variables
onready var grid = $Board
onready var delta_vector = Vector2(grid.position.x, grid.position.y)
onready var text_label = grid.player_text
var players = ["White", "Black"]
var player_turn = 0


func _ready():
#	Select random player to begin
	rng.randomize()
	player_turn = rng.randi_range(0,1)
	
	text_label.text = "Current player: " + str(players[player_turn])



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var mouse_position = Vector2()
	if not is_moving:
#		Iterate waiting counter up to 0.5
		if highlighted and waiting < 0.5:
			waiting += delta
		if Input.is_mouse_button_pressed(BUTTON_LEFT) and not highlighted:
#			Get Mouse position
			mouse_position_glob = get_viewport().get_mouse_position() - delta_vector
			mouse_position = grid.world_to_map(mouse_position_glob)
			if mouse_position.x >= 0 and mouse_position.x < grid.grid_size.x and mouse_position.y >= 0 and mouse_position.y < grid.grid_size.y:
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
		elif Input.is_mouse_button_pressed(BUTTON_LEFT) and highlighted and waiting > 0.5:
			waiting = 0
#			Get mouse position
			mouse_position_glob = get_viewport().get_mouse_position() - delta_vector
			mouse_position = grid.world_to_map(mouse_position_glob)
			
#			Check if figure can move to place
			if grid.grid[mouse_position.x][mouse_position.y] == grid.ENTITY_TYPES.READY:
#				Set target position
				target_position = mouse_position
				target_position_glob = grid.map_to_world(mouse_position)
#				Get direction vector
				direction = _get_direction(mouse_position - grid.world_to_map(selected_figure.position))
				
#			Remove highlighting
			grid._remove_highlights()
#			Check if direction is not zero
			if direction != Vector2():
#				Update arrays
				grid.update_child_pos(selected_figure, target_position)
				is_moving = true
			highlighted = false
	else:
#		Calculate speed per frame
		var velocity = GlobalVariables.SPEED * direction * delta
#		Calculate distance to target cell
		var distance = selected_figure.position - target_position_glob - GlobalVariables.TILE_SIZE/2
#		Check if distance is lower than move speed 
		if abs(distance.x) <= abs(velocity.x) and abs(distance.y) <= abs(velocity.y):
#			Set new position of figure
			selected_figure.position = target_position_glob + GlobalVariables.TILE_SIZE/2
#			Reset variables
			is_moving = false
			active_figure = null
			direction = Vector2()
			grid._can_jail(target_position)
			player_turn = int(!player_turn)
			text_label.text = "Current player: " + str(players[player_turn])
		else:
#			Move figure
			selected_figure.position += velocity
		

func _get_direction(delta_position):
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
