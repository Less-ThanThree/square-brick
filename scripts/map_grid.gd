extends GridContainer

@export var grid_container : GridContainer
@export var row: int
@export var col: int
@onready var EmptyTileScene = preload("res://components/empty_map_tile.tscn")
#@onready var GameTileScene = preload("res://components/tile.tscn")
@onready var resource_tiles = load("res://resources/tiles/tilles.tres")

var tile_1 = preload("res://components/tile_test/tile_1_test.tscn")
var tile_2 = preload("res://components/tile_test/tile_2_test.tscn")
var tile_3 = preload("res://components/tile_test/tile_3.tscn")
var tile_4 = preload("res://components/tile_test/tile_4.tscn")
var tile_5 = preload("res://components/tile_test/tile_5.tscn")
var tile_6 = preload("res://components/tile_test/tile_6.tscn")
var tile_7 = preload("res://components/tile_test/tile_7.tscn")
var tile_8 = preload("res://components/tile_test/tile_8.tscn")
var tile_9 = preload("res://components/tile_test/tile_9.tscn")
var tile_10 = preload("res://components/tile_test/tile_10.tscn")
var tile_11 = preload("res://components/tile_test/tile_11.tscn")
var tile_12 = preload("res://components/tile_test/tile_12.tscn")
var tile_13 = preload("res://components/tile_test/tile_13.tscn")
var tile_14 = preload("res://components/tile_test/tile_14.tscn")
var tile_15 = preload("res://components/tile_test/tile_15.tscn")
var tile_16 = preload("res://components/tile_test/tile_16.tscn")
var tile_17 = preload("res://components/tile_test/tile_17.tscn")
var tile_18 = preload("res://components/tile_test/tile_18.tscn")
var tile_19 = preload("res://components/tile_test/tile_19.tscn")

signal tile_set
signal tile_hovered
signal tile_exited
signal meeple_set
signal meeple_skip

const MATRIX_SIZE = 20
const MATRIX_SIZE_X2 = 100
const BLOCK_SIZE = 5

var tile_map = {
	"tile_1": tile_1,
	"tile_2": tile_2,
	"tile_3": tile_3,
	"tile_4": tile_4,
	"tile_5": tile_5,
	"tile_6": tile_6,
	"tile_7": tile_7,
	"tile_8": tile_8,
	"tile_9": tile_9,
	"tile_10": tile_10,
	"tile_11": tile_11,
	"tile_12": tile_12,
	"tile_13": tile_13,
	"tile_14": tile_14,
	"tile_15": tile_15,
	"tile_16": tile_16,
	"tile_17": tile_17,
	"tile_18": tile_18,
	"tile_19": tile_19,
}

var mapTiles = []
var dfsMapMatrix = []
var dfsGlobalMapMatrix = []
var mapIndex = []
var tileIndex = []
var mapCorner = []
var availCorner = []
var meeplePlayer = []
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

var current_tile_name
var current_angle_side = "top"
var current_angle = 0.0

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
	if Input.is_action_just_pressed("skip") && Player.get_current_state() == Player.STATE.CHOOSE_MIPLE:
		emit_signal("meeple_skip")

func _create_empty_tile(row: int, col: int):
	var empty_tile_instance = EmptyTileScene.instantiate()
	var index = row * grid_container.columns + col
	empty_tile_instance.custom_minimum_size = Vector2(256,256)
	empty_tile_instance.connect("tile_pressed", _on_empty_tile_click.bind(row,col,index))
	empty_tile_instance.connect("tile_mouse_entered", _on_empty_tile_hovered.bind(index))
	empty_tile_instance.connect("tile_mouse_exited", _on_empty_tile_exited.bind(index))
	grid_container.add_child(empty_tile_instance)

func create_empty_dfs(row: int, col: int, default_value = []) -> Array:
	var matrix = []
	for i in range(col):
		var row_arr = []
		for j in range(row):
			row_arr.append(default_value)
		matrix.append(row_arr)
	return matrix

func _on_empty_tile_click(row: int, col: int, index: int):
	if Player.get_current_state() == Player.STATE.CHOOSE_TILE:
		print("Clicked on empty tile on Row: %s, Col: %s, Index: %s" % [row, col, index])
		var empty_tile = grid_container.get_child(index)
		var new_tile = get_tile_by_name(current_tile_name).instantiate()
		tile_set.connect(new_tile._on_tile_set)
		#meeple_set.
		meeple_skip.connect(new_tile._on_tile_meeple_skip)
		#new_tile.connect("tile_set", _on_tile_set)
		new_tile.connect("ready", _on_tile_ready.bind(row, col, new_tile))
		#new_tile.connect("area_compare", _on_tile_compare.bind(index, row, col))
		new_tile.angle = current_angle
		new_tile.side = current_angle_side
		#new_tile.is_set = true
		#new_tile.is_current = true
		
		grid_container.remove_child(empty_tile)
		empty_tile.queue_free()

		grid_container.add_child(new_tile)
		grid_container.move_child(new_tile, index)
		
		find_tile_compare(row, col, index)
		emit_signal("tile_set")
		#skip_meeple_set()

func _on_empty_tile_hovered(index: int):
	emit_signal("tile_hovered", index)

func _on_empty_tile_exited(index: int):
	emit_signal("tile_exited", index)

#func set_tile_map(row: int, col: int, tile_info):
	#var index = row * grid_container.columns + col
	#var new_tile = GameTileScene.instantiate()
	#var empty_tile = grid_container.get_child(index)
	#tile_set.connect(new_tile._on_tile_set)
	#meeple_skip.connect(new_tile._on_meeple_skip)
	#new_tile.connect("meeple_set", _on_meeple_set)
	#new_tile.connect("ready", _on_tile_ready.bind(row, col, new_tile))
	#new_tile.tile_info = resource_tiles.tile_info_x5[tile_info]
	#new_tile.angel = currentTileRotate
	#
	#grid_container.remove_child(empty_tile)
	#empty_tile.queue_free()
#
	#grid_container.add_child(new_tile)
	#grid_container.move_child(new_tile, index)
	#
	#find_tile_compare(row, col, index)
	#
	#currentTileRotate = 0.0

func set_first_map_tile(row: int, col: int, tile_info, current_tile_name):
	var index = row * grid_container.columns + col
	var empty_tile = grid_container.get_child(index)
	current_tile_name = current_tile_name
	var new_tile = get_tile_by_name(current_tile_name).instantiate()
	tile_set.connect(new_tile._on_tile_set)
	new_tile.connect("ready", _on_tile_ready.bind(row, col, new_tile))
	meeple_skip.connect(new_tile._on_tile_meeple_skip)
	#tile_set.connect(new_tile._on_tile_set)
	#meeple_skip.connect(new_tile._on_tile_meeple_skip)
	#new_tile.connect("area_compare", _on_tile_compare.bind(index, row, col))
	new_tile.angle = currentTileRotate
	new_tile.side = current_angle_side
	new_tile.is_set = true
	
	grid_container.remove_child(empty_tile)
	empty_tile.queue_free()

	grid_container.add_child(new_tile)
	grid_container.move_child(new_tile, index)
	
	find_tile_compare(row, col, index)
	skip_meeple_set()
	#var index = row * grid_container.columns + col
	#var new_tile = GameTileScene.instantiate()
	#var empty_tile = grid_container.get_child(index)
	#tile_set.connect(new_tile._on_tile_set)
	#new_tile.connect("ready", _on_tile_ready.bind(row, col, new_tile))
	#meeple_skip.connect(new_tile._on_meeple_skip)
	#new_tile.tile_info = resource_tiles.tile_info_x5[tile_info]
	#new_tile.angel = currentTileRotate
	#new_tile.is_set = true
	#
	#grid_container.remove_child(empty_tile)
	#empty_tile.queue_free()
#
	#grid_container.add_child(new_tile)
	#grid_container.move_child(new_tile, index)
	#
	#tileIndex.append(index)
	
	#find_tile_compare(row, col, index)
	#skip_meeple_set()
func set_current_tile_name(na):
	current_tile_name = na

func get_current_tile_name():
	var tile = get_tile_by_name(current_tile_name)
	return tile

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
		for build in finds_zone_build:
			for index_build in build["Index"]:
				change_complete_zone(index_build)
		Player.increase_score(20)
		mapFindZonesSize["Build"] = finds_zone_build.size()
	
	if mapFindZonesSize["Road"] != finds_zone_road.size():
		for road in finds_zone_road:
			for index_road in road["Index"]:
				change_complete_zone(index_road)
		Player.increase_score(10)
		mapFindZonesSize["Road"] = finds_zone_road.size()
	
	print("----")
	print("ZONE MAP")
	print("------")
	print(zone)
	print("-----")

func skip_meeple_set() -> void:
	Player.update_current_state(Player.STATE.CHOOSE_TILE)
	emit_signal("meeple_skip")
	isCurrentMeepleChoose = false

func get_tile_by_name(scene_name: String):
	return tile_map.get(scene_name, null)

func _on_map_2_test_new_tile(info, current_tile_name) -> void:
	currentTileInfo = info
	current_tile_name = current_tile_name
	get_avalable_set_tile()

func _on_map_hover_tiles_is_tile_rotate(angle) -> void:
	currentTileRotate = angle
	get_avalable_set_tile()

func _on_meeple_set(node):
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
							
					var zone_indexes = []
					
					for coord in zone:
						var x_coord = coord.x
						var y_coord = coord.y
						
						var grid_x = int(x_coord / 5)
						var grid_y = int(y_coord / 5)
						var grid_index = grid_y * grid_container.columns + grid_x
						
						zone_indexes.append(grid_index)
						
					var dict = {
						"Zone type": zone_type,
						"Zones": zone,
						"Index": uniq_items(zone_indexes),
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

func change_complete_zone(index):
	var tile = grid_container.get_child(index)
	if tile is Tile:
		tile.set_done_tile()

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

func find_tile_compare(row: int, col: int, current_index: int):
	var dict = {
		"index": current_index,
		"row": row,
		"col": col,
	}
	
	mapIndex.append(dict)
	mapCorner = []
	
	for tile in mapIndex:
		get_available_corners(tile["row"], tile["col"], tile["index"])

func get_available_corners(row: int, col: int, current_index: int):
	var index_top = (row - 1) * grid_container.columns + col
	var index_left = row * grid_container.columns + (col - 1)
	var index_bottom = (row + 1) * grid_container.columns + col
	var index_right = row * grid_container.columns + ( col + 1)
	
	var index_top_left = (row - 1) * grid_container.columns + (col - 1)
	var index_top_right = (row - 1) * grid_container.columns + (col + 1)
	var index_top_top = (row - 2) * grid_container.columns + col
	
	var index_bottom_left = row * grid_container.columns + (col - 2)
	var index_bottom_right = row * grid_container.columns + ( col + 2)
	var index_top_bottom = (row + 2) * grid_container.columns + col
	
	var current_tile = grid_container.get_child(current_index)
	
	var sides = {
		"index": current_index,
		"neighbor": {
			"index_top": 0,
			"index_left": 0,
			"index_bottom": 0,
			"index_right": 0,
		},
		"neighbor_dial": {
			"index_top_bottom": 0,
			"index_top_left": 0,
			"index_top_right": 0,
			"index_top_top": 0,
		},
		"neighbor_bottom": {
			"index_left_bottom": null,
			"index_right_bottom": null,
			"index_top_bottom": null,
		},
		"top": [],
		"left": [],
		"bottom": [],
		"right": [],
		"angles": {
			"top_left": null,
			"top_right": null,
			"top_top": null,
		},
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
	
	if grid_container.get_child(index_top_left) is Tile:
		sides["angles"]["top_left"] = grid_container.get_child(index_top_left)
		sides["neighbor_dial"]["index_top_left"] = index_top_left
	if grid_container.get_child(index_top_right) is Tile:
		sides["angles"]["top_right"] = grid_container.get_child(index_top_right)
		sides["neighbor_dial"]["index_top_right"] = index_top_right
	if  grid_container.get_child(index_top_top) is Tile:
		sides["angles"]["top_top"] = grid_container.get_child(index_top_top)
		sides["neighbor_dial"]["index_top_top"] = index_top_top
	if grid_container.get_child(index_bottom_left) is Tile:
		sides["neighbor_bottom"]["index_left_bottom"] = grid_container.get_child(index_bottom_left)
	if grid_container.get_child(index_bottom_right) is Tile:
		sides["neighbor_bottom"]["index_right_bottom"] = grid_container.get_child(index_bottom_right)
	if grid_container.get_child(index_top_bottom) is Tile:
		sides["neighbor_bottom"]["index_top_bottom"] = grid_container.get_child(index_top_bottom)
	
	mapCorner.append(sides)

func get_avalable_set_tile():
	var info_matrix
	
	if current_angle_side == "top":
		info_matrix = resource_tiles.tile_info_x5[currentTileInfo]["top_level"]
	if current_angle_side == "left":
		info_matrix = rotate_counterclockwise(resource_tiles.tile_info_x5[currentTileInfo]["top_level"])
	if current_angle_side == "bottom":
		info_matrix = rotate_counterclockwise(resource_tiles.tile_info_x5[currentTileInfo]["top_level"])
		info_matrix = rotate_counterclockwise(info_matrix)
	if current_angle_side == "right":
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
		#print(mapCorner)
	
	for side in mapCorner:
		var side_top = side["top"].filter(func(item): return item != 5)
		var side_left = side["left"].filter(func(item): return item != 5)
		var side_bottom = side["bottom"].filter(func(item): return item != 5)
		var side_right = side["right"].filter(func(item): return item != 5)
		
		if uniq_items(side_left) == getRightSide(info_matrix):
			set_avail_tile(side["neighbor"]["index_left"])
			if Debug.ISDEBUG:
				print("Left Side Check")
		if uniq_items(side_right) == getLeftSide(info_matrix):
			set_avail_tile(side["neighbor"]["index_right"])
			if Debug.ISDEBUG:
				print("Right Side Check")
		if uniq_items(side_top) == getBottomSide(info_matrix):
				set_avail_tile(side["neighbor"]["index_top"])
				if Debug.ISDEBUG:
					print("Top Side Check")
		if uniq_items(side_bottom) == getTopSide(info_matrix):
			set_avail_tile(side["neighbor"]["index_bottom"])
			if Debug.ISDEBUG:
				print("Bottom Side Check")
		if uniq_items(side_left) == getRightSide(info_matrix) && side["neighbor_bottom"]["index_left_bottom"] != null:
			var tile_left_bottom = side["neighbor_bottom"]["index_left_bottom"]
			var tile_left_side = tile_left_bottom.getRightSide().filter(func(item): return item != 5)
			
			if uniq_items(tile_left_side) == getLeftSide(info_matrix):
				set_avail_tile(side["neighbor"]["index_left"])
				if Debug.ISDEBUG:
					print("Middle Left Side Check")
			else:
				set_tile_default(side["neighbor"]["index_left"])
		if uniq_items(side_right) == getLeftSide(info_matrix) && side["neighbor_bottom"]["index_right_bottom"] != null:
			var tile_right_bottom = side["neighbor_bottom"]["index_right_bottom"]
			var tile_right_side = tile_right_bottom.getLeftSide().filter(func(item): return item != 5)
			
			if uniq_items(tile_right_side) == getRightSide(info_matrix):
				set_avail_tile(side["neighbor"]["index_right"])
				if Debug.ISDEBUG:
					print("Middle Right Side Check")
			else:
				set_tile_default(side["neighbor"]["index_right"])
		
	for side in mapCorner:
		var side_top = side["top"].filter(func(item): return item != 5)
		var side_left = side["left"].filter(func(item): return item != 5)
		var side_bottom = side["bottom"].filter(func(item): return item != 5)
		var side_right = side["right"].filter(func(item): return item != 5)
		
		var is_angles_side = {
			"top_left_inside": null,
			"top_right_inside": null,
			"top_left_outside": null,
			"top_right_outside": null,
			"top_top": null,
		}
		
		for corner in side["angles"]:
			if corner == "top_left":
				if side["angles"][corner] != null:
					var tile = side["angles"][corner]
					
#					outside 
					var arr = tile.getBottomSide().filter(func(item): return item != 5)
					if uniq_items(arr) == getTopSide(info_matrix) && uniq_items(side_left) == getRightSide(info_matrix):
						set_avail_tile(side["neighbor"]["index_left"])
						is_angles_side["top_left_outside"] = true
						if Debug.ISDEBUG:
							print("Bottom Left otside angle")
					else:
						is_angles_side["top_left_outside"] = false
						set_tile_default(side["neighbor"]["index_left"])
						#if Debug.ISDEBUG:
							#print("Bottom Left otside angle disable")
						
#						inside
					var arr_right = tile.getRightSide().filter(func(item): return item != 5)
					if uniq_items(arr_right) == getLeftSide(info_matrix) && uniq_items(side_top) == getBottomSide(info_matrix):
						set_avail_tile(side["neighbor"]["index_top"])
						is_angles_side["top_left_inside"] = true
						if Debug.ISDEBUG:
							print("Bottom Left inside angle")
					else:
						set_tile_default(side["neighbor"]["index_top"])
						is_angles_side["top_left_inside"] = false
						#if Debug.ISDEBUG:
							#print("Top Left inside angle disable")
			if corner == "top_right":
				if side["angles"][corner] != null:
					var tile = side["angles"][corner]
					
#					outside
					var arr = tile.getBottomSide().filter(func(item): return item != 5)
					if uniq_items(arr) == getTopSide(info_matrix) && uniq_items(side_right) == getLeftSide(info_matrix):
						set_avail_tile(side["neighbor"]["index_right"])
						is_angles_side["top_right_outside"] = true
						if Debug.ISDEBUG:
							print("Bottom Right outside angle")
					else:
						set_tile_default(side["neighbor"]["index_right"])
						is_angles_side["top_right_outside"] = false
						#if Debug.ISDEBUG:
							#print("Bottom Right outside angle disable")
						
#					inside
					var arr_left = tile.getLeftSide().filter(func(item): return item != 5)
					if uniq_items(arr_left) == getRightSide(info_matrix) && uniq_items(side_top) == getBottomSide(info_matrix):
						set_avail_tile(side["neighbor"]["index_top"])
						is_angles_side["top_right_inside"] = true
						if Debug.ISDEBUG:
							print("Bottom Right inside angle")
					else:
						set_tile_default(side["neighbor"]["index_top"])
						is_angles_side["top_right_inside"] = false
						#if Debug.ISDEBUG:
							#print("Bottom Right inside angle disable")
			if corner == "top_top":
				if side["angles"][corner] != null:
					var tile = side["angles"][corner]
					var arr = tile.getBottomSide().filter(func(item): return item != 5)
					if uniq_items(arr) == getTopSide(info_matrix) && uniq_items(side_top) == getBottomSide(info_matrix):
						set_avail_tile(side["neighbor"]["index_top"])
						is_angles_side["top_top"] = true
						if Debug.ISDEBUG:
							print("Middle side check")
					else:
						set_tile_default(side["neighbor"]["index_top"])
						is_angles_side["top_top"] = false
#		3 ANGLES CHECK TOP
		if is_angles_side["top_left_inside"] == true && is_angles_side["top_right_inside"] == true:
			set_avail_tile(side["neighbor"]["index_top"])
			if Debug.ISDEBUG:
				print("3 Angles check")
		
		if is_angles_side["top_right_inside"] == true && is_angles_side["top_top"] == true:
			if uniq_items(side_top) == getBottomSide(info_matrix):
				set_avail_tile(side["neighbor"]["index_top"])
				if Debug.ISDEBUG:
					print("3 Angles check")
			else:
				set_tile_default(side["neighbor"]["index_top"])
		
		if is_angles_side["top_left_inside"] == true && is_angles_side["top_top"] == true:
			if uniq_items(side_top) == getBottomSide(info_matrix):
				set_avail_tile(side["neighbor"]["index_top"])
				if Debug.ISDEBUG:
					print("3 Angles check")
			else:
				set_tile_default(side["neighbor"]["index_top"])
		
		if (is_angles_side["top_left_inside"] == true && is_angles_side["top_right_inside"] == false) || (is_angles_side["top_left_inside"] == false && is_angles_side["top_right_inside"] == true):
			set_tile_default(side["neighbor"]["index_top"])
		
		if (is_angles_side["top_left_inside"] == true && is_angles_side["top_top"] == false) || (is_angles_side["top_left_inside"] == false && is_angles_side["top_top"] == true):
			set_tile_default(side["neighbor"]["index_top"])
		
		if (is_angles_side["top_right_inside"] == true && is_angles_side["top_top"] == false) || (is_angles_side["top_right_inside"] == false && is_angles_side["top_top"] == true):
			set_tile_default(side["neighbor"]["index_top"])
		
#		3 ANGLES BOTTOM CHECK
		if is_angles_side["top_left_outside"] == true && side["neighbor_bottom"]["index_left_bottom"] != null:
			#if side["neighbor_bottom"]["index_top_bottom"] == null:
			var tile_bottom_left = side["neighbor_bottom"]["index_left_bottom"]
			var tile_bottom_side = tile_bottom_left.getRightSide().filter(func(item): return item != 5)
			print(side["neighbor_bottom"]["index_top_bottom"])
				
			if getLeftSide(info_matrix) == uniq_items(tile_bottom_side):
				set_avail_tile(side["neighbor"]["index_left"])
				if Debug.ISDEBUG:
					print("3 Angles check bottom")
			else:
				set_tile_default(side["neighbor"]["index_left"])
			#else:
				#set_tile_default(side["neighbor"]["index_left"])
				#set_tile_default(side["neighbor"]["index_bottom"])
		
		if is_angles_side["top_right_outside"] == true && side["neighbor_bottom"]["index_right_bottom"] != null:
			print(side["neighbor_bottom"]["index_top_bottom"])
			#if side["neighbor_bottom"]["index_top_bottom"] == null:
			var tile_bottom_right = side["neighbor_bottom"]["index_right_bottom"]
			var tile_bottom_side = tile_bottom_right.getLeftSide().filter(func(item): return item != 5)
				
			if getRightSide(info_matrix) == uniq_items(tile_bottom_side):
				set_avail_tile(side["neighbor"]["index_right"])
				if Debug.ISDEBUG:
					print("3 Angles check bottom")
			else:
				set_tile_default(side["neighbor"]["index_right"])
			#else:
				#set_tile_default(side["neighbor"]["index_right"])
				#set_tile_default(side["neighbor"]["index_bottom"])
		
		if is_angles_side["top_left_outside"] == false && side["neighbor_bottom"]["index_left_bottom"] != null:
			set_tile_default(side["neighbor"]["index_left"])
		
		if is_angles_side["top_right_outside"] == false && side["neighbor_bottom"]["index_right_bottom"] != null:
			set_tile_default(side["neighbor"]["index_right"])
		
		#4 ANGLES CHECK
		if side["angles"]["top_left"] != null && side["angles"]["top_right"] != null && side["angles"]["top_top"] != null:
			print("FIND 4 ANGLES TOP")
			if is_angles_side["top_right_inside"] == true && is_angles_side["top_left_inside"] == true && is_angles_side["top_top"] == true:
				if uniq_items(side_top) == getBottomSide(info_matrix):
					set_avail_tile(side["neighbor"]["index_top"])
					#print(side["neighbor"]["index_top"])
					#print( grid_container.get_child(side["neighbor"]["index_top"]) is EmptyMapTile)
					#print(10 * grid_container.columns + 9)
					#set_avail_tile(side["neighbor"]["index_left"])
					#set_avail_tile(side["neighbor"]["index_right"])
					#set_avail_tile(side["neighbor"]["index_bottom"])
					if Debug.ISDEBUG:
						print("4 Angles check")
			else:
				#print("zalupniy")
				#print( grid_container.get_child(side["neighbor"]["index_top"]) is EmptyMapTile)
				#print(10 * grid_container.columns + 9)
				set_tile_default(side["neighbor"]["index_top"])
					#set_tile_default(side["neighbor"]["index_left"])
					#set_tile_default(side["neighbor"]["index_right"])
					#set_tile_default(side["neighbor"]["index_bottom"])
			
		#if side["neighbor_bottom"]["index_top_bottom"] != null && is_angles_side["top_right_outside"] == true && is_angles_side["top_left_outside"] == true:
			#var tile_bottom_top = side["neighbor_bottom"]["index_top_bottom"]
			#var side_bottom_top = tile_bottom_top.getTopSide().filter(func(item): return item != 5)
			#print("4 ANGLES FIND BOTTOM")
			#
			#if uniq_items(side_top) == getBottomSide(info_matrix):
				#set_avail_tile(side["neighbor"]["index_top"])
				#if Debug.ISDEBUG:
					#print("4 Angles check")
			#else:
				#set_tile_default(side["neighbor"]["index_top"])
			#
			#if uniq_items(side_bottom_top) == getBottomSide(info_matrix):
				#set_avail_tile(side["neighbor"]["index_bottom"])
				#if Debug.ISDEBUG:
					#print("4 Angles check")
			#else:
				#set_tile_default(side["neighbor"]["index_bottom"])
		
		#if is_angles_side["top_right_inside"] == true && is_angles_side["top_left_inside"] == true && is_angles_side["top_top"] == true && un

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
		#print("Set avail %s" % [index])
		current_tile.modulate_avail()

func set_tile_default(index):
	var current_tile = grid_container.get_child(index)
	if current_tile is EmptyMapTile:
		#print("Set default %s" % [index])
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

func get_fraction_float(num: float):
	var fraction = num - int(num)
	
	if fraction < 0.5:
		return floor(num)
	else:
		return ceil(num)

func _on_map_hover_tiles_update_tile_rotation(angle: float, side) -> void:
	current_angle = angle
	current_angle_side = side
	get_avalable_set_tile()
