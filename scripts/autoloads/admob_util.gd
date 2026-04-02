extends Node

var admob : Admob
signal banner_ad_loaded
signal rewarded_ad_loaded

func set_admob(ad : Admob):
	admob = ad

func load_banner_ad() -> void:
	admob.load_banner_ad()
	await admob.banner_ad_loaded
	banner_ad_loaded.emit()

func load_rewarded_ad() -> void:
	admob.load_rewarded_ad()
	await admob.rewarded_ad_loaded
	rewarded_ad_loaded.emit()


func show_banner_ad() -> void:
	admob.show_banner_ad()

func show_rewarded_ad() -> void:
	admob.show_rewarded_ad()

func get_banner_dimension() -> Variant:
	if admob_exists():
		return admob.get_banner_dimension_in_pixels()
	else: 
		return null

func admob_exists () -> bool:
	return get_tree().root.has_node("Admob")

func banner_ad_exists() -> bool:
	if admob == null:
		return false
	else:
		return admob.is_banner_ad_loaded()
