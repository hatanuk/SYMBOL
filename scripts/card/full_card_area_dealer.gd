extends Area2D

var card_parent = self

func _ready() -> void:
	while not card_parent is DealerCard: 
		card_parent = card_parent.get_parent()
