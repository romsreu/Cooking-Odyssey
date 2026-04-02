extends ColorRect

var mat: ShaderMaterial
@onready var rect: ColorRect = $"."

func _ready():
	mat = rect.material as ShaderMaterial
	rect.size = Vector2(300.0, 300.0)
	rect.position = Vector2(-150.0, -150.0)

func play() -> void:
	var tween = create_tween()
	tween.tween_method(func(v): mat.set_shader_parameter("progress", v), 0.0, 1.0, 0.6)
	tween.tween_callback(queue_free)
