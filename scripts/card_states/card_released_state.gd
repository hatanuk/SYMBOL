extends CardState


func enter():
	if not card.is_node_ready():
		await card.ready
		
	card.scale = card.base_scale
	card.find_child("Area2D").collision_layer = 1

	# debug
	card.color.color = Color.PURPLE
	card.state.text = "RELEASED"
	card.z_index_label.text = str(card.z_index)
	
