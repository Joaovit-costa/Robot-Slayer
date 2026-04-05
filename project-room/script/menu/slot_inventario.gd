extends Panel

# Sinal emitido quando um item é movido de slot
signal item_movido

# Guarda qual slot está atualmente em hover durante o drag
static var slot_hover_atual = null

# Tipo do slot: inventario, equipamento ou extensor
@export var tipo_slot: String = "inventario"

# Define se o slot começa bloqueado
@export var bloqueado: bool = false

# Guarda o item atual do slot
var item_atual = null

# Indica se este slot está sob o mouse durante um drag
var em_hover_drag: bool = false

# Indica se o item arrastado pode ser solto neste slot
var hover_valido: bool = false

# Referências visuais
@onready var icone_item = $FundoSlot/IconeItem
@onready var icone_cadeado = $FundoSlot/IconeCadeado


func _ready() -> void:
	# Atualiza o visual inicial do slot
	atualizar_visual()


func atualizar_visual() -> void:
	# Mostra ou esconde o cadeado
	icone_cadeado.visible = bloqueado

	# Se estiver bloqueado, esconde o item
	if bloqueado:
		icone_item.visible = false
		return

	# Se existe item no slot, tenta mostrar a imagem
	if item_atual != null:
		# Só tenta mostrar a imagem se a chave existir e não for nula
		if item_atual.has("imagem") and item_atual["imagem"] != null:
			icone_item.texture = item_atual["imagem"]
			icone_item.visible = true
		else:
			# Se não tiver imagem, não quebra, só esconde
			icone_item.visible = false
	else:
		icone_item.visible = false


func definir_item(item: Dictionary) -> bool:
	# Só coloca o item se o slot aceitar esse tipo
	if not pode_receber_item(item):
		return false

	item_atual = item
	atualizar_visual()
	return true


func limpar_slot() -> void:
	# Remove o item do slot
	item_atual = null
	atualizar_visual()


func definir_bloqueio(esta_bloqueado: bool) -> void:
	# Altera se o slot está bloqueado ou não
	bloqueado = esta_bloqueado
	atualizar_visual()


func pode_receber_item(item: Dictionary) -> bool:
	# Slot bloqueado não recebe nada
	if bloqueado:
		return false

	# Slot de inventário aceita qualquer item
	if tipo_slot == "inventario":
		return true

	# Slot de equipamento aceita apenas itens equipáveis
	if tipo_slot == "equipamento":
		return item["tipo"] == "equipavel"

	# Slot de extensor aceita apenas itens extensivos
	if tipo_slot == "extensor":
		return item["tipo"] == "extensivo"

	return false


func _get_drag_data(_at_position: Vector2):
	# Não permite arrastar se estiver bloqueado
	if bloqueado:
		return null

	# Não permite arrastar se estiver vazio
	if item_atual == null:
		return null

	# Se o item tiver imagem, usa a imagem como preview
	if item_atual.has("imagem") and item_atual["imagem"] != null:
		var preview = TextureRect.new()
		preview.texture = item_atual["imagem"]
		preview.custom_minimum_size = Vector2(48, 48)
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		preview.modulate = Color(1, 1, 1, 0.85)
		set_drag_preview(preview)
	else:
		# Se não tiver imagem, usa um preview de texto
		var preview_container = PanelContainer.new()
		var preview_label = Label.new()
		preview_label.text = item_atual["nome"]
		preview_container.add_child(preview_label)
		set_drag_preview(preview_container)

	# Retorna os dados do arraste
	return {
		"slot_origem": self,
		"item": item_atual
	}


func _can_drop_data(_at_position: Vector2, data) -> bool:
	# Valida se os dados recebidos são um dicionário
	if typeof(data) != TYPE_DICTIONARY:
		return false

	# Verifica se existe a chave "item"
	if not data.has("item"):
		return false

	var item = data["item"]

	# Verifica se o item pode entrar neste slot
	var pode = pode_receber_item(item)

	# Guarda hover atual
	if slot_hover_atual != null and slot_hover_atual != self:
		slot_hover_atual.em_hover_drag = false
		slot_hover_atual.hover_valido = false

	slot_hover_atual = self
	em_hover_drag = true
	hover_valido = pode

	return pode


func _drop_data(_at_position: Vector2, data) -> void:
	# Valida os dados
	if typeof(data) != TYPE_DICTIONARY:
		return

	if not data.has("slot_origem") or not data.has("item"):
		return

	var slot_origem = data["slot_origem"]
	var item_origem = data["item"]
	var item_destino = item_atual

	# Se soltou no mesmo slot, não faz nada
	if slot_origem == self:
		return

	# Se este slot não aceita o item da origem, cancela
	if not pode_receber_item(item_origem):
		return

	# Se houver item no destino, a origem precisa aceitar esse item para permitir troca
	if item_destino != null and not slot_origem.pode_receber_item(item_destino):
		return

	# Faz a troca ou movimentação
	slot_origem.item_atual = item_destino
	item_atual = item_origem

	# Atualiza os dois slots
	slot_origem.atualizar_visual()
	atualizar_visual()

	# Avisa que houve mudança no inventário
	slot_origem.item_movido.emit()
	item_movido.emit()
