extends Control

@onready var meeple_grid = $MeepleGrid
@onready var meeple = load("res://components/meeple.tscn")
@onready var meeple_texture = load("res://assets/meeple.png")

func _ready() -> void:
	load_grid_meeple()

func load_grid_meeple():
	var meeples_count = Player.get_meeples_amount()
	for col in range(meeples_count):
		var meeple_scene = meeple.instantiate()
		meeple_scene.custom_minimum_size = Vector2(64, 64)
		meeple_grid.add_child(meeple_scene)
