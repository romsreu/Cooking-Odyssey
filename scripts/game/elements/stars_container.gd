extends Control

func fill_star(amount: int) -> void:
	# Asegurarse de que amount esté en el rango válido
	amount = clamp(amount, 0, get_child_count())
	
	for i in range(amount):
		var star_container = get_child(i)
		
		# Buscar el FilledStar dentro del contenedor
		var filled_star = null
		for child in star_container.get_children():
			if "FilledStar" in child.name:
				filled_star = child
				break
		
		if filled_star:
			# Hacer visible el FilledStar
			filled_star.visible = true
			filled_star.modulate.a = 1.0
			
			# Configurar el pivot point al centro
			if filled_star is Sprite2D:
				filled_star.offset = Vector2.ZERO
			
			# Iniciar desde escala 0
			filled_star.scale = Vector2.ZERO
			
			# Crear el tween
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_BACK)
			
			# Animar la escala desde 0 hasta 1 con un pequeño delay por estrella
			tween.tween_property(
				filled_star,
				"scale",
				Vector2.ONE,
				0.4
			).set_delay(i * 0.1)
