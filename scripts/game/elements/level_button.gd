extends BaseMobileButton
class_name LevelButton

static var LEVEL_BUTTONS_COLOR_TYPES: int = 10

@onready var level_number_label: Label = $LevelNumberLabel
@onready var level_button_texture: TextureRect = $LevelButtonTexture
@onready var stars_container: Control = $StarsContainer
@onready var lock_icon: TextureRect = $LockIcon

var level_id: int
var level_number: String
var is_unlocked: bool = false
var stars: int = 0
var button_color: ButtonColor

const BLUE_BUTTON = preload("uid://ccpuk7opprrpg")
const CELESTE_BUTTON = preload("uid://dn0x6gdpoykrd")
const GRAY_BUTTON = preload("uid://d1xl4ub6ide0o")
const GREEN_BUTTON = preload("uid://dvy0bol3rohl4")
const ORANGE_BUTTON = preload("uid://d2mracan2xyyg")
const PINK_BUTTON = preload("uid://rexdgispioh8")
const PURPLE_BUTTON = preload("uid://dfh6g4x4dikgi")
const RED_BUTTON = preload("uid://rovc6j2x460m")
const WHITE_BUTTON = preload("uid://bjxu5m4moqx1k")
const YELLOW_BUTTON = preload("uid://vy44ffrhfah")

enum ButtonColor { 
	PURPLE, 
	PINK,  
	RED,   
	ORANGE,   
	YELLOW, 
	GREEN,   
	CELESTE,
	BLUE,     
	GRAY,     
	WHITE     
}

# ========== MÉTODO PÚBLICO PRINCIPAL ==========

func setup(id: int, color: ButtonColor, unlocked: bool, star_count: int) -> void:
	name = "LevelButton" + str(level_id)
	level_id = id
	level_number = str(id)
	button_color = color
	is_unlocked = unlocked
	stars = star_count

	if is_node_ready():
		_apply_setup()

func get_level_id() -> int:
	return level_id

# ========== MÉTODOS PRIVADOS ==========

func _apply_setup() -> void:
	update_label()
	apply_color()
	update_visual_state()

func update_label():
	if level_number_label:
		level_number_label.text = level_number if is_unlocked else ""

func set_next_color():
	button_color = ((button_color + 1) % LEVEL_BUTTONS_COLOR_TYPES) as ButtonColor
	apply_color()

func update_visual_state():
	if lock_icon:
		lock_icon.visible = not is_unlocked
	
	if level_number_label:
		level_number_label.visible = is_unlocked
	
	if stars_container:
		# Mostrar estrellas solo si el nivel está desbloqueado Y tiene al menos 1 estrella
		stars_container.visible = is_unlocked and stars > 0
		if stars_container.visible:
			update_stars_display()
	

func update_stars_display() -> void:
	for i in range(stars_container.get_child_count()):
		var star = stars_container.get_child(i)
		if star is TextureRect:
			star.modulate.a = 1.0 if i < stars else 0.6

func apply_color():
	if not level_button_texture:
		return
		
	match button_color:
		ButtonColor.ORANGE:
			level_button_texture.texture = ORANGE_BUTTON
		ButtonColor.YELLOW:
			level_button_texture.texture = YELLOW_BUTTON
		ButtonColor.GREEN:
			level_button_texture.texture = GREEN_BUTTON
		ButtonColor.CELESTE:
			level_button_texture.texture = CELESTE_BUTTON
		ButtonColor.BLUE:
			level_button_texture.texture = BLUE_BUTTON
		ButtonColor.PURPLE:
			level_button_texture.texture = PURPLE_BUTTON
		ButtonColor.PINK:
			level_button_texture.texture = PINK_BUTTON
		ButtonColor.RED:
			level_button_texture.texture = RED_BUTTON
		ButtonColor.WHITE:
			level_button_texture.texture = WHITE_BUTTON
		ButtonColor.GRAY:
			level_button_texture.texture = GRAY_BUTTON

func get_button_color_value() -> Color:
	match button_color:
		ButtonColor.PURPLE:
			return Color(0.58, 0.29, 0.8)  
		ButtonColor.PINK:
			return Color(1.0, 0.4, 0.7)   
		ButtonColor.RED:
			return Color(0.9, 0.2, 0.2)    
		ButtonColor.ORANGE:
			return Color(1.0, 0.6, 0.0)   
		ButtonColor.YELLOW:
			return Color(1.0, 0.9, 0.0)  
		ButtonColor.GREEN:
			return Color(0.2, 0.8, 0.3)  
		ButtonColor.CELESTE:
			return Color(0.3, 0.8, 0.9)   
		ButtonColor.BLUE:
			return Color(0.2, 0.4, 0.9)    
		ButtonColor.GRAY:
			return Color(0.5, 0.5, 0.5)    
		ButtonColor.WHITE:
			return Color(1.0, 1.0, 1.0)
	return Color.WHITE
	
func _ready():
	super._mobile_button_setup()
	_apply_setup()
