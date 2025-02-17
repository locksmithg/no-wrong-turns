class_name Player
extends CharacterBody2D

@onready var maze = get_parent().get_node("maze")
@onready var tilemap = maze.get_child(0)

enum State {CHOOSING, MOVING, FIGHTING, DEAD}
var current_state = State.CHOOSING

const SPEED = 500
var direction = Vector2.ZERO
var path = []
var path_index = 0

var current_map_node = "start"
var map = {}

func _ready():
	map = maze.map
	# Get the starting tile position
	var start_tile = map["start"]
	var start_cell = tilemap.local_to_map(maze.get_node("start").position)
	var start_position = tilemap.map_to_local(start_cell)
	
	# Center the player on the start tile
	position = start_position

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
	if Input.is_action_just_pressed("ui_up"):
		move_to_next("up")
	elif Input.is_action_just_pressed("ui_down"):
		move_to_next("down")
	elif Input.is_action_just_pressed("ui_left"):
		move_to_next("left")
	elif Input.is_action_just_pressed("ui_right"):
		move_to_next("right")
	

func move_to_next(direction):
	if direction in map[current_map_node]:
		
		var next_decision = map[current_map_node][direction]
		var next_position = maze.get_node(next_decision).position
		current_map_node = next_decision
		
		var current_cell = tilemap.local_to_map(position)
		var target_cell = tilemap.local_to_map(next_position)
		
		var path_cells = tilemap.get_astar_path(current_cell, target_cell)
		for i in range(path_cells.size()):
			path.append(tilemap.map_to_local(path_cells[i]))
		current_state = State.MOVING

func state_moving(delta):
	if path_index < path.size():
		var next_position = path[path_index]
		var curPos = position
		var move_vector = (next_position - position).normalized() * SPEED * delta
		
		if move_vector.length() >= (next_position - position).length():
			position = next_position
			path_index += 1  # Move to the next point in the path
		else:
			position += move_vector
	else:
		# Reached the end of the path
		if current_map_node.begins_with("trap"):
			current_state = State.DEAD
		else:
			current_state = State.CHOOSING
		path_index = 0
		path.clear()

func state_fighting():
	# Placeholder for combat logic
	print("Fighting...")
	# Transition back to choosing or dead after the fight is resolved
	current_state = State.CHOOSING

func state_dead():
	print("Knight is dead.")
	# Add death animation or sound here
	# Restart at the start node with a new knight
	current_map_node = "start"
	position = maze.get_node("start").position
	current_state = State.CHOOSING
