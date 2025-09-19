extends Control

@onready var level_label: Label = %LevelLabel
@onready var timer_label: Label = %TimerLabel
@onready var item_label: Label = %ItemLabel
@onready var background: ColorRect = %Background
@onready var game_complete: CenterContainer = %GameComplete
@onready var score_label: Label = %ScoreLabel
@onready var best_score_label: Label = %BestScoreLabel
@onready var buttons = [%MainButton, %QuitButton]

var current_button_index = 0
var total_levels: int = GameManager.get_total_levels()

var time_left: float = 25  # ⬅️ المؤقت

func _ready() -> void:
	set_process_mode(Node2D.PROCESS_MODE_ALWAYS)

	set_level_label()
	set_item_label()
	hide_hud()

	SignalManager.on_pickup_item.connect(on_pickup_item)
	SignalManager.on_game_complete.connect(on_game_complete)

func _process(delta: float) -> void:
	var current_time = ScoreManager.total_time
	update_timer_label(current_time)

	time_left -= delta
	timer_label.text = "Time Left: " + str(int(time_left))

	if time_left <= 0:
		_on_Timer_timeout()

	if background.visible:
		handle_input()

func _on_Timer_timeout() -> void:
	print("Time out")
	get_tree().reload_current_scene()

func update_timer_label(time: float) -> void:
	var minutes = int(time / 60)
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 100)

	var time_text = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
	# انتبه: هذا يظهر الوقت الإجمالي في HUD، بينما السطر فوق يظهر العداد التنازلي.

func hide_hud():
	background.visible = false
	game_complete.visible = false

func show_hud():
	get_tree().paused = true
	buttons[0].grab_focus()
	background.visible = true

func set_level_label():
	var current_level = GameManager.get_current_level()
	if total_levels == current_level:
		level_label.text = "FINAL STAGE"
	else:
		level_label.text = "STAGE " + str(current_level)

func set_item_label():
	item_label.text = str(ScoreManager.get_total_items())

func on_pickup_item():
	set_item_label()

func on_game_complete():
	game_complete.visible = true
	score_label.text = "Score: " + str(ScoreManager.calculate_score())
	best_score_label.text = "Best Score: " + str(ScoreManager.get_best_score())
	show_hud()

func handle_input():
	if Input.is_action_just_pressed("ui_up"):
		move_focus(-1)
	elif Input.is_action_just_pressed("ui_down"):
		move_focus(1)
	elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_select"):
		buttons[current_button_index].emit_signal("pressed")

func move_focus(direction: int) -> void:
	buttons[current_button_index].release_focus()
	current_button_index = (current_button_index + direction + buttons.size()) % buttons.size()
	buttons[current_button_index].grab_focus()

func _on_main_button_pressed() -> void:
	GameManager.load_main_scene()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
