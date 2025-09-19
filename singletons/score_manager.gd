extends Node

const SCORE_FILE: String = "user://PLATFORMER_SCORES.dat"
const SCORE_KEY: String = "best_score"

var total_time: float = 0.0
var total_items: int = 0
var best_score: int = 0

func _ready() -> void:
	load_best_score()
	SignalManager.on_pickup_item.connect(on_pickup_item)
	SignalManager.on_level_complete.connect(on_level_complete)
	SignalManager.on_game_complete.connect(on_game_complete)

func reset():
	total_time = 0.0
	total_items = 0

func add_time(delta: float):
	total_time += delta

func calculate_score():
	var time_penalty = int(total_time)
	var score = total_items * 10 - time_penalty

	if score > best_score:
		best_score = score

	return score

func get_best_score() -> int:
	return best_score

func get_total_items() -> int:
	return total_items

func save_best_score():
	var file = FileAccess.open(SCORE_FILE, FileAccess.WRITE)

	var data = {
		SCORE_KEY: best_score
	}

	file.store_string(JSON.stringify(data))

func load_best_score():
	if !FileAccess.file_exists(SCORE_FILE):
		return

	var file = FileAccess.open(SCORE_FILE, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())

	if SCORE_KEY in data:
		best_score = data[SCORE_KEY]

func on_pickup_item():
	total_items += 1

func on_level_complete():
	save_best_score()

func on_game_complete():
	save_best_score()
