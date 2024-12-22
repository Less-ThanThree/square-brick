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

@export var left_side_inside: Array[TYPES]= []
@export var left_side_outside:Array[TYPES]= []
@export var top_side_inside: Array[TYPES]= []
@export var top_side_outside: Array[TYPES]= []
@export var right_side_inside: Array[TYPES]= []
@export var right_side_outside: Array[TYPES]= []
@export var bottom_side_inside: Array[TYPES]= []
@export var bottom_side_outside: Array[TYPES]= []

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

var is_animation_rotate = false
var sides = {
	"top_inside": null,
	"top_outside": null,
	"right_inside": null,
	"right_outside": null,
	"bottom_inside": null,
	"bottom_outside": null,
	"left_inside": null,
	"left_outside": null,
}

func _ready() -> void:
	set_debug_settings()
	base.rotation_degrees = angle

func _input(event: InputEvent) -> void:
	if Player.get_current_state() == Player.STATE.CHOOSE_TILE:
		if Input.is_action_just_pressed("rotate_left") && !is_animation_rotate && !is_set:
			rotate_left()
		if Input.is_action_just_pressed("rotate_right") && !is_animation_rotate && !is_set:
			rotate_right()

func rotate_right():
	animate_rotation(90)
	emit_signal("rot_right")

func rotate_left():
	animate_rotation(-90)
	emit_signal("rot_left")

func animate_rotation(rot: float):
	var tween = create_tween()
	var target_rot = deg_to_rad(rot) + base.rotation
	is_animation_rotate = true
	
	tween.tween_property(base, "rotation", target_rot, 0.15)
	tween.finished.connect(_on_rotate_end)
	
func _on_rotate_end():
	is_animation_rotate = false

func _on_tile_set():
	sides = get_side_on_local_angle()
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

func _on_area_entered(zone: String):
	var side = get_side_on_local_angle()
	emit_signal("area_compare", side, zone)
		#print(left_side_isnide)
		#print("BUILD", area.name)

func get_side_on_local_angle() -> Dictionary:
	match side:
		"top":
			sides = {
				"top_inside": top_side_inside,
				"top_outside": top_side_outside,
				"right_inside": right_side_inside,
				"right_outside": right_side_outside,
				"bottom_inside": bottom_side_inside,
				"bottom_outside": bottom_side_outside,
				"left_inside": left_side_inside,
				"left_outside": left_side_outside,
			}
		"right":
			sides = {
				"top_inside": left_side_inside,
				"top_outside": left_side_outside,
				"right_inside": top_side_inside,
				"right_outside": top_side_outside,
				"bottom_inside": right_side_inside,
				"bottom_outside": right_side_outside,
				"left_inside": bottom_side_inside,
				"left_outside": bottom_side_outside,
			}
		"bottom":
			sides = {
				"top_inside": bottom_side_inside,
				"top_outside": bottom_side_outside,
				"right_inside": left_side_inside,
				"right_outside": left_side_outside,
				"bottom_inside": top_side_inside,
				"bottom_outside": top_side_outside,
				"left_inside": right_side_inside,
				"left_outside": right_side_outside,
			}
		"left":
			sides = {
				"top_inside": right_side_inside,
				"top_outside": right_side_outside,
				"right_inside": bottom_side_inside,
				"right_outside": bottom_side_outside,
				"bottom_inside": left_side_inside,
				"bottom_outside": left_side_outside,
				"left_inside": top_side_inside,
				"left_outside": top_side_outside,
			}
	return sides

func get_side_tile(side: String):
	return sides[side]

func get_sides() -> Dictionary:
	return sides
