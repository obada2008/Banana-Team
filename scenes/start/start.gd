extends StaticBody2D

@onready var spawn_position: Marker2D = $SpawnPosition
var player: Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	SignalManager.on_player_hit.connect(_on_player_hit)

func _on_player_hit():
	player.global_position = spawn_position.global_position
	player.spawn_player()
