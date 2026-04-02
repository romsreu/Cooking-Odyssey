extends CanvasLayer


func _on_watch_add_button_pressed() -> void:
	if AdmobUtil.admob_exists():
		await AdmobUtil.load_rewarded_ad()
		AdmobUtil.show_rewarded_ad()

func _on_base_mobile_button_pressed() -> void:
	self.hide()
