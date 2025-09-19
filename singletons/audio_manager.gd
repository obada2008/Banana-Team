extends Node

var sounds = {
	"hurt": load("res://assets/audio/sfx/hurt.wav"),
	"jump": load("res://assets/audio/sfx/jump.wav"),
	"fall": load("res://assets/audio/sfx/fall.wav"),
	"trampoline": load("res://assets/audio/sfx/trampoline.wav"),
	"fruit": load("res://assets/audio/sfx/fruit.wav"),
	"goal": load("res://assets/audio/sfx/goal.wav"),
	"level": load("res://assets/audio/music/level.wav"),
	"victory": load("res://assets/audio/music/victory.wav"),
}

@onready var sound_players: Array[AudioStreamPlayer] = []
@onready var music_player: AudioStreamPlayer = null

const MAX_SFX: int = 5

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

	for i in range(MAX_SFX):
		var player = AudioStreamPlayer.new()
		add_child(player)
		sound_players.append(player)

func play_sfx(sound_name: String):
	var sound_to_play = sounds.get(sound_name)
	if sound_to_play == null:
		print("Invalid sound name: ", sound_name)
		return

	for sound_player in sound_players:
		if !sound_player.playing:
			sound_player.stream = sound_to_play
			sound_player.play()
			return

func play_music(sound_name: String):
	var music_to_play = sounds.get(sound_name)
	if music_to_play == null:
		print("Invalid music name: ", sound_name)
		return

	stop_music()

	music_player.stream = music_to_play
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.play()

func stop_music():
	if music_player.playing:
		music_player.stop()
