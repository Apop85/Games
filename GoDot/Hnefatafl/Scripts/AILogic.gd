extends Node2D

var moving_figure = null
var grid = []

var enemy_movements = []
var player_movements = []
var king_movements = []
var position_origin = Vector2.ZERO
var best_turn = null
var visited = {}
var queue = []
var debug_fig = []
var king_moves_to_win = 999
var best_moves = []
var best_move_score = -1000
var rng = RandomNumberGenerator.new()

onready var parent = get_parent()
onready var directions = parent.move_directions
onready var king_goals = parent.goal_pos
onready var edge_position = [
	#	Top left
		Vector2(2,0), Vector2(1,1), Vector2(0,2),
	#	Top right
		Vector2(parent.grid_size.x - 3, 0), Vector2(parent.grid_size.x - 2, 1), Vector2(parent.grid_size.x - 1, 2),
	#	Bottom left
		Vector2(2, parent.grid_size.y-1), Vector2(1, parent.grid_size.y - 2), Vector2(0, parent.grid_size.y - 3),
	#	Bottom right
		Vector2(parent.grid_size.x - 1, parent.grid_size.y - 3), Vector2(parent.grid_size.x - 2, parent.grid_size.y - 2), Vector2(parent.grid_size.x - 3, parent.grid_size.y - 1)
	]
onready var debug_text = get_parent().get_parent().debug_text

const weights = {
	"center_edge" : 12, # Black player is on center edge position
	"edges" : 10, 		# Black player is on edge position
	"low_danger" : 2, 	# Player can loose 1 figure 
	"high_danger" : 4, 	# Player can loose 2 figures
	"win_game" : 100, 	# Player can win game
	"can_block_king" : 5, 	# Black can block king to move to goal
	"can_block_win": 30, # Player can block enemy from winning
	"stop_king_now": 50, # Player can block enemy from winning
	"move_to_goal" : 10 # White can move to goal
	}

const MAX_ITER = 1000


#func _ready():
#	print(get_parent().get_parent().debug_text)
#	for child in get_parent().get_parent().get_children():
#		print(child.name)
#	pass


func _update_grid():
	grid = parent.grid
	
	

func _check_options(entity):
#	for pos in edge_position:
#		debug_fig.append(add_highlights(pos))
	_update_grid()
	best_moves = []
	best_move_score = 0
#	king_movements = get_possible_moves(parent.world_to_map(parent.king_figure.position))
	var king_checkpoints = get_kings_path_to_goal()
#	if king_moves_to_win != null:
#		king_moves_to_win = king_moves_to_win.size()
#	else:
#		king_moves_to_win = 999
		
	if entity == parent.ENTITY_TYPES.WHITE:
		enemy_movements = get_all_possible_turns(parent.black_figures)
		player_movements = get_all_possible_turns(parent.white_figures)
		for figure in parent.white_figures:
			check_white_figure(figure)
			
	elif entity == parent.ENTITY_TYPES.BLACK:
		enemy_movements = get_all_possible_turns(parent.white_figures)
		player_movements = get_all_possible_turns(parent.black_figures)
#		print(enemy_movements)
		for figure in parent.black_figures:
			check_black_figure(figure)
	
	debug_text = get_parent().get_parent().get_node("UI/GameInterface/InfoBox/DEBUG")
#	print(debug_text)
	
	if best_moves.size() > 1:
		rng.randomize()
		var random = rng.randi_range(0,best_moves.size()-1)
		apply_move(best_moves[random][0], best_moves[random][1])
		if debug_text != null:
			debug_text.text = str(best_moves[random])
	else:
		apply_move(best_moves[0][0], best_moves[0][1])
		if debug_text != null:
			debug_text.text = str(best_moves[0])

func apply_move(start_pos, end_pos):
	for child in debug_fig:
		child.queue_free()
		remove_child(child)	
	debug_fig = []	
#	for pos in edge_position:
#		debug_fig.append(add_highlights(pos))
	for vec in king_movements:
		debug_fig.append(add_highlights(vec))
	debug_fig.append(add_highlights(start_pos))
	debug_fig.append(add_highlights(end_pos))


func get_kings_path_to_goal():
#	for child in debug_fig:
#		child.queue_free()
#		remove_child(child)
#	debug_fig = []
	var shortest_path = []
	king_moves_to_win = 999
	king_movements = []

	var start_pos = parent.world_to_map(parent.king_figure.position)
	for goal_pos in king_goals:
#		shortest_path = []
		
		queue = []
		visited = {}
		for direction in directions:
			queue.push_back({"pos" : {"x" : start_pos.x + direction.x, "y" : start_pos.y + direction.y}, "last_pos" : {"x" : start_pos.x, "y" : start_pos.y}})
			
		var iteration = 0
		while queue.size() > 0:
			var cell_to_check = queue.pop_front()
			
			if check_cell(cell_to_check.pos, cell_to_check.last_pos, goal_pos):
				break
			iteration += 1
			if iteration >= MAX_ITER:
				return []
		var backtraced_path = []
		var cur_pos = {"x" : goal_pos.x , "y" : goal_pos.y} #goal_pos
		
		var failed = false
		if not str(cur_pos) in visited.keys():
			failed = true
		while str(cur_pos) in visited.keys() and visited[str(cur_pos)] != null:
			if cur_pos != null:
				backtraced_path.append(cur_pos)
			cur_pos = visited[str(cur_pos)]
		
#			if not str(cur_pos) in visited:
#				print("V: ", visited.keys(), "\n\n")
		var path_key_cells
		if not failed:
			backtraced_path.invert()
			
	#			for pos in backtraced_path:
	#				debug_fig.append(add_highlights(pos))
			path_key_cells = shorten_path(backtraced_path, goal_pos)
#			if goal_pos == Vector2(0,10):
#				pass
			if shortest_path.size() == 0 or king_moves_to_win >= path_key_cells.size():
				shortest_path = path_key_cells
				king_movements = dict_to_double(backtraced_path)
				king_moves_to_win = shortest_path.size()
				
	#			print("path to goal: ", goal_pos, "  ", backtraced_path)
	#			shortest_path.pop_front()
#		print(goal_pos, "   ", shortest_path, "  ", path_key_cells)
	return dict_to_double(shortest_path)

func dict_to_double(dict):
	var double_list = []
	for part in dict:
		double_list.append(Vector2(part.x, part.y))
	return double_list

func shorten_path(path, goal):
	var king_position = parent.world_to_map(parent.king_figure.position)
	king_position = {"x" : king_position.x, "y" : king_position.y}
	path.insert(0,king_position)
#	var last_pos = king_position
	var last_direction = null
	var new_path = []
	for i in range(1,path.size()):
#	for vect in path:
		var direction = Vector2(path[i].x, path[i].y) - Vector2(path[i-1].x, path[i-1].y)
#		print(i, "  ", direction, "  ", path[i], "  ", path[i-1])
		if last_direction != direction:
			last_direction = direction
			new_path.append(path[i-1])
#			if not (path[i].x == last_pos.x or path[i].y == last_pos.y):
#				new_path.append(last_pos)
#				last_pos = path[i]
#		last_pos = path[i]
	new_path.append(goal)
	new_path.erase(king_position)
	return new_path

func add_highlights(pos):
	if parent._is_inside_grid(pos):
#		Load entity
		var new_figure = parent.highlight.instance()
	#	Set position of object
	#	Add entity to array
		add_child(new_figure)
		new_figure.position = parent.map_to_world(Vector2(pos.x, pos.y)) + parent.half_tile_size
		new_figure.scale.x = parent.scaling
		new_figure.scale.y = parent.scaling
		new_figure.z_index = 100

		return new_figure
	else:
		pass


func check_cell(pos, pos_last, goal):
	if not parent._is_inside_grid(Vector2(pos.x, pos.y)):
		return false
	if not grid[pos.x][pos.y] in [null, parent.ENTITY_TYPES.GOAL, parent.ENTITY_TYPES.THRONE]: #, parent.ENTITY_TYPES.KING]:
		return false
	if str(pos) in visited:
		return false
	
	visited[str(pos)] = pos_last
	
	if pos.x == goal.x and pos.y == goal.y:
		return true
		
	var delta_vector = Vector2(pos_last.x, pos_last.y) - Vector2(pos.x, pos.y)
	if delta_vector == Vector2(1,0):
		queue.push_back({"pos" : {"x" : pos.x + 1, "y" : pos.y}, "last_pos" : pos})
		queue.push_back({"pos" : {"x" : pos.x - 1, "y" : pos.y}, "last_pos" : pos})
		queue.push_back({"pos" : {"x" : pos.x , "y" : pos.y + 1}, "last_pos" : pos})
		queue.push_back({"pos" : {"x" : pos.x , "y" : pos.y - 1}, "last_pos" : pos})
		
	elif delta_vector == Vector2(-1,0):
		queue.push_back({"pos" : {"x" : pos.x - 1, "y" : pos.y}, "last_pos" : pos})
		queue.push_back({"pos" : {"x" : pos.x + 1, "y" : pos.y}, "last_pos" : pos})
		queue.push_back({"pos" : {"x" : pos.x , "y" : pos.y + 1}, "last_pos" : pos})
		queue.push_back({"pos" : {"x" : pos.x , "y" : pos.y - 1}, "last_pos" : pos})
		
	elif delta_vector == Vector2(0,1):
		queue.push_back({"pos" : {"x" : pos.x , "y" : pos.y + 1}, "last_pos" : pos})
		queue.push_back({"pos" : {"x" : pos.x , "y" : pos.y - 1}, "last_pos" : pos})
		queue.push_back({"pos" : {"x" : pos.x - 1, "y" : pos.y}, "last_pos" : pos})
		queue.push_back({"pos" : {"x" : pos.x + 1, "y" : pos.y}, "last_pos" : pos})
		
	elif delta_vector == Vector2(0,-1):
		queue.push_back({"pos" : {"x" : pos.x , "y" : pos.y - 1}, "last_pos" : pos})
		queue.push_back({"pos" : {"x" : pos.x , "y" : pos.y + 1}, "last_pos" : pos})
		queue.push_back({"pos" : {"x" : pos.x + 1, "y" : pos.y}, "last_pos" : pos})
		queue.push_back({"pos" : {"x" : pos.x - 1, "y" : pos.y}, "last_pos" : pos})
		
	return false
		
func get_all_possible_turns(entity):
	var move_list = []
	for figure in entity:
		if figure != null:
			move_list = get_possible_moves(parent.world_to_map(figure.position), move_list)
	return move_list

func check_black_figure(figure):
	var figure_position = parent.world_to_map(figure.position)
	var figure_score = 0
	var moves = []
	moves = get_possible_moves(figure_position)
	figure_score += black_weight_pos(figure_position, true)
	
	for move in moves:
		if move in king_movements:
			pass
		var current_score = [0, figure_position]
		var move_score = black_weight_pos(move)
#		if move_score + figure_score[0] > figure_score[0]:
		if king_moves_to_win <= 3:
			move_score += can_block_king(move)
#			print(figure_position, "  ", move_score+figure_score)
		current_score = [move_score + figure_score, move]
		
			
		if current_score[0] > best_move_score:
			best_moves = [[figure_position, move, current_score[0]]]
			best_move_score = current_score[0]
		elif current_score[0] == best_move_score:
			best_moves.append([figure_position, move, current_score[0]])
#		if move in [Vector2(0,1), Vector2(1,1)]:
#			print(current_score, king_moves_to_win)
	

func check_white_figure(figure):
	var figure_score = 0
	var figure_position = parent.world_to_map(figure.position)
	var moves = []
	moves = get_possible_moves(figure_position)
	
#	print(figure.name, "  ", moves)

	
func get_possible_moves(pos, possible_moves = []):
#	print(possible_moves)
	for direction in directions:
		var blocked = true
		if parent._is_inside_grid(pos + direction):
			if grid[ pos.x + direction.x ][ pos.y + direction.y ] == null:
				blocked = false
		if not blocked:
			var check_pos = pos + direction
			while parent._is_inside_grid(check_pos):
				if grid[ check_pos.x ][ check_pos.y ] == null and not check_pos in possible_moves:
					possible_moves.append(check_pos)
				elif check_pos in possible_moves:
					pass
				else:
					break
				check_pos += direction
	return possible_moves

func black_weight_pos(pos, startposition = false):
	var score = 0
	
	if startposition:
		position_origin = pos
#		Check if start position is on center edges
		if pos in [edge_position[1], edge_position[4], edge_position[7], edge_position[10]]:
			score += -weights["center_edge"]
#		Check if start position is on edges
		elif pos in edge_position:
			score += -weights["edges"]
		score -= is_in_danger(pos, parent.ENTITY_TYPES.BLACK)
	else:
#		Check if position is on center edges
		if pos in [edge_position[1], edge_position[4], edge_position[7], edge_position[10]]:
			score += weights["center_edge"]
#		Check if position is on edges
		elif pos in edge_position:
			score += weights["edges"]
		score += is_in_danger(pos, parent.ENTITY_TYPES.BLACK)
	
	return score


func is_in_danger(pos, player):
	var enemy = parent.ENTITY_TYPES.BLACK if player == parent.ENTITY_TYPES.WHITE else parent.ENTITY_TYPES.WHITE
	var danger_score = 0
	for axis in [Vector2(1,0), Vector2(0,1)]:
		if parent._is_inside_grid(pos - axis) and parent._is_inside_grid(pos + axis):
#			Check if single figure can be killed on next move
			if grid[pos.x - axis.x][pos.y - axis.y] in [enemy, parent.ENTITY_TYPES.THRONE, parent.ENTITY_TYPES.GOAL] and pos + axis in enemy_movements:
				danger_score += -weights["low_danger"]
			if grid[pos.x + axis.x][pos.y + axis.y] in [enemy, parent.ENTITY_TYPES.THRONE, parent.ENTITY_TYPES.GOAL] and pos - axis in enemy_movements:
				danger_score += -weights["low_danger"]
			
#			Check if two figures can be killed on next move
			if parent._is_inside_grid(pos - (axis * 2)):
				if pos - axis != position_origin:
					if grid[pos.x - axis.x][pos.y - axis.y] == player and grid[pos.x - (axis.x * 2)][pos.y - (axis.y * 2)] == enemy and pos + axis in enemy_movements:
						danger_score += -weights["high_danger"]
			if parent._is_inside_grid(pos + (axis * 2)):
				if pos + axis != position_origin:
					if grid[pos.x + axis.x][pos.y + axis.y] == player and grid[pos.x + (axis.x * 2)][pos.y + (axis.y * 2)] == enemy and pos - axis in enemy_movements:
						danger_score += -weights["high_danger"]
#	if pos == Vector2(4,1):
#		print(pos, "   ", danger_score)
	return danger_score

func can_block_king(move):
#	var need_to_block = false
#	if move in king_movements:
#		print("HIT")
	var can_block = false if not move in king_movements else true
	if can_block:
#		for goal in king_goals:
#			if goal in king_movements:
#				need_to_block = true
#		if need_to_block:
		if not move in king_goals:
			if king_moves_to_win == 1:
				return weights["stop_king_now"]
			elif king_moves_to_win == 2:
				return weights["can_block_win"]
			else:
				return weights["can_block_king"]
	return 0
