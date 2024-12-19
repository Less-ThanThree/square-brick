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

@export var left_side_1_object: TYPES
@export var left_side_2_object: TYPES
@export var top_side_1_object: TYPES
@export var top_side_2_object: TYPES
@export var right_side_1_object: TYPES
@export var right_side_2_object: TYPES
@export var bottom_side_1_object: TYPES
@export var bottom_side_2_object: TYPES

@export var is_set: bool = false
@export var is_meeple: bool = false
@export var angle: float = 0.0

@onready var base = $Base

signal show_meeple_advice
signal meeple_set
signal meeple_skip
signal rot_left
signal rot_right

var is_animation_rotate = false

func _ready() -> void:
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
	Player.update_current_state(Player.STATE.CHOOSE_MIPLE)
	emit_signal("show_meeple_advice")

func _on_tile_meeple_skip():
	emit_signal("meeple_skip")

func get_tile_resource():
	return tile_resource
	
