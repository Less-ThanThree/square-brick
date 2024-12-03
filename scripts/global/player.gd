extends Node

enum STATE {
	CHOOSE_TILE,
	CHOOSE_MIPLE,
}

var meeples = 6
var current_state = STATE.CHOOSE_TILE

func increase_meeple(count: int):
	meeples += count

func decrease_meeple(count: int):
	meeples -= count

func get_meeples_amount() -> int:
	return meeples

func get_current_state() -> STATE:
	return current_state

func update_current_state(state: STATE):
	current_state = state
