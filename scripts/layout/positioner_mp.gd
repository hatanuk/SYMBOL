extends Node2D

@onready var player_zone = $PlayerZone
@onready var player_area_shape = $PlayerZone/PlayerArea/ShapePlayer
@onready var player_hand = $PlayerZone/PlayerHand
@onready var player_deck = $PlayerZone/PlayerDeck

@onready var opp_zone = $OpponentZone
@onready var opp_area_shape = $OpponentZone/OpponentArea/ShapeOpponent
@onready var opp_hand = $OpponentZone/OpponentHand
@onready var opp_deck = $OpponentZone/OpponentDeck
@onready var hint_ui = $"../UI/Hint"

@onready var dealer_graphic = $DealerZone/DealerGraphic
@onready var dealer_area_shape = $DealerZone/DealerArea/ShapeDealer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position_player_elements()
	
func position_player_elements():
	const DECK_OFFSET_LEFT = 100
	const DEALER_OFFSET_RIGHT = -250
	
	player_hand.global_position = player_area_shape.global_position
	player_deck.global_position = player_area_shape.global_position
	dealer_graphic.global_position = dealer_area_shape.global_position
	
	opp_hand.global_position = opp_area_shape.global_position
	opp_deck.global_position = opp_area_shape.global_position
	
	var player_area_size = player_area_shape.shape.get_rect().size * player_area_shape.scale
	player_deck.global_position.x -= player_area_size.x / 2 + DECK_OFFSET_LEFT
	
	var opp_area_size = opp_area_shape.shape.get_rect().size * opp_area_shape.scale
	opp_deck.global_position.x -= opp_area_size.x / 2 + DECK_OFFSET_LEFT
	
	var dealer_area_size = dealer_area_shape.shape.get_rect().size * dealer_area_shape.scale
	
	dealer_graphic.global_position.x -= dealer_area_size.x / 2 + DEALER_OFFSET_RIGHT
	
	
func position_ui_elements():
	hint_ui.initial_position = player_area_shape.global_position
	
