extends Node

var ui: UI

var is_pause_open: bool = false

func initialize(ui_node : CanvasLayer):
	ui = ui_node
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func toggle_pause() -> void:
	is_pause_open = !is_pause_open
	ui.pause_menu.visible = is_pause_open
	get_tree().paused = is_pause_open
	if is_pause_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func force_unpause() -> void:
	is_pause_open = false
	ui.pause_menu.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)