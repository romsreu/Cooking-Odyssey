extends BaseMobileButton

var _tween: Tween = null

func _ready() -> void:
	super()
	self.visible = false

func set_visible_with_animation(showw: bool) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()

	if showw:
		if not visible:
			scale = Vector2.ZERO
			modulate.a = 0.0
			visible = true

		_tween.parallel().tween_property(
			self, "scale", Vector2.ONE, 0.6
		).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

		_tween.parallel().tween_property(
			self, "modulate:a", 1.0, 0.3
		).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

	else:
		# Primero desvanecer y reducir escala al mismo tiempo
		_tween.parallel().tween_property(
			self, "scale", Vector2.ZERO, 0.3
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

		_tween.parallel().tween_property(
			self, "modulate:a", 0.0, 0.2
		).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

		# Finalmente, ocultarlo
		_tween.tween_callback(func(): visible = false)
