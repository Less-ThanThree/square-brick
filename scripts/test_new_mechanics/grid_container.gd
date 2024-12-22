extends GridContainer

@export var row: int
@export var col: int
@export var grid_container : GridContainer

@onready var EmptyTileScene = preload("res://components/empty_map_tile.tscn")

var tile_1 = preload("res://components/tile_test/tile_1_test.tscn")
var tile_2 = preload("res://components/tile_test/tile_2_test.tscn")
var tile_6 = preload("res://components/tile_test/tile_6.tscn")

signal tile_hovered(index: int)
signal tile_exited(index: int)
signal tile_set
signal meeple_skip

var current_tile_name
var current_angle = 0.0
var current_angle_side = "top"
var find_zones = []
var current_zone = {
	"row": 0,
	"col": 0,
	"index": 0,
	"zone": null,
}

enum TYPES {
	NULL,
	FIELD, 
	BUILD,
	ROAD,
	DEADEND,
	CHURCH,
	BUILD_CORNER,
}

var tile_map = {
	"tile_1": tile_1,
	"tile_2": tile_2,
	"tile_6": tile_6,
}

func _ready() -> void:
	create_empty_map()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("skip") && Player.get_current_state() == Player.STATE.CHOOSE_MIPLE:
		emit_signal("meeple_skip")

func create_empty_map():
	var block_size = Vector2(256, 256)  # Размер блоков 3x3
	grid_container.columns = col
	
	# Генерация карты
	for row in range(col):
		for col in range(col):
			_create_empty_tile(row, col)

func _create_empty_tile(row: int, col: int):
	var empty_tile_instance = EmptyTileScene.instantiate()
	var index = row * grid_container.columns + col
	empty_tile_instance.custom_minimum_size = Vector2(256,256)
	empty_tile_instance.connect("tile_pressed", _on_empty_tile_click.bind(row,col,index))
	empty_tile_instance.connect("tile_mouse_entered", _on_empty_tile_hovered.bind(index))
	empty_tile_instance.connect("tile_mouse_exited", _on_empty_tile_exited.bind(index))
	grid_container.add_child(empty_tile_instance)

func _on_empty_tile_click(row: int, col: int, index: int):
	if Player.get_current_state() == Player.STATE.CHOOSE_TILE:
		print("Clicked on empty tile on Row: %s, Col: %s, Index: %s" % [row, col, index])
		var empty_tile = grid_container.get_child(index)
		var new_tile = get_tile_by_name(current_tile_name).instantiate()
		tile_set.connect(new_tile._on_tile_set)
		meeple_skip.connect(new_tile._on_tile_meeple_skip)
		new_tile.connect("area_compare", _on_tile_compare.bind(index, row, col))
		new_tile.angle = current_angle
		new_tile.side = current_angle_side
		#new_tile.is_current = true
		
		grid_container.remove_child(empty_tile)
		empty_tile.queue_free()

		grid_container.add_child(new_tile)
		grid_container.move_child(new_tile, index)
		
		emit_signal("tile_set")
		find_zone(index, row, col)

func set_first_tile(row: int, col: int):
	var index = row * grid_container.columns + col
	var empty_tile = grid_container.get_child(index)
	var new_tile = get_tile_by_name(current_tile_name).instantiate()
	#tile_set.connect(new_tile._on_tile_set)
	#meeple_skip.connect(new_tile._on_tile_meeple_skip)
	new_tile.connect("area_compare", _on_tile_compare.bind(index, row, col))
	new_tile.angle = current_angle
	new_tile.side = current_angle_side
	new_tile.is_set = true
	
	grid_container.remove_child(empty_tile)
	empty_tile.queue_free()

	grid_container.add_child(new_tile)
	grid_container.move_child(new_tile, index)
	emit_signal("tile_set")
	
func get_tile_by_name(scene_name: String):
	return tile_map.get(scene_name, null)

func get_current_tile_name():
	var tile = get_tile_by_name(current_tile_name)
	return tile

func _on_empty_tile_hovered(index: int):
	emit_signal("tile_hovered", index)

func _on_empty_tile_exited(index: int):
	emit_signal("tile_exited", index)

func _on_map_3_new_tile_test_new_tile(tile_name: String) -> void:
	current_tile_name = tile_name

func _on_map_hover_update_tile_rotation(angle: float, side: String) -> void:
	current_angle = angle
	current_angle_side = side

func _on_tile_compare(sides: Dictionary, zone: String, index, row, col):
	current_zone = {
		"row": row,
		"col": col,
		"index": index,
		"zone": zone,
	}
	#find_zone(index, row, col, zone)
	#print(zone)
	#pass
	#print(index)
	#print(sides)
	#print(row, col)

func find_zone(index, row, col):
	var zone = "build"
	var tile_current = grid_container.get_child(index)
	var sides = tile_current.get_sides()
	var zone_type = get_current_type_zone("build")
	var directions = {
		"left": Vector2(row, col - 1),
		"right": Vector2(row, col + 1),
		"top": Vector2(row - 1, col),
		"bottom": Vector2(row + 1, col) 
	}
	
	for direction in directions:
		var neigb_tile_index = directions[direction].x * grid_container.columns + directions[direction].y
		var neigb_tile = grid_container.get_child(neigb_tile_index)
		if neigb_tile is TileObject:
			if direction == "top":
				if zone_type in sides["top_inside"] && zone_type in neigb_tile.get_side_tile("bottom_inside"):
					add_to_zone(index, neigb_tile_index, zone)
					print("Found top tile")
			if direction == "left":
				if zone_type in sides["left_inside"] && zone_type in neigb_tile.get_side_tile("right_inside"):
					add_to_zone(index, neigb_tile_index, zone)
					print("Found left tile")
			if direction == "bottom":
				if zone_type in sides["bottom_inside"] && zone_type in neigb_tile.get_side_tile("top_inside"):
					add_to_zone(index, neigb_tile_index, zone)
					print("Found bottom tile")
			if direction == "right":
				if zone_type in sides["right_inside"] && zone_type in neigb_tile.get_side_tile("left_inside"):
					add_to_zone(index, neigb_tile_index, zone)
					print("Found right tile")
	print(find_zones)
		 #= direction.x * grid_container.columns + direction.y
		#var tile_neigb = grid_container.get_child(neigb_tile_index)
		#if tile_neigb is TileObject:
	
	#while to_check.size() > 0:
		#var current_tile = to_check.pop_back()
		#
		#if current_tile in visited:
			#continue
		#
		#visited.append(current_tile)
		#
		#for neigbor in get_neigbour(current_direction):
			#to_check.append(neigbor)

func add_to_zone(index, index_neigb, zone_name):
	var zone_name_index = "zone_" + str(index)
	var zone_name_index_neigb = "zone_" + str(index_neigb)
	var zone_area = {
		"indexes": [],
		"zone_name": zone_name_index,
		"zone_type": zone_name,
		"is_complete": false,
		"is_meeple": false,	
	}
	
	if find_zones.size() == 0:
		zone_area["indexes"].append(index)
		find_zones.append(zone_area)
	
	for zone in find_zones:
		if zone["zone_name"] == zone_name_index:
			if index_neigb not in zone["indexes"]:
				zone["indexes"].append(index_neigb)
			break
		else:
			zone_area["indexes"].append(index)
			zone_area["indexes"].append(index_neigb)
		find_zones.append(zone_area)
		break
	
	#for zone in find_zones:
		
	#for zone in find_zones:
		

func get_neigbour(directions) -> Array:
	var neigbours = []
	
	#for direction in directions:
		#var neigb_tile_index = direction.x * grid_container.columns + direction.y
		#var tile_neigb = grid_container.get_child(neigb_tile_index)
		#if tile_neigb is TileObject:
			#print("Found")
			#neigbours.append(tile_neigb)
	return neigbours

func get_current_type_zone(zone):
	match zone:
		"build":
			return TYPES.BUILD

func _on_map_3_new_tile_test_first_tile(tile_name: String) -> void:
	current_tile_name = tile_name
	set_first_tile(10, 10)
