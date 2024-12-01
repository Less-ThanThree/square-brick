extends Control

@onready var ui_component = $UI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui_component.global_position = self.position
