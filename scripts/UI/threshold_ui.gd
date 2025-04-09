extends Control

@onready var timer_progress_bar: TextureProgressBar = $TimerUI/TimerPanel/TimerProgressBar
@onready var time_label: RichTextLabel = $TimerUI/TimePanel/TimeLabel
@onready var timer_progress: Timer = $TimerUI/TimerPanel/Timer
@onready var timer_ui: VBoxContainer = $TimerUI
@onready var flip_display: Control = $Threshold/FlipDisplay

var elapsed_time = 0
var time_given = 0


func make_timer_appear():
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(timer_ui, "modulate", Color.WHITE, 1.0)

func _ready():
	timer_ui.modulate = Color.TRANSPARENT


func _on_threshold_score_changed(new_score):
	timer_ui.position.x = flip_display.get_display_size().x + 20
	make_timer_appear()
	$Threshold/FlipDisplay.value = new_score

func _on_threshold_start(time_given):
	self.time_given = time_given
	self.elapsed_time = 0
	_update_time_label(elapsed_time)
	timer_progress_bar.step = 0.1
	timer_progress_bar.max_value = time_given
	timer_progress.one_shot = false
	timer_progress.start(0.1)
	
	
func _update_time_label(seconds):
	var time_left = time_given - seconds
	var min = time_left / 60
	var sec = time_left % 60
	time_label.text = "[center]" + str(min).pad_zeros(2) + ":" + str(sec).pad_zeros(2) + "[/center]"

func _on_progress_update() -> void:
	elapsed_time += 1
	
	if elapsed_time % 10 == 0:
		_update_time_label(int(elapsed_time / 10))
	
	timer_progress_bar.value += 0.1

func _on_threshold_stop():
	timer_progress.stop()
	timer_progress_bar.value = 0
	_update_time_label(0)


func _on_game_manager_game_end_animation() -> void:
	self.visible = false
