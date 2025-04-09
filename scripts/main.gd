extends Node2D

var sp_layout = preload("res://scenes/layouts/layout_singleplayer.tscn")
var mp_layout = preload("res://scenes/layouts/layout_multiplayer.tscn")

func _enter_tree() -> void:
	GameInfo.game_type = GameInfo.GameTypes.SINGLEPLAYER
	
	if GameInfo.game_type == GameInfo.GameTypes.MULTIPLAYER:
		add_child(mp_layout.instantiate())
	else:
		add_child(sp_layout.instantiate())
		
