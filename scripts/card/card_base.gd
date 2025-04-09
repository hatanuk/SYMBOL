extends Panel

func _ready():
	var original_stylebox = get_theme_stylebox("panel")
	if original_stylebox:
		var unique_stylebox = original_stylebox.duplicate()
		add_theme_stylebox_override("panel", unique_stylebox)
