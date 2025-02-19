extends Node2D

# Maze dimensions (should be odd numbers for proper walls and paths)
@export var maze_width: int = 21
@export var maze_height: int = 21
@export var tile_size: int = 64
@export var finish: Vector2
const tile_coords: Vector2i = Vector2i(1,1)
# The maze grid: 1 = wall, 0 = path
@export var maze = []
# tile ids
@onready var maze_node = $"../maze"
@onready var tilemap = $"../maze".get_child(0)

func _ready():
	generate_maze()
	print_maze()  # For debugging in the output console
	place_special_nodes()
	set_tiles()

func set_tiles():
	for x in range(maze_width):
		for y in range(maze_height):
			if maze[x][y] == 1:
				tilemap.set_cell(Vector2i(x, y), 1, tile_coords)
			else:
				tilemap.set_cell(Vector2i(x, y), 0, tile_coords)
	tilemap.set_cell(finish, 0, Vector2i(6,1))

func generate_maze():
	# Initialize maze: fill with walls (1's)
	maze.resize(maze_width)
	for x in range(maze_width):
		maze[x] = []
		for y in range(maze_height):
			maze[x].append(1)
	
	# Start carving from cell (1,1)
	maze[1][1] = 0  # 0 represents a path
	carve_passages_from(1, 1)

func carve_passages_from(cx: int, cy: int):
	# Directions to move in "jumps" of 2 cells (to leave a wall between)
	var directions = [Vector2(2, 0), Vector2(-2, 0), Vector2(0, 2), Vector2(0, -2)]
	directions.shuffle()  # Randomize order for different maze layouts
	
	for dir in directions:
		var nx = cx + int(dir.x)
		var ny = cy + int(dir.y)
		# Check if the new cell is within bounds
		if nx > 0 and nx < maze_width - 1 and ny > 0 and ny < maze_height - 1:
			if maze[nx][ny] == 1:  # If it's still a wall, it hasn't been visited
				# Remove the wall between current cell and new cell
				maze[cx + int(dir.x / 2)][cy + int(dir.y / 2)] = 0
				maze[nx][ny] = 0
				carve_passages_from(nx, ny)

func print_maze():
	# Print the maze to the output for debugging (walls as '#' and paths as space)
	for y in range(maze_height):
		var line = ""
		for x in range(maze_width):
			line += ("#" if maze[x][y] == 1 else " ")
		print(line)

###############################
# Placing Special Maze Markers #
###############################

func place_special_nodes():
	# Define the starting position
	var start_pos = Vector2(1, 1)
	# Find the farthest cell from the start using BFS
	var finish_pos = find_finish(start_pos)
	finish = finish_pos
	# --- Place Start Node ---
	var start_node = Node2D.new()
	start_node.name = "start"
	start_node.position = start_pos * tile_size
	maze_node.add_child(start_node)
	
	# --- Place Finish Node ---
	var finish_node = Node2D.new()
	finish_node.name = "finish"
	finish_node.position = finish_pos * tile_size
	maze_node.add_child(finish_node)

#####################################
# Finding the Farthest ("Finish") Cell #
#####################################

func find_finish(start_pos: Vector2) -> Vector2:
	# Use Breadth-First Search (BFS) to find the farthest reachable cell from start.
	var queue = []
	var visited = {}
	queue.append({"pos": start_pos, "dist": 0})
	visited[start_pos] = true
	var farthest = start_pos
	var max_dist = 0

	while queue.size() > 0:
		var current = queue.pop_front()
		var pos = current["pos"]
		var dist = current["dist"]
		
		if dist > max_dist:
			max_dist = dist
			farthest = pos
		
		for offset in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
			var next_pos = pos + offset
			if next_pos.x >= 0 and next_pos.y >= 0 and next_pos.x < maze_width and next_pos.y < maze_height:
				if maze[int(next_pos.x)][int(next_pos.y)] == 0 and not visited.has(next_pos):
					visited[next_pos] = true
					queue.append({"pos": next_pos, "dist": dist + 1})
	
	return farthest
