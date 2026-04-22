extends Node2D

# Referencias principais controladas pelo main.
@onready var menu_inventario: Control = $InventoryMenu
@onready var fundo_escuro: MeshInstance2D = $MeshInstance2D
@onready var sala: Node2D = $sala

const ACAO_INVENTARIO := &"ui_inventario"

var tecla_inventario_estava_pressionada := false


# Inicializa o fluxo deixando a sala ativa e o inventario fechado.
func _ready() -> void:
	menu_inventario.visible = false
	fundo_escuro.visible = false
	_aplicar_estado_telas()


# O main centraliza a troca entre tela da sala e tela do inventario.
func _process(_delta: float) -> void:
	if _inventario_foi_acionado():
		menu_inventario.visible = not menu_inventario.visible
		fundo_escuro.visible = not fundo_escuro.visible
		

	_aplicar_estado_telas()


# Alterna visibilidade e processamento para pausar a sala ao abrir o inventario.
func _aplicar_estado_telas() -> void:
	var inventario_aberto := menu_inventario.visible

	sala.visible = not inventario_aberto
	fundo_escuro.visible = inventario_aberto
	sala.process_mode = Node.PROCESS_MODE_DISABLED if inventario_aberto else Node.PROCESS_MODE_INHERIT

	menu_inventario.process_mode = Node.PROCESS_MODE_INHERIT


# Usa a action do projeto quando existir e cai para a tecla E como fallback.
func _inventario_foi_acionado() -> bool:
	if InputMap.has_action(ACAO_INVENTARIO):
		return Input.is_action_just_pressed(ACAO_INVENTARIO)

	var pressionada_agora := Input.is_physical_key_pressed(KEY_E)
	var acabou_de_pressionar := pressionada_agora and not tecla_inventario_estava_pressionada
	tecla_inventario_estava_pressionada = pressionada_agora
	return acabou_de_pressionar
