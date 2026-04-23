extends Node
class_name ShopData

# Lista de itens disponiveis na loja, configurados via inspetor.
@export var itens_loja: Array[ShopItemData] = []


# Busca um item da loja pelo nome.
func buscar_item(nome: String) -> ShopItemData:
	for item in itens_loja:
		if item != null and item.nome == nome:
			return item
	return null
