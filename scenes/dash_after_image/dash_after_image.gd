extends Sprite2D

@export var fade_duration: float = 0.5

var fade_timer: float = 0.0

func _ready() -> void:
	fade_timer = fade_duration

func _process(delta: float) -> void:
	if fade_timer > 0:
		fade_timer -= delta
		modulate.a = 0.8 * (fade_timer / fade_duration)

		if fade_timer <= 0:
			queue_free()
