extends GridContainer

@export var grid_container : GridContainer
@export var row: int
@export var col: int
@onready var EmptyTileScene = preload("res://components/empty_map_tile.tscn")
@onready var GameTileScene = preload("res://components/tile.tscn")
@onready var resource_tiles = load("res://resources/tiles/tilles.tres")

var mapTiles  = []
var currentTileInfo

# Called when the node enters the scene tree for the first time.
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
	empty_tile_instance.connect("tile_pressed", _on_empty_tile_click.bind(row,col,empty_tile_instance))
	empty_tile_instance.connect("tile_mouse_entered", _on_empty_tile_hovered.bind(row,col,empty_tile_instance))
	empty_tile_instance.connect("tile_mouse_exited", _on_empty_tile_exited.bind(row,col,empty_tile_instance))
	grid_container.add_child(empty_tile_instance)
	mapTiles[row].append(empty_tile_instance)

func _on_empty_tile_click(row: int, col: int, empty_tile_instance: EmptyMapTile):
	var index = row * grid_container.columns + col
	var new_tile = GameTileScene.instantiate()
	new_tile.tile_info = resource_tiles.tile_info.brick_1
	
	grid_container.remove_child(empty_tile_instance)
	empty_tile_instance.queue_free()

	grid_container.add_child(new_tile)
	grid_container.move_child(new_tile, index)

func _on_empty_tile_hovered(row: int, col: int, empty_tile_instance: EmptyMapTile):
	print("hovered")
	var index = row * grid_container.columns + col
	var new_tile = GameTileScene.instantiate()
	new_tile.tile_info = resource_tiles.tile_info[currentTileInfo]
	
	grid_container.remove_child(empty_tile_instance)
	empty_tile_instance.queue_free()
	
	grid_container.add_child(new_tile)
	grid_container.move_child(new_tile, index)

func _on_empty_tile_exited(row: int, col: int, empty_tile_instance: EmptyMapTile):
	print("exited")
	
	#var index = row * grid_container.columns + col
	#var new_tile = EmptyTileScene.instantiate()
	
	#grid_container.remove_child(tile)
	#tile.queue_free()
	
	#grid_container.add_child(new_tile)
	#grid_container.move_child(new_tile, index)

func set_tile_map(row: int, col: int, tile_info):
	var index = row * grid_container.columns + col
	var new_tile = GameTileScene.instantiate()
	new_tile.tile_info = resource_tiles.tile_info[tile_info]
	new_tile.is_set = true

	grid_container.add_child(new_tile)
	grid_container.move_child(new_tile, index)

func _on_map_2_test_new_tile(info) -> void:
	currentTileInfo = info
