extends Camera2D

#@onready var ui_component = $"../UI"

# Movement settings
@export var move_speed: float = 300.0
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

func _process(delta):
	var input_vector = Vector2.ZERO
	var viewport_center = get_viewport().get_visible_rect().size / 2
	
	# WASD Movement
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	
	# Normalize to prevent faster diagonal movement
	input_vector = input_vector.normalized()
	
	# Move the camera
	position += input_vector * move_speed * delta
	
	#ui_component.global_position = position + viewport_center

func _input(event):
	# Zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			print(zoom)
			print(min_zoom)
			zoom -= Vector2(zoom_speed, zoom_speed)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += Vector2(zoom_speed, zoom_speed)
		
		# Clamp zoom
		zoom.x = clamp(zoom.x, min_zoom, max_zoom)
		zoom.y = clamp(zoom.y, min_zoom, max_zoom)
		
		#ui_component.scale = Vector2(1 / zoom.x, 1 / zoom.y)
