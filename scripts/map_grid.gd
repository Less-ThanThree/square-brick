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
	
	grid_container.remove_child(empty_tile)
	empty_tile.queue_free()

	grid_container.add_child(new_tile)
	grid_container.move_child(new_tile, index)
	
	currentTileRotate = 0.0
	
	#Debug.print_debug_matrix(new_tile.tile_info["top_level"])
	#fill_block_in_matrix(row, col, new_tile.tile_info["top_level"])

	#var zone = find_zones()
	#print_zones(zone)
	#dfsMapMatrix[row][col] = new_tile.tile_info["top_level"]
	
	#find_zones_map()

func set_first_map_tile(row: int, col: int, tile_info):
	var index = row * grid_container.columns + col
	var new_tile = GameTileScene.instantiate()
	var empty_tile = grid_container.get_child(index)
	tile_set.connect(new_tile._on_tile_set)
	#meeple_skip.connect(new_tile._on_meeple_skip)
	#new_tile.connect("meeple_set", _on_meeple_set)
	new_tile.connect("ready", _on_tile_ready.bind(row, col, new_tile))
	new_tile.tile_info = resource_tiles.tile_info_x5[tile_info]
	new_tile.angel = currentTileRotate
	new_tile.is_set = true
	
	grid_container.remove_child(empty_tile)
	empty_tile.queue_free()

	grid_container.add_child(new_tile)
	grid_container.move_child(new_tile, index)

func _on_tile_ready(row, col, node):
	fill_block_in_matrix(row, col, node.get_top_level_matrix())
	
	var zones = find_zones_2()
	print("ZONE MAP\n")
	print("------")
	print(zones)
	print("-----")
	print(finding_complete_buildings(zones))

func skip_meeple_set() -> void:
	Player.update_current_state(Player.STATE.CHOOSE_TILE)
	emit_signal("meeple_skip")
	isCurrentMeepleChoose = false

func _on_map_2_test_new_tile(info) -> void:
	currentTileInfo = info

func _on_map_hover_tiles_is_tile_rotate(angle) -> void:
	currentTileRotate = angle

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
						"Zones": zone
					}
					if zone_type != "Deadend" && zone_type != "Build_corner":
						zones.append(dict)
	return zones

func flood_fill(start, target_type, visited):
	var stack = [start]
	var zone = []
	
	while stack.size() > 0:
		var current = stack.pop_back()
		var x = current.x
		var y = current.y
		
		if x < 0 || y < 0 || x >= MATRIX_SIZE_X2 || y >= MATRIX_SIZE_X2:
			continue
		if visited[y][x] || dfsGlobalMapMatrix[y][x] != target_type:
			continue
		
		var has_adjacent_one = false
		var directions = [
			Vector2(1, 0),  # вправо
			Vector2(-1, 0), # влево
			Vector2(0, 1),  # вниз
			Vector2(0, -1)  # вверх
		]
		for dir in directions_x8:
			var nx = x + dir.x
			var ny = y + dir.y
			if nx >= 0 && ny >= 0 && nx < MATRIX_SIZE_X2 && ny < MATRIX_SIZE_X2:
				if dfsGlobalMapMatrix[ny][nx] == 1:
					has_adjacent_one = true
					break
		
		if !has_adjacent_one && target_type != 1:
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
		
		if neignbor_value == 1:
			continue
		
		if neignbor_value == 5:
			wall_found = true
		elif neignbor_value != 1:
			open_side_found = true
	
	return wall_found && !open_side_found

#func find_zones_map():
	#var state_enum = resource_tiles.TYPES
	#
	#print(dfsMapMatrix)
	#
	#var field_zone = find_connected_zones(state_enum.FIELD)
	#print("Field zones:")
	##print(field_zone)
	#
	#var build_zones = find_connected_zones(state_enum.BUILD)
	#print("City zones:")
	##print(build_zones)
	#for zone in build_zones:
		#find_builds_zone(zone)
	##print(find_builds_zone(build_zones))
	##print(build_zones)
	#
	#var road_zones = find_connected_zones(state_enum.ROAD)
	#print("Road zones:")
	#print(road_zones)
	#Debug.print_debug_matrix(road_zones)
	
	#print(dfsMapMatrix)

#func find_builds_zone(zone):
	#var valid_zone = true
	#for pos in zone:
		#if !check_building(pos.x, pos.y):
			#valid_zone = false
			#break
	#if valid_zone:
		#print("Valid zone")
		#for pos in zone:
			#print("Pos", pos)
	##for zone in zones:
		##for pos in zone:
			##if !check_building(pos.x, pos.y):
				##print("Invalide zone building at", pos)

# Проверяем тип
#func is_of_type(x, y, target_type):
	#if x < 0 || x >= MATRIX_SIZE || y < 0 || y >= MATRIX_SIZE:
		#return false
	#var block = dfsMapMatrix[x][y]
	#if block.size() == 0:
		#return false
	#
	#for row in block:
		#for val in row:
			#if val == target_type:
				#return true
	#return false
#
#func is_type_submatrix(x, y, target_type):
	#var block = dfsMapMatrix[x][y]
	#if block.size() == 0:
		#return false
	#for i in range(3):
		#for j in range(3):
			#if block[i][j] == target_type:
				#return true
	#return false
#
#func find_connected_zones(target_type):
	#var visited = []
	#for i in range(MATRIX_SIZE):
		#var row = []
		#for j in range(MATRIX_SIZE):
			#row.append(false)
		#visited.append(row)
	#
	#var zones = []
	#for i in range(MATRIX_SIZE):
		#for j in range(MATRIX_SIZE):
			#if !visited[i][j] && is_type_submatrix(i, j, target_type):
				#var zone = []
				#dfs(i, j, target_type, visited, zone)
				#if zone.size() > 0:
					#zones.append(zone)
	#
	#return zones
#
#func dfs(x, y, target_type, visited, zone):
	#if x < 0 || x >= col || y < 0 || y >= row || visited[x][y] || !is_type_submatrix(x, y, target_type):
		#return
	#
	#visited[x][y] = true
	#zone.append(Vector2(x, y))
	#
	#dfs(x - 1, y, target_type, visited, zone)
	#dfs(x + 1, y, target_type, visited, zone)
	#dfs(x, y - 1, target_type, visited, zone)
	#dfs(x, y + 1, target_type, visited, zone)
#
#func block_has_valid_neighbors_build(block):
	#var state_enum = resource_tiles.TYPES
	#
	#for row in block:
		#for value in row:
			#if value == state_enum.FIELD || value == state_enum.ROAD || value == state_enum.BUILD_CORNER:
				#return true
	#return false
#
#func check_building(x, y):
	#var valid = true
	#var directions = [
		#Vector2(-1, 0),
		#Vector2(1, 0),
		#Vector2(0, -1),
		#Vector2(0, 1),
	#]
	#
	#for direction in directions:
		#var new_x = x + direction.x
		#var new_y = y + direction.y
		#if new_x < 0 || new_x >= MATRIX_SIZE || new_y < 0 || new_y >= MATRIX_SIZE:
			#valid = false
			#break
		#
		#var block = dfsMapMatrix[new_x][new_y]
		#if block.size() == 0 || !block_has_valid_neighbors_build(block):
			#valid = false
			#break
	#return valid

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

#func find_zones():
	#var visited = []
	#for i in range(MATRIX_SIZE_X2):
		#visited.append([])
		#for j in range(MATRIX_SIZE_X2):
			#visited[i].append(false)
	#
	#var zones = []
	#
	#for i in range(MATRIX_SIZE_X2):
		#for j in range(MATRIX_SIZE_X2):
			#if visited[i][j] == false && dfsGlobalMapMatrix[i][j] != -1:
				#var zone = []
				#var type_of_zone = dfsGlobalMapMatrix[i][j]
				#dfs_2(i, j, visited, zone, type_of_zone)
				#if zone.size() > 0:
					##zones.append(zone)
					#var zone_type
					#match type_of_zone:
						#0:
							#zone_type = "Field"
						#1:
							#zone_type = "Build"
						#2:
							#zone_type = "Road"
						#3:
							#zone_type = "Deadend"
						#5:
							#zone_type = "Build_corner"
					#var dict = {
						#"Zone type": zone_type,
						#"Zones": zone
					#}
					#zones.append(dict)
	#return zones

#func is_edge(x, y):
	#for dir in directions_x8:
		#var nx = x + dir.x
		#var ny = y + dir.y
		#if nx < 0 || nx > MATRIX_SIZE_X2 || ny < 0 || ny >= MATRIX_SIZE_X2:
			#return true
		#if dfsGlobalMapMatrix[nx][ny] != 1 && dfsGlobalMapMatrix[nx][ny] != 5:
			#return true
	#return false

#func is_building_complete(building_zones):
	#for coord in building_zones:
		#var x = coord[0]
		#var y = coord[1]
		#if is_edge(x, y):
			#for dir in directions_x8:
				#var nx = x + dir.x
				#var ny = y + dir.y
				#if nx < 0 || nx >= MATRIX_SIZE_X2 || ny < 0 || ny >= MATRIX_SIZE_X2:
					#return false
				#var neighbor_value = dfsGlobalMapMatrix[nx][ny]
				#if neighbor_value != 0 || neighbor_value != 2 || neighbor_value != 5:
					#return false
	#return true


#
#func dfs(x, y, visited, zone, type_of_zone):
	#var directions = [
		#Vector2(0, 1),  # вниз
		#Vector2(0, -1),  # вверх
		#Vector2(1, 0),  # вправо
		#Vector2(-1, 0)   # влево
	#]	
	#
	#if x < 0 || x >= MATRIX_SIZE_X2 || y < 0 || y >= MATRIX_SIZE_X2:
		#return
	#if visited[x][y] || dfsGlobalMapMatrix[x][y] != type_of_zone || dfsGlobalMapMatrix[x][y] == -1:
		#return
	#
	#visited[x][y] = true
	#zone.append(Vector2(x, y))
	#
	#for dir in directions:
		#var nx = x + dir.x
		#var ny = y + dir.y
		#dfs(nx, ny, visited, zone, type_of_zone)
#
#func dfs_2(x, y, visited, zone, type_of_zone):
	#var directions = [
		#Vector2(0, 1),  # вниз
		#Vector2(0, -1),  # вверх
		#Vector2(1, 0),  # вправо
		#Vector2(-1, 0)   # влево
	#]	
	#
	#if x < 0 || x >= MATRIX_SIZE_X2 || y < 0 || y >= MATRIX_SIZE_X2:
		#return
	#if visited[x][y]:
		#return
	#if dfsGlobalMapMatrix[x][y] != type_of_zone:
		#return
	#
	#var has_adjacent_same_zone = false
	#for dir in directions:
		#var nx = x + dir.x
		#var ny = y + dir.y
		#if nx >= 0 && nx < MATRIX_SIZE_X2 && ny >= 0 && ny < MATRIX_SIZE_X2:
			#if dfsGlobalMapMatrix[nx][ny] == 1:
				#has_adjacent_same_zone = true
				#break
	#
	#if !has_adjacent_same_zone:
		#return false
	#
	#visited[x][y] = true
	#zone.append(Vector2(x, y))
	#
	#for dir in directions:
		#var nx = x + dir.x
		#var ny = y + dir.y
		#dfs_2(nx, ny, visited, zone, type_of_zone)
#
#func dfs_build(curr_x, curr_y, visited, zone):	
	#if curr_x < 0 or curr_x >= MATRIX_SIZE_X2 or curr_y < 0 or curr_y >= MATRIX_SIZE_X2:
		#return
	#
	#if visited.has([curr_x, curr_y]):
			#return
	#
	#visited.append([curr_x, curr_y])
	#
	#if dfsGlobalMapMatrix[curr_x][curr_y] != 1:
		#return
	#
	#zone.append([curr_x, curr_y])
	#
	#for dir in directions_x8:
		#var new_x = curr_x + dir.x
		#var new_y = curr_y + dir.y
		#dfs_build(new_x, new_y, visited, zone)
#func find_building_zone(x, y):
	#var visited = []
	#var zone = []
	#var directions = [
		#Vector2(-1, -1),
		#Vector2(0, -1), 
		#Vector2(1, -1),
		#Vector2(-1, 0), 
		#Vector2(1, 0),
		#Vector2(-1, 1), 
		#Vector2(0, 1), 
		#Vector2(1, 1)
		#]
		#
	#var dfs_bus = func(curr_x, curr_y):
		#if curr_x < 0 || curr_x >= MATRIX_SIZE_X2 || curr_y < 0 || curr_y >= MATRIX_SIZE_X2:
			#return
		#
		#if visited.has([curr_x, curr_y]):
			#return
		#
		#visited.append([curr_x, curr_y])
		#
		#if dfsGlobalMapMatrix[curr_x][curr_y] != 1:
			#return
		#
		#zone.append([curr_x, curr_y])
		#
		#for dir in directions:
			#var new_x = curr_x + dir.x
			#var new_y = curr_y + dir.y
			#dfs_bus.call(new_x, new_y)
	#
	#dfs_bus(x, y)
	#
	#for cell in zone:
		#var cx = cell[0]
		#var cy = cell[1]
		#
		#var is_valid = true
		#for dir in directions:
			#var new_x = cx + dir.x
			#var new_y = cy + dir.y
			#
			#if new_x < 0 || new_x >= MATRIX_SIZE_X2 || new_y < 0 || new_y >= MATRIX_SIZE_X2:
				#continue
		#
			#var neighbor_value = dfsGlobalMapMatrix[new_x][new_y]

#func find_building_zone(x, y):
	#var visited = []
	#var zone = []
	#
	#dfs_build(x, y, visited, zone)
	#
	#for cell in zone:
		#var cx = cell[0]
		#var cy = cell[1]
		#
		#var is_valid = true
		#for dir in directions:
			#var new_x = cx + dir.x
			#var new_y = cy + dir.y
			#
			#if new_x < 0 or new_x >= MATRIX_SIZE_X2 or new_y < 0 or new_y >= MATRIX_SIZE_X2:
				#continue
			#
			#var neighbor_value = dfsGlobalMapMatrix[new_x][new_y]
			#if neighbor_value == -1:
				#is_valid = false
				#break
			#if neighbor_value != 0 && neighbor_value != 2 && neighbor_value != 5:
				#is_valid = false
				#break
		#
		#if !is_valid:
			#zone.erase(cell)
	#
	#return zone
