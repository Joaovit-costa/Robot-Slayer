extends Node
class_name ShopManager

signal carrinho_atualizado
signal compra_finalizada(itens)

var carrinho: Array[Dictionary] = []
var total: int = 0
var shop_data: ShopData
var inventario_ref: Inventario
var comprador_ref: Node


func configurar(shop: ShopData, inventario: Inventario, comprador: Node) -> void:
	shop_data = shop
	inventario_ref = inventario
	comprador_ref = comprador


func adicionar_item(oferta: Dictionary) -> void:
	if oferta.is_empty():
		return

	var nome := str(oferta.get("nome", ""))
	var preco := int(oferta.get("preco", 0))
	var raridade := int(oferta.get("raridade", ItensData.Raridade.COMUM))

	for item in carrinho:
		if (
			str(item.get("nome", "")) == nome
			and int(item.get("preco", 0)) == preco
			and int(item.get("raridade", ItensData.Raridade.COMUM)) == raridade
		):
			item["quantidade"] = int(item.get("quantidade", 0)) + int(oferta.get("quantidade", 1))
			_recalcular_total()
			return

	carrinho.append({
		"nome": nome,
		"preco": preco,
		"quantidade": int(oferta.get("quantidade", 1)),
		"raridade": raridade
	})
	_recalcular_total()


func remover_item(nome: String, preco: int = -1, raridade: int = -1) -> void:
	for i in range(carrinho.size()):
		var item := carrinho[i]
		if str(item.get("nome", "")) != nome:
			continue
		if preco != -1 and int(item.get("preco", 0)) != preco:
			continue
		if raridade != -1 and int(item.get("raridade", ItensData.Raridade.COMUM)) != raridade:
			continue
		carrinho.remove_at(i)
		break

	_recalcular_total()

func remover_unidade(
	nome: String,
	preco: int = -1,
	raridade: int = -1
) -> void:

	for i in range(carrinho.size()):
		var item := carrinho[i]

		if str(item.get("nome", "")) != nome:
			continue

		if preco != -1 and int(item.get("preco", 0)) != preco:
			continue

		if raridade != -1 and int(
			item.get("raridade", ItensData.Raridade.COMUM)
		) != raridade:
			continue

		var quantidade := int(item.get("quantidade", 1))

		quantidade -= 1

		if quantidade <= 0:
			carrinho.remove_at(i)
		else:
			item["quantidade"] = quantidade

		break

	_recalcular_total()


func finalizar_compra() -> bool:
	
	if carrinho.is_empty():
		return false

	if comprador_ref == null \
	or not comprador_ref.has_method("tem_moedas") \
	or not comprador_ref.has_method("gastar_moedas"):
		return false

	if inventario_ref == null:
		return false

	if not comprador_ref.tem_moedas(total):
		return false

	# Ignorando a validação de espaço por enquanto

	if not comprador_ref.gastar_moedas(total):
		return false

	for item in carrinho:
		inventario_ref.adicionar_item(
			str(item.get("nome", "")),
			int(item.get("raridade", ItensData.Raridade.COMUM)),
			int(item.get("quantidade", 1))
		)

	var itens_comprados := carrinho.duplicate(true)

	carrinho.clear()
	_recalcular_total()

	# Salva imediatamente após concluir a compra
	if Engine.has_singleton("SaveManager"):
		SaveManager.solicitar_salvamento()

	compra_finalizada.emit(itens_comprados)

	return true


func _recalcular_total() -> void:
	total = 0
	for item in carrinho:
		total += int(item.get("preco", 0)) * int(item.get("quantidade", 1))
	carrinho_atualizado.emit()
