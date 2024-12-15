extends GridContainer

@export var row: int
@export var col: int
@export var grid_container : GridContainer

@onready var EmptyTileScene = preload("res://components/empty_map_tile.tscn")

var tile_1 = preload("res://components/tile_test/tile_1_test.tscn")
var tile_2 = preload("res://components/tile_test/tile_2_test.tscn")

var tile_deck_array = {
	"tile_1": {
		"count": 5,
	},
	"tile_2": {
		"count": 5,
	}
}

var tile_map = {
	"tile_1": tile_1,
	"tile_2": tile_2,
}

var tile_deck = []

func _ready() -> void:
	create_empty_map()
	generate_tile_deck()

func _process(delta: float) -> void:
	pass

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
	grid_container.add_child(empty_tile_instance)

func _on_empty_tile_click(row: int, col: int, index: int):
	print("Clicked on empty tile on Row: %s, Col: %s, Index: %s" % [row, col, index])
	var empty_tile = grid_container.get_child(index)
	var new_tile = get_tile_by_name(tile_deck[-1]).instantiate()
	
	grid_container.remove_child(empty_tile)
	empty_tile.queue_free()

	grid_container.add_child(new_tile)
	grid_container.move_child(new_tile, index)
	
	tile_deck.pop_back()
#func set_tile(id_tile: int, index: int):
	
func generate_tile_deck():
	for tile in tile_deck_array:
		for i in range(tile_deck_array[tile]["count"]):
			tile_deck.append(tile)
	tile_deck.shuffle()

func get_tile_by_name(scene_name: String):
	return tile_map.get(scene_name, null)
