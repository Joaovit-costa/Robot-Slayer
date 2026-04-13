extends TextureButton

# =========== Filhos ===========
@onready var rect: Panel= $pressed
@onready var borda: Panel= $Panel
@onready var icon: TextureRect = $TextureRect
# ==============================


# ============ DEPENDENCIAS ============
@export var idSlot: int
@export var tipo: String
@onready var inventario:= load("res://script/menu/Inventario/inventario.gd")
var podeBloquear := [25, 23, 24, 26]
var bloquear := [false, true, true, true]
# ======================================


# ============ QUANDO PRECIONAR ============
func _on_button_down() -> void:
	rect.visible = true
# ==========================================


# ============= QUANDO SOLTAR =============
func _on_button_up() -> void:
	rect.visible = false
# =========================================


# ============= QUANDO Entrar =============
func _on_mouse_entered() -> void:
	borda.visible = false
# =========================================


# ============== QUANDO Sair ==============
func _on_mouse_exited() -> void:
	borda.visible = true
# =========================================


# ============= MOSTRAR ICON AO ARRASTAR =============
func _get_drag_data(_at_position: Vector2) -> Variant:
	if icon.texture == null:
		return
	
	rect.visible = false
	
	var preview = TextureRect.new()
	preview.texture = icon.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.size = icon.size
	preview.modulate.a = 0.5
	
	var c = Control.new()
	c.add_child(preview)
	preview.position = -preview.size / 2
	
	set_drag_preview(c)
	icon.hide()
	
	return icon
# ====================================================


# ============== VER SE O ITEM PODE IR ==============
func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true

func _drop_data(_at_position: Vector2, _data: Variant) -> void:
	var antes = icon.texture
	icon.texture = _data.texture
	_data.texture = antes
	
	icon.show()
	_data.show()

	# Atualiza todos os slots
	for child in get_parent().get_children():
		if child is TextureButton:
			child.atualizar_estado()
# =================================

func atualizar_estado():
	disabled = !inventario.pode_usar_slot(idSlot)
# ====================================================
