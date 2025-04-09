extends Node2D
	
const TYPE_PROBS = {
		DealerCardResource.CardType.GOLD : 0.1,
		DealerCardResource.CardType.SILVER : 0.2,
		DealerCardResource.CardType.REGULAR : 0.3,
		DealerCardResource.CardType.BACKSIDE : 0.3,
	}
	
const MODIFIER_PROBS = {
		DealerCardResource.CardModifier.NONE : 1.0
	}
	
signal card_slot_cleared(slot)
signal card_dealt(slot, dealer_res)
signal card_lifetime_expired(slot)
signal rejected_input
signal accepted_input
signal card_added_as_input(card, slot)
signal card_removed_as_input(card)


const DEALER_CARD_SCENE_PATH = "res://scenes/cards/dealer_card.tscn"

const MIN_DEAL_DELAY = 1.0

@onready var db_manager = $"../DatabaseManager"
@onready var player_hand = $"../../Layout/PlayerZone/PlayerHand"
@onready var dealer_graphic = 	$"../../Layout/DealerZone/DealerGraphic"
@onready var game_manager: Node2D = $"../GameManager"

var card_slots = []

# would have been better if slots emitted their own signals
func _ready() -> void:
	for slot in get_node("../../Layout/DealerZone/CardSlots").get_children():
		card_slots.append(slot)

func _on_card_lifetime_over(card):
	
	var found_slot = null
	for slot in card_slots:
		if slot.dealt_card == card:
			found_slot = slot
			break
	if found_slot:
		reject_input(found_slot)
		if found_slot.dealt_card:
			await found_slot.dealt_card.remove_on_dissolve()
		clear_card_slot(found_slot)
		card_lifetime_expired.emit(found_slot)
	
	
func random_sample():
	return db_manager.sample_from_dealer()
	
func clear_card_slot(slot):
	if slot.dealt_card:
		slot.dealt_card = null
		slot.current_inputs.clear()
	
		
func accept_input(slot):
	accepted_input.emit(slot)
	for input in slot.current_inputs:
		input.remove_on_submission()
	if slot.dealt_card:
		slot.dealt_card.remove_on_submission()
	clear_card_slot(slot)


func reject_input(slot):
	rejected_input.emit()
	for input in slot.current_inputs:
		await input.reject_placement()
		player_hand.add_card_to_hand(input)
		remove_card_as_input(input)

func deal_card(slot, dealer_res):
	card_dealt.emit(slot, dealer_res)
	var new_card: DealerCard = instantiate_dealer_card(dealer_res)
	if not new_card.is_node_ready():
		await new_card.ready
	slot.dealt_card = new_card
	await new_card.emerge_from_hole(dealer_graphic, slot.global_position)
	new_card.start_lifetime()
	
		
func instantiate_dealer_card(dealer_res):
	var card_scene = preload(DEALER_CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	new_card.dealer_res = dealer_res
	new_card.name = "DealerCard"
	new_card.visible = false
	add_child(new_card)
	new_card.connect("lifetime_over", _on_card_lifetime_over)
	return new_card
	
func add_card_as_input(slot, card):
	card_added_as_input.emit(slot, card)
	slot.current_inputs.append(card)

func remove_card_as_input(card):
	for slot in card_slots:
		if card in slot.current_inputs:
			slot.current_inputs.erase(card)
			card_removed_as_input.emit(card)

func choose_type() -> int:
	return sample_using_probs(TYPE_PROBS)
	
func choose_modifier() -> int:
	return sample_using_probs(MODIFIER_PROBS)

func sample_using_probs(probs) -> int:
	var rand = randf()
	var cum_sum = 0
	for result in probs.keys():
		cum_sum += probs[result]
		if cum_sum >= rand:
			return result
	return 0


### SIGNALS
#CardManager
func _on_card_dropped_on_slot(card: Variant, slot: Variant) -> void:
	if slot.current_inputs.size() < slot.allowed_num_inputs:
		slot.current_inputs.append(card)


func _on_card_drag_started(card: Variant) -> void:
	remove_card_as_input(card)
	
