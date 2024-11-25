extends Control

@export var tile_info: Dictionary

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

var matrix_top_level: Array
var matrix_down_level: Dictionary
var angle = 0
var is_rotated = false

func _ready() -> void:
	var matrix = Basis()
	tile_sprite.texture = tile_info["tile_src"]
	matrix_top_level = tile_info["top_level"]
	matrix_down_level = tile_info["down_level"]
	Debug.print_debug_matrix(matrix_top_level, "Default matrix tile")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("rotate_right") && !is_rotated:
		rotate_clockwise()
	if Input.is_action_just_pressed("rotate_left") && !is_rotated:
		rotate_counterclockwise()

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
	rotate_transform_clockwise()
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
	rotate_transform_counterclockwise()
	if (Debug.ISDEBUG):
		Debug.print_debug_matrix(matrix_top_level, "Rotate tile matrix counterclockwise")

func rotate_transform_clockwise() -> void:
	var tween = create_tween()
	var target_rot = self.rotation_degrees + 90
	is_rotated = true
	
	tween.tween_property(self, "rotation_degrees", target_rot, 0.3)
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.play()
	tween.finished.connect(_on_finish_rotate)

func rotate_transform_counterclockwise() -> void:
	var tween = create_tween()
	var target_rot = self.rotation_degrees - 90
	is_rotated = true
	
	tween.tween_property(self, "rotation_degrees", target_rot, 0.3)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.play()
	tween.finished.connect(_on_finish_rotate)

func _on_finish_rotate() -> void:
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
