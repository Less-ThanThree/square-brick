extends Control

@onready var tile_block = load("res://components/tile.tscn")
@onready var resource_tiles = load("res://resources/tiles/tilles.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tile_block_scene = tile_block.instantiate()
	tile_block_scene.tile_info = resource_tiles.tile_info.brick_1
	add_child(tile_block_scene)
	#tile_block_scene = tile_block.instantiate()
	#tile_block_scene.tile_info = resource_tiles.tile_info.brick_1
	#add_child(tile_block_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
