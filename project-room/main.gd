extends Node2D

@onready var menu_inventario: Control = get_node_or_null("CanvasLayer/InventoryMenu") as Control
@onready var menu_loja_cura: Control = get_node_or_null("CanvasLayer/LojaItens") as Control
@onready var menu_loja_arma: Control = get_node_or_null("CanvasLayer/LojaItens2") as Control
@onready var menu_status = get_node_or_null("CanvasLayer/MenuStatus") as Control
@onready var fundo_escuro: ColorRect = get_node_or_null("CanvasLayer/MeshInstance2D") as ColorRect
@onready var sala: Node2D = get_node_or_null("sala") as Node2D

const ACAO_INVENTARIO := &"ui_inventario"
const ACAO_STATUS := &"ui_status"
const ACAO_LOJA := &"ui_interagir"
const ACAO_PAUSE := &"ui_cancel"

const TIPO_LOJA_CURA := &"cura"
const TIPO_LOJA_ARMA := &"arma"

const CENA_MENU_PAUSE := preload("res://res/Cenas/menu/pause/menu_pause.tscn")
const CENA_MENU_PRINCIPAL := "res://MenuPrincipal.tscn"

var tecla_inventario_estava_pressionada := false
var tecla_loja_estava_pressionada := false
var tecla_pause_estava_pressionada := false

var menu_pause_instance: CanvasLayer = null


func _ready() -> void:
	_fechar_menus()
	_aplicar_estado_telas()


func _process(_delta: float) -> void:
	if _pause_foi_acionado():
		_alternar_pause()
		return

	if _pause_esta_aberto():
		return

	if _inventario_foi_acionado():
		_alternar_menu(menu_inventario)
	elif _loja_foi_acionada():
		_alternar_loja_disponivel()
	elif menu_status != null and _status_foi_acionado():
		_alternar_menu(menu_status)

	_aplicar_estado_telas()


func _alternar_pause() -> void:
	if _pause_esta_aberto():
		_fechar_pause()
	else:
		_abrir_pause()


func _abrir_pause() -> void:
	_fechar_menus()

	menu_pause_instance = CENA_MENU_PAUSE.instantiate()
	add_child(menu_pause_instance)

	if menu_pause_instance.has_signal("continuar_pressed"):
		menu_pause_instance.continuar_pressed.connect(_on_pause_continuar_pressed)

	if menu_pause_instance.has_signal("sair_pressed"):
		menu_pause_instance.sair_pressed.connect(_on_pause_sair_pressed)

	_aplicar_estado_telas()


func _fechar_pause() -> void:
	if menu_pause_instance != null:
		menu_pause_instance.queue_free()
		menu_pause_instance = null

	_aplicar_estado_telas()


func _pause_esta_aberto() -> bool:
	return menu_pause_instance != null


func _on_pause_continuar_pressed() -> void:
	_fechar_pause()


func _on_pause_sair_pressed() -> void:
	_fechar_pause()
	get_tree().change_scene_to_file(CENA_MENU_PRINCIPAL)


func _alternar_menu(menu: Control) -> void:
	if menu == null:
		return

	var deve_abrir := not menu.visible
	_fechar_menus()
	menu.visible = deve_abrir


func _fechar_menus() -> void:
	if menu_inventario != null:
		menu_inventario.visible = false
	if menu_loja_cura != null:
		menu_loja_cura.visible = false
	if menu_loja_arma != null:
		menu_loja_arma.visible = false
	if menu_status != null:
		menu_status.visible = false


func _aplicar_estado_telas() -> void:
	var inventario_aberto := menu_inventario != null and menu_inventario.visible
	var loja_cura_aberta := menu_loja_cura != null and menu_loja_cura.visible
	var loja_arma_aberta := menu_loja_arma != null and menu_loja_arma.visible
	var status_aberto: bool = menu_status != null and menu_status.visible
	var pause_aberto := _pause_esta_aberto()

	var menu_aberto := (
		inventario_aberto
		or loja_cura_aberta
		or loja_arma_aberta
		or status_aberto
		or pause_aberto
	)

	if sala != null:
		sala.process_mode = Node.PROCESS_MODE_DISABLED if menu_aberto else Node.PROCESS_MODE_INHERIT

	if fundo_escuro != null:
		fundo_escuro.visible = menu_aberto and not pause_aberto

	if menu_inventario != null:
		menu_inventario.process_mode = Node.PROCESS_MODE_INHERIT
	if menu_loja_cura != null:
		menu_loja_cura.process_mode = Node.PROCESS_MODE_INHERIT
	if menu_loja_arma != null:
		menu_loja_arma.process_mode = Node.PROCESS_MODE_INHERIT
	if menu_status != null:
		menu_status.process_mode = Node.PROCESS_MODE_INHERIT


func _alternar_loja_disponivel() -> void:
	var tipo_loja := _obter_tipo_loja_disponivel()

	if tipo_loja == TIPO_LOJA_CURA:
		_alternar_menu(menu_loja_cura)
	elif tipo_loja == TIPO_LOJA_ARMA:
		_alternar_menu(menu_loja_arma)


func _obter_tipo_loja_disponivel() -> StringName:
	if sala == null:
		return &""

	if not sala.has_method("obter_loja_disponivel"):
		return &""

	return sala.obter_loja_disponivel()


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


func _status_foi_acionado() -> bool:
	if InputMap.has_action(ACAO_STATUS):
		return Input.is_action_just_pressed(ACAO_STATUS)

	var pressionada_agora := Input.is_physical_key_pressed(KEY_TAB)
	var acabou_de_pressionar := pressionada_agora and not tecla_inventario_estava_pressionada
	tecla_inventario_estava_pressionada = pressionada_agora
	return acabou_de_pressionar


func _pause_foi_acionado() -> bool:
	if InputMap.has_action(ACAO_PAUSE):
		return Input.is_action_just_pressed(ACAO_PAUSE)

	var pressionada_agora := Input.is_physical_key_pressed(KEY_ESCAPE)
	var acabou_de_pressionar := pressionada_agora and not tecla_pause_estava_pressionada
	tecla_pause_estava_pressionada = pressionada_agora
	return acabou_de_pressionar
