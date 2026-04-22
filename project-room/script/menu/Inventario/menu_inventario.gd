extends Control

# Cena usada como banco de itens cadastrados pelo inspetor.
const CENA_BANCO_ITENS = preload("res://res/Cenas/Data/itens.tscn")

# Estado do drag, referencia do inventario, banco e lista de slots visuais.
@onready var fundo_escuro: ColorRect = $FundoEscuro
@onready var painel_principal: Panel = $PainelPrincipal

var data_bk
var inventario_ref: Inventario
var banco_itens_ref: Itens
var slots: Array = []

# Inicializa o menu, cria dependencias e sincroniza os slots com a lista.
func _ready() -> void:
	_configurar_dependencias()
	_registrar_slots()
	_atualizar_slots()


# Corrige o cursor caso um drag invalido deixe o icone bloqueado.
func _process(_delta: float) -> void:
	if Input.get_current_cursor_shape() == CURSOR_FORBIDDEN:
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)


# Guarda os dados do drag atual e restaura o visual quando o drop falha.
func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_DRAG_BEGIN:
		data_bk = get_viewport().gui_get_drag_data()
	if what == Node.NOTIFICATION_DRAG_END:
		if not is_drag_successful() and typeof(data_bk) == TYPE_DICTIONARY:
			var slot_origem: TextureButton = _buscar_slot_por_id(int(data_bk.get("slot_origem", -1)))
			if slot_origem != null:
				slot_origem.atualizar_visual()
		data_bk = null


# Cria a instancia do inventario e a instancia do banco de itens deste menu.
func _configurar_dependencias() -> void:
	inventario_ref = Inventario.new()
	inventario_ref.name = "InventarioState"
	add_child(inventario_ref)

	var banco_instanciado = CENA_BANCO_ITENS.instantiate()
	banco_instanciado.name = "BancoDeItens"
	add_child(banco_instanciado)
	banco_itens_ref = banco_instanciado as Itens

	inventario_ref.configurar_banco_de_itens(banco_itens_ref)
	inventario_ref.inventario_atualizado.connect(_atualizar_slots)


# Encontra todos os slots da cena e injeta neles a referencia do inventario.
func _registrar_slots() -> void:
	slots.clear()
	for slot in _coletar_slots_recursivamente(self):
		slot.configurar(inventario_ref)
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


# Procura um slot pelo id para restaurar visual no fim do drag.
func _buscar_slot_por_id(id_slot: int) -> TextureButton:
	for slot in slots:
		if slot.idSlot == id_slot:
			return slot
	return null


# Fecha o menu quando o botao de fechar for pressionado.
func _on_botao_fechar_pressed() -> void:
	visible = false
