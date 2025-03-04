class_name UI
extends CanvasLayer

@onready var inventory: Control = $Inventory
@onready var pause_menu : Control = $PauseMenu

func _ready() -> void:
	UIManager.initialize(self)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if UIManager.is_inventory_open:
			UIManager.toggle_inventory()
		else:
			UIManager.toggle_pause()