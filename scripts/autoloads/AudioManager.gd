extends Node

var music_bus := "Music"
var sfx_bus := "SFX"
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var current_music: AudioStream = null

func _set_music_player() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "Music_Player"
	music_player.bus = music_bus
	set_volume(music_bus, slider_to_db(GameData.get_music_volume()))
	add_child(music_player)

func _set_sfx_player() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFX_Player"
	sfx_player.bus = sfx_bus
	set_volume(sfx_bus, slider_to_db(GameData.get_sfx_volume()))
	add_child(sfx_player)

func _ready():
	_set_music_player()
	_set_sfx_player()

func play_music(stream: AudioStream) -> void:
	if current_music == stream:
		return 
	current_music = stream
	music_player.stop()
	music_player.stream = stream
	music_player.play()

func stop_music() -> void:
	music_player.stop()
	current_music = null

func play_sfx(stream: AudioStream) -> void:
	sfx_player.stream = stream
	sfx_player.play()
	await sfx_player.finished

func set_volume(bus: String, db: float):
	var index = AudioServer.get_bus_index(bus)
	if index == -1:
		push_error("Bus '%s' no encontrado." % bus)
		return
	print_rich("[[b][color=green]", self.name, "[/color][/b]]",
		" New ", bus, " volume: ", db, " dB")
	AudioServer.set_bus_volume_db(index, db)

func get_sfx_bus () -> String:
	return sfx_bus

func get_music_bus () -> String:
	return music_bus

func slider_to_db(slider_value: float) -> float:
	if slider_value <= 0.0:
		return -80.0  # mute total
	var linear = slider_value / 100.0
	return -40.0 + (linear * 40.0)  

func db_to_slider(db: float) -> float:
	if db <= -80.0:
		return 0.0  
	var clamped_db = clamp(db, -40.0, 0.0)
	return ((clamped_db + 40.0) / 40.0) * 100.0
