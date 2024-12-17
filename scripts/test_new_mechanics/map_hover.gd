extends GridContainer

@export var row: int
@export var col: int
@export var grid_container : GridContainer

@onready var EmptyTileScene = preload("res://components/empty_tile_hover.tscn")
@onready var grid = $"../GridContainer"

signal update_tile_rotation(angle: float)

var current_angle: float = 0.0
var current_tile

func _ready() -> void:
	create_empty_map()

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
	grid_container.add_child(empty_tile_instance)

func _on_grid_container_tile_hovered(index: int) -> void:
	var new_tile = grid.get_current_tile_name().instantiate()
	var empty_tile = grid_container.get_child(index)
	new_tile.connect("rot_left", _on_update_local_angle.bind(-90))
	new_tile.connect("rot_right", _on_update_local_angle.bind(90))
	new_tile.angle = current_angle
	
	grid_container.remove_child(empty_tile)
	empty_tile.queue_free()
		
	grid_container.add_child(new_tile)
	grid_container.move_child(new_tile, index)

func _on_grid_container_tile_exited(index: int) -> void:
	var empty_tile = EmptyTileScene.instantiate()
	var old_tile = grid_container.get_child(index)
	
	grid_container.remove_child(old_tile)
	old_tile.queue_free()
		
	grid_container.add_child(empty_tile)
	grid_container.move_child(empty_tile, index)

func _on_update_local_angle(angle: float):
	current_angle += angle
	emit_signal("update_tile_rotation", current_angle)

func _on_grid_container_tile_set() -> void:
	current_angle = 0
