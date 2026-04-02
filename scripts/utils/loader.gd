extends ColorRect

@export var appear_duration: float = 0.6
@export var start_scale: float = 0.85
@export var end_scale: float = 1.0
@export var autoplay: bool = true

var _tween: Tween

func _ready():
	if autoplay:
		appear()
	else:
		# Importante: ocultarlo desde el arranque
		visible = false

func appear():
	# Asegurarse de que no se vea antes
	visible = true

	# Estado inicial REAL de aparición
	modulate.a = 0.0
	scale = Vector2.ONE * start_scale

	# Cancelar tween anterior
	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_ease(Tween.EASE_OUT)

	# Fade in
	_tween.tween_property(
		self,
		"modulate:a",
		1.0,
		appear_duration
	)

	# Scale in (un poco más rápido para punch)
	_tween.parallel().tween_property(
		self,
		"scale",
		Vector2.ONE * end_scale,
		appear_duration * 0.85
	)
