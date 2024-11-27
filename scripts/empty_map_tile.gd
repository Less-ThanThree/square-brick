extends Panel
class_name EmptyMapTile

signal tile_pressed
signal tile_mouse_entered
signal tile_mouse_exited

var original_color : Color = Color(1, 1, 1)  # Исходный цвет панели (белый)
var hover_color : Color = Color(0.5, 0.8, 1)  # Цвет при наведении (светло-синий)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Устанавливаем начальный цвет
	self.modulate = original_color

func _on_mouse_entered() -> void:
	self.modulate = hover_color  # Меняем цвет панели при наведении

func _on_mouse_exited() -> void:
	self.modulate = original_color  # Возвращаем исходный цвет, когда курсор уходит

func _on_button_pressed() -> void:
	self.emit_signal("tile_pressed")

func _on_button_mouse_entered() -> void:
	self.emit_signal("tile_mouse_entered")

func _on_button_mouse_exited() -> void:
	self.emit_signal("tile_mouse_exited")
