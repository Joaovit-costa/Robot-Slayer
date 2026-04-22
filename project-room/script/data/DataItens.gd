extends Node
class_name Itens

# Lista cadastrada no inspetor com todos os recursos de item do jogo.
@export var itens: Array[ItensData] = []


# Busca um item pelo nome para o inventario recuperar seus dados completos.
func buscar_item_por_nome(nome: String) -> ItensData:
	for item in itens:
		if item != null and item.nome == nome:
			return item
	return null
