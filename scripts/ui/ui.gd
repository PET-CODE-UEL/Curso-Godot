class_name UI
extends CanvasLayer

@onready var pause_menu: Control = $PauseMenu

func _ready() -> void:
    UIManager.initialize(self)

func _input(event):
    if event.is_action_pressed("ui_cancel"):
        UIManager.toggle_pause()