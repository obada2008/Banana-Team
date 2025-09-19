extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const FRUITS: Array = ["banana"]
const COLLECTED_SCENE: PackedScene = preload("res://scenes/collected/collected.tscn")

func _ready() -> void:
	animated_sprite_2d.play(FRUITS.pick_random())

func add_child_deferred(child_to_add):
	get_tree().root.add_child(child_to_add)

func call_add_child(child_to_add):
	call_deferred("add_child_deferred", child_to_add)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		AudioManager.play_sfx("fruit")
		SignalManager.on_pickup_item.emit()

		var collected = COLLECTED_SCENE.instantiate()
		collected.global_position = global_position
		call_add_child(collected)

		queue_free()
