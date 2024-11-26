extends Node

const ISDEBUG = true

var tile_resourse: Resource

func _ready() -> void:
	tile_resourse = load("res://resources/tiles/tilles.tres")

func print_debug_matrix(matrix: Array, descript: String = "Debug matrix"):
	print(descript)
	for row in matrix:
		print(row)

func get_tile_resource() -> Resource:
	return tile_resourse
