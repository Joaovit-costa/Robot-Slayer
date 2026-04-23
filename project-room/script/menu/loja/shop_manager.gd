extends Node
class_name ShopManager

# Sinal emitido sempre que o carrinho sofre alguma alteracao.
signal carrinho_atualizado

# Lista que armazena os itens do carrinho (nome + quantidade).
var carrinho: Array[Dictionary] = []

# Valor total acumulado da compra atual.
var total: float = 0.0

# Referencias externas para o banco da loja e inventario do jogador.
var shop_data: ShopData



# Recebe as dependencias necessarias para funcionamento da loja.
func configurar(shop: ShopData):
	shop_data = shop


# Adiciona um item ao carrinho ou incrementa sua quantidade.
func adicionar_item(nome: String):
	for item in carrinho:
		if item["nome"] == nome:
			item["quantidade"] += 1
			_recalcular_total()
			return
	
	# Cria novo registro caso o item ainda nao exista no carrinho.
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


# Recalcula o valor total da compra com base nos itens atuais.
func _recalcular_total():
	total = 0.0
	
	for item in carrinho:
		var dados = shop_data.buscar_item(item["nome"])
		
		if dados != null:
			total += dados.preco * item["quantidade"]
	
	# Notifica a interface para atualizar os dados visuais.
	carrinho_atualizado.emit()


# Finaliza a compra enviando os itens ao inventario.
func finalizar_compra():
	# Adiciona todos os itens do carrinho ao inventario global.
	for item in carrinho:
		InventarioGlobal.adicionar_item(item["nome"], item["quantidade"])
	
	# Limpa o carrinho apos a compra.
	carrinho.clear()
	
	_recalcular_total()
