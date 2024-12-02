extends Panel

var hovered_color = Color(1, 1, 1, 1)
var default_color = Color(1, 1, 1, 0)

func _on_mouse_entered() -> void:
	var tween = create_tween()
	
	tween.tween_property(self, "self_modulate", hovered_color, 0.2)
	tween.set_ease(Tween.EASE_IN)
	tween.play()

func _on_mouse_exited() -> void:
	var tween = create_tween()
	
	tween.tween_property(self, "self_modulate", default_color, 0.2)
	tween.set_ease(Tween.EASE_IN)
	tween.play()
	
