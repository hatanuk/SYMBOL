extends Node2D 
class_name Card

signal hovered
signal hovered_off
signal card_over_fusable(dragged_card, fusable_card)
signal card_off_fusable(off_card)

signal active_requests_updated
signal active_card_removed
signal active_card_dragged
signal active_card_finished_drag(active_card)
signal card_removed(card)

signal card_eclipsed(card)
signal card_eclipsed_exited

const ACTIONABLE_AURA_COLOR = Color("fefbe1")


@export var angle_x_max: float = deg_to_rad(10.0)
@export var angle_y_max: float = deg_to_rad(10.0)

var position_in_hand: Vector2
var drag_offset: Vector2 
var rot_x: float
var rot_y: float
var target_rot_x: float
var target_rot_y: float


const MOMENTUM = 0.5
const ACCELERATION = 30
var velocity: Vector2 = Vector2(0, 0)

const DEFAULT_CARD_SPEED = 0.2
const EMOJI_ICON_RES = 256

@export var card_res: CardResource
var card_visuals: CardVisuals
  
@onready var base_scale: Vector2 = self.scale
@onready var color: ColorRect = $SubViewportContainer/SubViewport/Debug/Color
@onready var z_index_label: Label = $SubViewportContainer/SubViewport/Debug/ZIndex
@onready var player_hand = get_node("../../../Layout/PlayerZone/PlayerHand")
@onready var card_manager = get_parent()
@onready var action_manager = get_node("../../ActionManager")
@onready var size = $SubViewportContainer/SubViewport/Graphics.get_size() * base_scale
@onready var collision = $Collision
@onready var full_card_shape = $Collision/FullCardArea/CollisionShape2D
@onready var actionable_shape = $Collision/ActionableArea/CollisionShape2D
@onready var state_chart = $StateChart
@onready var card_database = card_manager.card_database
@onready var movement_player: AnimationPlayer = $MovementPlayer
@onready var modulation_player: AnimationPlayer = $ModulationPlayer

  
func _ready() -> void:
	if card_res == null:
		print("Error initiating card: CardResource not set")
		self.remove()
		return
	setup_visuals()
	_on_update_active_card(null)
	_on_update_eclipsed_card(null, null)
	state_chart.set_expression_property("this_card", self)
	state_chart.set_expression_property("mouse_over_card", false)
	card_manager.connect_card_signals(self)
	card_manager.update_active_card.connect(_on_update_active_card)
	card_manager.update_eclipsed_card.connect(_on_update_eclipsed_card)

	action_manager.cancel_action.connect(_on_cancel_action)
	action_manager.begin_addition.connect(_on_begin_addition)
	action_manager.begin_duplication.connect(_on_begin_addition)

func setup_visuals():
	
	var viewport = get_node("SubViewportContainer")
	var card_back = get_node("SubViewportContainer/SubViewport/Graphics/CardBase/CardBack")
	var card_front = get_node("SubViewportContainer/SubViewport/Graphics/CardBase/CardFront")
	var card_back_pattern = get_node("SubViewportContainer/SubViewport/Graphics/CardBase/CardBack/CardBackPattern")
	var card_base = get_node("SubViewportContainer/SubViewport/Graphics/CardBase")
	
	viewport.material = viewport.material.duplicate()

	card_visuals = CardVisuals.new()
	card_visuals.card_res = card_res
	
	card_base.get_theme_stylebox("panel").bg_color = card_visuals.primary_color
	card_back.get_theme_stylebox("panel").bg_color = card_visuals.primary_color
	card_back_pattern.get_theme_stylebox("panel").texture = card_visuals.texture
	get_node("SubViewportContainer/SubViewport/Graphics/CardBase/CardFront/EmojiTexture").texture = CacheHandler.load_emoji_single(card_res.unicode, EMOJI_ICON_RES)
	

### Collision Signals 
func _on_area_2d_mouse_entered() -> void:
	state_chart.set_expression_property("mouse_over_card", true)
	card_manager.cards_requested_to_be_active.append(self)
	active_requests_updated.emit()
	

func _on_area_2d_mouse_exited() -> void:
	state_chart.set_expression_property("mouse_over_card", false)
	card_manager.cards_requested_to_be_active.erase(self)
	active_requests_updated.emit()
	
func _on_area_entered(area: Area2D) -> void:
	pass
	#print(area.name)
	#if area.card_parent:
		#print(area.card_parent.card_res.emoji)
		#var entering_card = area.card_parent
		#if entering_card  == card_manager.active_card:
			#state_chart.send_event("active_card_over")
		#

func _on_area_exited(area: Area2D) -> void:
	pass
	#if area.card_parent:
		#var exiting_card = area.card_parent
		#if exiting_card == card_manager.active_card:
			#state_chart.send_event("active_card_exit")
	###
	
func _on_idle_state_entered() -> void:
	active_card_removed.emit()
	set_shader_rotation(0, 0, true)


# Called by CardManager whenever request to the active state is approved (raycast required)
func transition_to_active() -> void:
	var transition: Transition = $StateChart/Root/Idle/ToActive
	transition.take()
	
# Called by CardManager whenever request to an eclipsed state is approved  (raycast required)
func transition_to_eclipsed() -> void:
	var transition: Transition = $StateChart/Root/Idle/ParallelState/IsEclipsed/NotEclipsed/ToEclipsed
	transition.take()
	
func _on_hovered_state_input(event: InputEvent) -> void:
	if event.is_action("primary_interact"):
		if event.is_pressed():
			state_chart.send_event("primary_pressed")

func _on_dragged_state_input(event: InputEvent) -> void:
	if event.is_action("primary_interact"):
		if event.is_released():
			state_chart.send_event("primary_released")
	
func _on_hovered_state_entered() -> void:
	hover_effect(true)

func _on_hovered_state_exited() -> void:
	hover_effect(false)

func _on_update_active_card(active_card) -> void:
	state_chart.set_expression_property("active_card", active_card)
	state_chart.send_event("active_card_update")

func _on_update_eclipsed_card(active_card, eclipsed_card) -> void:
	state_chart.set_expression_property("eclipsed_card", eclipsed_card)
	state_chart.send_event("eclipsed_card_update")
	
func _on_begin_addition(active_card):
	state_chart.send_event("begin_addition")
	
func _on_begin_duplication(active_card):
	print(active_card)
	state_chart.send_event("begin_duplication")

func _on_cancel_action():
	show_aura(false)
	state_chart.send_event("cancel_action")

	
func show_aura(activated: bool, color=Color(0.85, 0.75, 0.5, 1)):
	if activated:
		$SubViewportContainer/SubViewport/Graphics.modulate = color
	else:
		$SubViewportContainer/SubViewport/Graphics.modulate = Color(1, 1, 1, 1)

func animate_to_position(new_pos, duration=DEFAULT_CARD_SPEED):
	var tween = create_tween()
	update_z_index(200)
	collision.disable()
	tween.tween_property(self, "position", new_pos, duration)
	await tween.finished
	update_z_index(1)
	collision.enable()
	
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

func update_z_index(new):
	z_index = new
	z_index_label.text = str(new)
	
func reject_placement() -> void:
	collision.disable()
	modulation_player.play("reject")
	await modulation_player.animation_finished
	collision.enable()
	
func remove_on_submission() -> void:
	if self in player_hand.hand:
		player_hand.remove_card_from_hand(self)
	collision.disable()
	modulation_player.play("submit_and_fade")
	await modulation_player.animation_finished
	remove()
	
	
func remove():
	card_removed.emit(self)
	self.queue_free()
	
	

func _on_dragged_state_entered() -> void:
	set_shader_rotation(0, 0, true)
	self.actionable_shape.disabled = true
	drag_effect(true)
	active_card_dragged.emit()


func _on_dragged_state_exited() -> void:
	self.actionable_shape.disabled = false
	self.velocity = Vector2.ZERO
	active_card_finished_drag.emit(self)


func _on_addition_state_entered() -> void:
	var active_card = state_chart.get_expression_property("active_card")
	if action_manager.can_perform_addition(active_card, self):
		state_chart.send_event("card_is_combinable")

#func _on_not_eclipsed_event_received(event: StringName) -> void:
	#if event == "active_card_over":
		#print("eclipsing")
		#card_eclipsed.emit(self)

func _on_eclipsed_state_entered() -> void:
	update_z_index(2)

func _on_not_combinable_state_entered() -> void:
	pass
	
func _on_combinable_state_entered() -> void:
	show_aura(true, ACTIONABLE_AURA_COLOR)
	
func _on_eclipsed_state_exited() -> void:
	update_z_index(1)
	card_eclipsed_exited.emit()


func _on_active_state_input(event: InputEvent) -> void:
	
	if not event is InputEventMouseMotion: return
	
	# extra processing step which checks if mouse still on card
	# there are edge cases where mouse_exit_area is not called due to disabled collision
	if not is_mouse_over_card():
		_on_area_2d_mouse_exited()
	
	var mouse_pos: Vector2 = $SubViewportContainer/SubViewport/Graphics/CardBase.get_local_mouse_position()
	var size = $SubViewportContainer/SubViewport/Graphics.get_size()
	mouse_pos.x = clamp(mouse_pos.x, 0, size.x)
	mouse_pos.y = clamp(mouse_pos.y, 0, size.y)
	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	
	target_rot_x = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
	target_rot_y = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_val_y))

func is_mouse_over_card():
	var local_mouse = get_local_mouse_position()
	var half_size = $SubViewportContainer/SubViewport/Graphics.get_size() * 0.5
	var card_rect = Rect2(-half_size, $SubViewportContainer/SubViewport/Graphics.get_size())

	return card_rect.has_point(local_mouse)

func set_shader_rotation(x: float, y: float, tween: bool = false) -> void:
	get_node("SubViewportContainer").material.set_shader_parameter("x_rot", y)
	get_node("SubViewportContainer").material.set_shader_parameter("y_rot", x)


func _on_idle_state_processing(delta: float) -> void:
	if rot_x != 0 or rot_y != 0:
		var speed = 10
		rot_x = lerp(rot_x, 0.0, speed * delta)
		rot_y = lerp(rot_y, 0.0, speed * delta)
		set_shader_rotation(rot_x, rot_y)



func _on_hovered_state_processing(delta: float) -> void:
	var speed = 10
	rot_x = lerp(rot_x, target_rot_x, speed * delta)
	rot_y = lerp(rot_y, target_rot_y, speed * delta)
	set_shader_rotation(rot_x, rot_y)
	
func _on_dragged_state_processing(delta: float) -> void:
	card_manager.move_card_to_mouse(self, delta)
	card_manager.check_eclipsed()
	
	if rot_x != 0 or rot_y != 0:
		var speed = 5
		rot_x = lerp(rot_x, 0.0, speed * delta)
		rot_y = lerp(rot_y, 0.0, speed * delta)
		set_shader_rotation(rot_x, rot_y)

func shake():
	movement_player.play("shake")
	
func flip():
	modulation_player.play("card_flip_to_front")
	
