@tool
extends Node
class_name Itens

# Lista cadastrada no inspetor com todos os recursos de item do jogo.
@export var itens: Array[ItensData] = []


# Retorna so os nomes validos para montar seletores e validacoes.
func listar_nomes_itens() -> PackedStringArray:
	var nomes: PackedStringArray = []
	for item in itens:
		if item == null:
			continue
		var nome_item := item.nome.strip_edges()
		if nome_item.is_empty():
			continue
		nomes.append(nome_item)
	return nomes


# Busca um item pelo nome para o inventario recuperar seus dados completos.
func buscar_item_por_nome(nome: String) -> ItensData:
	for item in itens:
		if item != null and item.nome == nome:
			return item
	return null
