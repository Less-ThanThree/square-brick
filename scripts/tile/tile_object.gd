extends Node

class_name TileObject

enum TYPES {
	NULL,
	FIELD, 
	BUILD,
	ROAD,
	DEADEND,
	CHURCH,
	BUILD_CORNER,
}

@export var tile_resource: Resource

#@export var left_side_inside: Array[TYPES]= []
#@export var left_side_outside:Array[TYPES]= []
#@export var top_side_inside: Array[TYPES]= []
#@export var top_side_outside: Array[TYPES]= []
#@export var right_side_inside: Array[TYPES]= []
#@export var right_side_outside: Array[TYPES]= []
#@export var bottom_side_inside: Array[TYPES]= []
#@export var bottom_side_outside: Array[TYPES]= []

#@export var tile_info: Dictionary
@export var is_set: bool = false
@export var is_meeple: bool = false
@export var angle: float = 0.0
@export var side: String = "top"
#@export var is_current: bool = false

@onready var base = $Base
@onready var debug_center = $DebugCenter

signal show_meeple_advice
signal meeple_set
signal meeple_skip
signal rot_left
signal rot_right
signal area_compare(sides: Dictionary, zone: String)
signal is_rotate

var is_animation_rotate = false
var matrix_top_level: Array
var is_rotated = false
var local_angle = 0
var key_matrix_down = []
var zones = []
var rotated_count = 1

func _ready() -> void:
	set_debug_settings()
	matrix_top_level = tile_resource.top_level
	set_matrix_rotate()
	base.rotation_degrees = angle

func _input(event: InputEvent) -> void:
	if Player.get_current_state() == Player.STATE.CHOOSE_TILE:
		if Input.is_action_just_pressed("rotate_left") && !is_animation_rotate && !is_set:
			rotate_left()
		if Input.is_action_just_pressed("rotate_right") && !is_animation_rotate && !is_set:
			rotate_right()

func rotate_right():
	animate_rotation(90)
	rotate_clockwise()
	emit_signal("rot_right")

func rotate_left():
	animate_rotation(-90)
	rotate_counterclockwise()
	emit_signal("rot_left")

func getAngle() -> int:
	return local_angle

func getTopSide() -> Array:
	var array = [
		matrix_top_level[0][0], 
		matrix_top_level[0][1],
		matrix_top_level[0][2],
		matrix_top_level[0][3],
		matrix_top_level[0][4],
	]
	return array

func getLeftSide() -> Array:
	var result = []
	for i in range(matrix_top_level.size()):
		result.append(matrix_top_level[i][0])
	return result

func getBottomSide() -> Array:
	var array = [
		matrix_top_level[4][0], 
		matrix_top_level[4][1],
		matrix_top_level[4][2],
		matrix_top_level[4][3],
		matrix_top_level[4][4],
	]
	return array

func getRightSide() -> Array:
	var result = []
	for i in range(matrix_top_level.size()):
		result.append(matrix_top_level[i][-1])
	return result

func rotate_clockwise() -> void:
	var rotated = []
	for col in range(5):
		var new_row = []
		for row in range(4, -1, -1):
			new_row.append(matrix_top_level[row][col])
		rotated.append(new_row)
	matrix_top_level = rotated
	if (Debug.ISDEBUG):
		Debug.print_debug_matrix(matrix_top_level, "Rotate tile top level matrix clockwise")

func rotate_counterclockwise() -> void:
	var rotated = []
	for col in range(4, -1, -1):
		var new_row = []
		for row in range(5):
			new_row.append(matrix_top_level[row][col])
		rotated.append(new_row)
	matrix_top_level = rotated
	if (Debug.ISDEBUG):
		Debug.print_debug_matrix(matrix_top_level, "Rotate tile top level matrix counterclockwise")

func animate_rotation(rot: float):
	var tween = create_tween()
	var target_rot = deg_to_rad(rot) + base.rotation
	is_animation_rotate = true
	
	tween.tween_property(base, "rotation", target_rot, 0.15)
	tween.finished.connect(_on_rotate_end)
	
func _on_rotate_end():
	is_animation_rotate = false

func _on_tile_set():
	#sides = get_side_on_local_angle()
	Player.update_current_state(Player.STATE.CHOOSE_MIPLE)
	emit_signal("show_meeple_advice")

func _on_tile_meeple_skip():
	emit_signal("meeple_skip")

func get_tile_resource():
	return tile_resource

func set_debug_settings():
	if Debug.ISDEBUG:
		debug_center.visible = true
	else:
		debug_center.visible = false

func set_matrix_rotate():
	match side:
		"right":
			rotate_clockwise()
		"left":
			rotate_counterclockwise()
		"bottom":
			rotate_clockwise()
			rotate_clockwise()

func _on_area_entered(zone: String):
	#var side = get_side_on_local_angle()
	emit_signal("area_compare", side, zone)
		#print(left_side_isnide)
		#print("BUILD", area.name)

func get_top_level_matrix() -> Array:
	return matrix_top_level

#func get_side_on_local_angle() -> Dictionary:
	#match side:
		#"top":
			#sides = {
				#"top_inside": top_side_inside,
				#"top_outside": top_side_outside,
				#"right_inside": right_side_inside,
				#"right_outside": right_side_outside,
				#"bottom_inside": bottom_side_inside,
				#"bottom_outside": bottom_side_outside,
				#"left_inside": left_side_inside,
				#"left_outside": left_side_outside,
			#}
		#"right":
			#sides = {
				#"top_inside": left_side_inside,
				#"top_outside": left_side_outside,
				#"right_inside": top_side_inside,
				#"right_outside": top_side_outside,
				#"bottom_inside": right_side_inside,
				#"bottom_outside": right_side_outside,
				#"left_inside": bottom_side_inside,
				#"left_outside": bottom_side_outside,
			#}
		#"bottom":
			#sides = {
				#"top_inside": bottom_side_inside,
				#"top_outside": bottom_side_outside,
				#"right_inside": left_side_inside,
				#"right_outside": left_side_outside,
				#"bottom_inside": top_side_inside,
				#"bottom_outside": top_side_outside,
				#"left_inside": right_side_inside,
				#"left_outside": right_side_outside,
			#}
		#"left":
			#sides = {
				#"top_inside": right_side_inside,
				#"top_outside": right_side_outside,
				#"right_inside": bottom_side_inside,
				#"right_outside": bottom_side_outside,
				#"bottom_inside": left_side_inside,
				#"bottom_outside": left_side_outside,
				#"left_inside": top_side_inside,
				#"left_outside": top_side_outside,
			#}
	#return sides
#
#func get_side_tile(side: String):
	#return sides[side]
#
#func get_sides() -> Dictionary:
	#return sides
