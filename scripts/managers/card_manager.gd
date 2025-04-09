extends Node2D

signal update_active_card(active_card)
signal update_eclipsed_card(active_card, eclipsed_card)
signal card_dropped_on_slot(card, slot)
signal card_drag_started(card)
signal card_drag_stopped
signal action_taken(action)
signal updated_card_count(card_count)

var total_card_instances: int: 
	get:
		return get_children().size()


var cards_requested_to_be_active: Array[Card] = []

# Card that is currently being mouse-interacted with; exclusive to one
var active_card: Card = null:
	set = set_active_card
	
# Card that the active card is currently hovering over; exclusive to one
var eclipsed_card: Card = null:
	set = set_eclipsed_card

const CARD_SCENE_PATH = "res://scenes/cards/card.tscn"
const CARD_MOVE_VELOCITY = 50

@onready var card_database = $"../DatabaseManager".db_res
@onready var dealer_manager = $"../DealerManager"
@onready var action_manager = $"../ActionManager"
@onready var drag_bounding_area = $"../../Layout/DragZone/DragArea/ShapeDrag"
@onready var player_hand =  $"../../Layout/PlayerZone/PlayerHand"
@onready var input_manager = $"../InputManager"
@onready var game_manager = $"../GameManager"
@onready var screen_size: Vector2 = get_viewport_rect().size
	
	
func move_card_to_mouse(card, delta):
	var target_pos = get_global_mouse_position() + card.drag_offset

	if card.global_position == target_pos and card.velocity == Vector2.ZERO:
		return
	
	card.velocity = card.MOMENTUM * card.velocity + (1-card.MOMENTUM) * (target_pos - card.global_position) * card.ACCELERATION
	var drag_bounding_rect = Rect2(drag_bounding_area.global_position - drag_bounding_area.shape.get_size() *  drag_bounding_area.scale / 2,
	drag_bounding_area.shape.size  * drag_bounding_area.scale)
	card.global_position = clamped_card_position(card.global_position + card.velocity * delta, card, drag_bounding_rect)
	
func check_eclipsed():
	if active_card:
		var result = input_manager.raycast_check_eclipse(active_card)
		eclipsed_card = result

	
func instantiate_card(card_res, card_position):
	if total_card_instances > GameInfo.max_cards:
		return
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	new_card.card_res = card_res
	new_card.name = "Card"
	new_card.global_position = card_position
	add_child(new_card)
	return new_card
	
func _on_active_card_removed():
	var prev_active_card = self.active_card
	self.active_card = null
	var new_hovered = input_manager.raycast_check_for_card()
	if new_hovered and new_hovered != prev_active_card:
		cards_requested_to_be_active.append(new_hovered)
		_on_active_requests_updated()
	
func _on_active_card_dragged():
	if active_card:
		start_drag(active_card)
	
	
func _on_active_requests_updated():
	if not active_card:
		if cards_requested_to_be_active.size() == 1:
			active_card = cards_requested_to_be_active.pop_front()
		else:
			var selected_card = input_manager.raycast_check_for_card()
			for card in cards_requested_to_be_active:
				if selected_card == card:
					# Set raycasted card to active card
					active_card = selected_card
				else:
					# Deny other cards
					cards_requested_to_be_active.erase(card)
	else:
		# Deny other cards
		cards_requested_to_be_active = []			

func _on_card_eclipsed(card):
			
	if eclipsed_card and active_card:
		# Perform raycast
		var new_card = input_manager.raycast_check_eclipse(active_card)
		if new_card:
			eclipsed_card = new_card
	elif active_card:
		eclipsed_card = card
		
func _on_card_eclipsed_exited():
	eclipsed_card = null
	
func set_eclipsed_card(card):
	eclipsed_card = card
	update_eclipsed_card.emit(active_card, eclipsed_card)
	if eclipsed_card:
		$"../../Debug/EclipsedCard".text = eclipsed_card.card_res.emoji
	else:
		$"../../Debug/EclipsedCard".text = "null"
	
func set_active_card(card):
	
	if active_card and card:
		# Trying to set a new active card while one already exists
		return
	if card == null:
		active_card = null
		eclipsed_card = null
	elif active_card == null:
		active_card = card
		# Draw order priority
		move_child(card, -1)
		card.transition_to_active()
		
	update_active_card.emit(active_card)
	
	
func connect_card_signals(card):
	card.active_requests_updated.connect(_on_active_requests_updated)
	card.active_card_removed.connect(_on_active_card_removed)
	card.active_card_dragged.connect(_on_active_card_dragged)
	card.active_card_finished_drag.connect(_on_active_card_finished_drag)
	card.card_eclipsed.connect(_on_card_eclipsed)
	card.card_eclipsed_exited.connect(_on_card_eclipsed_exited)
	card.card_removed.connect(_on_card_removed)
	 
func start_drag(card):
	card_drag_started.emit(card)
	card.drag_offset = card.position - get_global_mouse_position()

func _on_active_card_finished_drag(active_card):
	# 1. Check for card slot
	# 2. Check for action
	# 3. Check for dropped area 
	# 4. Return to hand
	var action_success = false
	card_drag_stopped.emit()
	var card_slot = input_manager.raycast_check_for_card_slot()
	if card_slot and card_slot.current_inputs.size() < card_slot.allowed_num_inputs:
			card_dropped_on_slot.emit(active_card, card_slot)
			player_hand.remove_card_from_hand(active_card)
			action_success = true
	elif eclipsed_card:
		action_success = game_manager.perform_action(active_card, eclipsed_card)
	
	
	if not action_success and self.active_card:
		if input_manager.raycast_check_for_droppable_area(active_card):
			player_hand.remove_card_from_hand(active_card)
		else:
			player_hand.add_card_to_hand(active_card)
			
	eclipsed_card = null
	
func get_highest_z_index_card(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	for i in range(1, cards.size()):
		var cur_card = cards[i].collider.get_parent()
		if cur_card.z_index > highest_z_index:
			highest_z_card = cur_card
			highest_z_index = cur_card.z_index
	return highest_z_card  
	
	
func clamped_card_position(pos, card, bounding_rect: Rect2):
	var card_dims = card.full_card_shape.shape.get_rect().size * card.get_scale()

	var max_x = bounding_rect.position.x + bounding_rect.size.x - card_dims.x/2
	var min_x = bounding_rect.position.x + card_dims.x/2
	var max_y = bounding_rect.position.y + bounding_rect.size.y - card_dims.y/2
	var min_y = bounding_rect.position.y + card_dims.y/2
	
	return Vector2(clamp(pos.x, min_x, max_x), 
			clamp(pos.y, min_y, max_y))

func _on_card_removed(card):
	if eclipsed_card == card:
		eclipsed_card = null
	elif active_card == card:
		active_card = null
	player_hand.remove_card_from_hand(card)
		

# Emits signal when cards (children) are added/removed
func _on_child_entered_tree(node: Node) -> void:
	updated_card_count.emit(total_card_instances)


func _on_child_exiting_tree(node: Node) -> void:
	updated_card_count.emit(total_card_instances)
