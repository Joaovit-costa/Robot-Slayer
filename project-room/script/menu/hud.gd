extends CanvasLayer
class_name Hud

@onready var barraVida: ProgressBar = $ProgressBar
@onready var barra_de_cura: ProgressBar = $barraDeCura
@onready var label_nivel: Label = $labelNivel
@onready var barra_de_experiencia: ProgressBar = $barraDeExperiencia
@onready var label_moeda: Label = $containerMoedas/labelMoeda
@onready var container_moedas: HBoxContainer = $containerMoedas
@onready var panel: Panel = $Panel
@onready var grid_container: GridContainer = $GridContainer


func _ready() -> void:
	barraVida.z_index = 1940
	barra_de_cura.z_index = 1940
	label_nivel.z_index = 1940
	barra_de_experiencia.z_index = 1940
	label_moeda.z_index = 1940
	container_moedas.z_index = 1940
	panel.z_index = 1940
	grid_container.z_index = 1940
	add_to_group("hud")
