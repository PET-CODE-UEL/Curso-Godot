class_name ItemSlot
extends Button

var item: Item = null
var dragged_item: Item = null
var slot_index: int = -1
@onready var item_icon : TextureRect = $Margin/ItemIcon
@onready var quantity_label : Label = $ItemQuantity
@onready var index_label : Label = $Margin/Index

func _ready() -> void:
	index_label.hide()

func set_item(new_item: Item):
	if new_item:
		item = new_item.clone()
		item_icon.texture = item.texture # Define o ícone do item
		quantity_label.text = str(item.quantity) # Exibe a quantidade
		quantity_label.visible = item.quantity > 1 # Só exibe se for maior que 1
	else:
		clear_item()

func clear_item():
	item = null
	item_icon.texture = null
	quantity_label.text = ""
	quantity_label.visible = false

# Detecta quando o arrastar termina
func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and not get_viewport().gui_is_drag_successful():
		# O drop falhou! Restaura o item no slot original
		if dragged_item:
			set_item(dragged_item)
			dragged_item = null

# Drag & Drop
func _get_drag_data(_position):
	if item:
		var preview = TextureRect.new()
		preview.texture = item_icon.texture # Usa o ícone do item
		preview.custom_minimum_size = Vector2(32, 32) # Ajusta o tamanho do preview
		preview.modulate.a = 0.8 # Transparência no preview
		set_drag_preview(preview)

		dragged_item = item
		if is_in_group("inventory_slots"):
			clear_item()
		return self
	return null

func _can_drop_data(_position, data):
	return data is ItemSlot

func _drop_data(_position, data):
	var src_slot: ItemSlot = data
	var dst_slot: ItemSlot = self

	if not src_slot or not dst_slot:
		return

	var transaction_success = false

	# Se estiver arrastando um item do inventário para o inventário -> TROCA
	if src_slot.is_in_group("inventory_slots") and dst_slot.is_in_group("inventory_slots"):
		transaction_success = true
		InventoryManager.swap_items(src_slot.slot_index, dst_slot.slot_index)

	# Se a transação falhar, devolve o item ao slot original
	if not transaction_success and src_slot.dragged_item:
		src_slot.set_item(src_slot.dragged_item)

	# Limpa a variável temporária
	src_slot.dragged_item = null