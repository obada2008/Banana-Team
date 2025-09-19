extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func change_scene():
	animation_player.play("dissolve")
	await animation_player.animation_finished
	GameManager.load_next_level_scene()
	animation_player.play_backwards("dissolve")
