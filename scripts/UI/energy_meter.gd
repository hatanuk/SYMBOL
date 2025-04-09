extends Control

@export var initial_BPS = 0.5
@onready var beat_timer = $BeatTimer
@onready var animated_heart = $BeatingHeart
@onready var energy_points = $RightPanel/EnergyPoints.get_children()
@onready var heart_panel = $HeartPanel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var regen_interval = 5

@onready var label = $RichTextLabel

signal update_energy_points(energy)

@onready var max_energy = energy_points.size() * regen_interval

var energy = 0
var target = 0


func _ready() -> void:
	
	target = 0
	animated_heart.position = heart_panel.get_size() / 2
	beat_timer.start()
	animated_heart.play()
	animated_heart.sprite_frames.set_animation_speed("gif", 24)
	
	var i = 0
	for ep in energy_points:
		ep.ep_pos = i
		ep.max_value = regen_interval
		i += 1
	
	
func _on_beating_heart_animation_looped() -> void:
	
	var filled_points = energy / regen_interval
	
	if energy < max_energy:
		energy += 1
		
	for ep in energy_points:
		ep.update_energy_points(energy)
		
		
func use_energy(points) -> bool:
	var filled_points = energy / regen_interval
	
	if filled_points > 0:
		energy -= (regen_interval+1) * points
		return true
		
	else:
		return false
		
func blink():
	animation_player.play("blink")


func _on_game_manager_game_end_animation() -> void:
	self.visible = false
