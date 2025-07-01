extends GridContainer

@export var slot_scene: PackedScene
var slots: Array[ItemSlot] = []
var selected_index: int = 0 # Índice do slot atualmente selecionado

func _ready():
	setup_slots()
	InventoryManager.inventory_updated.connect(update_hotbar)
	select_slot(selected_index)

func setup_slots():
	for i in range(InventoryManager.HOTBAR_SIZE):
		var slot : ItemSlot = slot_scene.instantiate()
		add_child(slot)
		slots.append(slot)
		slot.set_item(InventoryManager.get_hotbar_item(i))
		slot.index_label.show()
		slot.index_label.text = str(i+1)

func update_hotbar():
	for i in range(InventoryManager.HOTBAR_SIZE):
		slots[i].set_item(InventoryManager.get_hotbar_item(i))
	
	# 🔥 Atualiza o item na mão caso o slot selecionado tenha sido modificado
	slot_selected.emit(selected_index)


func _input(event):
	for i in range(9):
		if event.is_action_pressed("hotbar_%d" % (i + 1)):
			select_slot(i)

signal slot_selected(index)

func select_slot(index: int):
	if index >= 0 and index < InventoryManager.HOTBAR_SIZE:
		clear_selected_style()
		selected_index = index
		set_selected_style(slots[selected_index])
		slot_selected.emit(index)  # 🔥 Emite o sinal para atualizar a mão

func clear_selected_style():
	for slot in slots:
		slot.remove_theme_stylebox_override("normal")

func set_selected_style(slot):
	var selected_style: StyleBox = preload("res://resources/styleboxes/selected_hotbar_slot.tres")
	slot.add_theme_stylebox_override("normal", selected_style)
