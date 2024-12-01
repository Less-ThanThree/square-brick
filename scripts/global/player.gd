extends Node

var meeples = 6

func increase_meeple(count: int):
	meeples += count

func decrease_meeple(count: int):
	meeples -= count

func get_meeples_amount() -> int:
	return meeples
