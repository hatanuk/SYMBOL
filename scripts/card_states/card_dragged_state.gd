extends CardState


func enter():
	if not card.is_node_ready():
		await card.ready
	
	card.scale = card.base_scale
	card.z_index = 2
	card.find_child("Area2D").collision_layer = 2
	
	# debug
	card.color.color = Color.DARK_RED
	card.state.text = "DRAGGED"
	card.z_index_label.text = str(card.z_index)
	
	
	card.player_hand.remove_card_from_hand(card)
	
	
func on_input(event: InputEvent):
	var mouse_motion := event is InputEventMouseMotion
	var cancel := !Input.is_action_pressed("primary_interact")
	#var confirm := event.is_action_released("left_mouse") or event.is_action_pressed("left_mouse")
	 
	
	if cancel:
		# Check if a card slot is underneath
		var card_slot = false
		if card_slot:
			card.position = card_slot.position
			transition_requested.emit(self, CardState.State.RELEASED)
		else:
			transition_requested.emit(self, CardState.State.HOVERED)
	elif mouse_motion:
		card.position = clamped_card_position(card, card.get_viewport_rect())
		
	#elif confirm:
		#get_viewport().set_input_as_handled()
		#transition_requested.emit(self, CardState.State.RELEASED)


func clamped_card_position(card, bounding_rect: Rect2):
	var mouse_pos = card.get_global_mouse_position()
	var card_dims = card.get_node("Area2D/CollisionShape2D").shape.get_rect().size * card.get_scale()

	var max_x = bounding_rect.position.x + bounding_rect.size.x - card_dims.x/2
	var min_x = bounding_rect.position.x + card_dims.x/2
	var max_y = bounding_rect.position.y + bounding_rect.size.y - card_dims.y/2
	var min_y = bounding_rect.position.y + card_dims.y/2
	
	return Vector2(clamp(mouse_pos.x + card.drag_offset.x, min_x, max_x), 
			clamp(mouse_pos.y + card.drag_offset.y, min_y, max_y))
