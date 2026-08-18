extends TextureRect

@export var Textura_habilidade: Texture2D
@export var Nome_habilidade: String
@export var Descrico_habilidade: String
@export var Missao_habilidade: String
@export var Tela_descricao: Descricao
@export var cooldown: float

@onready var button_equipar: Button = $Button_equipar
@onready var button_desequipar: Button = $Button_desequipar
@onready var bloqueado: TextureRect = $Bloqueado
@onready var slots_equipados: Array = [$"../../Control/SlotEquipados",$"../../Control/SlotEquipados2",$"../../Control/SlotEquipados3"]

@onready var icone_habilidade: TextureRect = $Icone_habilidade

var equipar: Dictionary = {"nome": "",
						  "textura": null,
						  "cooldown": 1}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Textura_habilidade == null:
		return

	icone_habilidade.texture = Textura_habilidade
	var esta_equipada := false
	for slot in slots_equipados:
		if slot.Nome == Nome_habilidade:
			esta_equipada = true
			break
	
	if bloqueado.visible:
		button_equipar.visible = false
		button_desequipar.visible = false
	else:
		button_equipar.visible = not esta_equipada
		button_desequipar.visible = esta_equipada


func _on_button_descricao_pressed() -> void:
	if Tela_descricao == null:
		return
	Tela_descricao.Textura_habilidade_clicada = Textura_habilidade
	Tela_descricao.Nome_habilidade_clicada = Nome_habilidade
	Tela_descricao.Descrico_habilidade_clicada = Descrico_habilidade
	Tela_descricao.Missao_habilidade_clicada = Missao_habilidade
	Tela_descricao.visible = true


func _on_button_equipar_pressed() -> void:
	if slots_equipados[0].Nome == "" or slots_equipados[1].Nome == "" or slots_equipados[2].Nome == "":
		equipar = {"nome": Nome_habilidade,
				   "textura": Textura_habilidade,
				   "cooldown": cooldown}


func _on_button_desequipar_pressed() -> void:
	equipar = {
		"nome": "",
		"textura": null,
		"cooldown": 1
	}

	for slot in slots_equipados:
		if slot.Nome == Nome_habilidade:
			slot.Nome = ""
			slot.Textura = null

			var save_manager = get_node("/root/SaveManager")
			if save_manager != null:
				save_manager.solicitar_salvamento()

			break
