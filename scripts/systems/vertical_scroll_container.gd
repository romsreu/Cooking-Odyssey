@tool
extends Control
class_name MobileScrollContainer

@export var inertia_friction: float = 0.88
@export var min_velocity: float = 5.0

var content: Control
var scroll_offset: float = 0.0

var is_dragging: bool = false
var last_touch_y: float = 0.0

var velocity_y: float = 0.0

var initialized: bool = false

func _ready():
	clip_contents = true
	_find_content()
	
	if not Engine.is_editor_hint():
		mouse_filter = Control.MOUSE_FILTER_STOP
	
	child_entered_tree.connect(_on_child_changed)
	resized.connect(_on_resized)

func _find_content():
	for child in get_children():
		if child is Control:
			content = child
			break

func _on_child_changed(_node):
	_find_content()

func _on_resized():
	_clamp_scroll()
	_update_content_position()

func _sync_scroll_offset():
	if content and not initialized:
		scroll_offset = -content.position.y
		initialized = true

func _input(event: InputEvent):
	if Engine.is_editor_hint():
		return
	
	if event is InputEventScreenTouch:
		if event.pressed:
			_sync_scroll_offset()
			is_dragging = true
			velocity_y = 0.0
			last_touch_y = event.position.y
		else:
			is_dragging = false
			
	elif event is InputEventScreenDrag:
		if not is_dragging:
			_sync_scroll_offset()
			is_dragging = true
			velocity_y = 0.0
			last_touch_y = event.position.y
			return
		
		# Movimiento directo basado en la diferencia
		var delta_y = event.position.y - last_touch_y
		scroll_offset -= delta_y
		
		# Guardar velocidad para inercia (suavizada)
		velocity_y = delta_y * 60.0
		
		last_touch_y = event.position.y
		
		_clamp_scroll()
		_update_content_position()

func _process(delta: float):
	if Engine.is_editor_hint():
		return
	
	# Aplicar inercia solo cuando no estás tocando
	if not is_dragging and abs(velocity_y) > min_velocity:
		scroll_offset -= velocity_y * delta
		velocity_y *= inertia_friction
		_clamp_scroll()
		_update_content_position()
	elif not is_dragging:
		velocity_y = 0.0

func _clamp_scroll():
	if not content:
		return
	
	var max_scroll = max(0.0, content.size.y - size.y)
	scroll_offset = clamp(scroll_offset, 0.0, max_scroll)

func _update_content_position():
	if content:
		content.position.y = -scroll_offset
