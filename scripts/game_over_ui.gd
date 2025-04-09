extends Control
@onready var viewport_screenshot: TextureRect = $ViewportScreenshot
@onready var rank_ui: Control = $RankUI
@onready var score_ui: Control = $ScoreUI

@onready var retry: TextureButton = $IconButtons/HBoxContainer/Retry
@onready var exit: TextureButton = $IconButtons/HBoxContainer/Exit

signal retry_pressed
signal exit_pressed


func _ready() -> void:
	self.visible = false
	rank_ui.visible = false
	retry.disabled = true
	exit.disabled = true
	retry.modulate = Color(1, 1, 1, 0)
	exit.modulate = Color(1, 1, 1, 0)
	score_ui.modulate = Color(1, 1, 1, 0)
	

func _on_game_end_animation() -> void:
	var img = get_tree().get_root().get_viewport().get_texture().get_image()
	var tex = ImageTexture.create_from_image(img)
	viewport_screenshot.texture = tex

	
	var tween = get_tree().create_tween()
	
	visible = true
	
	tween.tween_method(
	  func(value): viewport_screenshot.material.set_shader_parameter("dissolve_value", value),  
	  1.0,  # Start value
	  0.0,  # End value
	  2     # Duration
	);
	
	tween.tween_property(score_ui, "modulate", Color.WHITE, 1)
	await tween.finished
	rank_ui.update_rank()
	rank_ui.visible = true
	tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(rank_ui, "position", Vector2(rank_ui.position.x, rank_ui.position.y - 98), 2)
	await tween.finished
	
	# Icon buttons
	tween = get_tree().create_tween()
	tween.parallel().tween_property(exit, "modulate", Color.WHITE, 1)
	tween.parallel().tween_property(retry, "modulate", Color.WHITE, 1)
	retry.disabled = false
	exit.disabled = false
	

func _on_retry_pressed() -> void:
	retry.get_node("AnimationPlayer").play("on_click")
	await retry.get_node("AnimationPlayer").animation_finished
	retry_pressed.emit()


func _on_exit_pressed() -> void:
	exit.get_node("AnimationPlayer").play("on_click")
	await exit.get_node("AnimationPlayer").animation_finished
	exit_pressed.emit()
