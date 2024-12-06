extends Control

@onready var score_label = $Label

var local_score = Player.get_score_amount()

func _ready() -> void:
	update_score(local_score)

func _process(delta: float) -> void:
	if local_score != Player.get_score_amount():
		local_score = Player.get_score_amount()
		update_score(local_score)

func update_score(score: int):
	score_label.text = "Очки: %s" % [score]
