extends Node

class ItemRow:
	var slots: Array[Item] = []

	func _init(size: int):
		for i in range(size):
			slots.append(null)

func get_row(slot_index : int, columns : int) -> int:
	var row = floor(slot_index / float(columns))
	return row

func get_col(slot_index : int, columns : int) -> int:
	var col = slot_index % columns
	return col
