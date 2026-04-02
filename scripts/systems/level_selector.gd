extends Control

const LEVEL_BUTTON = preload("uid://c30k6yanvru6a")

@export var button_spacing_y: float = 120.0
@export var margin_top: float = 50.0
@export var serpentine_offset: float = 80.0

@onready var levels_container: Control = $VerticalScrollContainer/LevelsContainer
@onready var levels_path_main: Line2D = $VerticalScrollContainer/LevelsContainer/LevelsPathMain

var path_drawer: PathDrawer
var levels_amount: int

func _ready():
	levels_amount = GameData.get_total_levels()
	_add_levels()
	arrange_levels_serpentine()
	get_viewport().size_changed.connect(_on_viewport_resized)

func _add_levels() -> void:
	if levels_amount == 0:
		push_warning("No hay niveles en level_progress.json")
		return
	
	var color_change_counter = 0
	@warning_ignore("integer_division")
	var color_change_frequency = max(1, levels_amount / LevelButton.LEVEL_BUTTONS_COLOR_TYPES)
	
	var current_color = 0
	
	for i in range(levels_amount):
		var level_id = i + 1
		var level_button = LEVEL_BUTTON.instantiate()
		var is_unlocked = GameData.is_level_unlocked(level_id)
		var stars = GameData.get_level_stars(level_id)
		level_button.setup(level_id, current_color, is_unlocked, stars)
		
		if is_unlocked:
			level_button.pressed.connect(_on_level_button_pressed.bind(level_id))
		
		levels_container.add_child(level_button)
		
		color_change_counter += 1
		if color_change_counter >= color_change_frequency:
			current_color = (current_color + 1) % LevelButton.LEVEL_BUTTONS_COLOR_TYPES
			color_change_counter = 0

func _on_level_button_pressed(level_id: int) -> void:
	print("Nivel seleccionado: ", level_id)
	GameData.unlock_level(level_id+1)
	# Aquí cargas la escena del nivel
	# get_tree().change_scene_to_file("res://scenes/levels/level_" + str(level_id) + ".tscn")

func _on_resized():
	arrange_levels_serpentine()

func _on_viewport_resized():
	await get_tree().process_frame
	arrange_levels_serpentine()

func arrange_levels_serpentine():
	if not levels_container:
		return
	
	path_drawer = PathDrawer.new()
	
	var level_buttons: Array[Node] = []
	for child in levels_container.get_children():	
		if child is LevelButton:
			level_buttons.append(child)
	
	if level_buttons.is_empty():
		return
	
	var center_x = size.x / 2.0
	var total_levels = level_buttons.size()
	
	path_drawer.clear_points()
	
	for i in range(total_levels):
		var button = level_buttons[i]
		var inverted_index = total_levels - 1 - i
		var pos_y = margin_top + (inverted_index * button_spacing_y)
		var button_size = button.size if button.size != Vector2.ZERO else Vector2(64, 64)
		var pos_x: float
		
		if i % 2 == 0:
			pos_x = center_x - serpentine_offset - button_size.x / 2.0
		else:
			pos_x = center_x + serpentine_offset - button_size.x / 2.0
		
		button.position = Vector2(pos_x, pos_y)
		
		var button_center = Vector2(pos_x + button_size.x / 2.0, pos_y + button_size.y / 2.0)
		var button_color = button.get_button_color_value()
		path_drawer.append_point(button_center, button_color)
	
	path_drawer.draw_path(levels_path_main, Vector2.ZERO)
	
	var container_height = margin_top + (total_levels * button_spacing_y) + 50
	levels_container.custom_minimum_size.y = container_height

func refresh_layout():
	arrange_levels_serpentine()
