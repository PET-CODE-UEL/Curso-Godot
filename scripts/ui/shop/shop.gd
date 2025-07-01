extends Control

@export var slot_scene: PackedScene
@onready var player_inventory_grid: GridContainer = $Margin/Panel/Margin/VBox/PlayerInventoryGrid
@onready var shop_inventory_grid: GridContainer = $Margin/Panel/Margin/VBox/ShopGrid
@onready var money_label: Label = $Margin/Panel/Margin/VBox/HBox/Money

func _ready():
	initialize_ui()
	InventoryManager.inventory_updated.connect(refresh_ui)
	ShopManager.shop_updated.connect(refresh_ui)
	ShopManager.money_updated.connect(refresh_money)
	var tomate = load("res://resources/items/tomato.tres")
	ShopManager.add_item_to_shop(tomate)
	var milho = load("res://resources/items/corn.tres")
	ShopManager.add_item_to_shop(milho)

func initialize_ui():
	clear_children(player_inventory_grid)
	clear_children(shop_inventory_grid)

	for i in range(InventoryManager.INVENTORY_SIZE + InventoryManager.HOTBAR_SIZE):
		var slot = slot_scene.instantiate()
		slot.slot_index = i
		slot.add_to_group("inventory_slots") 
		player_inventory_grid.add_child(slot)

	for i in range(ShopManager.SHOP_SIZE):
		var slot = slot_scene.instantiate()
		slot.slot_index = i
		slot.add_to_group("shop_slots")
		shop_inventory_grid.add_child(slot)

	refresh_ui()

func refresh_ui():
	for i in range(InventoryManager.INVENTORY_SIZE + InventoryManager.HOTBAR_SIZE):
		var slot = player_inventory_grid.get_child(i)
		var item = InventoryManager.get_inventory_item(i)
		slot.set_item(item)

	for i in range(ShopManager.SHOP_SIZE):
		var slot = shop_inventory_grid.get_child(i)
		var item = ShopManager.get_shop_item(i)
		slot.set_item(item)

func refresh_money(money_amount):
	money_label.text = "$ " + str(money_amount)

func clear_children(node: Node):
	for child in node.get_children():
		child.queue_free()


func _on_close_pressed() -> void:
	UIManager.toggle_shop()
