extends Panel

@export var is_meeple: bool = false
@export var zone: String

@onready var meeple_texture = $TextureMeeple

signal meeple_set

var hovered_color = Color(1, 1, 1, 1)
var default_color = Color(1, 1, 1, 0)
var avail_color = Color(0.264, 0.747, 0.191, 1)
var disabled = false

func _on_mouse_entered() -> void:
	if !disabled:
		var tween = create_tween()
		
		tween.tween_property(self, "self_modulate", hovered_color, 0.2)
		tween.set_ease(Tween.EASE_IN)
		tween.play()

func _on_mouse_exited() -> void:
	if !disabled:
		var tween = create_tween()
		
		tween.tween_property(self, "self_modulate", default_color, 0.2)
		tween.set_ease(Tween.EASE_IN)
		tween.play()
	
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed() && !disabled && is_meeple:
		modulate_meeple()
		emit_signal("meeple_set", self)

func _on_disabled():
	var tween = create_tween()
		
	tween.tween_property(self, "self_modulate", default_color, 0.2)
	tween.set_ease(Tween.EASE_IN)
	tween.play()
	disabled = true
	
func modulate_meeple():
	meeple_texture.self_modulate = Color(1, 1, 1, 1)
