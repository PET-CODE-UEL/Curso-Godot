extends Node

signal inventory_updated # Emite quando o inventário for alterado

const ROWS := 4
const COLUMNS := 9
const INVENTORY_SIZE := (ROWS - 1) * COLUMNS
const HOTBAR_SIZE := 1 * COLUMNS

var inventory_items: Array[Utils.ItemRow] = []

func _init():
	for i in range(ROWS):
		inventory_items.append(Utils.ItemRow.new(COLUMNS))

func get_inventory_item(slot_index: int) -> Item:
	var row = Utils.get_row(slot_index, COLUMNS)
	var col = Utils.get_col(slot_index, COLUMNS)
	if row >= 0 and row < ROWS and col >= 0 and col < COLUMNS:
		return inventory_items[row].slots[col]
	return null

func set_inventory_item(slot_index: int, item: Item):
	var row = Utils.get_row(slot_index, COLUMNS)
	var col = Utils.get_col(slot_index, COLUMNS)
	if row >= 0 and row < ROWS and col >= 0 and col < COLUMNS:
		inventory_items[row].slots[col] = item
		inventory_updated.emit()

func get_hotbar_item(index: int) -> Item:
	if index >= 0 and index < HOTBAR_SIZE:
		return inventory_items[ROWS - 1].slots[index]
	return null

func set_hotbar_item(index: int, item: Item):
	if index >= 0 and index < HOTBAR_SIZE:
		inventory_items[ROWS - 1].slots[index] = item
		inventory_updated.emit()

func swap_items(src_index, dst_index):
	var src_item = get_inventory_item(src_index)
	var src_row = Utils.get_row(src_index, COLUMNS)
	var src_col = Utils.get_col(src_index, COLUMNS)
	var dst_item = get_inventory_item(dst_index)
	var dst_row = Utils.get_row(dst_index, COLUMNS)
	var dst_col = Utils.get_col(dst_index, COLUMNS)
	if src_item != null or dst_item != null:
		inventory_items[dst_row].slots[dst_col] = src_item
		inventory_items[src_row].slots[src_col] = dst_item
		inventory_updated.emit()

# Função para adicionar um item ao inventário
func add_item_to_inventory(new_item: Item) -> bool:
	# Procura no inventário um item igual para empilhar
	for row in inventory_items:
		for i in range(row.slots.size()):
			var existing_item := row.slots[i]
			if (
				existing_item
				and existing_item.name == new_item.name
				and existing_item.quantity < existing_item.max_stack
			):
				var available_space = existing_item.max_stack - existing_item.quantity
				var quantity_to_add = min(new_item.quantity, available_space)
				existing_item.quantity += quantity_to_add
				new_item.quantity -= quantity_to_add
				if new_item.quantity <= 0:
					inventory_updated.emit()
					return true

	# Caso não tenha espaço para empilhar, tenta encontrar um slot vazio no inventário
	for row in inventory_items:
		for i in range(row.slots.size()):
			if row.slots[i] == null:
				row.slots[i] = new_item.clone()
				inventory_updated.emit()
				return true

	# Inventário cheio
	return false

func remove_item_from_inventory(item_name: String, quantity: int) -> bool:
	var total_quantity_available := 0
	var slots_to_remove := []

	# Verifica a quantidade total disponível no inventário
	for row in inventory_items:
		for col in range(row.slots.size()):
			var item = row.slots[col]
			if item and item.name == item_name:
				total_quantity_available += item.quantity
				slots_to_remove.append([row, col])

	# Se não houver quantidade suficiente, retorna false
	if total_quantity_available < quantity:
		return false

	# Remover os itens
	while !slots_to_remove.is_empty():
		var slot = slots_to_remove.pop_back()
		var row: Utils.ItemRow = slot[0]
		var col: int = slot[1]
		var item := row.slots[col]
		if item.quantity > quantity:
			item.quantity -= quantity
			inventory_updated.emit()
			return true
		quantity -= item.quantity
		row.slots[col] = null

	# Remoção concluída com sucesso
	inventory_updated.emit()
	return true