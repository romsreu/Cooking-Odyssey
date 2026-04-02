extends ColorRect

@onready var rect: ColorRect = $"."
var mat: ShaderMaterial

func _ready():
	mat = rect.material as ShaderMaterial

func play_horizontal(piece_pos: Vector2) -> void:
	rect.size = Vector2(2000.0, 64.0)
	rect.position = piece_pos
	mat.set_shader_parameter("is_horizontal", true)
	_animate()

func play_vertical(piece_pos: Vector2) -> void:
	rect.size = Vector2(64.0, 2000.0)
	rect.position = piece_pos
	mat.set_shader_parameter("is_horizontal", false)
	_animate()
	
func _animate() -> void:
	var tween = create_tween()
	tween.tween_method(func(v): mat.set_shader_parameter("progress", v), 0.0, 1.0, 0.45)
	tween.tween_callback(queue_free)
