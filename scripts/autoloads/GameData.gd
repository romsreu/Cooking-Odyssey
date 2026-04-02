extends Node

const SAVE_PATH := "user://user_data/"
const DEFAULT_PATH := "res://data/"
const MEDIA_FILE := "media_data.json"
const LEVEL_PROGRESS_FILE := "levels_progress.json"

var media_data: Dictionary
var level_progress_data: Dictionary

func _ready():
	_ensure_save_directory()
	_load_media_data()
	_load_level_progress()

func _ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_recursive_absolute(SAVE_PATH)

func _load_media_data() -> void:
	var user_path := SAVE_PATH + MEDIA_FILE
	
	if FileAccess.file_exists(user_path):
		media_data = _load_json(user_path)
	else:
		media_data = _load_json(DEFAULT_PATH + MEDIA_FILE)
		if media_data:
			_save_json(MEDIA_FILE, media_data)

func _load_level_progress() -> void:
	var user_path := SAVE_PATH + LEVEL_PROGRESS_FILE
	
	if FileAccess.file_exists(user_path):
		level_progress_data = _load_json(user_path)
	else:
		level_progress_data = _load_json(DEFAULT_PATH + LEVEL_PROGRESS_FILE)
		if level_progress_data:
			_save_json(LEVEL_PROGRESS_FILE, level_progress_data)

func _load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		var content := file.get_as_text()
		var parsed = JSON.parse_string(content)
		return parsed if parsed else {}
	push_error("No se pudo abrir: " + path)
	return {}

func _save_json(filename: String, data: Dictionary) -> void:
	var path := SAVE_PATH + filename
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
	else:
		push_error("No se pudo escribir: " + path)

# ========== MEDIA ==========
func save_music_volume(volume: float) -> void:
	media_data["music_volume"] = volume
	_save_json(MEDIA_FILE, media_data)

func save_sfx_volume(volume: float) -> void:
	media_data["sfx_volume"] = volume
	_save_json(MEDIA_FILE, media_data)

func save_vibration_status(status: bool) -> void:
	media_data["vibration"] = status
	_save_json(MEDIA_FILE, media_data)

func get_music_volume() -> float:
	return media_data.get("music_volume", 1.0)

func get_sfx_volume() -> float:
	return media_data.get("sfx_volume", 1.0)
	
func get_vibration_status() -> bool:
	return media_data.get("vibration", true)

# ========== LEVEL PROGRESS ==========
func get_total_levels() -> int:
	var levels = level_progress_data.get("levels", [])
	return levels.size()

func get_level_data(level_id: int) -> Dictionary:
	var levels = level_progress_data.get("levels", [])
	for level in levels:
		if level.get("id") == level_id:
			return level
	return {}

func is_level_unlocked(level_id: int) -> bool:
	var level_data = get_level_data(level_id)
	return level_data.get("unlocked", false)

func get_level_stars(level_id: int) -> int:
	var level_data = get_level_data(level_id)
	return level_data.get("stars", 0)

func unlock_level(level_id: int) -> void:
	var levels = level_progress_data.get("levels", [])
	for level in levels:
		if level.get("id") == level_id:
			level["unlocked"] = true
			_save_json(LEVEL_PROGRESS_FILE, level_progress_data)
			return

func set_level_stars(level_id: int, stars: int) -> void:
	var levels = level_progress_data.get("levels", [])
	for level in levels:
		if level.get("id") == level_id:
			level["stars"] = clamp(stars, 0, 3)
			_save_json(LEVEL_PROGRESS_FILE, level_progress_data)
			return

func complete_level(level_id: int, stars: int) -> void:
	set_level_stars(level_id, stars)
	# Desbloquear el siguiente nivel
	unlock_level(level_id + 1)
