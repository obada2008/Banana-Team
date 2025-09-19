extends Node2D

@onready var spiked_ball: RigidBody2D = $SpikedBall

@export var oscillation_force: float = 600.0

func _ready() -> void:
	spiked_ball.apply_central_impulse(Vector2(oscillation_force, 0))
