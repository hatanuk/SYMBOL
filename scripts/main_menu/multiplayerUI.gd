extends Control

@export var game_scene: PackedScene

@onready var code_entry = $Panel/CodeEntry
@onready var status_label = $Panel/StatusLabel
@onready var start_button = $Panel/StartButton
@onready var host_button = $Panel/HostButton

var can_begin = false

func _ready():
	start_button.visible = false
	Lobby.player_connected.connect(_on_player_connected)
	Lobby.server_disconnected.connect(_on_server_disconnected)

func _on_host_button_pressed():
	
	Lobby.player_info = {"name": "Server"}
	var error = Lobby.create_game()
	if error:
		status_label.text = "Failed to create lobby."
		return
	status_label.text = "Lobby created: " + PlayerInfo.player_name
	start_button.visible = true
	_disable_controls()



func _on_join_button_pressed():
	
	# Get the code from CodeEntry and pass it to PackRPC
	
	var address = Lobby.DEFAULT_SERVER_IP
	Lobby.player_info = {"name": "Client"}
	var error = Lobby.join_game(address)
	if error:
		status_label.text = "Failed to join lobby."
		return
	status_label.text = "Joining lobby..."
	_disable_controls()

func _on_player_connected(peer_id, player_info):
	status_label.text = "Player connected: " + player_info.name
	can_begin = true
	

func _on_server_disconnected():
	status_label.text = "Server disconnected."
	can_begin = false
	_enable_controls()

func _disable_controls():
	host_button.disabled = true
	$Panel/JoinButton.disabled = true
	$Panel/CodeEntry.editable = false
	#$JoinAddressInput.editable = false

func _enable_controls():
	host_button.disabled = false
	$Panel/JoinButton.disabled = false
	$Panel/CodeEntry.editable = true
	#$JoinAddressInput.editable = true
	start_button.visible = false

func _on_start_button_pressed():
	if Lobby.players.size() == 2:
		Lobby.load_game.rpc(game_scene.resource_path)
	else:
		status_label.text = "Not enough players"
