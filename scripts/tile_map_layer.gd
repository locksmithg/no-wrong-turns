extends TileMapLayer

var astargrid = AStarGrid2D.new()
const is_solid = "is_solid"

func _ready() -> void:
	setup_grid()

func setup_grid():
	var rect = get_used_rect()
	astargrid.region = Rect2i(rect.position, rect.size)
	astargrid.cell_size = Vector2i(64, 64)
	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astargrid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astargrid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astargrid.update()
	# do not update after setting solid cells, it resets all cells
	for cell in get_used_cells():
		astargrid.set_point_solid(cell, is_cell_solid(cell))

func is_cell_solid(cell:Vector2i) -> bool:
	return get_cell_tile_data(cell).get_custom_data(is_solid)

func get_astar_path(start: Vector2i, end: Vector2i):
	return astargrid.get_id_path(start, end)
