class_name UI
extends CanvasLayer

@onready var pause_menu : Control = $PauseMenu

func _ready() -> void:
	UIManager.initialize(self)
