extends Control

@onready var tile_deck_count = $DeckCount

func _ready() -> void:
	tile_deck_count.text = "0"

func update_tile_count(count: int) -> void:
	tile_deck_count.text = "%s" % [count]
