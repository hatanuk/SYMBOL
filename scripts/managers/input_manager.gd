extends Node2D

signal primary_pressed
signal primary_released

enum COLLISION_MASKS {
	CARD = 1 << 0,
	CARD_SLOT = 1 << 1,
	DECK = 1 << 2,
	CARD_ACTIONABLE_ZONE = 1 << 3, 
	DROPPABLE = 1 << 12
}

@onready var card_manager = $"../CardManager"
@onready var player_deck = $"../../Layout/PlayerZone/PlayerDeck"

func _input(event: InputEvent) -> void:
	if event.is_action("primary_interact"):
		if event.is_pressed():  
			emit_signal('primary_pressed')
		else:
			emit_signal('primary_released')
			pass

func raycast_at_curser():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var selected = get_highest_z_index_card(result)
		var result_collision_mask = selected.collision_mask
		if result_collision_mask == COLLISION_MASKS.CARD:
			# CARD SELECTED
			var card = selected.get_parent()
			if card and card is Card:
				card_manager.start_drag(card)
		elif result_collision_mask == COLLISION_MASKS.DECK:
			# DECK SELECTED
			player_deck.draw_card()
			
	return null 		

	
func get_highest_z_index_card(result):
	
	var highest_z_result = result[0].collider.card_parent
	var highest_z_index = highest_z_result.z_index
	var same_index = [highest_z_result]
	
	for i in range(1, result.size()):
		
		var cur_result = result[i].collider.card_parent
		if cur_result.z_index > highest_z_index:
			same_index = [cur_result]
			highest_z_result = cur_result
			highest_z_index = cur_result.z_index
		elif cur_result.z_index == highest_z_index:

			same_index.append(cur_result)
	
	# Check for if multiple cards have the same index value; 
	# return one based on draw order if this is the case
	if same_index.size() < 2:
		return highest_z_result
	else:
		return get_highest_draw_order_card(same_index)
	
func get_highest_draw_order_card(result):
	
	var highest_draw_result = result[0]
	var highest_draw_order = highest_draw_result.get_index()
	
	for i in range(1, result.size()):
		var cur_result = result[i]
		if cur_result.get_index() > highest_draw_order:
			highest_draw_result = cur_result
			highest_draw_order = cur_result.get_index()
	return highest_draw_result


func raycast_check_for_droppable_area(active_card):
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = active_card.global_position
	parameters.collide_with_areas = true
	parameters.collision_mask =  COLLISION_MASKS.DROPPABLE
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
	
func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask =  COLLISION_MASKS.CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
	
func raycast_check_for_card_deck():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask =  COLLISION_MASKS.DECK
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
	
	
func raycast_check_eclipse(active_card):
		var space_state = get_world_2d().direct_space_state
		var parameters = PhysicsShapeQueryParameters2D.new()
		parameters.shape = active_card.actionable_shape.shape
		parameters.transform = active_card.actionable_shape.global_transform
		parameters.collide_with_areas = true
		parameters.collision_mask = COLLISION_MASKS.CARD_ACTIONABLE_ZONE
		var result = space_state.intersect_shape(parameters)
		if result.size() > 0:
			if result.size() == 1:
				return result[0].collider.card_parent
			else:
				return raycast_check_for_card(active_card)
		else:
			return null
		
		
func raycast_check_for_card(ignored_card=null):
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask =  COLLISION_MASKS.CARD
	var result = space_state.intersect_point(parameters)
	
	if ignored_card:
			for detected in result:
				if detected.collider.card_parent == ignored_card:
					result.erase(detected)
					break
					
	if result.size() > 0:
		
		var found_card = get_highest_z_index_card(result)
		if found_card is Card:
			return found_card
	return null
	

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("primary_interact"):
		#var card = raycast_check_for_card(COLLISION_MASK_CARD)
		#if card:
			#start_drag(card)
	#elif event.is_action_released("primary_interact"):
		#if dragged_card:
			#finish_drag(dragged_card)
			 
	#if event is InputEventMouseMotion:
		#if hovered_card:
			#var card = raycast_check_for_card(COLLISION_MASK_CARD)
			#if hovered_card != card:
				#on_hovered_off_card(hovered_card)
				
