extends Node2D

@export var STARTING_HAND_SIZE = 3
@export var STARTING_DEAL_SIZE = 3

@onready var dealer_manager = $"../DealerManager"
@onready var player_deck    = $"../../Layout/PlayerZone/PlayerDeck"
@onready var player_hand    = $"../../Layout/PlayerZone/PlayerHand"
@onready var action_manager: Node2D = $"../ActionManager"
@onready var energy_ui: Control = $"../../UI/EnergyUI"

@onready var main_menu_scene = preload("/Users/Lordf/cardgame/scenes/menu/main_menu.tscn") as PackedScene
@onready var game_scene = preload("res://scenes/main.tscn") as PackedScene


signal used_energy(cost)
signal score_changed(score)
signal display_added_score(pos, score)
signal game_end_animation

const ENERGY_COSTS = {
	"addition" : 1,
	"duplication": 1,
	"draw" : 1
}

var mp_manager = null
var sp_manager = null

var game_type: GameInfo.GameTypes

func _ready() -> void:
	game_type = GameInfo.game_type
	if game_type == GameInfo.GameTypes.MULTIPLAYER:
		mp_manager = add_game_type_manager("mp_manager")
	else:
		sp_manager = add_game_type_manager("sp_manager")
		
func _on_main_ready() -> void:
	if game_type == GameInfo.GameTypes.MULTIPLAYER:
		Lobby.player_loaded.rpc_id(1) # Notifies host; once everyone’s ready -> start
	else:
		singleplayer_start_game()

func add_score(score):
	GameInfo.game_score += score
	
	score_changed.emit(GameInfo.game_score)
	if game_type == GameInfo.GameTypes.MULTIPLAYER:
		mp_manager.opponent_score_changed.rpc()
	
func singleplayer_start_game():
	
	GameInfo.game_score = 0 # reset score
	
	for i in range(STARTING_HAND_SIZE):
		player_deck.draw_card()
	for i in range(STARTING_DEAL_SIZE):
		deal_card(dealer_manager.card_slots[i])
	
	await get_tree().create_timer(3.0).timeout
	
	sp_manager.start_game()
	

func deal_card(slot, card_res = null, type=null, modifier=null):
	# Only the multiplayer authority is required to deal new cards
	if is_multiplayer_authority():
		if card_res == null:
			card_res = dealer_manager.random_sample()
		if type == null:
			type = dealer_manager.choose_type()
		if modifier == null:
			modifier = dealer_manager.choose_modifier()
		var dealer_res = DealerCardResource.new().init(card_res, type, modifier)
		dealer_manager.deal_card(slot, dealer_res)
		
func draw_card():
	player_deck.draw_card()
	
func perform_action(active_card, eclipsed_card) -> bool:
	# Returns bool based on whether the action was successful
	match action_manager.current_action_mode:
		action_manager.action_modes.ADDITION:
			if action_manager.can_perform_addition(active_card, eclipsed_card):
				var cost = ENERGY_COSTS["addition"]
				#if energy_ui.use_energy(cost):
				return action_manager.add(active_card, eclipsed_card)
				#else:
					#energy_ui.blink()

	return false
				

# Submission has extra functions to help with syncing during multiplayer
func submit_input(slot, inputs):
	if slot.dealt_card and slot.dealt_card.dealer_res.verify_input(inputs):
		if is_multiplayer_authority():
			# Authority does not need to verify submission
			dealer_manager.accept_input(slot)
			deal_card(slot)
		else:
			# Client needs to sync submission with server
			mp_manager.request_card_submission(slot, inputs)
	else:
		dealer_manager.reject_input(slot)
		
####

func use_energy(action):
	var cost = ENERGY_COSTS[action]
	if cost:
		used_energy.emit(cost)


func add_game_type_manager(script_name: String):
	var manager = load("res://scripts/game_types/%s.gd" % script_name).new() 
	get_node("/root/Main/Managers").add_child.call_deferred(manager)
	return manager
	
func end_game():
	game_end_animation.emit()
	

func _on_accepted_input(slot) -> void:
	var pos = slot.global_position
	var score = slot.dealt_card.dealer_res.bounty
	display_added_score.emit(pos, score)
	add_score(slot.dealt_card.dealer_res.bounty)


func _on_card_dropped_on_slot(card: Variant, slot: Variant) -> void:
	# This is deferred, so the current_inputs are gauranteed to be up to date
	if slot.current_inputs.size() == slot.allowed_num_inputs:
		submit_input(slot, slot.current_inputs)

func _on_card_manager_action_taken(action) -> void:
	if action == action_manager.action_modes.ADDITION:
		use_energy("addition")


func _on_game_over_ui_exit_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)


func _on_game_over_ui_retry_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)


func _on_card_lifetime_expired(slot: Variant) -> void:
	deal_card(slot)


func _on_action_manager_begin_duplication(active_card: Variant) -> void:
	action_manager.dupe(active_card)
