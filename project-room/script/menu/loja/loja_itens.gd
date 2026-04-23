extends Control

# Referencias aos principais elementos da interface da loja.
@onready var grid: GridContainer = $PainelPrincipal/MarginContainer/HBoxContainer/GridContainer
@onready var lista_itens: VBoxContainer = $PainelPrincipal/MarginContainer/HBoxContainer/FundoCarrinho/MarginContainer/VBoxContainer/ListaDeItens
@onready var total_label: Label = $PainelPrincipal/MarginContainer/HBoxContainer/FundoCarrinho/MarginContainer/VBoxContainer/HBoxContainer/TotalLabel
@onready var botao_buy: Button = $PainelPrincipal/MarginContainer/HBoxContainer/FundoCarrinho/MarginContainer/VBoxContainer/BotaoBuy

# Template visual usado como base para criar os itens do carrinho dinamicamente.
@onready var item_template: HBoxContainer = lista_itens.get_node("Item1")

# Instancias responsaveis pela logica da loja e banco de dados dos itens.
var shop_manager: ShopManager
var shop_data: ShopData


# Inicializa a loja, instancia dependencias e configura a interface.
func _ready():
	# Cria e adiciona o gerenciador da loja na cena.
	shop_manager = ShopManager.new()
	add_child(shop_manager)
	
	# Cria e adiciona o banco de dados dos itens da loja.
	shop_data = ShopData.new()
	add_child(shop_data)
	
	# Configura o manager com o banco de dados e o inventario do jogador.
	shop_manager.configurar(shop_data)
	
	# Conecta o sinal para atualizar a interface sempre que o carrinho mudar.
	shop_manager.carrinho_atualizado.connect(_atualizar_ui)
	
	# Esconde o template para evitar que ele apareca na lista final.
	item_template.visible = false
	
	# Configura os itens disponiveis na loja (associacao temporaria via metadata).
	_configurar_itens_loja()
	
	# Conecta os botoes da grade para adicionar itens ao carrinho.
	_conectar_botoes()


# Associa manualmente os nomes dos itens aos botoes da loja.
func _configurar_itens_loja():
	# Lista temporaria de nomes que deve bater com o banco de itens.
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
	
	# Percorre os botoes do grid e atribui um nome de item via metadata.
	for botao in grid.get_children():
		if botao is TextureButton and i < nomes.size():
			botao.set_meta("nome_item", nomes[i])
			i += 1


# Conecta o evento de clique de cada botao para adicionar itens ao carrinho.
func _conectar_botoes():
	for botao in grid.get_children():
		if botao is TextureButton:
			botao.pressed.connect(func():
				var nome_item = botao.get_meta("nome_item")
				
				# Adiciona o item ao carrinho se houver metadata valida.
				if nome_item != null:
					shop_manager.adicionar_item(nome_item)
			)


# Atualiza a interface do carrinho sempre que houver alteracoes.
func _atualizar_ui():
	# Remove todos os itens atuais da lista, mantendo apenas o template.
	for child in lista_itens.get_children():
		if child != item_template:
			child.queue_free()
	
	# Percorre os itens do carrinho para recriar a lista visual.
	for item in shop_manager.carrinho:
		var dados = shop_data.buscar_item(item["nome"])
		
		# Duplica o template para criar uma nova linha visual.
		var linha = item_template.duplicate()
		linha.visible = true
		
		# Recupera os elementos internos da linha.
		var nome = linha.get_node("Nome")
		var quantidade = linha.get_node("Quantidade")
		var preco = linha.get_node("Preco")
		

		# Atualiza os valores exibidos na interface.
		nome.text = item["nome"]
		quantidade.text = str(item["quantidade"])
		
		# Calcula e exibe o preco total do item.
		if dados != null:
			preco.text = str(dados.preco * item["quantidade"])
		else:
			preco.text = "0"
		
		# Adiciona a linha atualizada na lista visual.
		lista_itens.add_child(linha)
	
	# Atualiza o valor total da compra.
	total_label.text = "Total: " + str(shop_manager.total)


# Finaliza a compra enviando os itens do carrinho para o inventario.
func _on_botao_buy_pressed() -> void:
	shop_manager.finalizar_compra()
