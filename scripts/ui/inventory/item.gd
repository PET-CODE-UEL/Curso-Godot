class_name Item
extends Resource

@export var name: String = ""
@export var texture: Texture2D = null
@export var max_stack: int = 64
@export var quantity: int = 1
@export var price: int = 0
@export var can_sell: bool = true

func clone() -> Item:
    # Cria uma cópia deste item
    var new_item = Item.new()
    new_item.name = name
    new_item.texture = texture
    new_item.max_stack = max_stack
    new_item.quantity = quantity
    new_item.price = price
    new_item.can_sell = can_sell
    return new_item
