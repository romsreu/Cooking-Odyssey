extends Node

const GENERAL_SETTINGS = preload("uid://bb7o8cneasyfo")
const EXTRA_LIFE_PANEL = preload("uid://mpgu7swj5kwr")
const EXTRA_COINS_PANEL = preload("uid://dt74bvii4v4lb")

var settings_menu: CanvasLayer
var extra_life_panel: CanvasLayer
var extra_coins_panel: CanvasLayer

func _ready():
	settings_menu = GENERAL_SETTINGS.instantiate()
	extra_life_panel = EXTRA_LIFE_PANEL.instantiate()
	extra_coins_panel = EXTRA_COINS_PANEL.instantiate()
	get_tree().root.call_deferred("add_child", settings_menu)
	get_tree().root.call_deferred("add_child", extra_life_panel)
	get_tree().root.call_deferred("add_child", extra_coins_panel)
	extra_life_panel.hide()
	extra_coins_panel.hide()
	settings_menu.hide()

func open_settings():
	if settings_menu:
		settings_menu.show_settings()

func open_extra_life_panel ():
	if extra_life_panel:
		extra_life_panel.show()
		
func open_extra_coins_panel ():
	if extra_coins_panel:
		extra_coins_panel.show()
	
