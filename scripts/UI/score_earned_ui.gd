extends Control

@onready var text: Label = $HBoxContainer/Text
@onready var h_box_container: HBoxContainer = $HBoxContainer


var score = 0
var max_score = 200

var min_color = Color("eed17b")
var max_color = Color("cc2b00")


func _ready():
	
	var x_variation = randi_range(-(h_box_container.size.x  / 2), h_box_container.size.x / 2)
	var y_variation = randi_range(-(h_box_container.size.y  / 2), h_box_container.size.y / 2)
	global_position = global_position + Vector2(x_variation, y_variation)
	h_box_container.material = h_box_container.material.duplicate(true)
	h_box_container.material.resource_local_to_scene = true

	var color = min_color.lerp(max_color, clamp(score/max_score, 0, 1))
	h_box_container.material.set_shader_parameter("new_color", color)
	text.text = "+" + str(score)
	
	
	rise_and_fade()
	
func rise_and_fade():
	
	var target_pos = Vector2(global_position.x, global_position.y - 200)
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(self, "position", target_pos, 2)
	tween.parallel().tween_property(h_box_container.material, "shader_parameter/alpha_value", 0, 2)
	tween.parallel().tween_property(h_box_container.material, "shader_parameter/dissolve_value", 0, 2)
	await tween.finished
	queue_free()
