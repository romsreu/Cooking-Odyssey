@tool
extends BaseMobileButton
@export var custom_texture: Texture2D

@onready var texture_node := $TextureRect

@export var label_text: String = "Texto personalizado" :
	set(value):
		label_text = value
		update_label()

@onready var label_node := $Label

func _ready():
	super()
	update_label()
	update_texture()

func update_texture():
	if texture_node and custom_texture:
		texture_node.texture = custom_texture

func update_label():
	if not is_instance_valid(label_node):
		return

	label_node.text = label_text
