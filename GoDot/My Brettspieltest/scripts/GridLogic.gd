extends TileMap


var tile_size = get_cell_size()
var half_tile_size = tile_size / 2
var tile_offset = Vector2(tile_size.x / 2, tile_size.y / 2)
var rng = RandomNumberGenerator.new()
var grid_size = Vector2(10, 10)
var grid = []

enum ENTITY_TYPES {PLAYER, OBSTACLE}

onready var obstacle = preload("res://obstacle.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
#	Create grid array
	for x in range(grid_size.x):
		grid.append([])
		for y in range(grid_size.y):
			grid[x].append(null) 

#	Set player to start position
	var player = get_node("Player")
	var start_pos = update_child_pos(player.position, Vector2(), ENTITY_TYPES.PLAYER)
	player.position = start_pos

#	Create Obstacles
	var positions = []
	for obstacle in range(5):
#		Randomize based on time
		rng.randomize()
#		Create random vector
		var grid_pos = Vector2(rng.randf_range(0, grid_size.x), rng.randf_range(0, grid_size.y))
		if not grid_pos in positions:
			positions.append(grid_pos)
	
	for pos in positions:
#		Add obstacles to grid
		var new_obstacle = obstacle.instance()
		new_obstacle.position = map_to_world(pos) + half_tile_size
		grid[pos.x][pos.y] = ENTITY_TYPES.OBSTACLE
		add_child(new_obstacle)
	

func _is_path_free(delta_movement, current_position, direction):
	var target_cell = current_position + delta_movement
	var check_cell = current_position
#	Check each cell on path 
	while check_cell != target_cell:
		check_cell += direction
		if grid[check_cell.x][check_cell.y] != null:
			return false
	return true
		

func update_child_pos(pos, direction, type):
#	Get grid position of player
	var grid_position = world_to_map(pos)
#	Reset cell
	grid[grid_position.x][grid_position.y] = null
	
#	Add player entity to new position
	var new_grid_position = grid_position + direction
	grid[new_grid_position.x][new_grid_position.y] = type
#	Calculate target position to world coordinates
	var target_position = map_to_world(new_grid_position) + tile_offset 

	return target_position

	

