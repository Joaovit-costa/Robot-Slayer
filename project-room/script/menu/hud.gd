extends CanvasLayer
class_name Hud

@onready var barraVida: ProgressBar = $ProgressBar
@onready var barra_de_cura: ProgressBar = $barraDeCura
@onready var label_nivel: Label = $labelNivel
@onready var barra_de_experiencia: ProgressBar = $barraDeExperiencia
@onready var label_moeda: Label = $containerMoedas/labelMoeda
@onready var container_moedas: HBoxContainer = $containerMoedas
@onready var lista_drops: VBoxContainer = $DropNotifications
@onready var panel: Panel = $Panel
@onready var grid_container: GridContainer = $GridContainer

const DURACAO_NOTIFICACAO_DROP := 5.0
const ALTURA_NOTIFICACAO_DROP := 52.0
const FONTE_DROP := preload("res://res/design/Font/PixelPurl.ttf")


func _ready() -> void:
	barraVida.z_index = 1940
	barra_de_cura.z_index = 1940
	label_nivel.z_index = 1940
	barra_de_experiencia.z_index = 1940
	label_moeda.z_index = 1940
	container_moedas.z_index = 1940
	lista_drops.z_index = 1940
	panel.z_index = 1940
	grid_container.z_index = 1940
	add_to_group("hud")


func mostrar_item_dropado(
	nome_item: String,
	quantidade: int,
	icone_item: Texture2D,
	raridade: int = ItensData.Raridade.COMUM
) -> void:
	if nome_item.strip_edges().is_empty() or quantidade <= 0:
		return

	var aviso := PanelContainer.new()
	aviso.custom_minimum_size = Vector2(270.0, ALTURA_NOTIFICACAO_DROP)
	aviso.clip_contents = true
	aviso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aviso.modulate.a = 0.0
	aviso.scale = Vector2(1.0, 0.0)
	var cor_raridade := _cor_raridade(raridade)
	aviso.add_theme_stylebox_override("panel", _criar_estilo_drop(cor_raridade))

	var margem := MarginContainer.new()
	margem.add_theme_constant_override("margin_left", 8)
	margem.add_theme_constant_override("margin_top", 5)
	margem.add_theme_constant_override("margin_right", 10)
	margem.add_theme_constant_override("margin_bottom", 5)
	margem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aviso.add_child(margem)

	var conteudo := HBoxContainer.new()
	conteudo.add_theme_constant_override("separation", 8)
	conteudo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margem.add_child(conteudo)

	var icone := TextureRect.new()
	icone.custom_minimum_size = Vector2(40.0, 40.0)
	icone.texture = icone_item
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	conteudo.add_child(icone)

	var texto := Label.new()
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texto.text = "%s  x%d" % [nome_item, quantidade]
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.add_theme_font_override("font", FONTE_DROP)
	texto.add_theme_font_size_override("font_size", 20)
	texto.add_theme_color_override("font_color", cor_raridade)
	texto.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	texto.add_theme_constant_override("shadow_offset_x", 2)
	texto.add_theme_constant_override("shadow_offset_y", 2)
	texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	conteudo.add_child(texto)

	lista_drops.add_child(aviso)
	_animar_notificacao_drop(aviso)


func _animar_notificacao_drop(aviso: Control) -> void:
	await get_tree().process_frame
	if not is_instance_valid(aviso):
		return

	# O pivo no topo faz a entrada crescer para baixo e a saida recolher
	# a borda inferior em direcao ao topo.
	aviso.pivot_offset = Vector2(aviso.size.x * 0.5, 0.0)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(aviso, "scale:y", 1.0, 0.2)
	tween.parallel().tween_property(aviso, "modulate:a", 1.0, 0.12)
	tween.tween_interval(DURACAO_NOTIFICACAO_DROP)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(aviso, "scale:y", 0.0, 0.25)
	tween.parallel().tween_property(aviso, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func(): aviso.queue_free())


func _cor_raridade(raridade: int) -> Color:
	match raridade:
		ItensData.Raridade.INCOMUM:
			return Color(0.32, 0.9, 0.38)
		ItensData.Raridade.RARO:
			return Color(0.3, 0.78, 1.0)
		ItensData.Raridade.EPICO:
			return Color(0.72, 0.38, 1.0)
		ItensData.Raridade.LENDARIO:
			return Color(1.0, 0.68, 0.16)
		_:
			return Color(0.68, 0.7, 0.74)


func _criar_estilo_drop(cor_raridade: Color) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.015, 0.025, 0.09, 0.92)
	estilo.border_color = Color(cor_raridade, 0.9)
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(6)
	return estilo
