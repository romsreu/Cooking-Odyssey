extends Node2D
class_name PathDrawer

var points: Array[Vector2] = []
var colors: Array[Color] = []

func append_point(point: Vector2, color: Color) -> void:
	points.append(point)
	colors.append(color)

func clear_points() -> void:
	points.clear()
	colors.clear()

func draw_path(line: Line2D, offset: Vector2 = Vector2.ZERO, shadow_offset: Vector2 = Vector2(3, 3)) -> void:
	if points.is_empty():
		return
	
	var shadow_line: Line2D = null
	if line.has_node("Shadow"):
		shadow_line = line.get_node("Shadow")
	else:
		shadow_line = Line2D.new()
		shadow_line.name = "Shadow"
		line.add_child(shadow_line)
	
	shadow_line.clear_points()
	shadow_line.position = shadow_offset
	shadow_line.width = line.width + 2
	shadow_line.default_color = Color(0, 0, 0, 0.4)
	shadow_line.joint_mode = Line2D.LINE_JOINT_ROUND
	
	for point in points:
		shadow_line.add_point(point)
	
	# Configurar línea principal
	line.clear_points()
	line.position = offset
	
	# Crear el gradiente considerando segmentos
	var gradient = Gradient.new()
	
	for i in range(points.size()):
		line.add_point(points[i])
		
		if i == 0:
			# Primer punto
			gradient.add_point(0.0, colors[0])
		elif i == points.size() - 1:
			# Último punto
			gradient.add_point(1.0, colors[i])
		else:
			# Puntos intermedios
			var offset_ratio = float(i) / float(points.size() - 1)
			
			# Si el color actual es diferente al anterior, crear transición
			if colors[i] != colors[i - 1]:
				# Agregar el color anterior justo antes del cambio
				var prev_offset = float(i - 1) / float(points.size() - 1)
				gradient.add_point(prev_offset, colors[i - 1])
				# Agregar el nuevo color
				gradient.add_point(offset_ratio, colors[i])
			else:
				# Mismo color, mantener continuidad
				gradient.add_point(offset_ratio, colors[i])
	
	line.gradient = gradient
