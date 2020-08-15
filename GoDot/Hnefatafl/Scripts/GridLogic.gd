extends TileMap

# Grid properties
var tile_size = get_cell_size()
var half_tile_size = tile_size / 2
var tile_offset = Vector2(tile_size.x / 2, tile_size.y / 2)
var grid_size = Vector2(11, 11)
var grid = []

# Figure properties
var move_directions = [Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1)]

# Child arrays and dictionaries
var figures = {}
var highlight_child = []

# Figures starting position
var white_start_pos = [Vector2(5,3), Vector2(5,7), Vector2(3,5), Vector2(7,5), Vector2(4,4), Vector2(5,4), 
					   Vector2(6,4), Vector2(4,5), Vector2(6,5), Vector2(4,6), Vector2(5,6), Vector2(6,6)]

var black_start_pos = [Vector2(3,0), Vector2(4,0), Vector2(5,0), Vector2(6,0), Vector2(7,0), Vector2(5,1), 
					   Vector2(0,3), Vector2(0,4), Vector2(0,5), Vector2(0,6), Vector2(0,7), Vector2(1,5), 
					   Vector2(3,10), Vector2(4,10), Vector2(5,10), Vector2(6,10), Vector2(7,10), Vector2(5,9), 
					   Vector2(10,3), Vector2(10,4), Vector2(10,5), Vector2(10,6), Vector2(10,7), Vector2(9,5)]

var goal_pos = [Vector2(0,0), Vector2(10,10), Vector2(10,0), Vector2(0,10)]

var throne_pos = Vector2(5,5)

var king_start_pos = Vector2(5,5)

var forbidden_cells

# Aviable entities
enum ENTITY_TYPES {WHITE, BLACK, KING, READY, THRONE ,GOAL}

onready var black_player = preload("res://Scenes/Player_B.tscn")
onready var white_player = preload("res://Scenes/Player_W.tscn")
onready var king_player = preload("res://Scenes/Player_King.tscn")
onready var highlight = preload("res://Scenes/Highlight.tscn")
onready var goal = preload("res://Scenes/Goal.tscn")
onready var throne = preload("res://Scenes/Throne.tscn")

onready var player_text = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
#	Create grid array
	forbidden_cells = goal_pos
	forbidden_cells.append(throne_pos)
	
	for x in range(grid_size.x):
		grid.append([])
		for y in range(grid_size.y):
			grid[x].append(null) 

	#	Create goals
	for pos in goal_pos:
#		Add figures to grid
		_add_entity(goal, pos, ENTITY_TYPES.GOAL)

	_add_entity(throne, throne_pos, null)

	#	Create white figures
	for pos in white_start_pos:
#		Add figures to grid
		_add_entity(white_player, pos, ENTITY_TYPES.WHITE)
		
	#	Create black figures
	for pos in black_start_pos:
#		Add figures to grid
		_add_entity(black_player, pos, ENTITY_TYPES.BLACK)
	
	_add_entity(king_player, king_start_pos, ENTITY_TYPES.KING)
	


func _add_entity(object, target_position, entity):
#	Load entity
	var new_figure = object.instance()
#	var new_figure = object.instance(1)
#	Add entity to array if is not prop
	if entity in [ENTITY_TYPES.BLACK, ENTITY_TYPES.WHITE ,ENTITY_TYPES.KING]:
		figures[str(target_position)] = new_figure
#	Set position of object
	new_figure.position = map_to_world(target_position) + half_tile_size
#	Add entity to array
	grid[target_position.x][target_position.y] = entity
	add_child(new_figure)
	
		
func update_child_pos(child, pos_target):
#	Get grid position of player
	var grid_position = world_to_map(child.position)
	var type = grid[grid_position.x][grid_position.y]
	
	figures[str(pos_target)] = child
	figures.erase(str(grid_position))
	
	#	Reset cell
	if grid_position in forbidden_cells:
		if grid_position == throne_pos:
			grid[grid_position.x][grid_position.y] = ENTITY_TYPES.THRONE
		else:
			grid[grid_position.x][grid_position.y] = ENTITY_TYPES.GOAL
	else:
		grid[grid_position.x][grid_position.y] = null
#	Add player entity to new position
	grid[pos_target.x][pos_target.y] = type


func _highlight_paths(child):
#	Get positions
	var object_position = child.position
	var map_coordinates = world_to_map(object_position)
#	Check if figure is king
	var king = true if grid[map_coordinates.x][map_coordinates.y] == ENTITY_TYPES.KING else false
#	move_directions to highlight
	
	for direction in move_directions:
#		Iterate check_position
		var check_position = map_coordinates + direction
#		Add highlights to any aviable cell
		while true:
			if check_position.x >= 0 and check_position.y >= 0:
				if check_position.x < grid_size.x and check_position.y < grid_size.y:
					var type = grid[check_position.x][check_position.y]
#					Load new figure to instance
					var new_figure = highlight.instance()
					if type == null or (king and (type in [ENTITY_TYPES.GOAL, ENTITY_TYPES.THRONE])):
#						Set figure position
						new_figure.position = map_to_world(check_position) + half_tile_size
#						Update grid array
						grid[check_position.x][check_position.y] = ENTITY_TYPES.READY
#						Add child to array
						highlight_child.append(new_figure)
						check_position += direction
						add_child(new_figure)
					else: 
						break
				else:
					break
			else:
				break


func _remove_highlights():
	if highlight_child.size() > 0:
		var object_position
		for object in highlight_child:
#			Remove highlights
			object_position = world_to_map(object.position)
			grid[object_position.x][object_position.y] = null
			remove_child(object)
			object.queue_free()
#		Reset array
		highlight_child = []

func _can_jail(figure_position):
	var type = grid[figure_position.x][figure_position.y]
	type = type if type in [0,1] else 0
	var enemy_type = ENTITY_TYPES.BLACK if type == ENTITY_TYPES.WHITE or type == ENTITY_TYPES.KING else ENTITY_TYPES.WHITE
	
	var direction_index = {}
	var possible_jails = [
		[type, enemy_type, enemy_type, type],
		[type, enemy_type, type],
		[type, enemy_type, type, enemy_type], 
		[type, enemy_type, ENTITY_TYPES.THRONE],
		[type, enemy_type, ENTITY_TYPES.GOAL],
		[type, enemy_type, ENTITY_TYPES.KING],
		[ENTITY_TYPES.WHITE, enemy_type, enemy_type, ENTITY_TYPES.KING]
	]
	for direction in move_directions:
		if not str(direction) in direction_index.keys():
			direction_index[str(direction)] = []
			
		direction_index[str(direction)] = [direction, type]
		
		for i in range(1,4):
			var check_position = figure_position + (i * direction)
#			Check if position is within board boundries
			if check_position.x < grid_size.x and check_position.y < grid_size.y and check_position.x >= 0 and check_position.y >= 0:
#				Check content of cell
				if not grid[check_position.x][check_position.y] in [ENTITY_TYPES.KING, ENTITY_TYPES.THRONE, ENTITY_TYPES.GOAL]:
					direction_index[str(direction)].append(grid[check_position.x][check_position.y])
				elif grid[check_position.x][check_position.y] in [ENTITY_TYPES.THRONE, ENTITY_TYPES.GOAL]:
					direction_index[str(direction)].append(type)
				else:
					direction_index[str(direction)].append(ENTITY_TYPES.WHITE)
			else:
				direction_index[str(direction)].append(null)
		
#		Remove Null entrys
		direction_index[str(direction)] = _cut_array(direction_index[str(direction)])

		
	var entities_to_remove = []
	for key in direction_index.keys():
		var direction = direction_index[key][0]
		var list = []
#		Create new list without direction
		for i in range(1, direction_index[key].size()):
			if i > 2:
				if direction_index[key][i] != type:
					break
			list.append(direction_index[key][i])
		if list in possible_jails:
			var counter = 0
			for number in list:
				if not number in [type, ENTITY_TYPES.GOAL, ENTITY_TYPES.THRONE]:
					if counter > 0 and number != type:
#						Save enemy position if can be jailed
						entities_to_remove.append(figure_position + direction * counter)
					else: 
						break
				counter += 1
	
	if entities_to_remove != []:
		_kill_figures(entities_to_remove)

func _cut_array(array_item):
	var new_array = []
	for item in array_item:
		if item != null:
			new_array.append(item)
		else:
			return new_array
	return new_array
		
func _kill_figures(position_list):
	for pos in position_list:
#		Get node
		var figure = figures[str(pos)]

#		Remove figure from field
		grid[pos.x][pos.y] = null
		figures.erase(str(pos))
		
		remove_child(figure)
		figure.queue_free()
	
