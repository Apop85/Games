extends Node2D

func _ready():
#	modulate(0,0,0,0)
#	set_opacity(0.5)
	pass

func _draw():
	var LINE_COLOR = Color(20, 20, 20, 0.1)
	var LINE_WIDTH = 2
	var window_size = OS.get_window_size()

#	self_modulate(0,0,0,0)

	for x in range(GlobalVariables.GRID_SIZE.x + 1):
		var col_pos = x * GlobalVariables.TILE_SIZE.x
		var limit = GlobalVariables.GRID_SIZE.y * GlobalVariables.TILE_SIZE.y
		draw_line(Vector2(col_pos, 0), Vector2(col_pos, limit), LINE_COLOR, LINE_WIDTH)
	for y in range(GlobalVariables.GRID_SIZE.y + 1):
		var row_pos = y * GlobalVariables.TILE_SIZE.y
		var limit = GlobalVariables.GRID_SIZE.x * GlobalVariables.TILE_SIZE.x
		draw_line(Vector2(0, row_pos), Vector2(limit, row_pos), LINE_COLOR, LINE_WIDTH)
