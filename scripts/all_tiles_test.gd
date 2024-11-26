extends Control

@onready var grid = $ScrollContainer/VBoxContainer/GridContainer
@onready var tile = load("res://components/tile.tscn")

func _ready() -> void:
	var resource_tiles = Debug.get_tile_resource()
	
	for i in range(19):
		i += 1
		var tile_scene = tile.instantiate()
		tile_scene.tile_info = resource_tiles.tile_info["brick_%s" % [i]]
		grid.add_child(tile_scene)
