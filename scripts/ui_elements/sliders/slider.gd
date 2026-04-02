extends HSlider
@onready var slider: HSlider = $"."

func _ready() -> void:
	slider.focus_mode = Control.FOCUS_NONE
