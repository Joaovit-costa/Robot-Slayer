extends Control
class_name Descricao

@onready var icone_habilidade: TextureRect = $Panel/HBoxContainer/Control/TextureRect/Icone_habilidade
@onready var nome_habilidade: Label = $Panel/HBoxContainer/Control/Nome_habilidade
@onready var descricao: Label = $Panel/HBoxContainer/GridContainer/Descricao
@onready var missao: Label = $Panel/HBoxContainer/GridContainer/Missao

@onready var Textura_habilidade_clicada: Texture2D
@onready var Nome_habilidade_clicada: String
@onready var Descrico_habilidade_clicada: String
@onready var Missao_habilidade_clicada: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ( Textura_habilidade_clicada == null or
		 Nome_habilidade_clicada == null or 
		 Descrico_habilidade_clicada == null or 
		 Missao_habilidade_clicada == null ):
		self.visible = false
		return
	
	icone_habilidade.texture = Textura_habilidade_clicada
	nome_habilidade.text = Nome_habilidade_clicada
	descricao.text = Descrico_habilidade_clicada
	missao.text = Missao_habilidade_clicada


func _on_texture_button_pressed() -> void:
	self.visible = false
	Textura_habilidade_clicada = null
	Nome_habilidade_clicada = ""
	Descrico_habilidade_clicada = ""
	Missao_habilidade_clicada = ""
