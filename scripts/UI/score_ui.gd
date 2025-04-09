extends Control
@onready var score_label: Label = $Panel/HBoxContainer/ScoreLabel


static func thousands_sep(number, prefix=''):
	number = int(number)
	var neg = false
	if number < 0:
		number = -number
		neg = true
	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	if neg: res = '-'+prefix+res
	else: res = prefix+res
	return res



func _on_score_changed(score: Variant) -> void:
	score_label.text = thousands_sep(score)


func _on_game_manager_game_end_animation() -> void:
	self.visible = false
