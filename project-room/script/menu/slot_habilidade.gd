extends TextureRect

@export var Textura_habilidade: Texture2D
@export var Nome_habilidade: String
@export var Descrico_habilidade: String
@export var Missao_habilidade: String
@export var Tela_descricao: Descricao
@onready var icone_habilidade: TextureRect = $Icone_habilidade
var Textura_habilidade_clicada: Texture2D
var Nome_habilidade_clicada: String
var Descrico_habilidade_clicada: String
var Missao_habilidade_clicada: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_descricao_pressed() -> void:
	if Tela_descricao == null:
		return
	Textura_habilidade_clicada = Textura_habilidade
	Nome_habilidade_clicada = Nome_habilidade
	Descrico_habilidade_clicada = Descrico_habilidade
	Missao_habilidade_clicada = Missao_habilidade
	Tela_descricao.visible = true
