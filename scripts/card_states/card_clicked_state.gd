extends CardState


func enter():
	if not card.is_node_ready():
		await card.ready
	
	card.color.color = Color.INDIAN_RED
	card.state.text = "CLICKED"
	
func on_input(event: InputEvent):
	if event is InputEventMouseButton and not event.pressed:
		transition_requested.emit(self, CardState.State.BASE)
	if event is InputEventMouseMotion:
		transition_requested.emit(self, CardState.State.DRAGGED)
	
