extends Control

@export var tile_info: Dictionary

@onready var tile_sprite = $Tile_img

var matrix_top_level: Array
var matrix_down_level: Dictionary
var angle = 0

func _ready() -> void:
	var matrix = Basis()
	tile_sprite.texture = tile_info["tile_src"]
	matrix_top_level = tile_info["top_level"]
	matrix_down_level = tile_info["down_level"]
	Debug.print_debug_matrix(matrix_top_level, "Default matrix tile")

func getTopSide() -> Array:
	var array = [
		matrix_top_level[0][0], 
		matrix_top_level[0][1],
		matrix_top_level[0][2],
	]
	return array

func getLeftSide() -> Array:
	var array = [
		matrix_top_level[0][0], 
		matrix_top_level[1][0],
		matrix_top_level[2][0],
	]
	return array

func getBottomSide() -> Array:
	var array = [
		matrix_top_level[2][0], 
		matrix_top_level[2][1],
		matrix_top_level[2][2],
	]
	return array

func getRightSide() -> Array:
	var array = [
		matrix_top_level[0][2], 
		matrix_top_level[1][2],
		matrix_top_level[2][2],
	]
	return array

func rotate_clockwise() -> void:
	var rotated = []
	for col in range(3):
		var new_row = []
		for row in range(2, -1, -1):
			new_row.append(matrix_top_level[row][col])
		rotated.append(new_row)
	matrix_top_level = rotated
	if (Debug.ISDEBUG):
		Debug.print_debug_matrix(matrix_top_level, "Rotate tile matrix clockwise")

func rotate_counterclockwise() -> void:
	var rotated = []
	for col in range(2, -1, -1):
		var new_row = []
		for row in range(3):
			new_row.append(matrix_top_level[row][col])
		rotated.append(new_row)
	matrix_top_level = rotated
	if (Debug.ISDEBUG):
		Debug.print_debug_matrix(matrix_top_level, "Rotate tile matrix counterclockwise")
