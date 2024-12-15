extends GridContainer

@export var is_disabled: bool = false

@onready var meeple_panel = load("res://components/ui/meeple_grid_tile.tscn")

signal disabled
signal meeple_set

func _ready() -> void:
	load_grid_meeple()

func load_grid_meeple():
	for col in range(25):
		var meeple_tile = meeple_panel.instantiate()
		meeple_tile.custom_minimum_size = Vector2(50, 50)
		meeple_tile.connect("meeple_set", _on_meeple_set)
		disabled.connect(meeple_tile._on_disabled)
		add_child(meeple_tile)

func _on_meeple_set(node):
	clear_meeple_advice(node)
	emit_signal("disabled")
	emit_signal("meeple_set", node)
	change_state_disabled()
	if Debug.ISDEBUG:
		print("meeple_set")

func clear_meeple_advice(node):
	for child in get_children():
		if child != node:
			var texture = child.get_node("TextureMeeple")
			texture.texture = null

func _on_tile_meeple_skip() -> void:
	if !is_disabled:
		clear_meeple_advice(null)
		emit_signal("disabled")
		change_state_disabled()
		if Debug.ISDEBUG:
			print("meeple_skip")

func change_state_disabled():
	is_disabled = !is_disabled
