extends Control

@export var icon_size = 50
@export var separation = -3
@export var scramble_duration = 1.5
@export var max_letters = 6
@export var padding = true
@export var active_color = Color.WHITE

@onready var h_box_container: HBoxContainer = $HBoxContainer

@onready var activated_mat = preload("res://shaders/flip_display_materials/activated.tres")
@onready var deactivated_mat = preload("res://shaders/flip_display_materials/deactivated.tres")

@export var value: int = 0:
	set(val):
		value = clamp(val, 0, pow(10, max_letters) - 1)
		value_changed()
		
func get_display_size():
	if not is_node_ready():
		await ready
	return h_box_container.size * scale

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	h_box_container.add_theme_constant_override("separation", separation)
	value_changed()
	

func value_changed():
	
	if not h_box_container.is_node_ready():
		await h_box_container.is_node_ready()
	
	var val_str = str(value)
	clear_letters()
	print(h_box_container)
	
	if padding:
		var to_pad = max_letters - val_str.length()
		if to_pad > 0:
			for i in range(to_pad):
				var font = number_to_font_icon("0")
				add_letter(font)
	
	# Exception: 0 does not count as "activated"
	var activated = true		
	if value == 0:
		activated = false
	for num in val_str:
		var font = number_to_font_icon(num)
		add_letter(font, activated)
		
	if scramble_duration > 0:
		scramble_effect(scramble_duration)
	
		
func clear_letters():
	for letter in h_box_container.get_children():
		h_box_container.remove_child(letter)
		
func add_letter(font, active=false):
	var font_icon = FontIcon.new()
	font_icon.icon_settings = font
	if active:
		font_icon.modulate = active_color
		font_icon.material = activated_mat
	else:
		font_icon.material = deactivated_mat
		
	h_box_container.add_child(font_icon)

func number_to_font_icon(num: String) -> FontIconSettings:
	var font = FontIconSettings.new()
	font.icon_font = "Emojis"
	var name = "keycap_" + num
	font.icon_name = name
	font.icon_size = icon_size
	return font
	
func scramble_effect(duration):
	var original_settings = []
	for letter in h_box_container.get_children():
		original_settings.append(letter.icon_settings)
	
	var time_awaited = 0
	while time_awaited < duration:
		for i in range(h_box_container.get_child_count()):
			var letter = h_box_container.get_child(i)
			letter.icon_settings = number_to_font_icon(str(randi_range(0, 9)))
			letter._on_icon_settings_changed()
		time_awaited += 0.05
		await get_tree().create_timer(0.05).timeout
	
	for letter in h_box_container.get_children():
		letter.icon_settings = original_settings.pop_front()
		letter._on_icon_settings_changed()



func _on_h_slider_value_changed(value: float) -> void:
	icon_size = value
	value_changed()


func _on_h_slider_2_value_changed(value: float) -> void:
	separation = value
	h_box_container.add_theme_constant_override("separation", separation)
	

func _on_spin_box_value_changed(value: float) -> void:
	self.value = value
	await scramble_effect(1)
