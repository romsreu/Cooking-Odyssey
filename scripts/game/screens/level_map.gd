extends Control
@onready var top_nav: TextureRect = $TopNav
@onready var top_nav_fill: ColorRect = $TopNavFill

@onready var levels_section: Control = $LevelsSection
@onready var bottom_nav: Panel = $BottomNav


var safe_area = DisplayServer.get_display_safe_area()

func _ready() -> void:
	_adjust_top_nav_to_safe()
	_adjust_bottom_nav_to_safe()
	
func _adjust_top_nav_to_safe() -> void:
	
	if safe_area.position.y > 0:
		top_nav.offset_top = safe_area.position.y
		top_nav_fill.custom_minimum_size.y = safe_area.position.y
	else: return
		
func _adjust_bottom_nav_to_safe() -> void:
	if AdmobUtil.admob_exists() and AdmobUtil.banner_ad_exists():
		var banner_height = AdmobUtil.get_banner_dimension().y
		bottom_nav.offset_bottom = -banner_height
