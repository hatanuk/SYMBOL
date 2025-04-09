extends Node2D

# Controls the threshold score system
# threshold continiously increases and must be met under time limit

@onready var game_manager: Node2D = $"../GameManager"
var timer: Timer = Timer.new()

@export var threshold_time_limit = 30
@export var initial_threshold: int = 300
@export var max_th_difference: int = 1000
@export var th_difference_multiplier: float = 1.2
@onready var threshold_ui: Control = $"../../UI/ThresholdUI"


var threshold: int = 0
var th_difference: int = initial_threshold

signal threshold_score_changed(new_score)


func start_game():
	threshold = initial_threshold
	threshold_score_changed.emit(threshold)
	threshold_ui._on_threshold_score_changed(threshold)
	
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = threshold_time_limit
	timer.connect("timeout", _on_th_timeout)
	add_child(timer)
	
	start_threshold()
	
func increment_difference():
	th_difference = th_difference * th_difference_multiplier
	th_difference = clamp(th_difference, 0, max_th_difference)
	
func _on_th_timeout():
	threshold_ui._on_threshold_stop()
	
	if GameInfo.game_score < threshold:
		game_manager.end_game()
		timer.stop()
		return
	
	# Threshold update
	threshold += th_difference
	# Round to nearest hundred places
	threshold = int(ceil(float(threshold) / 100) * 100)
	increment_difference()
	###
	
	GameInfo.game_rank += 1
	
	start_threshold()

func start_threshold():
	threshold_score_changed.emit(threshold)
	threshold_ui._on_threshold_score_changed(threshold)
	await get_tree().create_timer(2).timeout
	threshold_ui._on_threshold_start(threshold_time_limit)
	timer.start()
