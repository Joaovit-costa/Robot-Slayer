extends Control

# Estado do drag, referencia do inventario, banco e lista de slots visuais.
@onready var painel_principal: Panel = $PainelPrincipal
@onready var label_titulo: Label = $PainelPrincipal/Conteudo/PainelEsquerdo/VBoxContainer/Container/titulo
@onready var label_tipo: Label = $PainelPrincipal/Conteudo/PainelEsquerdo/VBoxContainer/HBoxContainer/tipo
@onready var label_raridade: Label = $PainelPrincipal/Conteudo/PainelEsquerdo/VBoxContainer/HBoxContainer/raridade
@onready var grid_especificacoes: GridContainer = $PainelPrincipal/Conteudo/PainelEsquerdo/VBoxContainer/GridContainer
@onready var label_forca: Label = $PainelPrincipal/Conteudo/PainelEsquerdo/VBoxContainer/GridContainer/forca
@onready var label_defesa: Label = $PainelPrincipal/Conteudo/PainelEsquerdo/VBoxContainer/GridContainer/defesa
@onready var label_inteligencia: Label = $PainelPrincipal/Conteudo/PainelEsquerdo/VBoxContainer/GridContainer/inteligencia
@onready var label_vitalidade: Label = $PainelPrincipal/Conteudo/PainelEsquerdo/VBoxContainer/GridContainer/vitalidade
@onready var slot_lixeira: Control = $PainelPrincipal/Conteudo/VBoxContainer/HBoxContainer/SlotLixeira

var inventario_ref: Inventario
var slots: Array = []
var slot_selecionado: int = -1
var label_descricao: Label
var label_buffs_extra: Label

# Inicializa o menu, cria dependencias e sincroniza os slots com a lista.
func _ready() -> void:
	_configurar_dependencias()
	slot_lixeira.call("configurar", inventario_ref)
	_registrar_slots()
	_atualizar_slots()
	_limpar_painel_especificacoes()


# Corrige o cursor caso um drag invalido deixe o icone bloqueado.
func _process(_delta: float) -> void:
	if Input.get_current_cursor_shape() == CURSOR_FORBIDDEN:
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)


# Guarda os dados do drag atual e restaura o visual ao final de qualquer arraste.
func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_DRAG_END:
		call_deferred("_atualizar_slots")


# Cria a instancia do inventario e a instancia do banco de itens deste menu.
func _configurar_dependencias() -> void:
	inventario_ref = Inventario.new()
	inventario_ref.name = "InventarioState"
	add_child(inventario_ref)
	inventario_ref.add_to_group("inventario_principal")

	inventario_ref.inventario_atualizado.connect(_atualizar_slots)
	SaveManager.aplicar_no_inventario(inventario_ref)

# Encontra todos os slots da cena e injeta neles a referencia do inventario.
func _registrar_slots() -> void:
	slots.clear()
	for slot in _coletar_slots_recursivamente(self):
		slot.configurar(inventario_ref)
		var clique_slot := _on_slot_pressed.bind(slot)
		if not slot.pressed.is_connected(clique_slot):
			slot.pressed.connect(clique_slot)
		slots.append(slot)


# Percorre a arvore da interface para localizar todos os botoes-slot.
func _coletar_slots_recursivamente(node: Node) -> Array:
	var encontrados := []
	for child in node.get_children():
		if child.has_method("configurar") and child.has_method("atualizar_visual"):
			encontrados.append(child)
		encontrados.append_array(_coletar_slots_recursivamente(child))
	return encontrados


# Atualiza a aparencia e o estado habilitado de todos os slots.
func _atualizar_slots() -> void:
	for slot in slots:
		slot.atualizar_visual()
		slot.atualizar_estado()
	if slot_selecionado != -1:
		_mostrar_item_do_slot(slot_selecionado)


func _on_slot_pressed(slot) -> void:
	slot_selecionado = slot.idSlot
	_mostrar_item_do_slot(slot.idSlot)


func _mostrar_item_do_slot(id_slot: int) -> void:
	if inventario_ref == null:
		_limpar_painel_especificacoes()
		return

	var item := inventario_ref.get_item_no_slot(id_slot)
	if item.is_empty():
		_limpar_painel_especificacoes()
		return

	var dados_item := inventario_ref.buscar_info_item(str(item.get("nome", "")))
	if dados_item == null:
		_limpar_painel_especificacoes()
		return

	var raridade := int(item.get("raridade", ItensData.Raridade.COMUM))
	label_titulo.text = dados_item.nome
	label_tipo.text = "Tipo: " + _tipo_item_para_texto(dados_item.tipo)
	label_raridade.text = "Raridade: " + ItensData.raridade_para_string(raridade).capitalize()

	if dados_item.tipo == ItensData.TipoItem.EQUIPAVEL:
		_mostrar_buffs_equipaveis(dados_item, raridade)
	else:
		_mostrar_sem_buffs()


func _limpar_painel_especificacoes() -> void:
	label_titulo.text = "Selecione um item"
	label_tipo.text = "Tipo: -"
	label_raridade.text = "Raridade: -"
	if label_descricao != null:
		label_descricao.text = ""
	_mostrar_sem_buffs()


func _mostrar_buffs_equipaveis(dados_item: ItensData, raridade: int) -> void:
	var buffs := {}
	if dados_item.buffs_por_raridade.has(raridade):
		buffs = dados_item.buffs_por_raridade[raridade]

	label_forca.text = "Forca: " + _formatar_buff_percentual(float(buffs.get("forca", 0.0)))
	label_defesa.text = "Defesa: " + _formatar_buff_percentual(float(buffs.get("defesa", 0.0)))
	label_inteligencia.text = "Inteligência: " + _formatar_buff_percentual(float(buffs.get("inteligencia", 0.0)))
	label_vitalidade.text = "Vitalidade: " + _formatar_buff_percentual(float(buffs.get("vitalidade", 0.0)))


func _mostrar_sem_buffs() -> void:
	label_forca.text = "Forca: -"
	label_defesa.text = "Defesa: -"
	label_inteligencia.text = "Inteligência: -"
	label_vitalidade.text = "Vitalidade: -"
	if label_buffs_extra != null:
		label_buffs_extra.text = ""


func _formatar_buff_percentual(valor: float) -> String:
	var porcentagem := valor * 100.0
	var sinal := "+" if porcentagem >= 0.0 else ""
	if is_equal_approx(porcentagem, round(porcentagem)):
		return "%s%d%%" % [sinal, int(round(porcentagem))]
	return "%s%.1f%%" % [sinal, porcentagem]


func _formatar_buffs_extra(buffs: Dictionary) -> String:
	var chaves_padrao := ["forca", "defesa", "inteligencia", "vitalidade"]
	var linhas: PackedStringArray = []
	for chave in buffs.keys():
		if chave in chaves_padrao:
			continue
		var valor := float(buffs.get(chave, 0.0))
		if is_zero_approx(valor):
			continue
		linhas.append(_formatar_nome_buff(str(chave)) + ": " + _formatar_buff_percentual(valor))
	return "\n".join(linhas)


func _formatar_nome_buff(nome_buff: String) -> String:
	return nome_buff.replace("_", " ").capitalize()


func _tipo_item_para_texto(tipo_item: int) -> String:
	match tipo_item:
		ItensData.TipoItem.EXTENSOR:
			return "Extensor"
		ItensData.TipoItem.EQUIPAVEL:
			return "Equipavel"
		_:
			return "Inventario"


func obter_titulo_item_selecionado() -> String:
	return label_titulo.text


func quantidade_itens_equipados() -> int:
	if inventario_ref == null:
		return 0

	var quantidade := 0
	for id_slot in Inventario.SLOTS_EQUIPAVEIS:
		if not inventario_ref.get_item_no_slot(id_slot).is_empty():
			quantidade += 1

	return quantidade


# Fecha o menu quando o botao de fechar for pressionado.
func _on_botao_fechar_pressed() -> void:
	visible = false
