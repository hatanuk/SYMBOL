extends Control

@onready var mp_card = $HoleGraphic/MultiplayerCard
@onready var sp_card = $HoleGraphic/SingleplayerCard
@onready var input_filter = $InputFilter
@onready var exit: TextureButton = $MarginContainer/IconButtons/VBoxContainer/Exit
@onready var settings: TextureButton = $MarginContainer/IconButtons/VBoxContainer/Settings

@onready var game_scene = preload("res://scenes/main.tscn") as PackedScene

var is_startup = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	
	# Set the actual title letters invisible as the animated ones will take their place
	hide_template_elements()
	
	if is_startup:
		perform_startup_anim()
	else:
		position_elements()


func hide_template_elements():
	var title = $MarginContainer/VBoxContainer/Title
	for letter in title.get_children():
		letter.modulate = Color(1, 1, 1, 0)
	mp_card.modulate = Color(1, 1, 1, 0)
	sp_card.modulate = Color(1, 1, 1, 0)
	
	
func get_letters():
	var letters = []
	for letter in $HoleGraphic/Mask.get_children():
		letters.append(letter)
	return letters

func position_elements():
	
	# Letter positioning
	var title = $MarginContainer/VBoxContainer/Title
	var letters = get_letters()
	
	for i in range(letters.size()):
		letters[i].size = title.get_child(i).size * 2
		letters[i].global_position = title.get_child(i).global_position
		letters[i].reparent($HoleGraphic)
	
	# Show menu cards
	mp_card.modulate = Color(1, 1, 1, 1)
	sp_card.modulate = Color(1, 1, 1, 1)
	
func perform_startup_anim():
	hide_icon_buttons()
	disable_inputs(false)
	
	var title = $MarginContainer/VBoxContainer/Title
	var letters = get_letters()
	
	for i in range(letters.size()):
		letters[i].size = title.get_child(i).size * 2
		await animate_letter_to(letters[i], title.get_child(i).global_position)
	
	await animate_menu_cards()
	
	enable_inputs()
	show_icon_buttons()

func hide_icon_buttons():
	for icon_button in $MarginContainer/IconButtons/VBoxContainer.get_children():
		icon_button.modulate =  Color(1, 1, 1, 0)
		
func show_icon_buttons():
	for icon_button in $MarginContainer/IconButtons/VBoxContainer.get_children():
		icon_button.get_node("AnimationPlayer").play("fade_in")
		
func enable_inputs():
	input_filter.modulate = Color(0, 0, 0, 0)
	input_filter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func disable_inputs(dim: bool):
	input_filter.mouse_filter = Control.MOUSE_FILTER_STOP
	if dim:
		input_filter.modulate = Color(0, 0, 0, 0.4)
	else:
		input_filter.modulate = Color(0, 0, 0, 0)
	
func animate_menu_cards():
	var mp_card_original_pos = mp_card.global_position
	var sp_card_original_pos = sp_card.global_position
	
	var hole_pos = Vector2($HoleGraphic/Hole.global_position.x + 45, $HoleGraphic/Hole.global_position.y + 250)
	
	mp_card.reparent($HoleGraphic/Mask)
	sp_card.reparent($HoleGraphic/Mask)
	mp_card.global_position = hole_pos
	sp_card.global_position = hole_pos
	mp_card.modulate = Color(1, 1, 1, 1)
	sp_card.modulate = Color(1, 1, 1, 1)
	
	sp_card.reparent($HoleGraphic/Mask)
	await pop_out_of_hole(sp_card, 300)
	sp_card.reparent($HoleGraphic)
	await move_to(sp_card, sp_card_original_pos)
	
	mp_card.reparent($HoleGraphic/Mask)
	await pop_out_of_hole(mp_card, 300)
	mp_card.reparent($HoleGraphic)
	await move_to(mp_card, mp_card_original_pos)
	
		
func animate_letter_to(letter, final_pos):
	var tween = get_tree().create_tween()
	
	# Move out of hole
	letter.global_position = Vector2($HoleGraphic/Hole.global_position.x + 80, $HoleGraphic/Hole.global_position.y + 200)	
	await pop_out_of_hole(letter, 200)
	letter.reparent($HoleGraphic)
	# Move to title
	move_to(letter, final_pos)

func pop_out_of_hole(node, y_offset):
	var tween = get_tree().create_tween()
	var pos = Vector2(node.global_position.x, node.global_position.y - y_offset)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "global_position", pos, 0.5)
	await tween.finished
	
func move_to(node, pos):
	var tween = get_tree().create_tween()
	tween.tween_property(node, "global_position", pos, 0.4)
	await tween.finished


func _on_multiplayer_card_gui_input(event: InputEvent) -> void:
	if event.is_action("primary_interact"):
		if event.is_pressed():  
			mp_card.get_node("AnimationPlayer").play("on_click")
			
	if event is InputEventMouseMotion:
		shader_3d_effect(event, mp_card)

			

func _on_singleplayer_card_gui_input(event: InputEvent) -> void:
	if event.is_action("primary_interact"):
		if event.is_pressed():  
			sp_card.get_node("AnimationPlayer").play("on_click")
			await sp_card.get_node("AnimationPlayer").animation_finished
			begin_singleplayer()
			
	if event is InputEventMouseMotion:
		shader_3d_effect(event, sp_card)
	
func begin_singleplayer():
	GameInfo.game_type = GameInfo.GameTypes.SINGLEPLAYER
	get_tree().change_scene_to_packed(game_scene)

func shader_3d_effect(event, card):
	
	var mouse_pos: Vector2 = card.get_node('SubViewport/Graphics/CardBase').get_local_mouse_position()
	var size = card.get_node('SubViewport/Graphics').get_size()
	mouse_pos.x = clamp(mouse_pos.x, 0, size.x)
	mouse_pos.y = clamp(mouse_pos.y, 0, size.y)
	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	
	var angle_x_max: float = deg_to_rad(10.0)
	var angle_y_max: float = deg_to_rad(10.0)
	var target_rot_x = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
	var target_rot_y = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_val_y))
	card.target_rot_x = target_rot_x
	card.target_rot_y = target_rot_y

	


func _on_exit_pressed() -> void:
	exit.get_node("AnimationPlayer").play("on_click")
	await exit.get_node("AnimationPlayer").animation_finished
	get_tree().quit()


func _on_settings_pressed() -> void:
	settings.get_node("AnimationPlayer").play("on_click")
	await settings.get_node("AnimationPlayer").animation_finished
