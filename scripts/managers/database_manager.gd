extends Node2D

var temp_cards = ['🌍', '🔥', '🌱', '🪨', '🌋', '💧']
@export var db_res: CardDatabase

func initialise_deck():
	pass
	## Sample a good combination cards (based on a group?) which have high combinatory interplay with one anothr
	## Currently this is supplemented by temp_cards

func sample_from_deck():
	## replace with a ranked sampling based on card usefulness
	var emoji = temp_cards[randi() % temp_cards.size()]
	var card_res = db_res.find_res(db_res.emoji_to_unicode(emoji)) # extremely inefficient please change
	
	return card_res
	
func sample_from_dealer():
	## replace with a ranked sampling based on difficulty
	var emoji = temp_cards[randi() % temp_cards.size()]
	var card_res = db_res.find_res(db_res.emoji_to_unicode(emoji))
	return card_res

func get_card_res_from_unicode(unicode):
	return db_res.find_res(unicode)

func _on_action_manager_begin_addition(active_card: Variant) -> void:
	## on fusion of a new emoji type, make it possible to draw from deck
	if active_card.card_res.emoji not in temp_cards:
		temp_cards.append(active_card.card_res.emoji)
