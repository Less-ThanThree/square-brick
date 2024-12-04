extends Control

@onready var label = $Label

var state_set_tile = "Установи тайл"
var state_set_meeple = "Установи мипла или пропусти ход [space]"
var current_player_state = Player.get_current_state()

func _ready() -> void:
	label.text = state_set_tile

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_player_state != Player.get_current_state():
		match Player.get_current_state():
			Player.STATE.CHOOSE_TILE:
				label.text = state_set_tile
			Player.STATE.CHOOSE_MIPLE:
				label.text = state_set_meeple
		current_player_state = Player.get_current_state()

#func update_state():
	#if 
