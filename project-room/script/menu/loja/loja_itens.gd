extends Control

# Referencias da UI
@onready var grid: GridContainer = $PainelPrincipal/MarginContainer/HBoxContainer/GridContainer
@onready var lista_itens: VBoxContainer = $PainelPrincipal/MarginContainer/HBoxContainer/FundoCarrinho/MarginContainer/VBoxContainer/ListaDeItens
@onready var total_label: Label = $PainelPrincipal/MarginContainer/HBoxContainer/FundoCarrinho/MarginContainer/VBoxContainer/HBoxContainer/TotalLabel
@onready var botao_buy: Button = $PainelPrincipal/MarginContainer/HBoxContainer/FundoCarrinho/MarginContainer/VBoxContainer/BotaoBuy

# Template do item do carrinho
@onready var item_template: HBoxContainer = lista_itens.get_node("Item1")

var shop_manager: ShopManager
var shop_data: ShopData


func _ready():
	shop_manager = ShopManager.new()
	add_child(shop_manager)
	
	shop_data = ShopData.new()
	add_child(shop_data)
	
	shop_manager.configurar(shop_data)
	shop_manager.carrinho_atualizado.connect(_atualizar_ui)
	
	item_template.visible = false
	
	_configurar_itens_loja()
	_conectar_botoes()


func _configurar_itens_loja():
	var nomes = [
		"lume_mod",
		"volt_mod",
		"white_hat_mod",
		"vítreo_mod",
		"pyromancer",
		"enginer",
		"aegis",
		"heather",
		"eile",
		"overclock",
	]
	
	var i = 0
	
	for botao in grid.get_children():
		if botao is TextureButton and i < nomes.size():
			botao.set_meta("nome_item", nomes[i])
			i += 1


func _conectar_botoes():
	for botao in grid.get_children():
		if botao is TextureButton:
			botao.pressed.connect(func():
				var nome_item = botao.get_meta("nome_item")
				
				if nome_item != null:
					shop_manager.adicionar_item(nome_item)
			)


func _atualizar_ui():
	for child in lista_itens.get_children():
		if child != item_template:
			child.queue_free()
	
	for item in shop_manager.carrinho:
		var dados = shop_data.buscar_item(item["nome"])
		
		var linha = item_template.duplicate()
		linha.visible = true
		
		var nome = linha.get_node("Nome")
		var quantidade = linha.get_node("Quantidade")
		var preco = linha.get_node("Preco")
		
		nome.text = item["nome"]
		quantidade.text = str(item["quantidade"])
		
		if dados != null:
			preco.text = str(dados.preco * item["quantidade"])
		else:
			preco.text = "0"
		
		lista_itens.add_child(linha)
	
	total_label.text = "Total: " + str(shop_manager.total)


func _on_botao_buy_pressed():
	shop_manager.finalizar_compra()
