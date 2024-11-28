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

signal is_rotate

var matrix_top_level: Array
var matrix_down_level: Dictionary
var is_rotated = false
var local_angle
var key_matrix_down = []

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
	
	tween.tween_property(panel, "modulate", color, 0.2)
	tween.set_ease(Tween.EASE_IN)
	tween.play()

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
