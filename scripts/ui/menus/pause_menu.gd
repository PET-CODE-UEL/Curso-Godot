extends Control

func _on_resume_pressed() -> void:
	UIManager.toggle_pause()

func _on_menu_exit_pressed() -> void:
	UIManager.force_unpause()
	get_tree().change_scene_to_file("res://scenes/ui/menus/main_menu.tscn")

func _on_desktop_exit_pressed() -> void:
	get_tree().quit()
