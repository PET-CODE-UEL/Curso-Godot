extends Control

@export var slot_scene: PackedScene
@onready var hotbar_grid : GridContainer = $Margin/Panel/Margin/VBox/HotbarGrid
@onready var inventory_grid : GridContainer = $Margin/Panel/Margin/VBox/InventoryGrid


func _ready() -> void:
	inventory_grid.columns = InventoryManager.COLUMNS
	hotbar_grid.columns = InventoryManager.COLUMNS
	inventory_grid.size_flags_stretch_ratio = InventoryManager.ROWS - 1
	hotbar_grid.size_flags_stretch_ratio = 1
	initialize_ui()
	InventoryManager.inventory_updated.connect(refresh_ui)
	var enxada: Item = load("res://resources/items/enxada.tres")
	var regador: Item = load("res://resources/items/regador.tres")
	InventoryManager.add_item_to_inventory(enxada)
	InventoryManager.add_item_to_inventory(regador)
	InventoryManager.add_item_to_inventory(enxada)

func clear_children(node : Node) -> void:
	for child in node.get_children():
		child.queue_free()

func initialize_ui():
	clear_children(hotbar_grid)
	clear_children(inventory_grid)
	
	# Criar os slots do inventário
	for i in range(InventoryManager.INVENTORY_SIZE):
		var slot = slot_scene.instantiate()
		slot.slot_index = i
		slot.add_to_group("inventory_slots")
		inventory_grid.add_child(slot)

	# Criar os slots da hotbar
	for i in range(InventoryManager.HOTBAR_SIZE):
		var slot = slot_scene.instantiate()
		slot.slot_index = i + InventoryManager.INVENTORY_SIZE
		slot.add_to_group("inventory_slots")
		hotbar_grid.add_child(slot)

	refresh_ui()

func refresh_ui():
	for i in range(InventoryManager.INVENTORY_SIZE):
		var slot = inventory_grid.get_child(i)
		var item = InventoryManager.get_inventory_item(i)
		slot.set_item(item)

	for i in range(InventoryManager.HOTBAR_SIZE):
		var slot = hotbar_grid.get_child(i)
		var item = InventoryManager.get_hotbar_item(i)
		slot.set_item(item)
