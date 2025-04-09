extends Control
@onready var label: Label = $Panel/VBoxContainer/HBoxContainer/Label

var max_cards = GameInfo.max_cards
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	_on_updated_card_count(0)

func blink():
	animation_player.play("blink")


func _on_updated_card_count(card_count: Variant) -> void:
	label.text = str(card_count) + "/" + str(max_cards)
