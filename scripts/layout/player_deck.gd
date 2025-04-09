extends Node2D

@onready var player_hand = $"../PlayerHand"
@onready var input_manager = $"../../../Managers/InputManager"
@onready var card_manager = $"../../../Managers/CardManager"


signal drawn_card(card)
signal attempted_overdraw

const CARD_DRAW_SPEED = 0.2

@onready var db_manager = get_node("../../../Managers/DatabaseManager")

var deck = [1, 2, 3, 4, 5, 6]

func _ready() -> void:
	await get_tree().process_frame
	if not player_hand.is_node_ready():
		await player_hand.ready
		
	input_manager.connect('primary_pressed', on_primary_pressed)
	
	var hand_width = player_hand.hand.size() * player_hand.CARD_SPACING
	instantiate_sprites()
	

func on_primary_pressed():
	if input_manager.raycast_check_for_card_deck():
		await draw_card()
	
func instantiate_sprites():
	var offset = Vector2(-15, 15)
	for i in range(clamp(deck.size() - 1, 0, 5)):
		var copied_sprite = $Graphics/CardBackGraphic.duplicate()
		copied_sprite.visible = true
		copied_sprite.position += offset * (i+1)
		copied_sprite.z_index = deck.size() - i
		$Graphics/BackLayer.add_child(copied_sprite)

func remove_sprite():
	var sprites = $Graphics/BackLayer.get_children()
	if sprites.size() > 0:
		$Graphics/BackLayer.remove_child(sprites[-1])
		
func draw_card():
	
	if player_hand.hand.size() >= player_hand.MAX_HAND_SIZE:
		for card in player_hand.hand:
			card.shake()
		return
	if card_manager.total_card_instances >= GameInfo.max_cards:
		attempted_overdraw.emit()
		return
		
	if not $DrawCooldown.is_stopped:
		await $DrawCooldown.timeout
		
	var card_res = db_manager.sample_from_deck()
	
	if deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Graphics/CardBackGraphic.visible = false
		
	var new_card = card_manager.instantiate_card(card_res, global_position)
	if not new_card.is_node_ready():
		await new_card.ready
		
	drawn_card.emit(new_card)
	
	new_card.flip()
	player_hand.add_card_to_hand(new_card)
	
	# Activate cooldown
	$DrawCooldown.start()
