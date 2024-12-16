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

signal show_meeple_advice
signal meeple_set

var is_animation_rotate = false

func _ready() -> void:
	emit_signal("show_meeple_advice")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("rotate_left") && !is_animation_rotate:
		rotate_left()
	if Input.is_action_just_pressed("rotate_right") && !is_animation_rotate:
		rotate_right()

func rotate_right():
	animate_rotation(90)

func rotate_left():
	animate_rotation(-90)

func animate_rotation(rot: float):
	var tween = create_tween()
	var target_rot = deg_to_rad(rot) + self.rotation
	is_animation_rotate = true
	
	tween.tween_property(self, "rotation", target_rot, 0.15)
	tween.finished.connect(_on_rotate_end)
	
func _on_rotate_end():
	is_animation_rotate = false

func get_tile_resource():
	return tile_resource
