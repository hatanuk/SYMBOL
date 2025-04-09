extends CardState


func enter():
	if not card.is_node_ready():
		await card.ready
		
	card.scale = card.base_scale * 1.05
	card.z_index = 2
	card.find_child("Area2D").collision_layer = 2
	card.move_to_front()
	
	#if card not in card.player_hand.player_hand:
		#card.player_hand.add_card_to_hand(card)
		
	# debug
	card.color.color = Color.DARK_CYAN
	card.state.text = "HOVERED"
	card.z_index_label.text = str(card.z_index)
	
	

func on_input(event: InputEvent):
	if event.is_action("primary_interact"):
		card.drag_offset = card.position - card.get_global_mouse_position()
		transition_requested.emit(self, CardState.State.DRAGGED)

func on_mouse_exited():
	transition_requested.emit(self, CardState.State.BASE)
