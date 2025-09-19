extends AnimatableBody2D

@export var p1: Marker2D
@export var p2: Marker2D
@export var speed: float = 50.0

var tween: Tween

func _ready() -> void:
	var distance = p1.global_position.distance_to(p2.global_position)
	var time_to_move = distance / speed
	
	tween = get_tree().create_tween()
	tween.set_loops(0)
	tween.tween_property(self, "global_position", p1.global_position, time_to_move)
	tween.tween_property(self, "global_position", p2.global_position, time_to_move)

func _exit_tree() -> void:
	tween.kill()
