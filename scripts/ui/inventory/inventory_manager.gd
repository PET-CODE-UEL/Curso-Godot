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

# Função para salvar o inventário
func save() -> Dictionary:
	var inventory_data := {}
	inventory_data["inventory"] = []

	# Salvando cada slot da matriz
	for row in inventory_items:
		for item in row.slots:
			if item != null:
				inventory_data["inventory"].append({"name": item.name, "quantity": item.quantity})

	return inventory_data


# Função para carregar o inventário
func load(inventory_data: Dictionary):
	var item_index = 0

	for row in inventory_items:
		for col in range(COLUMNS):
			if item_index < inventory_data["inventory"].size():
				var item_data = inventory_data["inventory"][item_index]
				print("res://resources/items/" + item_data["name"].to_lower() + ".tres")
				var item = load("res://resources/items/" + item_data["name"].to_lower() + ".tres")
				item.quantity = item_data["quantity"]
				row.slots[col] = item
				item_index += 1
# Função para adicionar um item ao inventário
func add_item_to_inventory(new_item: Item) -> bool:
	var hotbar_row := inventory_items[ROWS - 1]
	var inventory_rows := inventory_items.slice(0, ROWS - 1)

	# 1. Tenta empilhar na hotbar
	for i in range(HOTBAR_SIZE):
		var existing_item = hotbar_row.slots[i]
		if (
			existing_item
			and existing_item.name == new_item.name
			and existing_item.quantity < existing_item.max_stack
		):
			var space = existing_item.max_stack - existing_item.quantity
			var to_add = min(space, new_item.quantity)
			existing_item.quantity += to_add
			new_item.quantity -= to_add
			if new_item.quantity <= 0:
				inventory_updated.emit()
				return true

	# 2. Tenta empilhar no inventário
	for row in inventory_rows:
		for i in range(row.slots.size()):
			var existing_item = row.slots[i]
			if (
				existing_item
				and existing_item.name == new_item.name
				and existing_item.quantity < existing_item.max_stack
			):
				var space = existing_item.max_stack - existing_item.quantity
				var to_add = min(space, new_item.quantity)
				existing_item.quantity += to_add
				new_item.quantity -= to_add
				if new_item.quantity <= 0:
					inventory_updated.emit()
					return true

	if new_item.quantity > 0:
		# Distribui unidade por unidade restante
		var remaining = new_item.quantity

		# 1. Hotbar
		for i in range(HOTBAR_SIZE):
			if remaining <= 0:
				break
			if hotbar_row.slots[i] == null:
				var clone = new_item.clone()
				clone.quantity = 1
				hotbar_row.slots[i] = clone
				remaining -= 1

		# 2. Inventário
		for row in inventory_rows:
			for i in range(row.slots.size()):
				if remaining <= 0:
					break
				if row.slots[i] == null:
					var clone = new_item.clone()
					clone.quantity = 1
					row.slots[i] = clone
					remaining -= 1

		inventory_updated.emit()
		return remaining <= 0
		# Nenhum espaço disponível
	return false

# Função para remover um item do inventário
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
		var index: int = slot[1]
		var item := row.slots[index]
		if item.quantity > quantity:
			item.quantity -= quantity
			inventory_updated.emit()
			return true
		quantity -= item.quantity
		row.slots[index] = null

	# Remoção concluída com sucesso
	inventory_updated.emit()
	return true
	
func print_inventory_state(title: String = ""):
	print("=== INVENTÁRIO DO JOGADOR === ", title)
	for row_idx in range(inventory_items.size()):
		var row = inventory_items[row_idx]
		for col_idx in range(row.slots.size()):
			var item = row.slots[col_idx]
			if item != null:
				print("  Slot [", row_idx, ",", col_idx, "] = ", item.name, " x", item.quantity)
			else:
				print("  Slot [", row_idx, ",", col_idx, "] = vazio")
	print("==============================")
	
func normalize_inventory():
	var seen := {}

	for row in inventory_items:
		for i in range(row.slots.size()):
			var item = row.slots[i]
			if item:
				if not seen.has(item.name):
					seen[item.name] = item  # Primeiro encontrado
				else:
					var main_item = seen[item.name]
					var space = main_item.max_stack - main_item.quantity
					var to_add = min(space, item.quantity)
					main_item.quantity += to_add
					item.quantity -= to_add

					# Se o duplicado estiver vazio, remove
					if item.quantity <= 0:
						row.slots[i] = null

	inventory_updated.emit()
