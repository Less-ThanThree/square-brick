extends Node2D

@onready var player = $Player
@onready var tile_deck = $Player/Camera2D/TileDeck
@onready var map_grid = $MapGrid

signal new_tile

var tile_deck_array = []
var global_map_tile_array = []
var current_tile

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tiles = Debug.get_tile_resource()
	for brick in tiles.tile_info:
		tile_deck_array.append(tiles.tile_info[brick])
	tile_deck.update_tile_count(tile_deck_array.size())
	global_map_tile_array = create_empty_global_map_tile(map_grid.columns, map_grid.columns)
	player.position = get_map_grid_center_position(map_grid.columns, map_grid.columns, Vector2(256, 256))
	get_center_element_grid(map_grid.columns, map_grid.columns)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_map_grid_center_position(cols: int, rows: int, cell_size: Vector2) -> Vector2:
	var grid_width = cols * cell_size.x
	var grid_height = rows * cell_size.y
	return Vector2(grid_width / 2, grid_height / 2)

func create_empty_global_map_tile(cols: int, rows: int, default_value = null) -> Array:
	var matrix = []
	for row in range(rows):
		var new_row = []
		for col in range(cols):
			new_row.append(default_value)
		matrix.append(new_row)
	return matrix

func get_center_element_grid(cols: int, rows: int):
	var center_row = (rows / 2)
	var center_col = (cols / 2)
	var tile_first_tile = get_random_tile_deck()
	map_grid.set_tile_map(center_row, center_col, tile_first_tile)
	current_tile = get_random_tile_deck()

func remove_tile_deck_elem(index: int):
	tile_deck_array.remove_at(index)
	tile_deck.update_tile_count(tile_deck_array.size())

func get_random_tile_deck():
	var rand_indx = randi() % tile_deck_array.size()
	var info = tile_deck_array[rand_indx].name
	emit_signal("new_tile", info)
	remove_tile_deck_elem(rand_indx)
	return info

func _on_map_grid_tile_set() -> void:
	get_random_tile_deck()
