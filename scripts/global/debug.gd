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

# Базовая колодка каркасона
# tile_19 - 4 карты
# tile_18 - 2 карты
# tile_17 - 4 карты
# tile_16 - 8 карт
# tile_13 - 9 карт
# tile_14 - 5 карт
# tile_15 - 5 карт
# tile_3 - 5 карты
# tile_5 - 3 карты
# tile_9 - 3 карты
# tile_6 - 4 карты
# tile_10 - 3 карты
# tile_11 - 1 карта
# tile_12 - 1 карта
# tile_1 - 2 карты
# tile_4 - 3 карты
# tile_8 - 3 карты
# tile_7 - 3 карты
# tile_2 - 3 карты
func get_base_tile_array() -> Array:
	var deck_base = tile_resourse.base_array_load
	var tile_base_array = []
	for brick in deck_base:
		for i in range(deck_base[brick] + 1):
			tile_base_array.append(tile_resourse.tile_info[brick])
	print(tile_base_array)
	return tile_base_array

func get_base_tile_array_x5() -> Array:
	var deck_base = tile_resourse.test_stack_x5
	var tile_base_array = []
	for brick in deck_base:
		for i in range(deck_base[brick] + 1):
			tile_base_array.append(tile_resourse.tile_info_x5[brick])
	print(tile_base_array)
	return tile_base_array
