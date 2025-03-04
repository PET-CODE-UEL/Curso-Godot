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

func clear_item() -> void:
	item = null
	item_icon.texture = null
	quantity_label.text = ""
	quantity_label.visible = false

func set_item(new_item: Item) -> void:
	if new_item:
		item = new_item.clone()
		item_icon.texture = item.texture
		quantity_label.text = str(item.quantity)
		quantity_label.visible = item.quantity > 1
	else:
		clear_item()

func _get_drag_data(_at_position: Vector2) -> Variant:
	if item:
		var preview = TextureRect.new()
		preview.texture = item.texture
		preview.custom_minimum_size = Vector2(32,32)
		preview.modulate.a = 0.8
		set_drag_preview(preview)

		dragged_item = item
		if is_in_group("inventory_slots"):
			clear_item()
		return self
	return null

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is ItemSlot

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var src_slot : ItemSlot = data
	var dst_slot : ItemSlot = self

	var transaction_success = false

	# Se o item que está sendo arrastado dentro do inventário para o inventário, realiza a TROCA
	if src_slot.is_in_group("inventory_slots") and dst_slot.is_in_group("inventory_slots"):
		transaction_success = true
		InventoryManager.swap_items(src_slot.slot_index, dst_slot.slot_index)

	# Caso a transação falhe, restaura o item no slot de origem
	if not transaction_success and src_slot.dragged_item:
		src_slot.set_item(src_slot.dragged_item)

	src_slot.dragged_item = null

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and not get_viewport().gui_get_drag_data():
		if dragged_item:
			set_item(dragged_item)
			dragged_item = null
