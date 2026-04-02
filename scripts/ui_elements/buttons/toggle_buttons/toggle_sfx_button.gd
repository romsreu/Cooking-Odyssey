extends BaseMobileButton

const SOUND_EFFECTS_BUTTON = preload("uid://bwh85srt1qt8j")
const SOUND_EFFECTS_OFF = preload("uid://colhvywgd1sui")

signal sfx_toggled_off
signal sfx_toggled_on (restore_volume)

var toggled_off_volume = 0
var toggled_on_volume = 80

func _ready() -> void:
	super()
	if GameData.get_sfx_volume() == 0:
		set_pressed_no_signal(true)
		self.icon = SOUND_EFFECTS_OFF
	else: 
		set_pressed_no_signal(false)
		self.icon = SOUND_EFFECTS_BUTTON

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		set_off_icon()
		AudioManager.set_volume(AudioManager.get_sfx_bus(), AudioManager.slider_to_db(toggled_off_volume))
		GameData.save_sfx_volume(toggled_off_volume)
		sfx_toggled_off.emit()
	else:
		set_on_icon()
		AudioManager.set_volume(AudioManager.get_sfx_bus(), AudioManager.slider_to_db(toggled_on_volume)) 
		GameData.save_sfx_volume(toggled_on_volume)
		sfx_toggled_on.emit(toggled_on_volume)

func set_on_icon ():
	self.icon = SOUND_EFFECTS_BUTTON 
	
func set_off_icon ():
	self.icon = SOUND_EFFECTS_OFF
