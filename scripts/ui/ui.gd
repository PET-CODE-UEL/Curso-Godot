class_name UI
extends CanvasLayer

@onready var hud: Control = $HUD
@onready var inventory: Control = $Inventory
@onready var shop: Control = $Shop
@onready var pause_menu: Control = $PauseMenu

func _ready() -> void:
	UIManager.initialize(self)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if UIManager.is_inventory_open:
			UIManager.toggle_inventory()
		elif UIManager.is_shop_open:
			UIManager.toggle_shop()
		elif pause_menu.visible:
			UIManager.toggle_pause()
		else:
			UIManager.toggle_pause()
