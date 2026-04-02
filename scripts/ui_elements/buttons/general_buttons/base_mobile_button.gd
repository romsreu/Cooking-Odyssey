extends Button
class_name BaseMobileButton

const CANCEL_POP = preload("uid://bvk64igtjhiqj")
const UI_BUTTON_CONFIRM_POP = preload("uid://jeu4qbuh0iu5")
const UI_BUTTON_FIRST_POP = preload("uid://bck70xfu4231i")

@export var idle_animation := false

var tween: Tween
var idle_tween: Tween
var was_pressed := false
var cancelled := false

func _ready():
	_mobile_button_setup()

func _mobile_button_setup():
	focus_mode = Control.FOCUS_NONE
	
	await get_tree().process_frame
	pivot_offset = size * 0.5
	
	connect("button_down", _on_button_down)
	connect("button_up", _on_button_up)
	connect("mouse_exited", _on_mouse_exited)

	if idle_animation:
		_start_idle_animation()

func _start_idle_animation() -> void:
	if idle_tween: idle_tween.kill()
	idle_tween = create_tween()
	idle_tween.set_loops()  # loop infinito
	idle_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	idle_tween.tween_property(self, "scale", Vector2(1.03, 1.03), 1.0)
	idle_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 1.0)

func _stop_idle_animation() -> void:
	if idle_tween:
		idle_tween.kill()
		idle_tween = null
	scale = Vector2.ONE

func _on_button_down() -> void:
	was_pressed = true
	cancelled = false

	AudioManager.play_sfx(UI_BUTTON_FIRST_POP)
	if tween: tween.kill()
	_stop_idle_animation()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(0.88, 0.88), 0.12)

func _on_mouse_exited() -> void:
	if was_pressed:
		cancelled = true
		AudioManager.play_sfx(CANCEL_POP)
		was_pressed = false

	if tween: tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.12)

	if idle_animation:
		await tween.finished
		_start_idle_animation()

func _on_button_up() -> void:
	if not was_pressed or cancelled:
		return

	if tween: tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.12)

	AudioManager.play_sfx(UI_BUTTON_CONFIRM_POP)

	was_pressed = false
	cancelled = false

	if idle_animation:
		await tween.finished
		_start_idle_animation()
