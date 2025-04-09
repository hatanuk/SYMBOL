extends Control

const SCORE_EARNED_UI = preload("res://scenes/score_earned_ui.tscn")
	

func _display_added_score(pos: Variant, score: Variant) -> void:
	var display = SCORE_EARNED_UI.instantiate()
	display.score = score
	display.global_position = pos
	add_child(display)
