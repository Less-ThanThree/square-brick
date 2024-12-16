extends Panel

@onready var meeple_asset = preload("res://assets/meeple.png")
@onready var texture_meeple = $TextureRect

var color_hover = Color(1, 1, 1, 1)
var color_default = Color(1, 1, 1, 0)

func _on_mouse_entered() -> void:
	animate_color(color_hover)

func _on_mouse_exited() -> void:
	animate_color(color_default)

func animate_color(color: Color):
	var tween = create_tween()
	
	tween.tween_property(self, "self_modulate", color, 0.15)

func _on_meeple_set():
	texture_meeple.texture = meeple_asset
