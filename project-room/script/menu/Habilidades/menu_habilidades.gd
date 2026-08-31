extends Control

@onready var main: Node2D = $"../.."

@onready var icone_habilidade_hud: TextureRect = $"../../sala/Hud/GridContainer/TextureRect/Icone_habilidade_hud"
@onready var icone_habilidade_hud_2: TextureRect = $"../../sala/Hud/GridContainer/TextureRect2/Icone_habilidade_hud_2"
@onready var icone_habilidade_hud_3: TextureRect = $"../../sala/Hud/GridContainer/TextureRect3/Icone_habilidade_hud_3"
@onready var progress_bar: ProgressBar = $"../../sala/Hud/GridContainer/TextureRect/ProgressBar"
@onready var progress_bar1: ProgressBar = $"../../sala/Hud/GridContainer/TextureRect2/ProgressBar"
@onready var progress_bar2: ProgressBar = $"../../sala/Hud/GridContainer/TextureRect3/ProgressBar"
@onready var destalhes_habilidades: Descricao = $DestalhesHabilidades


@onready var slot_equipados: TextureRect = $Panel/HBoxContainer/Control/SlotEquipados
@onready var slot_equipados_2: TextureRect = $Panel/HBoxContainer/Control/SlotEquipados2
@onready var slot_equipados_3: TextureRect = $Panel/HBoxContainer/Control/SlotEquipados3

@onready var texture_button: TextureButton = $Panel/TextureButton

@onready var habilidades_declaradas = [
	$Panel/HBoxContainer/GridContainer/Slot_habilidade,
	$Panel/HBoxContainer/GridContainer/Slot_habilidade2,
	$Panel/HBoxContainer/GridContainer/Slot_habilidade3,
	$Panel/HBoxContainer/GridContainer/Slot_habilidade4,
	$Panel/HBoxContainer/GridContainer/Slot_habilidade5,
	$Panel/HBoxContainer/GridContainer/Slot_habilidade6
]


func _ready() -> void:
	add_to_group("gerenciador_habilidades")

	# Carrega as habilidades salvas.
	var save_manager = get_node("/root/SaveManager")

	if save_manager != null:
		save_manager.aplicar_no_gerenciador_habilidades(self)

	atualizar_hud()


func _process(_delta: float) -> void:
	processar_equipamentos()
	atualizar_hud()
	verificar_habilidades()

func verificar_habilidades():
	if main.habilidade1_desbloqueada:
		habilidades_declaradas[0].bloqueado.visible = false
	if main.habilidade2_desbloqueada:
		habilidades_declaradas[1].bloqueado.visible = false
	if main.habilidade3_desbloqueada:
		habilidades_declaradas[2].bloqueado.visible = false
	if main.habilidade4_desbloqueada:
		habilidades_declaradas[3].bloqueado.visible = false
	if main.habilidade5_desbloqueada:
		habilidades_declaradas[4].bloqueado.visible = false
	if main.habilidade6_desbloqueada:
		habilidades_declaradas[5].bloqueado.visible = false

func processar_equipamentos() -> void:
	for hab in habilidades_declaradas:
		var nome :String= hab.equipar.get("nome", "")

		if nome == "":
			continue

		# Já está equipada?
		if (
			nome == slot_equipados.Nome or
			nome == slot_equipados_2.Nome or
			nome == slot_equipados_3.Nome
		):
			hab.equipar = {
				"nome": "",
				"textura": null,
				"cooldown": 1
			}
			continue

		# Procura um slot vazio.
		if slot_equipados.Nome == "":
			slot_equipados.Nome = nome
			slot_equipados.Textura = hab.equipar.get("textura")
			slot_equipados.cooldown = float(hab.equipar.get("cooldown", 1.0))
			limpar_pedido_equipamento(hab)
			solicitar_save()
			continue

		if slot_equipados_2.Nome == "":
			slot_equipados_2.Nome = nome
			slot_equipados_2.Textura = hab.equipar.get("textura")
			slot_equipados_2.cooldown = float(hab.equipar.get("cooldown", 1.0))
			limpar_pedido_equipamento(hab)
			solicitar_save()
			continue

		if slot_equipados_3.Nome == "":
			slot_equipados_3.Nome = nome
			slot_equipados_3.Textura = hab.equipar.get("textura")
			slot_equipados_3.cooldown = float(hab.equipar.get("cooldown", 1.0))
			limpar_pedido_equipamento(hab)
			solicitar_save()
			continue


func limpar_pedido_equipamento(habilidade) -> void:
	habilidade.equipar = {
		"nome": "",
		"textura": null,
		"cooldown": 1
	}


func atualizar_hud() -> void:
	icone_habilidade_hud.texture = slot_equipados.Textura
	icone_habilidade_hud_2.texture = slot_equipados_2.Textura
	icone_habilidade_hud_3.texture = slot_equipados_3.Textura

	progress_bar.max_value = slot_equipados.cooldown
	progress_bar.value = slot_equipados.tempo_restante

	progress_bar1.max_value = slot_equipados_2.cooldown
	progress_bar1.value = slot_equipados_2.tempo_restante

	progress_bar2.max_value = slot_equipados_3.cooldown
	progress_bar2.value = slot_equipados_3.tempo_restante


func solicitar_save() -> void:
	var save_manager = get_node("/root/SaveManager")

	if save_manager != null:
		save_manager.solicitar_salvamento()


func get_habilidades_equipadas() -> Array:
	return [
		{
			"nome": slot_equipados.Nome,
			"textura": _caminho_textura(slot_equipados.Textura),
			"cooldown": slot_equipados.cooldown,
			"tempo_restante": slot_equipados.tempo_restante
		},
		{
			"nome": slot_equipados_2.Nome,
			"textura": _caminho_textura(slot_equipados_2.Textura),
			"cooldown": slot_equipados_2.cooldown,
			"tempo_restante": slot_equipados_2.tempo_restante
		},
		{
			"nome": slot_equipados_3.Nome,
			"textura": _caminho_textura(slot_equipados_3.Textura),
			"cooldown": slot_equipados_3.cooldown,
			"tempo_restante": slot_equipados_3.tempo_restante
		}
	]


func _caminho_textura(textura: Texture2D) -> String:
	if textura == null:
		return ""

	return textura.resource_path


func carregar_habilidades_equipadas(habilidades: Array) -> void:
	var slots := [
		slot_equipados,
		slot_equipados_2,
		slot_equipados_3
	]

	for i in range(min(habilidades.size(), slots.size())):
		var habilidade = habilidades[i]

		if typeof(habilidade) != TYPE_DICTIONARY:
			continue

		var nome := str(habilidade.get("nome", ""))
		var caminho_textura := str(habilidade.get("textura", ""))
		var cooldown := float(habilidade.get("cooldown", 1.0))
		var tempo_restante := float(habilidade.get("tempo_restante", 0.0))

		slots[i].Nome = nome
		slots[i].cooldown = cooldown
		slots[i].tempo_restante = tempo_restante

		if caminho_textura != "":
			slots[i].Textura = load(caminho_textura) as Texture2D
		else:
			slots[i].Textura = null

	atualizar_hud()


func _on_texture_button_pressed() -> void:
	main._fechar_menus()

func usar_habilidade(slot: TextureRect) -> void:
	if slot.Nome == "":
		return

	if not slot.esta_disponivel():
		return

	# Executa a habilidade aqui.

	slot.iniciar_cooldown()
