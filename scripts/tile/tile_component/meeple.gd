extends Panel

@onready var meeple_asset = preload("res://assets/meeple.png")
@onready var texture_meeple = $TextureRect

signal meeple_set(node)

var color_hover = Color(1, 1, 1, 1)
var color_default = Color(1, 1, 1, 0)
var is_meeple = false

func _on_mouse_entered() -> void:
	animate_color(color_hover)

func _on_mouse_exited() -> void:
	animate_color(color_default)

func animate_color(color: Color):
	var tween = create_tween()
	
	tween.tween_property(self, "self_modulate", color, 0.15)

func _on_meeple_set():
	texture_meeple.texture = meeple_asset
	is_meeple = true

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed() && is_meeple:
		emit_signal("meeple_set", self)
		is_meeple = false

func clear_advice():
	texture_meeple.texture = null
	is_meeple = false
