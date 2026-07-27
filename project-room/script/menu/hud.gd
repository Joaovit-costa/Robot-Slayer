extends CanvasLayer
class_name Hud

@onready var barraVida: ProgressBar = $ProgressBar
@onready var barra_de_cura: ProgressBar = $barraDeCura
@onready var label_nivel: Label = $labelNivel
@onready var barra_de_experiencia: ProgressBar = $barraDeExperiencia
@onready var label_moeda: Label = $containerMoedas/labelMoeda

func _ready() -> void:
	add_to_group("hud")
