extends Node2D
class_name OpponentCard

var position_in_hand
var color
var pattern

func _ready():
	setup_visuals()

func setup_visuals():
	
	var viewport = get_node("SubViewportContainer")
	var card_back = get_node("SubViewportContainer/SubViewport/Graphics/CardBase/CardBack")
	var card_back_pattern = get_node("SubViewportContainer/SubViewport/Graphics/CardBase/CardBack/CardBackPattern")
	
	viewport.material = viewport.material.duplicate()

	card_back.get_theme_stylebox("panel").bg_color = color
	card_back_pattern.get_theme_stylebox("panel").texture = pattern
	
func animate_to_position(new_pos, duration=Card.DEFAULT_CARD_SPEED):
	var tween = create_tween()
	tween.tween_property(self, "position", new_pos, duration)
	await tween.finished
