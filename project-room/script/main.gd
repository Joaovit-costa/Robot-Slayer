extends Node2D

@onready var menu_inventario: Control = get_node_or_null("CanvasLayer/InventoryMenu") as Control
@onready var menu_loja: Control = get_node_or_null("CanvasLayer/LojaItens") as Control
@onready var fundo_escuro: ColorRect = get_node_or_null("CanvasLayer/MeshInstance2D") as ColorRect
@onready var sala: Node2D = get_node_or_null("sala") as Node2D

const ACAO_INVENTARIO := &"ui_inventario"
const ACAO_LOJA := &"ui_interagir"

var tecla_inventario_estava_pressionada := false
var tecla_loja_estava_pressionada := false


func _ready() -> void:
	_fechar_menus()
	_aplicar_estado_telas()


func _process(_delta: float) -> void:
	if _inventario_foi_acionado():
		_alternar_menu(menu_inventario)
	elif menu_loja != null and _loja_foi_acionada():
		_alternar_menu(menu_loja)

	_aplicar_estado_telas()


func _alternar_menu(menu: Control) -> void:
	if menu == null:
		return

	var deve_abrir := not menu.visible
	_fechar_menus()
	menu.visible = deve_abrir


func _fechar_menus() -> void:
	if menu_inventario != null:
		menu_inventario.visible = false
	if menu_loja != null:
		menu_loja.visible = false


func _aplicar_estado_telas() -> void:
	var inventario_aberto := menu_inventario != null and menu_inventario.visible
	var loja_aberta := menu_loja != null and menu_loja.visible
	var menu_aberto := inventario_aberto or loja_aberta

	if sala != null:
		sala.visible = not menu_aberto
		sala.process_mode = Node.PROCESS_MODE_DISABLED if menu_aberto else Node.PROCESS_MODE_INHERIT
	if fundo_escuro != null:
		fundo_escuro.visible = menu_aberto
	if menu_inventario != null:
		menu_inventario.process_mode = Node.PROCESS_MODE_INHERIT
	if menu_loja != null:
		menu_loja.process_mode = Node.PROCESS_MODE_INHERIT


func _inventario_foi_acionado() -> bool:
	if InputMap.has_action(ACAO_INVENTARIO):
		return Input.is_action_just_pressed(ACAO_INVENTARIO)

	var pressionada_agora := Input.is_physical_key_pressed(KEY_E)
	var acabou_de_pressionar := pressionada_agora and not tecla_inventario_estava_pressionada
	tecla_inventario_estava_pressionada = pressionada_agora
	return acabou_de_pressionar


func _loja_foi_acionada() -> bool:
	if InputMap.has_action(ACAO_LOJA):
		return Input.is_action_just_pressed(ACAO_LOJA)

	var pressionada_agora := Input.is_physical_key_pressed(KEY_F)
	var acabou_de_pressionar := pressionada_agora and not tecla_loja_estava_pressionada
	tecla_loja_estava_pressionada = pressionada_agora
	return acabou_de_pressionar
