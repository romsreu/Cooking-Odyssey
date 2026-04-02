extends Control
@onready var sfx_slider: HSlider = $SFXSlider
@onready var music_slider: HSlider = $MusicSlider

signal sfx_slider_value_not_zero
signal music_slider_value_not_zero

signal sfx_slider_value_zero
signal music_slider_value_zero

var mute_slider : int = 0

func _ready() -> void:
	sfx_slider.value = GameData.get_sfx_volume()
	music_slider.value = GameData.get_music_volume()

func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		AudioManager.set_volume(
			AudioManager.get_sfx_bus(), 
			AudioManager.slider_to_db(sfx_slider.value)
		)
		GameData.save_sfx_volume(sfx_slider.value)
		
		if sfx_slider.value == 0:
			sfx_slider_value_zero.emit()
		else:
			sfx_slider_value_not_zero.emit()
		

func _on_music_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		AudioManager.set_volume(
			AudioManager.get_music_bus(), 
			AudioManager.slider_to_db(music_slider.value)
		)
		GameData.save_music_volume(music_slider.value)
		
		if music_slider.value == 0:
			music_slider_value_zero.emit()
		else:
			music_slider_value_not_zero.emit()

func sfx_toggle_off ():
	sfx_slider.value = mute_slider
	
func sfx_toggle_on (restore_volume):
	sfx_slider.value = restore_volume

func music_toggle_off():
	music_slider.value = mute_slider

func music_toggle_on(restore_volume):
	music_slider.value = restore_volume
