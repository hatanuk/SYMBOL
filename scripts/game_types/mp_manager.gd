extends Node2D

@onready var game_manager = $"../../Managers/GameManager"
@onready var dealer_manager = $"../../Managers/DealerManager"
@onready var opponent_deck = $"../../Layout/OpponentZone/OpponentDeck"
@onready var player_hand = $"../../Layout/PlayerZone/PlayerHand"
@onready var player_deck = $"../../Layout/PlayerZone/PlayerDeck"
@onready var db_manager = $"../../Managers/DatabaseManager"

### SIGNALS
# DealerManager
func _on_rejected_input() -> void:
	opponent_input_rejected.rpc()
	
func _on_accepted_input() -> void:
	opponent_input_accepted.rpc()
	
func _on_card_dealt(slot: Variant, dealer_res: Variant) -> void:
	# Authority should broadcast the card dealing to client
	var data = pack_dealer_card_data(dealer_res)
	recieve_dealt_card.rpc(dealer_manager.card_slots.get_index(slot), data)




func request_card_submission(slot, inputs):
	var slot_idx = dealer_manager.card_slots.get_index(slot)
	var groups = []
	var unicodes = []
	for input in inputs:
		groups.append(input.card_res.group)
		unicodes.append(input.card_res.unicode)
		
	verify_submission.rpc_id(1, slot_idx, groups, unicodes)


@rpc("any_peer", "call_remote", "reliable")
func opponent_input_accepted(slot_idx):
	
	var slot = dealer_manager.card_slots[slot_idx]
	dealer_manager.clear_card_slot(slot)
	
	if is_multiplayer_authority():
		game_manager.deal_card(slot)

@rpc("any_peer", "call_remote", "reliable")
func opponent_input_rejected():
	# Moves opponents card back to hand on screen
	pass
	
@rpc("any_peer", "call_remote", "reliable")
func verify_submission(slot_idx, groups, unicodes):
	# Sends an RPC response back to client with approval or denial
	var approved = false
	
	if dealer_manager.card_slots[slot_idx] and dealer_manager.card_slots[slot_idx].dealer_res:	
		var dealer_res = dealer_manager.card_slots[slot_idx].dealer_res
		if dealer_res.verify_rpc_inputs(groups, unicodes):
			approved = true
			
	recieve_submission_result.rpc(approved, slot_idx)

@rpc("authority", "call_remote", "reliable")
func recieve_submission_result(approved, slot_idx):
	if approved:
		dealer_manager.accept_input(dealer_manager.card_slots[slot_idx])
	else:
		dealer_manager.reject_input(dealer_manager.card_slots[slot_idx])


## Packing data for transmission
func pack_dealer_card_data(dealer_res):
	return {
		"type": dealer_res.card_type,
		"unicode": dealer_res.card_res.unicode,
		"modifier": dealer_res.card_modifier
	}
	
func unpack_dealer_card_data(data):
	var unicode = data["unicode"]
	var type = data["type"]
	var modifier = data["modifier"]
	var card_res = db_manager.find_res(unicode)
	return DealerCardResource.new().init(card_res, type, modifier)

### RPC SYNCS
@rpc("any_peer", "call_local", "reliable")
func recieve_dealt_card(slot_idx, data):
	var dealer_res = unpack_dealer_card_data(data)
	dealer_manager.deal_card(dealer_manager.card_slots[slot_idx], dealer_res)


@rpc("authority", "call_local", "reliable")
func multiplayer_start_game():
	
	for i in range(game_manager.STARTING_HAND_SIZE):
		player_deck.draw_card()
		
	await get_tree().create_timer(1.0).timeout
	# Host chooses dealt cards and syncs
	if is_multiplayer_authority():
		for i in range(game_manager.STARTING_DEAL_SIZE):
			game_manager.deal_card(dealer_manager.card_slots[i])
			


@rpc("any_peer", "call_remote", "reliable")
func opponent_card_drawn(pattern, color):
	opponent_deck.draw_card(pattern, color)

@rpc("any_peer", "call_remote", "reliable")
func opponent_score_changed(score):
	$"../../Debug/ScoreOpp".text = score


## SIGNALS
# not connected
func _on_player_deck_drawn_card(card) -> void:
	
	var pattern = card.card_visuals.texture
	var primary_color = card.card_visuals.primary_color
	
	opponent_card_drawn.rpc(pattern, primary_color)
