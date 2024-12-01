extends Control

@export var tile_info: Dictionary
@export var is_set: bool
@export var angel: float = 0.0

@onready var tile_sprite = $Tile_img
@onready var meeple_grid = $MeepleGrid
@onready var panel_1 = $MeepleGrid/Panel
@onready var panel_2 = $MeepleGrid/Panel2
@onready var panel_3 = $MeepleGrid/Panel3
@onready var panel_4 = $MeepleGrid/Panel4
@onready var panel_5 = $MeepleGrid/Panel5
@onready var panel_6 = $MeepleGrid/Panel6
@onready var panel_7 = $MeepleGrid/Panel7
@onready var panel_8 = $MeepleGrid/Panel8
@onready var panel_9 = $MeepleGrid/Panel9
@onready var meeple = load("res://assets/meeple.png")

signal is_rotate

var matrix_top_level: Array
var matrix_down_level: Dictionary
var is_rotated = false
var local_angle
var key_matrix_down = []
var zones = []
var rotated_count = 1

func _ready() -> void:
	tile_sprite.rotation_degrees = angel
	self.rotation_degrees = angel
	tile_sprite.texture = tile_info["tile_src"]
	matrix_top_level = tile_info["top_level"]
	matrix_down_level = tile_info["down_level"]
	key_matrix_down = create_2darray_key_matrix()

func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("rotate_right") && !is_rotated:
		#rotate_clockwise()
	if Input.is_action_just_pressed("rotate") && !is_rotated && !is_set:
		rotate_counterclockwise()

func getAngle() -> int:
	return local_angle

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
	rotate_down_level_clockwise()
	rotate_transform_clockwise()
	if (Debug.ISDEBUG):
		Debug.print_debug_matrix(matrix_top_level, "Rotate tile top level matrix clockwise")
		Debug.print_debug_matrix(key_matrix_down, "Rotate tile down level matrix clockwise")
		print(matrix_down_level)

func rotate_down_level_clockwise() -> void:
	for block in matrix_down_level:
		var rotated = []
		var mt = matrix_down_level[block]
		for col in range(3):
			var new_row = []
			for row in range(2, -1, -1):
				new_row.append(mt[row][col])
			rotated.append(new_row)
		matrix_down_level[block] = rotated
	rotate_down_level_dictionary_keys_clockwise()

func rotate_down_level_counterclockwise() -> void:	
	for block in matrix_down_level:
		var rotated = []
		var mt = matrix_down_level[block]
		for col in range(2, -1, -1):
			var new_row = []
			for row in range(3):
				new_row.append(mt[row][col])
			rotated.append(new_row)
		matrix_down_level[block] = rotated
	rotate_down_level_dictionary_keys_counterclockwise()
		#matrix_down_level[block] = rotated
		#if (Debug.ISDEBUG):
			#print(matrix_down_level)
			#Debug.print_debug_matrix(matrix_down_level[block], "Rotate tile matrix down level %s counterclockwise" % block)

func create_2darray_key_matrix() -> Array:
	var key_matrix = []
	for block in matrix_down_level:
		key_matrix.append(block)
	var key_matrix_ar = []
	var i = 0
	for row in range(3):
		var new_row = []
		for col in range(3):
			new_row.append(key_matrix[i])
			i += 1
		key_matrix_ar.append(new_row)
	return key_matrix_ar

func rotate_down_level_dictionary_keys_clockwise() -> void:
	var rotated_keys = []
	for i in range(3):
		rotated_keys.append([key_matrix_down[2][i], key_matrix_down[1][i], key_matrix_down[0][i]])
	
	#for row in rotated_keys:
		#row.reverse()
	#for col in range(3):
		#var new_row = []
		#for row in range(2, -1, -1):
			#new_row.append(key_matrix_down[row][col])
		#rotated_keys.append(new_row)
	
	var rotated_dict = {}
	for i in range(3):
		for j in range(3):
			var old_key = key_matrix_down[i][j]
			var new_key = rotated_keys[i][j]
			rotated_dict[new_key] = matrix_down_level[old_key]
	matrix_down_level = rotated_dict
	key_matrix_down = rotated_keys

func rotate_down_level_dictionary_keys_counterclockwise() -> void:
	var rotated_keys = []
	#for col in range(2, -1, -1):
		#var new_row = []
		#for row in range(3):
			#new_row.append(key_matrix_down[row][col])
		#rotated_keys.append(new_row)
	for i in range(3):
		rotated_keys.append([key_matrix_down[0][i], key_matrix_down[1][i], key_matrix_down[2][i]])
	
	for row in rotated_keys:
		row.reverse()
	
	var rotated_dict = {}
	for i in range(3):
		for j in range(3):
			var old_key = key_matrix_down[i][j]
			var new_key = rotated_keys[i][j]
			rotated_dict[new_key] = matrix_down_level[old_key]
	matrix_down_level = rotated_dict
	key_matrix_down = rotated_keys

func rotate_counterclockwise() -> void:
	var rotated = []
	for col in range(2, -1, -1):
		var new_row = []
		for row in range(3):
			new_row.append(matrix_top_level[row][col])
		rotated.append(new_row)
	matrix_top_level = rotated
	rotate_down_level_counterclockwise()
	rotate_transform_counterclockwise()
	if rotated_count == 4:
		rotated_count = 1
	rotated_count += 1
	print(rotated_count)
	if (Debug.ISDEBUG):
		Debug.print_debug_matrix(matrix_top_level, "Rotate tile top level matrix counterclockwise")
		Debug.print_debug_matrix(key_matrix_down, "Rotate tile down level matrix counterclockwise")
		print(matrix_down_level)

func rotate_transform_clockwise() -> void:
	var tween = create_tween()
	var target_rot = tile_sprite.rotation_degrees + 90
	is_rotated = true
	
	tween.tween_property(tile_sprite, "rotation_degrees", target_rot, 0.15)
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.play()
	tween.finished.connect(_on_finish_rotate)

func rotate_transform_counterclockwise() -> void:
	var tween = create_tween()
	var target_rot = tile_sprite.rotation_degrees - 90
	is_rotated = true
	
	tween.tween_property(tile_sprite, "rotation_degrees", target_rot, 0.15)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.play()
	tween.finished.connect(_on_finish_rotate)

func _on_finish_rotate() -> void:
	emit_signal("is_rotate", tile_sprite.rotation_degrees)
	is_rotated = false

func modulate_tween_meeple(panel: Panel, color: Color) -> void:
	var tween = create_tween()
	
	tween.tween_property(panel, "self_modulate", color, 0.2)
	tween.set_ease(Tween.EASE_IN)
	tween.play()

func find_zones():
	var debug = []
	var visited = []
	for y in range(3):
		visited.append([])
		for x in range(3):
			visited[y].append(false)
	
	for y in range(3):
		for x in range(3):
			if !visited[x][y]:
				var zone = flood_fill(Vector2(x, y), matrix_top_level[y][x], visited)
				if zone.size() > 0:
					#zones.append(zone)
					var zone_type
					match matrix_top_level[y][x]:
						0:
							zone_type = "Field"
						1:
							zone_type = "Build"
						2:
							zone_type = "Road"
						3:
							zone_type = "Deadend"
					var dict = {
						"Zone type": zone_type,
						"Zones": zone
					}
					zones.append(dict)
	print("Zones finds ", zones)

func flood_fill(start, target_type, visited):
	var stack = [start]
	var zone = []
	
	while stack.size() > 0:
		var current = stack.pop_back()
		var x = current.x
		var y = current.y
		
		if x < 0 || y < 0 || x >= 3 || y >= 3:
			continue
		if visited[y][x] || matrix_top_level[y][x] != target_type:
			continue
		
		visited[y][x] = true
		zone.append(current)
		
		stack.append(Vector2(x + 1, y))
		stack.append(Vector2(x - 1, y))
		stack.append(Vector2(x, y + 1))
		stack.append(Vector2(x, y - 1))
	
	return zone

func get_center_meeple(points: Array) -> Vector2:
	var sum_x = 0.0
	var sum_y = 0.0
	var count = points.size()
	var center
	
	for point in points:
		sum_x += point.x
		sum_y += point.y
	
	center = Vector2(sum_x / count, sum_y / count)
	return Vector2(round(center.x), round(center.y))

#func get_dominante_axis(points: Array) -> Vector2:
	#var count_x = {}
	#var count_y = {}
	#
	#for point in points:
		#var x = point.x
		#var y = point.y
		#
		#count_x[x] = count_x.get(x, 0) + 1
		#count_y[y] = count_y.get(y, 0) + 1
	#
	#var max_x = count_x.values().max()
	#var max_y = count_y.values().max()
#
	#if max_x >= max_y:
		#var sum_x = 0
		#for point in points:
			#sum_x += point.x
		#var center_x = sum_x / points.size()
		#return Vector2(round(center_x), 0)
		#

func get_array_center(points: Array) -> Vector2:
	var center_index = round(points.size() / 2)
	return points[center_index]

func _on_tile_set():
	#if is_set:
	find_zones()
	var meeple_center = []
	for zone in zones:
		meeple_center.append(get_array_center(zone["Zones"]))
	
	print(meeple_center)
	
	for meeple in meeple_center:
		var index = meeple.y * meeple_grid.columns + meeple.x
		#if rotated_count == 1:
			#
		#if rotated_count == 2:
			#index = meeple.x * meeple_grid.columns + meeple.y
		#elif rotated_count
		#else:
			#index = meeple.y * meeple_grid.columns + meeple.x
		set_avaliable_grid_meeple(index)

func set_avaliable_grid_meeple(index: int):
	var tile_meeple = meeple_grid.get_child(index)
	var tile_texture = tile_meeple.get_node("TextureRect")
	tile_texture.texture = meeple
	tile_texture.self_modulate = Color(1, 1, 1, 0.5)

func _on_panel_mouse_entered() -> void:
	modulate_tween_meeple(panel_1, Color(1, 1, 1, 1))

func _on_panel_mouse_exited() -> void:
	modulate_tween_meeple(panel_1, Color(1, 1, 1, 0))

func _on_panel_2_mouse_entered() -> void:
	modulate_tween_meeple(panel_2, Color(1, 1, 1, 1))

func _on_panel_2_mouse_exited() -> void:
	modulate_tween_meeple(panel_2, Color(1, 1, 1, 0))

func _on_panel_3_mouse_entered() -> void:
	modulate_tween_meeple(panel_3, Color(1, 1, 1, 1))

func _on_panel_3_mouse_exited() -> void:
	modulate_tween_meeple(panel_3, Color(1, 1, 1, 0))

func _on_panel_4_mouse_entered() -> void:
	modulate_tween_meeple(panel_4, Color(1, 1, 1, 1))

func _on_panel_4_mouse_exited() -> void:
	modulate_tween_meeple(panel_4, Color(1, 1, 1, 0))

func _on_panel_5_mouse_entered() -> void:
	modulate_tween_meeple(panel_5, Color(1, 1, 1, 1))

func _on_panel_5_mouse_exited() -> void:
	modulate_tween_meeple(panel_5, Color(1, 1, 1, 0))

func _on_panel_6_mouse_entered() -> void:
	modulate_tween_meeple(panel_6, Color(1, 1, 1, 1))

func _on_panel_6_mouse_exited() -> void:
	modulate_tween_meeple(panel_6, Color(1, 1, 1, 0))

func _on_panel_7_mouse_entered() -> void:
	modulate_tween_meeple(panel_7, Color(1, 1, 1, 1))

func _on_panel_7_mouse_exited() -> void:
	modulate_tween_meeple(panel_7, Color(1, 1, 1, 0))

func _on_panel_8_mouse_entered() -> void:
	modulate_tween_meeple(panel_8, Color(1, 1, 1, 1))

func _on_panel_8_mouse_exited() -> void:
	modulate_tween_meeple(panel_8, Color(1, 1, 1, 0))

func _on_panel_9_mouse_entered() -> void:
	modulate_tween_meeple(panel_9, Color(1, 1, 1, 1))
	
func _on_panel_9_mouse_exited() -> void:
	modulate_tween_meeple(panel_9, Color(1, 1, 1, 0))
