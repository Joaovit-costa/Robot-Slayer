extends TextureRect

var inventario_ref: Inventario
var tutorial_ref: ControladorTutorial
var descarte_habilitado := true


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = "Arraste um item aqui para descartá-lo"
	call_deferred("_configurar_estado_do_tutorial")


func _configurar_estado_do_tutorial() -> void:
	tutorial_ref = get_tree().get_first_node_in_group(
		"controlador_tutorial"
	) as ControladorTutorial

	if tutorial_ref != null:
		var atualizar := _on_etapa_tutorial_alterada
		if not tutorial_ref.etapa_alterada.is_connected(atualizar):
			tutorial_ref.etapa_alterada.connect(atualizar)

	_atualizar_estado_da_lixeira()


func _on_etapa_tutorial_alterada(_nova_etapa: int) -> void:
	_atualizar_estado_da_lixeira()


func _atualizar_estado_da_lixeira() -> void:
	descarte_habilitado = (
		tutorial_ref == null
		or not tutorial_ref.tutorial_esta_ativo()
	)

	if descarte_habilitado:
		self_modulate = Color.WHITE
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tooltip_text = "Arraste um item aqui para descartá-lo"
	else:
		self_modulate = Color(0.45, 0.45, 0.45, 0.65)
		mouse_default_cursor_shape = Control.CURSOR_ARROW
		tooltip_text = "A lixeira fica disponível após o tutorial"


func configurar(novo_inventario: Inventario) -> void:
	inventario_ref = novo_inventario


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if (
		not descarte_habilitado
		or inventario_ref == null
		or typeof(data) != TYPE_DICTIONARY
	):
		return false
	if not data.has("slot_origem"):
		return false

	var slot_origem := int(data["slot_origem"])
	return not inventario_ref.get_item_no_slot(slot_origem).is_empty()


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if not _can_drop_data(Vector2.ZERO, data):
		return

	var slot_origem := int(data["slot_origem"])
	if inventario_ref.remover_item_do_slot(slot_origem):
		_animar_descarte()


func _animar_descarte() -> void:
	modulate = Color(1.5, 0.45, 0.45, 1.0)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.25)
