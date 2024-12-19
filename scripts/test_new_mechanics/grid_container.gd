extends GridContainer

@export var row: int
@export var col: int
@export var grid_container : GridContainer

@onready var EmptyTileScene = preload("res://components/empty_map_tile.tscn")

var tile_1 = preload("res://components/tile_test/tile_1_test.tscn")
var tile_2 = preload("res://components/tile_test/tile_2_test.tscn")

signal tile_hovered(index: int)
signal tile_exited(index: int)
signal tile_set
signal meeple_skip

var current_tile_name
var current_angle = 0.0

var tile_map = {
	"tile_1": tile_1,
	"tile_2": tile_2,
}

func _ready() -> void:
	create_empty_map()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("skip") && Player.get_current_state() == Player.STATE.CHOOSE_MIPLE:
		emit_signal("meeple_skip")

func create_empty_map():
	var block_size = Vector2(256, 256)  # Размер блоков 3x3
	grid_container.columns = col
	
	# Генерация карты
	for row in range(col):
		for col in range(col):
			_create_empty_tile(row, col)

func _create_empty_tile(row: int, col: int):
	var empty_tile_instance = EmptyTileScene.instantiate()
	var index = row * grid_container.columns + col
	empty_tile_instance.custom_minimum_size = Vector2(256,256)
	empty_tile_instance.connect("tile_pressed", _on_empty_tile_click.bind(row,col,index))
	empty_tile_instance.connect("tile_mouse_entered", _on_empty_tile_hovered.bind(index))
	empty_tile_instance.connect("tile_mouse_exited", _on_empty_tile_exited.bind(index))
	grid_container.add_child(empty_tile_instance)

func _on_empty_tile_click(row: int, col: int, index: int):
	if Player.get_current_state() == Player.STATE.CHOOSE_TILE:
		print("Clicked on empty tile on Row: %s, Col: %s, Index: %s" % [row, col, index])
		var empty_tile = grid_container.get_child(index)
		var new_tile = get_tile_by_name(current_tile_name).instantiate()
		tile_set.connect(new_tile._on_tile_set)
		meeple_skip.connect(new_tile._on_tile_meeple_skip)
		new_tile.angle = current_angle
		
		grid_container.remove_child(empty_tile)
		empty_tile.queue_free()

		grid_container.add_child(new_tile)
		grid_container.move_child(new_tile, index)
		
		emit_signal("tile_set")
#func set_tile(id_tile: int, index: int):

func get_tile_by_name(scene_name: String):
	return tile_map.get(scene_name, null)

func get_current_tile_name():
	var tile = get_tile_by_name(current_tile_name)
	return tile

func _on_empty_tile_hovered(index: int):
	emit_signal("tile_hovered", index)

func _on_empty_tile_exited(index: int):
	emit_signal("tile_exited", index)

func _on_map_3_new_tile_test_new_tile(tile_name: String) -> void:
	current_tile_name = tile_name

func _on_map_hover_update_tile_rotation(angle: float) -> void:
	current_angle = angle
