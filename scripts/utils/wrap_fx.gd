extends ColorRect

@onready var rect: ColorRect = $"."
var mat: ShaderMaterial

func _ready():
	mat = rect.material as ShaderMaterial
	# 200x200 centrado
	rect.size = Vector2(200.0, 200.0)
	rect.position = Vector2(-100.0, -100.0)

func play() -> void:
	var tween = create_tween()
	tween.tween_method(func(v): mat.set_shader_parameter("progress", v), 0.0, 1.0, 0.5)
	tween.tween_callback(queue_free)
