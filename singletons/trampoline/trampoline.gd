extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var jump_force: float = 600.0

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		AudioManager.play_sfx("trampoline")
		animated_sprite_2d.play("jump")
		body.jump(jump_force)
