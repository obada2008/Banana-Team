extends Button


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
	pass # Replace with function body.


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
	pass # Replace with function body.
