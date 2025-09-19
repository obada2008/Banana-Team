extends Node

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const TOTAL_LEVELS: int = 5

var current_level: int = 0
var level_scenes = {}

func _ready() -> void:
	for ln in range(1, TOTAL_LEVELS + 1):
		level_scenes[ln] = load("res://scenes/levels/level_%s.tscn" % ln)

func get_total_levels():
	return TOTAL_LEVELS

func get_current_level():
	return current_level

func load_main_scene():
	current_level = 0
	get_tree().change_scene_to_packed(MAIN_SCENE)

func load_next_level_scene():
	set_next_level()
	get_tree().change_scene_to_packed(level_scenes[current_level])

func set_next_level():
	current_level += 1

	if current_level > TOTAL_LEVELS:
		current_level = 1
