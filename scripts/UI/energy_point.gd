extends Panel

signal is_filled(ep)

@onready var tex_rect = $TextureRect

@export var highlight_color = Color.DEEP_PINK
@export var max_value: float = 5
@export var initial_value: float = 0

var value = 0:
	set(val):
		value = val
		on_set_value()

var active_tween: Tween

var filled = false

const GROW_DURATION = 0.4
const RESET_DURATION = 0.1

var ep_pos: int

func _ready():
	value = initial_value
	tex_rect.scale = Vector2.ZERO
	
func update_energy_points(energy):
	
	var allocated_progress = energy - ep_pos * max_value
	if allocated_progress >= max_value:
		allocated_progress = max_value
	elif allocated_progress < 0:
		allocated_progress = 0
	
	value = allocated_progress
	var tex_scale = Vector2(value / max_value, value / max_value)
	tween_texture_scale(tex_scale, 0.5)

func highlight(on):
	if on:
		self.modulate = highlight_color
	else:
		self.modulate = Color.WHITE

func tween_texture_scale(tex_scale: Vector2, duration):
	#if active_tween and active_tween.is_running():
		#active_tween.kill()
		
	active_tween = create_tween()
	active_tween.set_ease(Tween.EASE_IN_OUT)
	active_tween.set_trans(Tween.TRANS_ELASTIC)
	var size = tex_rect.size
	tex_rect.set_pivot_offset(size / 2)
	active_tween.tween_property(tex_rect, "scale", tex_scale, duration).from_current()
	if tex_scale.x == 1:
		active_tween.tween_callback(highlight.bind(true))
	else:
		active_tween.tween_callback(highlight.bind(false))
#
func increment_progress():
	if value == max_value:
		return
	value += 1
	var tex_scale = Vector2(value / max_value, value / max_value)
	tween_texture_scale(tex_scale, GROW_DURATION)

func on_set_value():
	if self.value == self.max_value:
		self.filled = true
		#await active_tween.finished
		is_filled.emit(self)
	else:
		self.filled = false
#
	#
func reset_progress():
	
	value = 0
	tween_texture_scale(Vector2.ZERO, RESET_DURATION)

func set_progress(value: float):
	value = value
	var tex_scale = Vector2(value/ max_value, value / max_value)
	tex_rect.scale = tex_scale
