extends Control

@onready var go_back_button: Button = $SettingsPanel/GoBackButton
@onready var sub_menu_stack: Control = $MenuClip/SubMenuStack
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
