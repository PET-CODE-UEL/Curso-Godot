extends Node

signal inventory_updated # Emite quando o inventário for alterado

const ROWS := 4
const COLUMNS := 9
const INVENTORY_SIZE := (ROWS - 1) * COLUMNS
const HOTBAR_SIZE := 1 * COLUMNS

var inventory_items: Array[Utils.ItemRow] = []

func _init() -> void:
	for i in range(ROWS):
		inventory_items.append(Utils.ItemRow.new(COLUMNS))

func get_inventory_item(slot_index: int) -> Item:
	var row = Utils.get_row(slot_index, COLUMNS)
	var col = Utils.get_col(slot_index, COLUMNS)
	if row >= 0 and row < ROWS and col >= 0 and col < COLUMNS:
		return inventory_items[row].slots[col]
	return null

func set_inventory_item(slot_index: int, item: Item) -> void:
	var row = Utils.get_row(slot_index, COLUMNS)
	var col = Utils.get_col(slot_index, COLUMNS)
	if row >= 0 and row < ROWS and col >= 0 and col < COLUMNS:
		inventory_items[row].slots[col] = item
		inventory_updated.emit()

func get_hotbar_item(slot_index: int) -> Item:
	if slot_index >= 0 and slot_index < HOTBAR_SIZE:
		return inventory_items[ROWS - 1].slots[slot_index]
	return null

func set_hotbar_item(slot_index: int, item: Item) -> void:
	if slot_index >= 0 and slot_index < HOTBAR_SIZE:
		inventory_items[ROWS - 1].slots[slot_index] = item
		inventory_updated.emit()

func swap_items(src_index : int, dst_index : int):
	var src_item = get_inventory_item(src_index)
	var dst_item = get_inventory_item(dst_index)
	if src_item != null or dst_item != null:
		set_inventory_item(src_index, dst_item)
		set_inventory_item(dst_index, src_item)

func add_item_to_inventory(new_item : Item) -> bool:
	# Procurar no inventário um item igual para empilhar
	for row in inventory_items:
		for slot in row.slots:
			if slot and slot.name == new_item.name and slot.quantity < slot.max_stack:
				var add_amount = min(new_item.quantity, slot.max_stack - slot.quantity)
				slot.quantity += add_amount
				new_item.quantity -= add_amount
				if new_item.quantity == 0:
					inventory_updated.emit()
					return true

	# Se não for possível empilhar, coloca em um slot vazio
	for row in inventory_items:
		for i in range(row.slots.size()):
			if row.slots[i] == null:
				row.slots[i] = new_item.clone()
				inventory_updated.emit()
				return true

	# Inventário cheio
	return false

func remove_item_from_inventory(item_name: String, quantity: int) -> bool:
	var needed = quantity
	var slots = []
	
	# Primeiro, procurar os slots que possuem o item
	for row in inventory_items:
		for col in range(row.slots.size()):
			var item = row.slots[col]
			if item and item.name == item_name:
				slots.append([row, col, item])
				needed -= item.quantity
				if needed <= 0:
					break
		if needed <= 0:
			break

	# Se não há itens suficientes, retorna falso
	if needed > 0:
		return false

	# Agora remove os itens do inventário
	for slot in slots:
		var row : Utils.ItemRow = slot[0]
		var col : int = slot[1]
		var item : Item = slot[2]

		if item.quantity > quantity:
			item.quantity -= quantity
			inventory_updated.emit()
			return true
		
		quantity -= item.quantity
		row.slots[col] = null

	inventory_updated.emit()
	return true
