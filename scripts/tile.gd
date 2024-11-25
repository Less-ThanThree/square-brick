extends Control

@export var tile_info: Dictionary

@onready var tile_sprite = $Tile_img

var matrix_top_level: Array
var matrix_down_level: Array

func _ready() -> void:
	tile_sprite.texture = tile_info["tile_src"]
