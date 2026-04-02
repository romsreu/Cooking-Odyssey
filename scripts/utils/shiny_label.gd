extends Label

@export var shine_time := 0.6

func _ready():

	if material:
		(material as ShaderMaterial).set_shader_parameter("text_size", size)

	resized.connect(func():
		if material:
			(material as ShaderMaterial).set_shader_parameter("text_size", size)
	)


func shine_fx():

	if not material or not material is ShaderMaterial:
		return


	(material as ShaderMaterial).set_shader_parameter("shine_progress", 0.0)


	var tween := create_tween()
	tween.tween_property(
		material as ShaderMaterial,
		"shader_parameter/shine_progress",
		1.0,
		shine_time
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
