extends CardState


func enter():
	if not card.is_node_ready():
		await card.ready
	
	card.scale = card.base_scale
	card.z_index = 0
	card.find_child("Area2D").collision_layer = 1
	card.drag_offset = Vector2.ZERO
	
	
	# debug
	card.color.color = Color.CORNFLOWER_BLUE
	card.state.text = "Base"
	card.z_index_label.text = str(card.z_index)

		
	#if card not in card.player_hand.player_hand:
		#card.player_hand.add_card_to_hand(card)


func on_mouse_entered():
	transition_requested.emit(self, CardState.State.HOVERED)
