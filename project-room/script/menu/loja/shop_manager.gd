extends Node
class_name ShopManager

signal carrinho_atualizado

var carrinho: Array[Dictionary] = []
var total: float = 0.0

var shop_data: ShopData
var inventario_ref: Inventario

func configurar(shop: ShopData, inventario: Inventario):
	shop_data = shop
	inventario_ref = inventario

func adicionar_item(nome: String):
	for item in carrinho:
		if item["nome"] == nome:
			item["quantidade"] += 1
			_recalcular_total()
			return
	
	carrinho.append({
		"nome": nome,
		"quantidade": 1
	})
	
	_recalcular_total()

func remover_item(nome: String):
	for i in range(carrinho.size()):
		if carrinho[i]["nome"] == nome:
			carrinho.remove_at(i)
			break
	
	_recalcular_total()

func _recalcular_total():
	total = 0.0
	
	for item in carrinho:
		var dados = shop_data.buscar_item(item["nome"])
		if dados != null:
			total += dados.preco * item["quantidade"]
	
	carrinho_atualizado.emit()

func finalizar_compra():
	if inventario_ref == null:
		return
	
	for item in carrinho:
		inventario_ref.adicionar_item(item["nome"], item["quantidade"])
	
	carrinho.clear()
	_recalcular_total()
