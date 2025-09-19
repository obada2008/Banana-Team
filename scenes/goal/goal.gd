extends Area2D

@export var is_final_level: bool = false

var DISAPPEAR_SCENE: PackedScene = preload("res://scenes/disappear/disappear.tscn")

func add_child_deferred(child_to_add):
	get_tree().root.add_child(child_to_add)

func call_add_child(child_to_add):
	call_deferred("add_child_deferred", child_to_add)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.visible = false
		body.can_move = false
	
		if is_final_level:
			AudioManager.play_music("victory")
		else:
			AudioManager.play_sfx("goal")

		var disappear = DISAPPEAR_SCENE.instantiate()
		disappear.global_position = body.global_position
		call_add_child(disappear)

		await get_tree().create_timer(0.5).timeout

		if is_final_level:
			SignalManager.on_game_complete.emit()
		else:
			SignalManager.on_level_complete.emit()
			SceneTransition.change_scene()
