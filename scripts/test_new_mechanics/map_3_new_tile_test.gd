extends Control

@onready var ui_count_deck = $UI/Player/UI/TileDeck

signal new_tile(tile_name: String)

var tile_deck_array = {
	"tile_1": {
		"count": 5,
	},
	"tile_2": {
		"count": 5,
	}
}

var tile_deck = []

func _ready() -> void:
	generate_tile_deck()
	get_random_tile_deck()

func generate_tile_deck():
	for tile in tile_deck_array:
		for i in range(tile_deck_array[tile]["count"]):
			tile_deck.append(tile)
	tile_deck.shuffle()

func get_random_tile_deck():
	var rand_indx = randi() % tile_deck.size()
	var tile_info = tile_deck[rand_indx]
	emit_signal("new_tile", tile_info)
	remove_tile_deck_elem(rand_indx)
	
func remove_tile_deck_elem(index: int):
	tile_deck.remove_at(index)
	ui_count_deck.update_tile_count(tile_deck.size())

func _on_grid_container_tile_set() -> void:
	get_random_tile_deck()
