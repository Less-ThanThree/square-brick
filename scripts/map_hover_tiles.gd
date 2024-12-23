extends GridContainer

@export var grid_container : GridContainer
@export var row: int
@export var col: int
@onready var EmptyTileScene = preload("res://components/empty_tile_hover.tscn")
@onready var GameTileScene = preload("res://components/tile.tscn")
@onready var resource_tiles = load("res://resources/tiles/tilles.tres")
@onready var map_grid = $"../MapGrid"

signal is_tile_rotate
signal update_tile_rotation(angle: float)

var mapTiles  = []
var currentTileRotateAngle: float = 0.0
var isCurrentMeepleChoose = false
var sides = ["top", "right", "bottom", "left"]
var side_index = 0
var current_side = sides[side_index]
var current_angle: float = 0.0

func _ready() -> void:
	var block_size = Vector2(256, 256)  # Размер блоков 3x3
	grid_container.columns = col
	
	# Генерация карты
	for row in range(col):
		mapTiles.append([])
		for col in range(col):
			mapTiles[row].append([])
			_create_empty_tile(row, col)

func _create_empty_tile(row: int, col: int):
	var empty_tile_instance = EmptyTileScene.instantiate()
	empty_tile_instance.custom_minimum_size = Vector2(256,256)
	grid_container.add_child(empty_tile_instance)
	mapTiles[row].append(empty_tile_instance)

func _on_map_grid_tile_hovered(index: int) -> void:
	if Player.get_current_state() == Player.STATE.CHOOSE_TILE:
		var new_tile = map_grid.get_current_tile_name().instantiate()
		var empty_tile = grid_container.get_child(index)
		new_tile.connect("rot_left", _on_update_local_angle.bind(-90))
		new_tile.connect("rot_right", _on_update_local_angle.bind(90))
		#new_tile.connect("is_rotate", _on_update_rotate_tile)
		new_tile.angle = current_angle
		
		grid_container.remove_child(empty_tile)
		empty_tile.queue_free()
			
		grid_container.add_child(new_tile)
		grid_container.move_child(new_tile, index)
	#if !isCurrentMeepleChoose:
		#var index = row * grid_container.columns + col
		#var new_tile = GameTileScene.instantiate()
		#var empty_tile = grid_container.get_child(index)
		#new_tile.connect("is_rotate", _on_update_rotate_tile)
		#new_tile.tile_info = resource_tiles.tile_info_x5[tile_info]
		#new_tile.angel = currentTileRotateAngle
		#print(currentTileRotateAngle)
		#
		#grid_container.remove_child(empty_tile)
		#empty_tile.queue_free()
		#
		#grid_container.add_child(new_tile)
		#grid_container.move_child(new_tile, index)
		
		#if (Debug.ISDEBUG):
			#print("Hover to Row: %s Col: %s \n Current tile info: %s \n Currner degress %s" % [row, col, tile_info, currentTileRotateAngle])

func _on_map_grid_tile_exited(index: int) -> void:
	var empty_tile = EmptyTileScene.instantiate()
	var old_tile = grid_container.get_child(index)
	
	grid_container.remove_child(old_tile)
	old_tile.queue_free()
		
	grid_container.add_child(empty_tile)
	grid_container.move_child(empty_tile, index)

func _on_update_local_angle(angle: float):
	if angle < 0:
		side_index -= 1
		if side_index < 0:
			side_index = 3
	if angle > 0:
		side_index += 1
		if side_index > sides.size() - 1:
			side_index = 0
	if angle == 0:
		side_index = 0
	current_side = sides[side_index]
	current_angle += angle
	emit_signal("update_tile_rotation", current_angle, current_side)

func _on_grid_container_tile_set() -> void:
	current_angle = 0
	side_index = 0
	current_side = sides[side_index]

func _on_update_rotate_tile():
	currentTileRotateAngle = currentTileRotateAngle + (-90)
	if currentTileRotateAngle <= -360:
		currentTileRotateAngle = 0
	emit_signal("is_tile_rotate", currentTileRotateAngle)
	if (Debug.ISDEBUG):
		print("rotated %s" % [currentTileRotateAngle])

func _on_map_grid_tile_set() -> void:
	currentTileRotateAngle = 0.0
	isCurrentMeepleChoose = true

func _on_map_grid_meeple_set() -> void:
	isCurrentMeepleChoose = false

func _on_map_grid_meeple_skip() -> void:
	isCurrentMeepleChoose = false
