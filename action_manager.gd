extends Node2D

signal display_hint(action, emoji1, emoji2, result, pos)
signal hide_hint

@onready var input_manager = $"../InputManager"
@onready var card_manager = $"../CardManager"
@onready var player_hand = $"../../Layout/PlayerZone/PlayerHand"
@onready var card_database = $"../DatabaseManager".db_res

signal begin_addition(active_card)
signal begin_duplication(active_card)
signal cancel_action

var actionable_cards = []

var current_action_mode = action_modes.NONE

enum action_modes {
	NONE,
	ADDITION,
	SUBTRACTION,
	DUPLICATION
}

### CardManager Signals

	
func _on_update_eclipsed_card(active_card, eclipsed_card) -> void:
	if active_card and eclipsed_card:
		match current_action_mode:
			action_modes.ADDITION:
				var combined = card_database.find_combo(active_card.card_res.unicode, eclipsed_card.card_res.unicode)
				if combined:
					send_hint_signal("addition", active_card, eclipsed_card, combined)
					$"../../Debug/Addition".text = card_database.unicode_to_emoji(combined)
				else:
					hide_hint.emit()
					$"../../Debug/Addition".text = "Not addable"
			action_modes.NONE:
				hide_hint.emit()
	else:
		hide_hint.emit()
		$"../../Debug/Addition".text = ""
### Actions


func send_hint_signal(action_mode, active_card, eclipsed_card, combined_unicode):
	var y_pos = eclipsed_card.global_position.y + eclipsed_card.size.y/2
	var x_pos = eclipsed_card.global_position.x
	var hint_pos
	if eclipsed_card in player_hand.hand:
		hint_pos = Vector2(x_pos, y_pos - eclipsed_card.size.y - 60)
	else:
		hint_pos = Vector2(x_pos, y_pos)
	display_hint.emit(action_mode, active_card.card_res.unicode, eclipsed_card.card_res.unicode, combined_unicode, hint_pos)
	
func dupe(card)	-> bool:
	var card_res = card.card_res
	var new_card = card_manager.instantiate_card(card_res, card.global_position)
	if new_card:
		player_hand.add_card_to_hand(new_card)
		return true
	else:
		return false
	
func add(card1, card2) -> bool:
	var combined_unicode = card_database.find_combo(card1.card_res.unicode, card2.card_res.unicode)
	if not combined_unicode:
		print("ADDITION FAILURE")
		return false
		
	card1.collision.disable()
	card2.collision.disable()
	var card_res = card_database.find_res(combined_unicode)
	var new_card = card_manager.instantiate_card(card_res, card1.global_position)
	if new_card:
		player_hand.add_card_to_hand(new_card)
		card1.remove()
		card2.remove()
		return true
	else:
		return false
	
func can_perform_addition(card1, card2) -> bool:
	var combined_unicode = card_database.find_combo(card1.card_res.unicode, card2.card_res.unicode)
	if combined_unicode:
		return true
	else:
		return false
		
#func can_perform_action_on(eclipsed_card):
	#if eclipsed_card in actionable_cards:
		#return true
	#else:
		#false

## Broadcasts to the Card state charts to transition to their respective actions
func _on_start_drag(active_card):
	match current_action_mode:
		action_modes.ADDITION:
			begin_addition.emit(active_card)
		action_modes.DUPLICATION:
			begin_duplication.emit(active_card)
		action_modes.NONE:
			cancel_action.emit()

func _on_stop_drag():
	cancel_action.emit()

	
### Action Toggle Signals


func _on_action_ui_addition_toggled(toggled_on) -> void:
	if toggled_on:
		current_action_mode = action_modes.ADDITION
	else:
		current_action_mode = action_modes.NONE



func _on_action_ui_duplication_toggled(toggled_on) -> void:
	if toggled_on:
		current_action_mode = action_modes.DUPLICATION
	else:
		current_action_mode = action_modes.NONE



func _on_action_ui_subtraction_toggled(toggled_on) -> void:
	if toggled_on:
		current_action_mode = action_modes.SUBTRACTION
	else:
		current_action_mode = action_modes.NONE
