extends BaseMobileButton

const MUSIC_TOGGLE_BUTTON = preload("uid://cele588k07dyy")
const MUSIC_TOGGLE_OFF = preload("uid://ipuwjaxaqhvd")


signal music_toggled_off
signal music_toggled_on (restore_volume)

var toggled_off_volume = 0
var toggled_on_volume = 80

func _ready() -> void:
	super()
	if GameData.get_music_volume() == 0:
		set_pressed_no_signal(true)
		self.icon = MUSIC_TOGGLE_OFF
	else: 
		set_pressed_no_signal(false)
		self.icon = MUSIC_TOGGLE_BUTTON


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		set_off_icon()
		AudioManager.set_volume(AudioManager.get_music_bus(), AudioManager.slider_to_db(toggled_off_volume))
		GameData.save_music_volume(toggled_off_volume)
		music_toggled_off.emit()
	else:
		set_on_icon()
		AudioManager.set_volume(AudioManager.get_music_bus(), AudioManager.slider_to_db(toggled_on_volume))
		GameData.save_music_volume(toggled_on_volume)
		music_toggled_on.emit(toggled_on_volume)

func set_on_icon (): 
	self.icon = MUSIC_TOGGLE_BUTTON
	
func set_off_icon ():
	self.icon = MUSIC_TOGGLE_OFF
