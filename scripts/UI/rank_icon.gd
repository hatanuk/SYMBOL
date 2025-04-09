@tool
extends Control

@onready var label: Label = $CenterContainer/Label
@onready var font_icon: FontIcon = $CenterContainer/FontIcon

var current_color = Color.GRAY

func _ready():
	GameInfo.connect("game_rank_changed", _on_game_rank_change)
	font_icon.material.set_shader_parameter("new_color", current_color)
	font_icon.material.set_shader_parameter("speed", 0)
	update_rank()

var rank_bracket:
	get:
		for rank in GameInfo.rank_colors.keys():
			if self.rank <= rank:
				return rank
		return GameInfo.rank_colors.keys().max()

var target_color:
	get:
		return GameInfo.rank_colors[rank_bracket]

@export var rank = 1:
	set(value):
		rank = value
		update_rank()

func update_rank():
	if not is_node_ready():
		await self.ready
		
	if rank < GameInfo.rank_colors.keys().max():
		label.text = str(rank)
	else:
		label.text = str(GameInfo.rank_colors.keys().max())
	
	
	var progress = float(rank % 10) / 10.0
	var transitional_color = current_color.lerp(target_color, progress)
	if rank >= rank_bracket:
		current_color = target_color
		transitional_color = target_color
	
	font_icon.material.set_shader_parameter("new_color", transitional_color)
	if rank >= GameInfo.elite_rank_threshold:
		font_icon.material.set_shader_parameter("speed", 0.3)
	else:
		font_icon.material.set_shader_parameter("speed", 0)

func _on_game_rank_change(new_rank):
	rank = new_rank
