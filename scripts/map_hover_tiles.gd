extends GridContainer

@export var grid_container : GridContainer
@export var row: int
@export var col: int
@onready var EmptyTileScene = preload("res://components/empty_map_tile.tscn")
@onready var GameTileScene = preload("res://components/tile.tscn")
@onready var resource_tiles = load("res://resources/tiles/tilles.tres")

signal is_tile_rotate

var mapTiles  = []
var currentTileRotateAngle = 0.0
var isCurrentMeepleChoose = false

func _ready() -> void:
	var block_size = Vector2(256, 256)  # Размер блоков 3x3
	grid_container.columns = col
	
	# Генерация карты
	for row in range(col):
		mapTiles.append([])
		for col in range(col):
			mapTiles[row].append([])
			_create_empty_tile(row, col)

func _create_empty_tile(row: int, col: int):
	var empty_tile_instance = EmptyTileScene.instantiate()
	empty_tile_instance.custom_minimum_size = Vector2(256,256)
	grid_container.add_child(empty_tile_instance)
	mapTiles[row].append(empty_tile_instance)

func _on_map_grid_tile_hovered(row, col, tile_info) -> void:
	if !isCurrentMeepleChoose:
		var index = row * grid_container.columns + col
		var new_tile = GameTileScene.instantiate()
		var empty_tile = grid_container.get_child(index)
		new_tile.connect("is_rotate", _on_update_rotate_tile)
		new_tile.tile_info = resource_tiles.tile_info[tile_info]
		new_tile.angel = currentTileRotateAngle
		
		grid_container.remove_child(empty_tile)
		empty_tile.queue_free()
		
		grid_container.add_child(new_tile)
		grid_container.move_child(new_tile, index)
		
		if (Debug.ISDEBUG):
			print("Hover to Row: %s Col: %s \n Current tile info: %s" % [row, col, tile_info])

func _on_map_grid_tile_exited(row, col) -> void:
	if !isCurrentMeepleChoose:
		var index = row * grid_container.columns + col
		var new_tile = EmptyTileScene.instantiate()
		var old_tile = grid_container.get_child(index)

		grid_container.remove_child(old_tile)
		old_tile.queue_free()
		
		grid_container.add_child(new_tile)
		grid_container.move_child(new_tile, index)

func _on_update_rotate_tile(angle: float):
	currentTileRotateAngle = angle
	emit_signal("is_tile_rotate", angle)
	if (Debug.ISDEBUG):
		print("rotated %s" % [angle])

func _on_map_grid_tile_set() -> void:
	currentTileRotateAngle = 0.0
	isCurrentMeepleChoose = true

func _on_map_grid_meeple_set() -> void:
	isCurrentMeepleChoose = false

func _on_map_grid_meeple_skip() -> void:
	isCurrentMeepleChoose = false
