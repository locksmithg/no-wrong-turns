class_name Player
extends CharacterBody2D

enum State {CHOOSING, MOVING, FIGHTING, DEAD}
var current_state = State.CHOOSING

const SPEED = 400
var direction = Vector2.ZERO
var target_position = Vector2.ZERO

var current_map_node = "start"
var map = {}

func _ready():
	target_position = position
	map = $"../maze".map

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
		var next_position = $"../maze".get_node(next_decision).position
		
		target_position = next_position
		current_map_node = next_decision
		current_state = State.MOVING

func state_moving(delta):
	var move_vector = (target_position - position).normalized() * SPEED * delta
	if move_vector.length() > (target_position - position).length():
		position = target_position
		current_state = State.CHOOSING  # Arrived at next decision point
	else:
		position += move_vector

func state_fighting():
	# Placeholder for combat logic
	print("Fighting...")
	# Transition back to choosing or dead after the fight is resolved
	current_state = State.CHOOSING

func state_dead():
	print("Knight is dead.")
	# Handle respawning or game over logic here

func can_move(dir):
	# Check if the next position is within maze bounds or not blocked
	# Implement collision or maze boundary checks here
	return true  # Placeholder
