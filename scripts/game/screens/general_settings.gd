extends CanvasLayer

@onready var sub_menu_stack: Control = $GeneralSettings/MenuClip/SubMenuStack
@onready var go_back_button: Button = $GeneralSettings/SettingsPanel/GoBackButton
@onready var audio_settings: Control = $GeneralSettings/MenuClip/SubMenuStack/AudioSettings

@onready var toggle_sfx_button: Button = $GeneralSettings/MenuClip/SubMenuStack/MainSettings/ToggleBttnsContainer/ToggleSFXButton
@onready var toggle_music_button: Button = $GeneralSettings/MenuClip/SubMenuStack/MainSettings/ToggleBttnsContainer/ToggleMusicButton

var tween: Tween
var menu_width: float
var is_animating: bool = false

func _ready():
	# IMPORTANTE: Este menú NO se pausa
	process_mode = Node.PROCESS_MODE_ALWAYS
	menu_width = sub_menu_stack.size.x
	hide()

func show_settings():
	show()
	get_tree().paused = true

func go_to_menu(index: int):
	if is_animating:
		return
	
	if tween and tween.is_valid():
		tween.kill()
	
	var target_x = -index * menu_width
	
	tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(
		sub_menu_stack,
		"position:x",
		target_x,
		0.25
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	is_animating = true
	await tween.finished
	is_animating = false
	
	if index == 0:
		_remove_go_back_button()
	else:
		_show_go_back_button()

func _on_audio_settings_pressed():
	go_to_menu(1)

func _show_go_back_button():
	go_back_button.set_visible_with_animation(true)

func _remove_go_back_button():
	go_back_button.set_visible_with_animation(false)

func _on_go_back_button_pressed():
	go_to_menu(0)

func _on_close_button_pressed():
	get_tree().paused = false
	hide()


func _on_toggle_sfx_button_sfx_toggled_off() -> void:
	audio_settings.sfx_toggle_off()

func _on_toggle_music_button_music_toggled_off() -> void:
	audio_settings.music_toggle_off()

func _on_toggle_sfx_button_sfx_toggled_on(restore_volume: Variant) -> void:
	audio_settings.sfx_toggle_on(restore_volume)
	
func _on_toggle_music_button_music_toggled_on(restore_volume : Variant) -> void:
	audio_settings.music_toggle_on(restore_volume)

func _on_audio_settings_music_slider_value_not_zero() -> void:
	toggle_music_button.set_on_icon()
	toggle_music_button.set_pressed_no_signal(false)

func _on_audio_settings_music_slider_value_zero() -> void:
	toggle_music_button.set_off_icon()
	toggle_music_button.set_pressed_no_signal(true)

func _on_audio_settings_sfx_slider_value_not_zero() -> void:
	toggle_sfx_button.set_on_icon()
	toggle_sfx_button.set_pressed_no_signal(false)

func _on_audio_settings_sfx_slider_value_zero() -> void:
	toggle_sfx_button.set_off_icon()
	toggle_sfx_button.set_pressed_no_signal(true)
