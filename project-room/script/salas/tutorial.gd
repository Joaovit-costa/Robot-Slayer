class_name ControladorTutorial
extends Node2D

const ETAPA_MOVIMENTACAO := 0
const ETAPA_ATAQUE := 1
const ETAPA_ABRIR_INVENTARIO := 2
const ETAPA_ABRIR_STATUS := 3
const ETAPA_INTERFACE_VIDA := 4
const ETAPA_INTERFACE_ULTIMA := 8
const ETAPA_INVENTARIO_PRIMEIRA := 9
const ETAPA_INVENTARIO_FECHAR := 15
const ETAPA_STATUS_PRIMEIRA := 16
const ETAPA_STATUS_FECHAR := 18
const ETAPA_CONCLUIDA := 19

@onready var menu_compras: Control = $Menu_Compras
@onready var tutorial_geral: Array[Control] = []

var tutorial := ETAPA_MOVIMENTACAO


func _ready() -> void:
	add_to_group("controlador_tutorial")
	for indice in range(ETAPA_CONCLUIDA):
		var etapa := get_node_or_null("Tutorial_%d" % indice) as Control
		if etapa != null:
			tutorial_geral.append(etapa)
	_configurar_sobreposicoes_para_ignorar_mouse()
	_ocultar_todas_as_etapas()


func mostrar_etapa_atual() -> void:
	mostrar_etapa(tutorial)


func mostrar_etapa(etapa: int) -> void:
	if not tutorial_esta_ativo():
		_ocultar_todas_as_etapas()
		return

	for indice in range(tutorial_geral.size()):
		tutorial_geral[indice].visible = indice == etapa


func avancar_para(proxima_etapa: int) -> void:
	var etapa_anterior := tutorial
	tutorial = clampi(proxima_etapa, ETAPA_MOVIMENTACAO, ETAPA_CONCLUIDA)
	_ocultar_todas_as_etapas()
	if tutorial != etapa_anterior:
		SaveManager.solicitar_salvamento()


func avancar() -> void:
	avancar_para(tutorial + 1)


func tutorial_esta_ativo() -> bool:
	return tutorial >= ETAPA_MOVIMENTACAO and tutorial < ETAPA_CONCLUIDA


func tem_etapa_visivel() -> bool:
	for etapa in tutorial_geral:
		if etapa.visible:
			return true
	return false


func ocultar_etapas() -> void:
	_ocultar_todas_as_etapas()


func _ocultar_todas_as_etapas() -> void:
	for etapa in tutorial_geral:
		etapa.visible = false


func _configurar_sobreposicoes_para_ignorar_mouse() -> void:
	for etapa in tutorial_geral:
		etapa.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for controle in etapa.find_children("*", "Control", true, false):
			(controle as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
