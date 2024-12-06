extends Node

enum STATE {
	CHOOSE_TILE,
	CHOOSE_MIPLE,
}

var meeples = 6
var current_state = STATE.CHOOSE_TILE
var score = 0

func increase_meeple(count: int):
	meeples += count

func decrease_meeple(count: int):
	meeples -= count

func increase_score(count: int):
	score += count

func get_score_amount() -> int:
	return score

func get_meeples_amount() -> int:
	return meeples

func get_current_state() -> STATE:
	return current_state

func update_current_state(state: STATE):
	current_state = state
