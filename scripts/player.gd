class_name Player
extends CharacterBody2D

@onready var maze = get_parent().get_node("maze")
@onready var tilemap = maze.get_child(0)

enum State {CHOOSING, MOVING, FIGHTING, DEAD}
var current_state = State.CHOOSING

# Maze data from the parent (maze generator)
var map = []
var maze_width: int = 0
var maze_height: int = 0
var tile_size: int = 64

const SPEED = 1000
var target_position: Vector2
var current_cell: Vector2 = Vector2(1, 1)
var target_cell: Vector2 = Vector2(1, 1)
var final_cell: Vector2 = Vector2(1, 1)
var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO
var chain_moving: bool = false  # true if we are in an auto–movement chain

func _ready():
	var generator = get_parent().get_node("MazeGenerator")
	current_cell = tilemap.local_to_map(maze.get_node("start").position)
	maze_width = generator.maze_width
	maze_height = generator.maze_height
	tile_size = generator.tile_size
	final_cell = generator.finish
	map = generator.maze
	# Center the player on the start tile
	position = current_cell * (tile_size*1.5)
	target_position = position

func _process(delta):
	match current_state:
		State.CHOOSING:
			state_choosing()
		State.MOVING:
			state_moving(delta)
		State.FIGHTING:
			state_fighting()
		State.DEAD:
			state_dead()

func state_choosing():
	direction = Vector2.ZERO
	if Input.is_action_just_pressed("ui_up"):
		direction = Vector2(0, -1)
	elif Input.is_action_just_pressed("ui_down"):
		direction = Vector2(0, 1)
	elif Input.is_action_just_pressed("ui_left"):
		direction = Vector2(-1, 0)
	elif Input.is_action_just_pressed("ui_right"):
		direction = Vector2(1, 0)
	
	if direction != Vector2.ZERO:
		# Check if the adjacent cell in that direction is open.
		var neighbor = current_cell + direction
		if is_in_bounds(neighbor) and map[int(neighbor.x)][int(neighbor.y)] == 0:
			last_direction = direction
			target_cell = move_until_wall(current_cell, direction)
			chain_moving = true
			current_state = State.MOVING

func state_moving(delta):
	var target_pos = target_cell * tile_size
	target_pos.x += tile_size/2
	target_pos.y += tile_size/2
	position = position.move_toward(target_pos, SPEED * delta)
	if position.distance_to(target_pos) < 1.0:
		# Arrived at the target cell.
		position = target_pos
		current_state = State.CHOOSING
		current_cell = target_cell

		# If we’re in chain–movement mode, decide what to do next.
		if chain_moving:
			if count_open_neighbors(current_cell) >= 3:
				chain_moving = false
			else:
				# Try to auto-move in an open adjacent direction (not the cell we came from).
				var next_direction = find_adjacent_direction(current_cell, -last_direction)
				if next_direction != Vector2.ZERO:
					last_direction = next_direction
					target_cell = move_until_wall(current_cell, last_direction)
					current_state = State.MOVING
				else:
					chain_moving = false
		if (current_state != State.MOVING):
			if(count_open_neighbors(current_cell) == 1):
				if (current_cell == final_cell):
					complete_level()
				else:
					current_state = State.DEAD

# Counts the number of open (path) adjacent cells (up, down, left, right) from a given cell.
func count_open_neighbors(cell: Vector2) -> int:
	var count = 0
	var directions = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
	for d in directions:
		var neighbor = cell + d
		if is_in_bounds(neighbor) and map[int(neighbor.x)][int(neighbor.y)] == 0:
			count += 1
	return count

# Returns the furthest cell (in grid coordinates) in the given direction
# that the player can move to without hitting a wall.
func move_until_wall(start: Vector2, direction: Vector2) -> Vector2:
	var cell = start
	while true:
		var next_cell = cell + direction
		if (not is_in_bounds(next_cell)) or (map[int(next_cell.x)][int(next_cell.y)] == 1):
			break
		cell = next_cell
		if(count_open_neighbors(cell) > 2):
			break
	return cell

# Looks for an open adjacent direction (as a Vector2) from the given cell,
# excluding the direction provided in 'exclude' (usually the reverse of last_direction).
# Checks the four cardinal directions in order: up, right, down, left.
func find_adjacent_direction(cell: Vector2, exclude: Vector2) -> Vector2:
	var directions = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
	for d in directions:
		if d == exclude:
			continue
		var neighbor = cell + d
		if is_in_bounds(neighbor) and map[int(neighbor.x)][int(neighbor.y)] == 0:
			return d
	return Vector2.ZERO

# Checks if the cell is within maze boundaries.
func is_in_bounds(cell: Vector2) -> bool:
	return (cell.x >= 0) and (cell.y >= 0) and (cell.x < maze_width) and (cell.y < maze_height)

# Checks whether the given cell contains a special point.
# This function iterates through all nodes in the "special" group.
func is_special_cell(cell: Vector2) -> bool:
	for special in get_tree().get_nodes_in_group("special"):
		var node_cell = Vector2(int(special.position.x / tile_size), int(special.position.y / tile_size))
		if node_cell == cell:
			return true
	return false

func state_fighting():
	# Placeholder for combat logic
	print("Fighting...")
	# Transition back to choosing or dead after the fight is resolved
	current_state = State.CHOOSING

func state_dead():
	print("Knight is dead.")
	# Add death animation or sound here
	# Restart at the start node with a new knight
	current_cell = Vector2(1,1)
	position = current_cell * (tile_size*1.5)
	current_state = State.CHOOSING

func complete_level():
	print("You did it!")
