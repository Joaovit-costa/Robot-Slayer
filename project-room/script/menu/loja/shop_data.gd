extends Node
class_name ShopData

@export var itens_loja: Array[ShopItemData] = []

func buscar_item(nome: String) -> ShopItemData:
	for item in itens_loja:
		if item != null and item.nome == nome:
			return item
	return null
