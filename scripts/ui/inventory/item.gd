class_name Item
extends Resource

@export var name : String = ""
@export var texture : Texture2D = null
@export var max_stack : int = 64
@export var quantity : int = 1
@export var price : int = 0
@export var can_sell : bool = true

func clone() -> Item:
	return duplicate() as Item
