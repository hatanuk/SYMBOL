
extends Node2D

const MAX_HAND_SIZE = 5
const CARD_SPACING = 125
const DEFAULT_CARD_HAND_SPEED = 0.2

@onready var center_x = $"../OpponentArea/ShapeOpponent".global_position.x

var hand = []

		
func add_card_to_hand(card, speed=DEFAULT_CARD_HAND_SPEED):
	if card not in hand:
		hand.append(card)
		update_hand_position(speed)
	else:
		card.animate_to_position(card.position_in_hand, speed)
	
func remove_card_from_hand(card, speed=DEFAULT_CARD_HAND_SPEED):
	if card in hand:
		hand.erase(card)
		update_hand_position(speed)
	
func update_hand_position(speed=DEFAULT_CARD_HAND_SPEED):
	for i in range(hand.size()):
		var new_position = Vector2(calculate_card_position(i), global_position.y)
		var card = hand[i]
		
		card.animate_to_position(new_position, speed) 
		card.position_in_hand = new_position
		
		
func calculate_card_position(index):
	var x_offset  = (hand.size() - 1) * CARD_SPACING
	var x_position = center_x + index * CARD_SPACING - x_offset / 2
	return x_position 
		
