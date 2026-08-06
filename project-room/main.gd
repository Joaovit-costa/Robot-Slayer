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

const TIPO_LOJA_CURA := &"cura"
const TIPO_LOJA_ARMA := &"arma"

var tecla_inventario_estava_pressionada := false
var tecla_loja_estava_pressionada := false
var tecla_status_estava_pressionada := false
var menu_pause_instance: CanvasLayer = null


func _ready() -> void:
	_fechar_menus()
	_aplicar_estado_telas()


func _process(_delta: float) -> void:
	if _pause_esta_aberto():
		return

	if _inventario_foi_acionado():
		_alternar_menu(menu_inventario)
	elif _loja_foi_acionada():
		_alternar_loja_disponivel()
	elif menu_status != null and _status_foi_acionado():
		_alternar_menu(menu_status)

	_aplicar_estado_telas()
	if sala.color_rect.visible:
		return
	var mudou_direcao = Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")
	if mudou_direcao and sala.tutorial.tutorial == 0:
		sala.tutorial.tutorial_0.visible = false
		sala.tutorial.tutorial = 1

	elif Input.is_action_just_pressed("ui_attack") and sala.tutorial.tutorial == 1 and sala.tutorial.tutorial_1.visible:
		sala.tutorial.tutorial = 2
		sala.tutorial.tutorial_1.visible = false

	elif sala.tutorial.tutorial == 2 and menu_inventario.visible and sala.tutorial.tutorial_2.visible:
		sala.tutorial.tutorial = 3
		sala.tutorial.tutorial_2.visible = false

	elif sala.tutorial.tutorial == 3 and menu_status.visible and sala.tutorial.tutorial_3.visible:
		sala.tutorial.tutorial = 4
		sala.tutorial.tutorial_3.visible = false

	elif Input.is_action_just_pressed("ui_attack") and sala.tutorial.tutorial >= 4:
		# Simplificado: se a tela X está visível, o tutorial com certeza é o X
		if sala.tutorial.tutorial == 4:
			sala.tutorial.tutorial = 5
			sala.tutorial.tutorial_4.visible = false
		elif sala.tutorial.tutorial == 5:
			sala.tutorial.tutorial = 6
			sala.tutorial.tutorial_5.visible = false
		elif sala.tutorial.tutorial == 6:
			sala.tutorial.tutorial = 7
			sala.tutorial.tutorial_6.visible = false
		elif sala.tutorial.tutorial == 7:
			sala.tutorial.tutorial = 8
			sala.tutorial.tutorial_7.visible = false
		elif sala.tutorial.tutorial == 8:
			sala.tutorial.tutorial = 9
			sala.tutorial.tutorial_8.visible = false
		
	for tutorial in sala.tutorial.tutorial_geral:
		if tutorial.visible and sala != null:
			sala.process_mode = Node.PROCESS_MODE_DISABLED

func _pause_esta_aberto() -> bool:
	return menu_pause_instance != null


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

	if menu_aberto:
		SoundManager.parar_passo()

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
	var acabou_de_pressionar := pressionada_agora and not tecla_status_estava_pressionada
	tecla_status_estava_pressionada = pressionada_agora
	return acabou_de_pressionar


func _alternar_loja_disponivel() -> void:
	if menu_loja_cura != null and menu_loja_cura.visible:
		menu_loja_cura.visible = false
		_aplicar_estado_telas()
		return

	if menu_loja_arma != null and menu_loja_arma.visible:
		menu_loja_arma.visible = false
		_aplicar_estado_telas()
		return

	var tipo_loja := _obter_tipo_loja_disponivel()

	if tipo_loja == TIPO_LOJA_CURA:
		_alternar_menu(menu_loja_cura)
	elif tipo_loja == TIPO_LOJA_ARMA:
		_alternar_menu(menu_loja_arma)	
