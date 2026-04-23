extends Node
class_name ShopManager

# Sinal emitido sempre que o carrinho sofre alguma alteracao.
signal carrinho_atualizado

# Sinal emitido quando a compra é finalizada (para integração futura).
signal compra_finalizada(itens)

# Lista que armazena os itens do carrinho (nome + quantidade).
var carrinho: Array[Dictionary] = []

# Valor total acumulado da compra atual.
var total: float = 0.0

# Referencia ao banco de dados da loja.
var shop_data: ShopData


# Recebe o banco de dados da loja.
func configurar(shop: ShopData):
	shop_data = shop


# Adiciona um item ao carrinho ou incrementa sua quantidade.
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


# Remove completamente um item do carrinho.
func remover_item(nome: String):
	for i in range(carrinho.size()):
		if carrinho[i]["nome"] == nome:
			carrinho.remove_at(i)
			break
	
	_recalcular_total()


# Recalcula o valor total da compra.
func _recalcular_total():
	total = 0.0
	
	for item in carrinho:
		var dados = shop_data.buscar_item(item["nome"])
		
		if dados != null:
			total += dados.preco * item["quantidade"]
	
	carrinho_atualizado.emit()


# Finaliza a compra (sem integrar com inventario).
func finalizar_compra():
	compra_finalizada.emit(carrinho)
	
	carrinho.clear()
	
	_recalcular_total()
