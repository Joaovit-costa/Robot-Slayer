extends TextureButton

# ============================================================
# REFERÊNCIAS VISUAIS
# ============================================================

@onready var rect: Panel = $pressed
@onready var borda: Panel = $Panel
@onready var icon: TextureRect = $TextureRect


# ============================================================
# DADOS DO SLOT
# ============================================================

@export var idSlot: int
@export var tipo: String

var inventario_ref: Inventario


# ============================================================
# CONFIGURAÇÃO
# ============================================================

func configurar(novo_inventario: Inventario) -> void:
	inventario_ref = novo_inventario
	atualizar_visual()
	atualizar_estado()


# ============================================================
# VISUAL DO BOTÃO
# ============================================================

func _on_button_down() -> void:
	rect.visible = true


func _on_button_up() -> void:
	rect.visible = false


func _on_mouse_entered() -> void:
	borda.visible = false


func _on_mouse_exited() -> void:
	borda.visible = true


# ============================================================
# DRAG AND DROP
# ============================================================

func _get_drag_data(_at_position: Vector2) -> Variant:
	if inventario_ref == null:
		return null

	var item := inventario_ref.get_item_no_slot(idSlot)

	if item.is_empty():
		return null

	if not inventario_ref.slot_esta_habilitado(idSlot):
		return null

	rect.visible = false

	# --------------------------------------------------------
	# PREVIEW DO DRAG
	# --------------------------------------------------------

	var preview := Control.new()

	# Define o tamanho do preview.
	preview.size = icon.size
	preview.custom_minimum_size = icon.size

	# Impede que o preview interaja com o mouse.
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var preview_icon := TextureRect.new()

	preview_icon.texture = icon.texture
	preview_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_icon.size = icon.size
	preview_icon.position = Vector2.ZERO

	preview_icon.modulate.a = 0.5
	preview_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE

	preview.add_child(preview_icon)

	# Faz o ponto central do preview ficar no cursor.
	preview.position = -preview.size / 2.0

	set_drag_preview(preview)

	# Deixa o ícone original translúcido.
	icon.modulate.a = 0.35

	return {
		"slot_origem": idSlot
	}


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if inventario_ref == null:
		return false

	if typeof(data) != TYPE_DICTIONARY:
		return false

	if not data.has("slot_origem"):
		return false

	var slot_origem := int(data["slot_origem"])

	# Não permite soltar no próprio slot.
	if slot_origem == idSlot:
		return false

	# Verifica se a origem ainda possui um item.
	var item_origem := inventario_ref.get_item_no_slot(slot_origem)

	if item_origem.is_empty():
		return false

	# Verifica se o destino está habilitado.
	if not inventario_ref.slot_esta_habilitado(idSlot):
		return false

	# Verifica se o tipo do item pode ocupar o destino.
	var tipo_item := str(item_origem.get("tipo", ""))

	if not inventario_ref.item_pode_ir_para_slot(tipo_item, idSlot):
		return false

	return true


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if inventario_ref == null:
		return

	if typeof(data) != TYPE_DICTIONARY:
		return

	if not data.has("slot_origem"):
		return

	var slot_origem := int(data["slot_origem"])

	if slot_origem == idSlot:
		return

	# Confere novamente se o item ainda existe.
	var item_origem := inventario_ref.get_item_no_slot(slot_origem)

	if item_origem.is_empty():
		return

	# Faz a movimentação real no inventário.
	inventario_ref.mover_item(slot_origem, idSlot)

	# Atualiza os slots.
	_atualizar_slots_apos_drag()


# ============================================================
# ATUALIZAÇÃO VISUAL
# ============================================================

func atualizar_visual() -> void:
	# Sempre começa com o ícone totalmente visível.
	icon.modulate.a = 1.0

	if inventario_ref == null:
		icon.texture = null
		icon.show()
		return

	var item := inventario_ref.get_item_no_slot(idSlot)

	if item.is_empty():
		icon.texture = null
		icon.show()
		return

	var nome_item := str(item.get("nome", ""))

	var dados_item := inventario_ref.buscar_info_item(nome_item)

	if dados_item != null:
		icon.texture = dados_item.icone
	else:
		icon.texture = null

	icon.show()


func atualizar_estado() -> void:
	if inventario_ref == null:
		disabled = false
		return

	disabled = not inventario_ref.slot_esta_habilitado(idSlot)


# ============================================================
# ATUALIZAÇÃO APÓS DRAG
# ============================================================

func _atualizar_slots_apos_drag() -> void:
	# Atualiza o slot atual.
	atualizar_visual()
	atualizar_estado()

	# Atualiza os outros slots do mesmo inventário.
	var parent := get_parent()

	if parent == null:
		return

	for filho in parent.get_children():
		if filho == self:
			continue

		if filho.has_method("atualizar_visual"):
			filho.atualizar_visual()

		if filho.has_method("atualizar_estado"):
			filho.atualizar_estado()
