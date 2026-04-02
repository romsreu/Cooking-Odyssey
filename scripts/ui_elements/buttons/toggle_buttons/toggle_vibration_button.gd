extends BaseMobileButton

const VIBRATION_OFF = preload("uid://bw7632b7bigra")
const VIBRATION_TOGGLE_BUTTON = preload("uid://ujgx8dkch6xo")

func _ready() -> void:
	super()
	if GameData.get_vibration_status() == true:
		set_pressed_no_signal(true)
		self.icon = VIBRATION_OFF
	else:
		set_pressed_no_signal(false)
		self.icon = VIBRATION_TOGGLE_BUTTON

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		self.icon = VIBRATION_OFF
		GameData.save_vibration_status(false)
	else:
		self.icon = VIBRATION_TOGGLE_BUTTON
		GameData.save_vibration_status(true)
