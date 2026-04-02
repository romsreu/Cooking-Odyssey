extends Control

const LEVEL_MAP = preload("uid://bos2b5dyds6qn")
var admob : Admob
var banner_ad_space: Vector2

@onready var settings_button: Button = $GameSpace/SettingsButton


func _ready() -> void:

	if OS.get_name() == "Android":
		
		if AdmobUtil.admob_exists():
			AdmobUtil.load_banner_ad()
			await AdmobUtil.banner_ad_loaded
			banner_ad_space = AdmobUtil.get_banner_dimension()
			AdmobUtil.show_banner_ad()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(LEVEL_MAP)
