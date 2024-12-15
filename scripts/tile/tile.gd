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

@export var left_side_1_object: TYPES
@export var left_side_2_object: TYPES
@export var top_side_1_object: TYPES
@export var top_side_2_object: TYPES
@export var right_side_1_object: TYPES
@export var right_side_2_object: TYPES
@export var bottom_side_1_object: TYPES
@export var bottom_side_2_object: TYPES
