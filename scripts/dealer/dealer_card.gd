extends Node2D 
class_name DealerCard

var position_in_hand: Vector2
var drag_offset: Vector2 

const MOMENTUM = 0.5
const ACCELERATION = 30
var velocity: Vector2 = Vector2(0, 0)

signal lifetime_over(dealer_card)

const DEFAULT_CARD_SPEED = 0.2
const EMOJI_ICON_RES = 256

@export var dealer_res: DealerCardResource
@export var initial_lifetime: int = 10
var lifetime

@onready var card_database = get_node("../../DatabaseManager").db_res

var card_visuals: CardVisuals
  
@onready var base_scale: Vector2 = self.scale

@onready var dealer_manager = get_parent()

@onready var lifetime_timer: Timer = $LifetimeTimer


func _ready() -> void:
	if dealer_res == null:
		print("Error initiating card: DealerCardResource not set")
		self.remove()
		return
	
	setup_visuals()
	
	lifetime = initial_lifetime
	
func start_lifetime():
	lifetime_timer.start()
	var tween = get_tree().create_tween()
	var viewport = get_node("SubViewportContainer")
	tween.tween_property(viewport.material, "shader_parameter/dissolve_value", 0.7, lifetime)
	
func _on_tickdown():
	lifetime -= 1
	if lifetime <= 0:
		lifetime_over.emit(self)
	
func setup_visuals():
	var viewport = get_node("SubViewportContainer")
	var card_back = get_node("SubViewportContainer/SubViewport/Graphics/CardBase/CardBack")
	var card_front = get_node("SubViewportContainer/SubViewport/Graphics/CardBase/CardFront")
	var card_back_pattern = get_node("SubViewportContainer/SubViewport/Graphics/CardBase/CardBack/CardBackPattern")
	var card_base = get_node("SubViewportContainer/SubViewport/Graphics/CardBase")
	
	viewport.material = viewport.material.duplicate()

	card_visuals = CardVisuals.new()
	card_visuals.card_res = dealer_res.card_res
	
	card_visuals = CardVisuals.new()
	card_visuals.card_res = dealer_res.card_res
	
	card_base.get_theme_stylebox("panel").bg_color = card_visuals.primary_color
	card_back.get_theme_stylebox("panel").bg_color = card_visuals.primary_color
	card_back_pattern.get_theme_stylebox("panel").texture = card_visuals.texture
	get_node("SubViewportContainer/SubViewport/Graphics/CardBase/CardFront/EmojiTexture").texture = CacheHandler.load_emoji_single(dealer_res.card_res.unicode, EMOJI_ICON_RES)
	
	viewport.material.set_shader_parameter("speed", 0)
	if dealer_res.card_type == DealerCardResource.CardType.BACKSIDE:
		get_node("SubViewportContainer/SubViewport/Graphics/CardBase/CardBack").visible = true
		get_node("SubViewportContainer/SubViewport/Graphics/CardBase/CardFront").visible = false
	if dealer_res.card_type == DealerCardResource.CardType.GOLD or dealer_res.card_type == DealerCardResource.CardType.SILVER:
		viewport.material.set_shader_parameter("modulate", dealer_res.HolographicColors[dealer_res.card_type])
		viewport.material.set_shader_parameter("speed", 1)
	viewport.material.set_shader_parameter("burn_offset", Vector2(randf(), randf()))

func show_aura(activated: bool, color=Color(1, 1, 1, 1)):
	if activated:
		modulate = color
	else:
		modulate = Color(1, 1, 1, 1)
		
func emerge_from_hole(dealer_graphic, slot_position):
	reparent(dealer_graphic.get_node("DealerMask"))
	global_position = Vector2(dealer_graphic.global_position.x, dealer_graphic.global_position.y + 800)
	get_node("AnimationPlayer").play("emerge")
	visible = true
	await get_node("AnimationPlayer").animation_finished
	reparent(dealer_manager)
	
	get_node("AnimationPlayer").play("card_flip_to_front")
	await animate_to_position(slot_position)
	

func animate_to_position(new_pos, duration=DEFAULT_CARD_SPEED):
	var tween = create_tween()
	update_z_index(200)
	tween.tween_property(self, "position", new_pos, duration)
	await tween.finished
	update_z_index(1)
	
func hover_effect(activated):
	if activated:
		scale = base_scale * 1.05
		update_z_index(2)
	else:
		scale = base_scale
		update_z_index(1)
		
func drag_effect(activated):
	if activated:
		hover_effect(false)
		update_z_index(3)
	else:
		hover_effect(true)
		
		
func remove_on_dissolve() -> void:
	get_node("AnimationPlayer").play("dissolve")
	await get_node("AnimationPlayer").animation_finished
	remove()
	
func remove_on_submission() -> void:
	get_node("AnimationPlayer").play("submit_and_fade")
	await get_node("AnimationPlayer").animation_finished
	remove()
	
func update_z_index(new):
	z_index = new
	
func remove():
	self.queue_free()
