extends Node2D

func _ready() -> void:
	get_tree().paused = false
	AudioManager.play_music("level")

func _process(delta: float) -> void:
	ScoreManager.add_time(delta)


func _on_timer_timeout() -> void:
	pass # Replace with function body.
