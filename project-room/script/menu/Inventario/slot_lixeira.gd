extends TextureRect

var inventario_ref: Inventario


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = "Arraste um item aqui para descartá-lo"


func configurar(novo_inventario: Inventario) -> void:
	inventario_ref = novo_inventario


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if inventario_ref == null or typeof(data) != TYPE_DICTIONARY:
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
