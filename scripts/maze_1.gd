extends Node2D

@export var map = {
	"start": {"up": "dp"},
	"dp": {"left": "trap", "right": "dp2", "down": "start"},
	"dp2": {"left": "finish", "right": "trap2", "down": "dp"},
	"trap": {},
	"trap2": {},
	"finish": {}
}
