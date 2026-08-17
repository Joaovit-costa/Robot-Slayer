extends TextureRect

@onready var texture_rect: TextureRect = $TextureRect

@onready var slot_habilidade_1: TextureRect = $"../../GridContainer/Slot_habilidade"
@onready var slot_habilidade_2: TextureRect = $"../../GridContainer/Slot_habilidade2"
@onready var slot_habilidade_3: TextureRect = $"../../GridContainer/Slot_habilidade3"
@onready var slot_habilidade_4: TextureRect = $"../../GridContainer/Slot_habilidade4"
@onready var slot_habilidade_5: TextureRect = $"../../GridContainer/Slot_habilidade5"
@onready var slot_habilidade_6: TextureRect = $"../../GridContainer/Slot_habilidade6"
@onready var label: Label = $Label

@export var Tela_descricao: Descricao
@export var Nome: String
@export var Textura: Texture2D
@export var tecla: String

var cooldown: float = 1.0
var tempo_restante: float = 0.0

@onready var habilidades_declaradas = [[slot_habilidade_1.Nome_habilidade, slot_habilidade_1.Descrico_habilidade, slot_habilidade_1.Missao_habilidade, slot_habilidade_1.Textura_habilidade],
									   [slot_habilidade_2.Nome_habilidade, slot_habilidade_2.Descrico_habilidade, slot_habilidade_2.Missao_habilidade, slot_habilidade_2.Textura_habilidade],
									   [slot_habilidade_3.Nome_habilidade, slot_habilidade_3.Descrico_habilidade, slot_habilidade_3.Missao_habilidade, slot_habilidade_3.Textura_habilidade],
									   [slot_habilidade_4.Nome_habilidade, slot_habilidade_4.Descrico_habilidade, slot_habilidade_4.Missao_habilidade, slot_habilidade_4.Textura_habilidade],
									   [slot_habilidade_5.Nome_habilidade, slot_habilidade_5.Descrico_habilidade, slot_habilidade_5.Missao_habilidade, slot_habilidade_5.Textura_habilidade],
									   [slot_habilidade_6.Nome_habilidade, slot_habilidade_6.Descrico_habilidade, slot_habilidade_6.Missao_habilidade, slot_habilidade_6.Textura_habilidade]]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = tecla


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Nome == "":
		texture_rect.texture = null
		tempo_restante = 0.0
		return

	texture_rect.texture = Textura

	if tempo_restante > 0.0:
		tempo_restante = max(tempo_restante - _delta, 0.0)

func _on_button_descricao_pressed() -> void:
	for hab in habilidades_declaradas:
		if hab[0] == Nome and hab[3] == Textura:
			Tela_descricao.Textura_habilidade_clicada = hab[3]
			Tela_descricao.Nome_habilidade_clicada = hab[0]
			Tela_descricao.Descrico_habilidade_clicada = hab[1]
			Tela_descricao.Missao_habilidade_clicada = hab[2]
			Tela_descricao.visible = true
			return

func iniciar_cooldown() -> void:
	tempo_restante = cooldown

func esta_disponivel() -> bool:
	return tempo_restante <= 0.0
