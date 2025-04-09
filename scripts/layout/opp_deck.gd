extends Node2D

@onready var opp_hand = $"../OpponentHand"
@onready var input_manager = $"../../../Managers/InputManager"
@onready var card_manager = $"../../../Managers/CardManager"

const CARD_SCENE_PATH = "res://scenes/cards/opp_card.tscn"
const CARD_DRAW_SPEED = 0.2

#@onready var card_database = get_node("../../../Managers/DatabaseManager").db_res

var deck = ["🌍", "💧", "🔥", "💧", "🌍", "🔥", "🔥"] 

func _ready() -> void:
	if not opp_hand.is_node_ready():
		await opp_hand.ready
	
	var hand_width = opp_hand.hand.size() * opp_hand.CARD_SPACING
	instantiate_sprites()

	
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
		
func draw_card(pattern, color):
	var new_card = instantiate_card(pattern, color)
	opp_hand.add_card_to_hand(new_card)

func instantiate_card(pattern, color):
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	new_card.color = color
	new_card.pattern = pattern
	new_card.name = "OppCard"
	add_child(new_card)
	return new_card
