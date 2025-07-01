extends Node

signal money_updated(new_money) # Emite quando o money for alterado
signal shop_updated # Emite quando o shop for alterado

const ROWS := 3
const COLUMNS := 9
const SHOP_SIZE := ROWS * COLUMNS

var shop_items: Array[Utils.ItemRow] = []
var player_money: int = 100  # Dinheiro inicial do jogador

func _init():
	for i in range(ROWS):
		shop_items.append(Utils.ItemRow.new(COLUMNS))
	load_items_to_shop()

func add_item_to_shop(item: Item) -> bool:
	for i in range(SHOP_SIZE):
		var existing_item = get_shop_item(i)
		if existing_item == null:
			set_shop_item(i, item.clone())
			return true
	return false  # Loja cheia

func load_items_to_shop():
	var items: Array[Item] = load("res://resources/shop/shop_items.tres").items
	var item_index := 0
	for row in range(ROWS):
		for col in range(COLUMNS):
			if item_index < items.size():
				shop_items[row].slots[col] = items[item_index]
				item_index += 1
			else:
				break
	shop_updated.emit()

func set_money(amount: int):
	player_money = max(0, amount)
	money_updated.emit(player_money)

func add_money(amount: int):
	set_money(player_money + amount)

func remove_money(amount: int) -> bool:
	if player_money >= amount:
		set_money(player_money - amount)
		return true
	return false

func buy_item(item: Item) -> bool:
	if remove_money(item.price):
		InventoryManager.print_inventory_state("DEPOIS DA COMPRA ✅ SUCESSO")
		InventoryManager.normalize_inventory()
		return true
	return false

func sell_item(item: Item) -> bool:
	if item.can_sell:
		add_money(ceil(item.price * item.quantity * 0.8))
		return true
	return false

func get_shop_item(slot_index: int) -> Item:
	var row = Utils.get_row(slot_index, COLUMNS)
	var col = Utils.get_col(slot_index, COLUMNS)
	if row >= 0 and row < ROWS and col >= 0 and col < COLUMNS:
		return shop_items[row].slots[col]
	return null

func set_shop_item(slot_index: int, item: Item):
	var row = Utils.get_row(slot_index, COLUMNS)
	var col = Utils.get_col(slot_index, COLUMNS)
	if row >= 0 and row < ROWS and col >= 0 and col < COLUMNS:
		shop_items[row].slots[col] = item
		shop_updated.emit()
