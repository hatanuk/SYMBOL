extends Control

@onready var addition_b =$Panel/MarginContainer/HBoxContainer/AdditionButton
@onready var subtraction_b = $Panel/MarginContainer/HBoxContainer/SubtractionButton
@onready var duplication_b = $Panel/MarginContainer/HBoxContainer/DuplicationButton
@onready var h_box_container: HBoxContainer = $Panel/MarginContainer/HBoxContainer

signal duplication_toggled(toggled_on)
signal addition_toggled(toggled_on)
signal subtraction_toggled(toggled_on)

func highlight_button(button, on):
	if on:
		button.pivot_offset = button.size / 2
		button.scale = button.scale * 1.1
		button.modulate = Color(0.4, 0.4, 0.4, 1)
	else:
		button.scale = Vector2(1, 1)
		button.modulate = Color.BLACK

func unhighlight_all():
	for button in h_box_container.get_children():
		highlight_button(button, false)


func _on_addition_button_focus_entered() -> void:
	unhighlight_all()
	highlight_button(addition_b, true)



func _on_subtraction_button_focus_entered() -> void:
	unhighlight_all()
	highlight_button(subtraction_b, true)



func _on_duplication_button_focus_entered() -> void:
	unhighlight_all()
	highlight_button(duplication_b, true)

func _on_addition_button_toggled(toggled_on: bool) -> void:
	addition_toggled.emit(toggled_on)


func _on_subtraction_button_toggled(toggled_on: bool) -> void:
	subtraction_toggled.emit(toggled_on)


func _on_duplication_button_toggled(toggled_on: bool) -> void:
	duplication_toggled.emit(toggled_on)
