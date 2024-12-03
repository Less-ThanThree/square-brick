extends Control

@onready var meeple_grid = $MeepleGrid
@onready var meeple = load("res://components/meeple.tscn")
@onready var meeple_texture = load("res://assets/meeple.png")

var current_meeples = Player.get_meeples_amount()

func _ready() -> void:
	load_grid_meeple()

func _process(delta: float) -> void:
	if current_meeples != Player.get_meeples_amount():
		clear_grid_meeple()
		load_grid_meeple()
		current_meeples = Player.get_meeples_amount()

func load_grid_meeple():
	var meeples_count = Player.get_meeples_amount()
	for col in range(meeples_count):
		var meeple_scene = meeple.instantiate()
		meeple_scene.custom_minimum_size = Vector2(64, 64)
		meeple_grid.add_child(meeple_scene)

func clear_grid_meeple():
	for child in meeple_grid.get_children():
		child.queue_free()
