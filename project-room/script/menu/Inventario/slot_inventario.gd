extends TextureButton

# Referencias visuais do slot para clique, borda e icone.
@onready var rect: Panel = $pressed
@onready var borda: Panel = $Panel
@onready var icon: TextureRect = $TextureRect

# Dados fixos do slot definidos na cena e referencia ao inventario real.
@export var idSlot: int
@export var tipo: String

var inventario_ref: Inventario


# Recebe a instancia central do inventario criada pelo menu.
func configurar(novo_inventario: Inventario) -> void:
	inventario_ref = novo_inventario


# Mostra o destaque visual enquanto o botao esta pressionado.
func _on_button_down() -> void:
	rect.visible = true


# Remove o destaque visual ao soltar o botao.
func _on_button_up() -> void:
	rect.visible = false


# Esconde a borda padrao no hover para reforcar a selecao.
func _on_mouse_entered() -> void:
	borda.visible = false


# Restaura a borda quando o mouse sai do slot.
func _on_mouse_exited() -> void:
	borda.visible = true


# Inicia o drag retornando o slot de origem como dado principal.
func _get_drag_data(_at_position: Vector2) -> Variant:
	if inventario_ref == null:
		return

	var item := inventario_ref.get_item_no_slot(idSlot)
	if item.is_empty():
		return

	rect.visible = false

	var preview := TextureRect.new()
	preview.texture = icon.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.size = icon.size
	preview.modulate.a = 0.5

	var container := Control.new()
	container.add_child(preview)
	preview.position = -preview.size / 2

	set_drag_preview(container)
	icon.hide()

	return {
		"slot_origem": idSlot
	}


# Valida se o item arrastado pode ser solto neste slot.
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if inventario_ref == null or typeof(data) != TYPE_DICTIONARY:
		return false

	var slot_origem := int(data.get("slot_origem", -1))
	if slot_origem == -1:
		return false

	var item_origem := inventario_ref.get_item_no_slot(slot_origem)
	if item_origem.is_empty():
		return false

	return (
		inventario_ref.slot_esta_habilitado(idSlot)
		and inventario_ref.item_pode_ir_para_slot(str(item_origem.get("tipo", "")), idSlot)
	)


# Executa a movimentacao real do item dentro da lista do inventario.
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if inventario_ref == null:
		return

	var slot_origem := int(data.get("slot_origem", -1))
	if slot_origem == -1:
		return

	inventario_ref.mover_item(slot_origem, idSlot)


# Desenha o icone correto no slot com base no item salvo naquele id.
func atualizar_visual() -> void:
	if inventario_ref == null:
		icon.texture = null
		icon.show()
		return

	var item := inventario_ref.get_item_no_slot(idSlot)
	if item.is_empty():
		icon.texture = null
		icon.show()
		return

	var dados_item := inventario_ref.buscar_info_item(str(item.get("nome", "")))
	icon.texture = dados_item.icone if dados_item != null else null
	icon.show()


# Habilita ou desabilita o slot conforme a regra dos extensores.
func atualizar_estado() -> void:
	if inventario_ref == null:
		disabled = false
		return
	disabled = not inventario_ref.slot_esta_habilitado(idSlot)
