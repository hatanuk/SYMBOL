extends Control

@onready var icon_fallback = preload("res://resources/icon_cache/2753.png")
@onready var active_card_emoji = $"Panel/ActiveCardEmoji"
@onready var eclipsed_card_emoji = $"Panel/EclipsedCardEmoji"
@onready var result_emoji = $"Panel/ResultEmoji"
@onready var panel = $"Panel"
@onready var operators = $"Panel/Operators"
@onready var anim_player = $AnimationPlayer
@onready var linger_timer = $LingerTimer
@onready var initial_pos = panel.global_position

@export var static_position: bool = false

var shown: bool = false
var lingering: bool = false

func _ready():
	self.modulate = Color(0, 0, 0, 0)

func _on_action_manager_display_hint(action: String, unicode1: String, unicode2: String, unicode_result: String, pos: Vector2) -> void:
	set_all_operators_invisible()
	var tex1 = load_icon(unicode1)
	var tex2 = load_icon(unicode2)
	var tex3 = load_icon(unicode_result)
	
	
	if not static_position:
		var x_offset = pos.x - panel.size.x/2 * panel.scale.x
		panel.global_position = Vector2(x_offset, pos.y)
	else:
		panel.global_position = initial_pos
	
	active_card_emoji.texture = tex1
	eclipsed_card_emoji.texture = tex2
	result_emoji.texture = tex3
	
	match action:
		"addition":
			operators.find_child("Addition").visible = true
		"subtraction":
			operators.find_child("Subtraction").visible = true
	
	if static_position:
		lingering = true # prevents hint from immediately dissapearing with a grace period 
		linger_timer.start()
	
	if not shown:
		fade_in()
		shown = true
	
func _on_action_manager_hide_hint() -> void:
	if static_position and lingering:
		return
	if shown:
		fade_out()
		shown = false


func fade_in() -> void:
	anim_player.play("fade in")
	await anim_player.animation_finished 
	
func fade_out() -> void:
	anim_player.play("fade out")
	await anim_player.animation_finished 
	

func load_icon(unicode) -> Texture:
	var tex = load("res://resources/icon_cache/%s.png" % unicode)
	if tex == null:
		tex = icon_fallback
	return tex

func set_all_operators_invisible():
	for operator in operators.get_children():
		operator.visible = false


func _on_linger_timer_timeout() -> void:
	lingering = false
