extends GridContainer

@export var grid_container : GridContainer
@export var row: int
@export var col: int
@onready var EmptyTileScene = preload("res://components/empty_map_tile.tscn")
@onready var GameTileScene = preload("res://components/tile.tscn")
@onready var resource_tiles = load("res://resources/tiles/tilles.tres")

signal tile_set
signal tile_hovered
signal tile_exited
signal meeple_set
signal meeple_skip

const MATRIX_SIZE = 20
const MATRIX_SIZE_X2 = 100
const BLOCK_SIZE = 5

var mapTiles = []
var dfsMapMatrix = []
var dfsGlobalMapMatrix = []
var mapIndex = []
var mapCorner = []
var availCorner = []
var mapFindZonesSize = {
	"Build": 0,
	"Road": 0,
}
var currentTileMatrix
var mapHoverTiles
var currentTileInfo
var currentTileRotate = 0.0
var isCurrentMeepleChoose = false
var directions_x8 = [
	Vector2(-1, -1),
	Vector2(0, -1), 
	Vector2(1, -1),
	Vector2(-1, 0), 
	Vector2(1, 0),
	Vector2(-1, 1), 
	Vector2(0, 1), 
	Vector2(1, 1)
]

var directions = [
	Vector2(1, 0),  # вправо
	Vector2(-1, 0), # влево
	Vector2(0, 1),  # вниз
	Vector2(0, -1)  # вверх
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var block_size = Vector2(256, 256)  # Размер блоков 3x3
	grid_container.columns = col
	dfsMapMatrix = create_empty_dfs(row, col)
	dfsGlobalMapMatrix = create_empty_dfs(100, 100, -1)
	
	# Генерация карты
	for row in range(col):
		mapTiles.append([])
		for col in range(col):
			mapTiles[row].append([])
			_create_empty_tile(row, col)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("skip") && isCurrentMeepleChoose:
		skip_meeple_set()

func _create_empty_tile(row: int, col: int):
	var empty_tile_instance = EmptyTileScene.instantiate()
	empty_tile_instance.custom_minimum_size = Vector2(256,256)
	empty_tile_instance.connect("tile_pressed", _on_empty_tile_click.bind(row,col,empty_tile_instance))
	empty_tile_instance.connect("tile_mouse_entered", _on_empty_tile_hovered.bind(row,col,empty_tile_instance))
	empty_tile_instance.connect("tile_mouse_exited", _on_empty_tile_exited.bind(row,col,empty_tile_instance))
	grid_container.add_child(empty_tile_instance)
	mapTiles[row].append(empty_tile_instance)

func create_empty_dfs(row: int, col: int, default_value = []) -> Array:
	var matrix = []
	for i in range(col):
		var row_arr = []
		for j in range(row):
			row_arr.append(default_value)
		matrix.append(row_arr)
	return matrix

func _on_empty_tile_click(row: int, col: int, empty_tile_instance: EmptyMapTile):
	if !isCurrentMeepleChoose:
		set_tile_map(row, col, currentTileInfo)
		emit_signal("tile_set")
		isCurrentMeepleChoose = true
		Player.update_current_state(Player.STATE.CHOOSE_MIPLE)

func _on_empty_tile_hovered(row: int, col: int, empty_tile_instance: EmptyMapTile):
	emit_signal("tile_hovered", row, col, currentTileInfo)

func _on_empty_tile_exited(row: int, col: int, empty_tile_instance: EmptyMapTile):
	emit_signal("tile_exited", row, col)

func set_tile_map(row: int, col: int, tile_info):
	var index = row * grid_container.columns + col
	var new_tile = GameTileScene.instantiate()
	var empty_tile = grid_container.get_child(index)
	tile_set.connect(new_tile._on_tile_set)
	meeple_skip.connect(new_tile._on_meeple_skip)
	new_tile.connect("meeple_set", _on_meeple_set)
	new_tile.connect("ready", _on_tile_ready.bind(row, col, new_tile))
	new_tile.tile_info = resource_tiles.tile_info_x5[tile_info]
	new_tile.angel = currentTileRotate
	
	mapIndex.append(index)
	
	grid_container.remove_child(empty_tile)
	empty_tile.queue_free()

	grid_container.add_child(new_tile)
	grid_container.move_child(new_tile, index)
	
	get_available_corners(row, col, index)
	
	currentTileRotate = 0.0

func set_first_map_tile(row: int, col: int, tile_info):
	var index = row * grid_container.columns + col
	var new_tile = GameTileScene.instantiate()
	var empty_tile = grid_container.get_child(index)
	tile_set.connect(new_tile._on_tile_set)
	new_tile.connect("ready", _on_tile_ready.bind(row, col, new_tile))
	meeple_skip.connect(new_tile._on_meeple_skip)
	new_tile.tile_info = resource_tiles.tile_info_x5[tile_info]
	new_tile.angel = currentTileRotate
	new_tile.is_set = true
	
	grid_container.remove_child(empty_tile)
	empty_tile.queue_free()

	grid_container.add_child(new_tile)
	grid_container.move_child(new_tile, index)
	
	get_available_corners(row, col, index)
	skip_meeple_set()

func _on_tile_ready(row, col, node):
	fill_block_in_matrix(row, col, node.get_top_level_matrix())
	
	var zone = find_zones_2()
	var finds_zone_build = finding_complete_buildings(zone)
	var finds_zone_road = finding_complete_roads(zone)
	
	print("----")
	print("FIND ZONE BUILD")
	print("------")
	print(finds_zone_build)
	
	print("----")
	print("FIND ZONE ROAD")
	print("------")
	print(finds_zone_road)
	
	if mapFindZonesSize["Build"] != finds_zone_build.size():
		Player.increase_score(20)
		mapFindZonesSize["Build"] = finds_zone_build.size()
	
	if mapFindZonesSize["Road"] != finds_zone_road.size():
		Player.increase_score(10)
		mapFindZonesSize["Road"] = finds_zone_road.size()
	
	#if finds_zone.size() > 0:
		#for zone in finds_zone:
			#remove_index_by_key_value(mapZone, "Index", zone["Index"])
	
	print("----")
	print("ZONE MAP")
	print("------")
	print(zone)
	print("-----")

func skip_meeple_set() -> void:
	Player.update_current_state(Player.STATE.CHOOSE_TILE)
	emit_signal("meeple_skip")
	isCurrentMeepleChoose = false

func _on_map_2_test_new_tile(info) -> void:
	currentTileInfo = info
	get_avalable_set_tile()

func _on_map_hover_tiles_is_tile_rotate(angle) -> void:
	currentTileRotate = angle
	get_avalable_set_tile()

func _on_meeple_set():
	Player.decrease_meeple(1)
	Player.update_current_state(Player.STATE.CHOOSE_TILE)
	isCurrentMeepleChoose = false
	emit_signal("meeple_set")

func find_zones_2():
	var zones = []
	var visited = []
	for y in range(MATRIX_SIZE_X2):
		visited.append([])
		for x in range(MATRIX_SIZE_X2):
			visited[y].append(false)
	
	for y in range(MATRIX_SIZE_X2):
		for x in range(MATRIX_SIZE_X2):
			if !visited[y][x] && dfsGlobalMapMatrix[y][x] != -1:
				var zone = flood_fill(Vector2(x, y), dfsGlobalMapMatrix[y][x], visited)
				if zone.size() > 0:
					var zone_type
					match dfsGlobalMapMatrix[y][x]:
						0:
							zone_type = "Field"
						1:
							zone_type = "Build"
						2:
							zone_type = "Road"
						3:
							zone_type = "Deadend"
						5:
							zone_type = "Build_corner"
					var dict = {
						"Zone type": zone_type,
						"Zones": zone,
						#"Index": mapIndex[-1],
					}
					if zone_type != "Build_corner":
						zones.append(dict)
	return zones

func flood_fill(start, target_type, visited):
	var stack = [start]
	var zone = []
	var directions = [
		Vector2(1, 0),  # вправо
		Vector2(-1, 0), # влево
		Vector2(0, 1),  # вниз
		Vector2(0, -1)  # вверх
	]
	
	while stack.size() > 0:
		var current = stack.pop_back()
		var x = current.x
		var y = current.y
		
		if x < 0 || y < 0 || x >= MATRIX_SIZE_X2 || y >= MATRIX_SIZE_X2:
			continue
		if visited[y][x] || dfsGlobalMapMatrix[y][x] != target_type:
			continue
		
		var has_adjacent_one = false
		for dir in directions:
			var nx = x + dir.x
			var ny = y + dir.y
			if nx >= 0 && ny >= 0 && nx < MATRIX_SIZE_X2 && ny < MATRIX_SIZE_X2:
				if dfsGlobalMapMatrix[ny][nx] == 1:
					has_adjacent_one = true
					break
				if dfsGlobalMapMatrix[ny][nx] == 2:
					has_adjacent_one = true
					break
		
		if !has_adjacent_one && target_type != 1 && target_type != 2:
			continue
		
		visited[y][x] = true
		zone.append(current)
		
		stack.append(Vector2(x + 1, y))
		stack.append(Vector2(x - 1, y))
		stack.append(Vector2(x, y + 1))
		stack.append(Vector2(x, y - 1))
	
	return zone

func is_wall_closed(x, y):
	var wall_found = false
	var open_side_found = false
	
	for dir in directions_x8:
		var nx = x + dir.x
		var ny = y + dir.y
		if nx < 0 || nx >= MATRIX_SIZE_X2 || ny < 0 || ny >= MATRIX_SIZE_X2:
			continue
		
		var neignbor_value = dfsGlobalMapMatrix[ny][nx] 
		
		if neignbor_value == 5 || neignbor_value == 1:
			wall_found = true
		elif neignbor_value != 1:
			open_side_found = true
	
	if open_side_found || !wall_found:
		return false
	return true

func is_road_closed(x, y):
	var angle_find = false
	
	for dir in directions:
		var nx = x + dir.x
		var ny = y + dir.y
		if nx < 0 || nx >= MATRIX_SIZE_X2 || ny < 0 || ny >= MATRIX_SIZE_X2:
			continue
		
		var neignbor_value = dfsGlobalMapMatrix[ny][nx] 
		
		if neignbor_value == 3:
			angle_find = true
			
	return angle_find

func finding_complete_buildings(zone_data):
	var complete_bulildings = []
	for zone in zone_data:
		if zone["Zone type"] == "Build" && "Zones" in zone:
			var building_zone = zone["Zones"]
			var building_complete = true
			
			for coord in building_zone:
				var x = coord[0]
				var y = coord[1]
				
				if !is_wall_closed(x, y):
					building_complete = false
					break
			
			if building_complete:
				complete_bulildings.append(zone)
	return complete_bulildings

func finding_complete_roads(zone_data):
	var complete = []
	var founds_angle = 0
	for zone in zone_data:
		if zone["Zone type"] == "Road" && "Zones" in zone:
			var building_zone = zone["Zones"]
			
			for coord in building_zone:
				var x = coord[0]
				var y = coord[1]
				
				if is_road_closed(x, y):
					print("found")
					founds_angle += 1
			
			if founds_angle == 2:
				complete.append(zone)
			
			founds_angle = 0
			
	return complete
#func print_zones(zones):
	#for zone in zones:
		#print("Zone:")
		#for cell in zone:
			#print(cell)
		#print("----")

func fill_block_in_matrix(i, j, block):
	var start_x = i * BLOCK_SIZE
	var start_y = j * BLOCK_SIZE
	
	if start_x + BLOCK_SIZE > MATRIX_SIZE_X2 || start_y + BLOCK_SIZE > MATRIX_SIZE_X2:
		return
	
	for x in range(BLOCK_SIZE):
		for y in range(BLOCK_SIZE):
			dfsGlobalMapMatrix[start_x + x][start_y + y] = block[x][y]

func remove_index_by_key_value(array, key, value):
	for i in range(array.size()):
		if array[i].has(key) && array[i][key] == value:
			array.remove_at(i)
			break

func get_available_corners(row: int, col: int, current_index: int):
	var index_top = (row - 1) * grid_container.columns + col
	var index_left = row * grid_container.columns + (col - 1)
	var index_bottom = (row + 1) * grid_container.columns + col
	var index_right = row * grid_container.columns + ( col + 1)
	var current_tile = grid_container.get_child(current_index)
	
	var sides = {
		"index": current_index,
		"neighbor": {
			"index_top": 0,
			"index_left": 0,
			"index_bottom": 0,
			"index_right": 0,
		},
		"top": [],
		"left": [],
		"bottom": [],
		"right": [],
	}
	
	if grid_container.get_child(index_top) is EmptyMapTile:
		sides["top"] = current_tile.getTopSide()
		sides["neighbor"]["index_top"] = index_top
	if grid_container.get_child(index_left) is EmptyMapTile:
		sides["left"] = current_tile.getLeftSide()
		sides["neighbor"]["index_left"] = index_left
	if grid_container.get_child(index_bottom) is EmptyMapTile:
		sides["bottom"] = current_tile.getBottomSide()
		sides["neighbor"]["index_bottom"] = index_bottom
	if grid_container.get_child(index_right) is EmptyMapTile:
		sides["right"] = current_tile.getRightSide()
		sides["neighbor"]["index_right"] = index_right
	
	mapCorner.append(sides)

func get_avalable_set_tile():
	var info_matrix
	
	if currentTileRotate == 0:
		info_matrix = resource_tiles.tile_info_x5[currentTileInfo]["top_level"]
	if currentTileRotate == -90:
		info_matrix = rotate_counterclockwise(resource_tiles.tile_info_x5[currentTileInfo]["top_level"])
	if currentTileRotate == -180:
		#for i in range(2):
			#print("rotate")
		info_matrix = rotate_counterclockwise(resource_tiles.tile_info_x5[currentTileInfo]["top_level"])
		info_matrix = rotate_counterclockwise(info_matrix)
	if currentTileRotate == -270:
		#for i in range(3):
		info_matrix = rotate_counterclockwise(resource_tiles.tile_info_x5[currentTileInfo]["top_level"])
		info_matrix = rotate_counterclockwise(info_matrix)
		info_matrix = rotate_counterclockwise(info_matrix)
	
	reset_tiles(mapCorner)
	
	if Debug.ISDEBUG:
		print("Current tile top")
		print(getTopSide(info_matrix))
		print("Current tile left")
		print(getLeftSide(info_matrix))
		print("Current tile bottom")
		print(getBottomSide(info_matrix))
		print("Current tile right")
		print(getRightSide(info_matrix))
		print(mapCorner)
	
	for side in mapCorner:
		var side_top = side["top"].filter(func(item): return item != 5)
		var side_left = side["left"].filter(func(item): return item != 5)
		var side_bottom = side["bottom"].filter(func(item): return item != 5)
		var side_right = side["right"].filter(func(item): return item != 5)
		var corner = {
			"index": side["index"],
			"sides": {
				"index_top": null,
				"index_left": null,
				"index_bottom": null,
				"index_right": null,
			}
		}
		
		#side_top.to_set()
		#side_left.to_set()
		#side_bottom.to_set()
		#side_right.to_set()
		
		#if is_compare(1, side_top, getBottomSide(info_matrix)) || is_compare(2, side_top, getBottomSide(info_matrix)) || is_compare(0, side_top, getBottomSide(info_matrix)):
		if uniq_items(side_top) == getBottomSide(info_matrix):
			#corner["sides"]["index_top"] = side["neighbor"]["index_top"]
			set_avail_tile(side["neighbor"]["index_top"])
			if Debug.ISDEBUG:
				print("Top Side Check")
		#if is_compare(1, side_left, getRightSide(info_matrix)) || is_compare(2, side_left, getRightSide(info_matrix)) || is_compare(0, side_left, getRightSide(info_matrix)):
		if uniq_items(side_left) == getRightSide(info_matrix):
			#corner["sides"]["index_left"] = side["neighbor"]["index_left"]
			set_avail_tile(side["neighbor"]["index_left"])
			if Debug.ISDEBUG:
				print("Left Side Check")
		#if is_compare(1, side_bottom, getTopSide(info_matrix)) || is_compare(2, side_bottom,  getTopSide(info_matrix)) || is_compare(0, side_bottom,  getTopSide(info_matrix)):
		if uniq_items(side_bottom) == getTopSide(info_matrix):
			#corner["sides"]["index_bottom"] = side["neighbor"]["index_bottom"]
			set_avail_tile(side["neighbor"]["index_bottom"])
			if Debug.ISDEBUG:
				print("Bottom Side Check")
		#if is_compare(1, side_right, getLeftSide(info_matrix)) || is_compare(2, side_right, getLeftSide(info_matrix)) || is_compare(0, side_right, getLeftSide(info_matrix)):
		if uniq_items(side_right) == getLeftSide(info_matrix):
			set_avail_tile(side["neighbor"]["index_right"])
			#corner["sides"]["index_right"] = side["neighbor"]["index_right"]
			if Debug.ISDEBUG:
				print("Right Side Check")
	
		availCorner.append(corner)

func getTopSide(matrix_top_level: Array) -> Array:
	var array = [
		matrix_top_level[0][0], 
		matrix_top_level[0][1],
		matrix_top_level[0][2],
		matrix_top_level[0][3],
		matrix_top_level[0][4],
	]
	array = array.filter(func(item): return item != 5)
	return uniq_items(array)

func getLeftSide(matrix: Array) -> Array:
	var result = []
	for i in range(matrix.size()):
		result.append(matrix[i][0])
	result = result.filter(func(item): return item != 5)
	return uniq_items(result)

func getBottomSide(matrix_top_level: Array) -> Array:
	var array = [
		matrix_top_level[4][0], 
		matrix_top_level[4][1],
		matrix_top_level[4][2],
		matrix_top_level[4][3],
		matrix_top_level[4][4],
	]
	array = array.filter(func(item): return item != 5)
	return uniq_items(array)

func getRightSide(matrix: Array) -> Array:
	var result = []
	for i in range(matrix.size()):
		result.append(matrix[i][-1])
	result = result.filter(func(item): return item != 5)
	return uniq_items(result)

func set_avail_tile(index):
	var current_tile = grid_container.get_child(index)
	if current_tile is EmptyMapTile:
		current_tile.modulate_avail()

func set_tile_default(index):
	var current_tile = grid_container.get_child(index)
	if current_tile is EmptyMapTile:
		current_tile.modulate_default()

func reset_tiles(info: Array):
	for neighbor in info:
		for index in neighbor["neighbor"]:
			set_tile_default(neighbor["neighbor"][index])

func is_compare(val: int, array_1: Array, array_2: Array) -> bool:
	if array_1.has(val) && array_2.has(val):
		return true
	return false

func uniq_items(array) -> Array:
	var unique_array = []
	for item in array:
		if not unique_array.has(item):  # Проверяем, есть ли уже этот элемент в новом массиве
			unique_array.append(item)
	unique_array.sort()
	return unique_array

func rotate_counterclockwise(matrix):
	var rotated = []
	for col in range(4, -1, -1):
		var new_row = []
		for row in range(5):
			new_row.append(matrix[row][col])
		rotated.append(new_row)
	return rotated
