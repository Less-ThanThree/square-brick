extends GridContainer


@export var grid_container : GridContainer
@onready var EmptyTileScene = preload("res://components/empty_map_tile.tscn")
@onready var GameTileScene = preload("res://components/tile.tscn")
@onready var resource_tiles = load("res://resources/tiles/tilles.tres")

var mapTiles  = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var block_size = Vector2(256, 256)  # Размер блоков 3x3
	var cols = 33  # 100/3 ≈ 33 столбца
	
	# Генерация карты
	for row in range(cols):  # 100/3 ≈ 33 строки
		mapTiles.append([])
		for col in range(cols):
			mapTiles[row].append([])
			_create_empty_tile(row, col)

func _create_empty_tile(row: int, col: int):
	var empty_tile_instance = EmptyTileScene.instantiate()
	empty_tile_instance.custom_minimum_size = Vector2(256,256)
	empty_tile_instance.connect("tile_pressed", _on_empty_tile_click.bind(row,col,empty_tile_instance))
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

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
