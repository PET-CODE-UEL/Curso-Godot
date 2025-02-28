extends Node

var ui: UI

func initialize(ui_node : CanvasLayer):
	ui = ui_node
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)