extends Control

@export_group("Catalogo da Loja")
@export var itens_loja: Array[ShopItemData] = []
@export_range(0, 100, 1) var chance_slot_vazio: int = 10

@onready var grid: GridContainer = find_child("GridContainer", true, false) as GridContainer
@onready var lista_itens: VBoxContainer = find_child("ListaDeItens", true, false) as VBoxContainer
@onready var total_label: Label = find_child("TotalLabel", true, false) as Label
@onready var botao_buy: Button = find_child("BotaoBuy", true, false) as Button
@onready var item_template: HBoxContainer = lista_itens.get_node("Item1") as HBoxContainer
@onready var aviso_moedas: ColorRect = find_child("ColorRect", true, false) as ColorRect

var shop_manager: ShopManager
var shop_data: ShopData
var ofertas_atuais: Array[Dictionary] = []
var tween_aviso_moedas: Tween


func _ready() -> void:
	_configurar_dependencias()
	_conectar_botoes()
	sortear_itens_loja()
	_atualizar_ui()


func _configurar_dependencias() -> void:
	shop_data = ShopData.new()
	shop_data.itens_loja = itens_loja
	shop_data.chance_slot_vazio = chance_slot_vazio
	add_child(shop_data)

	shop_manager = ShopManager.new()
	add_child(shop_manager)
	shop_manager.configurar(shop_data, _buscar_inventario(), _buscar_comprador())
	shop_manager.carrinho_atualizado.connect(_atualizar_ui)
	shop_manager.compra_finalizada.connect(_on_compra_finalizada)

	item_template.visible = false
	if aviso_moedas != null:
		aviso_moedas.visible = false
		aviso_moedas.modulate.a = 0.0


func sortear_itens_loja() -> void:
	if grid == null:
		return

	var botoes := _get_botoes_de_item()
	ofertas_atuais = shop_data.sortear_ofertas(botoes.size())

	for i in range(botoes.size()):
		var botao := botoes[i]
		var oferta := ofertas_atuais[i] if i < ofertas_atuais.size() else {}
		_configurar_botao_item(botao, oferta)


func _conectar_botoes() -> void:
	for botao in _get_botoes_de_item():
		botao.pressed.connect(_on_item_loja_pressed.bind(botao))


func _get_botoes_de_item() -> Array[TextureButton]:
	var botoes: Array[TextureButton] = []
	if grid == null:
		return botoes

	for child in grid.get_children():
		if child is TextureButton:
			botoes.append(child)
	return botoes


func _configurar_botao_item(botao: TextureButton, oferta: Dictionary) -> void:
	if not botao.has_meta("textura_padrao"):
		botao.set_meta("textura_padrao", botao.texture_normal)

	botao.set_meta("oferta", oferta)

	if oferta.is_empty():
		botao.disabled = true
		botao.tooltip_text = "Vazio"
		botao.texture_normal = botao.get_meta("textura_padrao") as Texture2D
		_atualizar_icone_botao(botao, null)
		return

	botao.disabled = false
	botao.tooltip_text = "%s - %d moedas" % [str(oferta.get("nome", "")), int(oferta.get("preco", 0))]
	botao.texture_normal = botao.get_meta("textura_padrao") as Texture2D
	_atualizar_icone_botao(botao, oferta.get("icone", null) as Texture2D)


func _atualizar_icone_botao(botao: TextureButton, icone: Texture2D) -> void:
	var texture_rect := botao.find_child("TextureRect", false, false) as TextureRect
	if texture_rect == null:
		return

	texture_rect.texture = icone
	texture_rect.visible = icone != null


func _on_item_loja_pressed(botao: TextureButton) -> void:
	var oferta := botao.get_meta("oferta", {}) as Dictionary
	if oferta.is_empty():
		return

	shop_manager.adicionar_item(oferta)


func _atualizar_ui() -> void:
	if lista_itens == null or item_template == null:
		return

	# Remove todas as linhas antigas
	for child in lista_itens.get_children():
		if child != item_template:
			child.queue_free()

	# Cria uma linha para cada item do carrinho
	for item in shop_manager.carrinho:
		var linha := item_template.duplicate() as HBoxContainer
		linha.visible = true

		var nome := linha.get_node("Nome") as Label
		var quantidade := linha.get_node("Quantidade") as Label
		var preco := linha.get_node("Preco") as Label
		var botao_retirar := linha.get_node("Retirar_item") as Button

		var nome_item := str(item.get("nome", ""))
		var preco_item := int(item.get("preco", 0))
		var raridade_item := int(
			item.get("raridade", ItensData.Raridade.COMUM)
		)

		var quantidade_item := int(
			item.get("quantidade", 1)
		)

		# Atualiza informações visuais
		nome.text = nome_item
		quantidade.text = "x" + str(quantidade_item)

		preco.text = str(
			preco_item * quantidade_item
		)

		# Conecta o botão dessa linha ao item correspondente
		botao_retirar.pressed.connect(
			_on_retirar_item_pressed.bind(
				nome_item,
				preco_item,
				raridade_item
			)
		)

		lista_itens.add_child(linha)

	# Atualiza o total
	if total_label != null:
		total_label.text = "Total: " + str(shop_manager.total)

	# Desabilita comprar se não houver itens
	if botao_buy != null:
		botao_buy.disabled = shop_manager.carrinho.is_empty()


func _on_retirar_item_pressed(
	nome: String,
	preco: int,
	raridade: int
) -> void:

	shop_manager.remover_unidade(
		nome,
		preco,
		raridade
	)


func _on_botao_buy_pressed() -> void:
	if shop_manager.carrinho.is_empty():
		return

	var comprador := _buscar_comprador()
	if comprador == null:
		return
	if _get_moedas_comprador(comprador) < shop_manager.total:
		_exibir_aviso_moedas()
		return

	shop_manager.configurar(shop_data, _buscar_inventario(), comprador)
	if not shop_manager.finalizar_compra():
		_exibir_aviso_moedas()


func _on_compra_finalizada(_itens: Array) -> void:
	sortear_itens_loja()


func _buscar_inventario() -> Inventario:
	return get_tree().get_first_node_in_group("inventario_principal") as Inventario


func _buscar_comprador() -> Node:
	var comprador := get_tree().get_first_node_in_group("protagonista")
	if comprador != null:
		return comprador
	return get_tree().get_first_node_in_group("player")


func _get_moedas_comprador(comprador: Node) -> int:
	if comprador == null:
		return 0
	return int(comprador.get("moedas"))


func _exibir_aviso_moedas() -> void:
	if aviso_moedas == null:
		return

	if tween_aviso_moedas != null:
		tween_aviso_moedas.kill()

	aviso_moedas.visible = true
	aviso_moedas.z_index = 100
	aviso_moedas.modulate.a = 1.0

	tween_aviso_moedas = create_tween()
	tween_aviso_moedas.tween_interval(3.0)
	tween_aviso_moedas.tween_property(aviso_moedas, "modulate:a", 0.0, 0.5)
	tween_aviso_moedas.tween_callback(func(): aviso_moedas.visible = false)


func _on_botao_sair_pressed() -> void:
	visible = false
