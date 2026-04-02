extends Panel

# Guarda qual slot está atualmente com hover de drag
# Isso evita que vários slots fiquem destacados ao mesmo tempo
static var slot_hover_atual = null

# Tipo do slot: inventario, chip ou equipamento
@export var tipo_slot: String = "inventario"

# Define se o slot começa bloqueado
@export var bloqueado: bool = false

# Guarda o item atual do slot
var item_atual: Item = null

# Indica se este slot está atualmente sob o mouse durante um drag
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
	# Mostra ou esconde o cadeado dependendo do estado do slot
	icone_cadeado.visible = bloqueado

	# Se o slot estiver bloqueado, não mostra item
	if bloqueado:
		icone_item.visible = false
	else:
		# Se houver item, mostra o ícone
		if item_atual != null:
			icone_item.texture = item_atual.icone
			icone_item.visible = true
		else:
			icone_item.visible = false

	# Reaplica o estilo visual correto
	atualizar_estilo()


func definir_item(item: Item) -> bool:
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


func pode_receber_item(item: Item) -> bool:
	# Slot bloqueado não recebe nada
	if bloqueado:
		return false

	# Slot de inventário aceita qualquer item
	if tipo_slot == "inventario":
		return true

	# Slot de chip aceita apenas itens do tipo chip
	if tipo_slot == "chip":
		return item.tipo == "chip"

	# Slot de equipamento aceita apenas itens do tipo equipamento
	if tipo_slot == "equipamento":
		return item.tipo == "equipamento"

	return false


func aplicar_estilo_slot(cor_fundo: Color, cor_borda: Color, espessura: int = 2) -> void:
	# Cria um novo estilo visual para o slot
	var estilo = StyleBoxFlat.new()

	# Cor de fundo
	estilo.bg_color = cor_fundo

	# Cor e espessura da borda
	estilo.border_color = cor_borda
	estilo.set_border_width_all(espessura)

	# Cantos arredondados
	estilo.set_corner_radius_all(12)

	# Aplica o estilo ao painel
	add_theme_stylebox_override("panel", estilo)


func atualizar_estilo() -> void:
	# Se o slot estiver bloqueado, usa visual escuro
	if bloqueado:
		aplicar_estilo_slot(Color("#14261F"), Color("#E4F5DF"), 2)
		return

	# Se não estiver em hover de drag, usa o visual normal
	if not em_hover_drag:
		aplicar_estilo_slot(Color("#2C4B3A"), Color("#E4F5DF"), 2)
		return

# Se estiver em hover e for válido, usa verde
	if hover_valido:
		aplicar_estilo_slot(Color("#3E6B45"), Color("#7CFF7A"), 2)
	else:
		# Se estiver em hover e for inválido, usa vermelho
		aplicar_estilo_slot(Color("#4A2A2A"), Color("#FF5C5C"), 2)

	# Se estiver em hover e for válido, usa verde
	if hover_valido:
		aplicar_estilo_slot(Color("#3E6B45"), Color("#7CFF7A"), 4)
	else:
		# Se estiver em hover e for inválido, usa vermelho
		aplicar_estilo_slot(Color("#4A2A2A"), Color("#FF5C5C"), 4)


func limpar_hover_global() -> void:
	# Se existir algum slot marcado como hover atual, limpa ele
	if slot_hover_atual != null:
		slot_hover_atual.em_hover_drag = false
		slot_hover_atual.hover_valido = false
		slot_hover_atual.atualizar_estilo()
		slot_hover_atual = null


func _get_drag_data(at_position: Vector2):
	# Não permite arrastar se o slot estiver bloqueado
	if bloqueado:
		return null

	# Não permite arrastar se o slot estiver vazio
	if item_atual == null:
		return null

	# Cria a prévia visual do item sendo arrastado
	var preview = TextureRect.new()
	preview.texture = item_atual.icone
	preview.custom_minimum_size = Vector2(48, 48)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.modulate = Color(1, 1, 1, 0.85)

	# Define a prévia do drag
	set_drag_preview(preview)

	# Retorna os dados do arraste
	return {
		"slot_origem": self,
		"item": item_atual
	}


func _can_drop_data(at_position: Vector2, data) -> bool:
	# Valida se os dados recebidos são um dicionário
	if typeof(data) != TYPE_DICTIONARY:
		limpar_hover_global()
		return false

	# Verifica se existe a chave "item"
	if not data.has("item"):
		limpar_hover_global()
		return false

	var item = data["item"]

	# Verifica se o item pode entrar neste slot
	var pode = pode_receber_item(item)

	# Se havia outro slot em hover, limpa o anterior
	if slot_hover_atual != null and slot_hover_atual != self:
		slot_hover_atual.em_hover_drag = false
		slot_hover_atual.hover_valido = false
		slot_hover_atual.atualizar_estilo()

	# Marca este slot como o slot em hover atual
	slot_hover_atual = self
	em_hover_drag = true
	hover_valido = pode
	atualizar_estilo()

	# O retorno continua sendo true ou false normalmente
	return pode


func _drop_data(at_position: Vector2, data) -> void:
	# Limpa o hover ao soltar
	limpar_hover_global()

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

	# Se houver item no destino, a origem precisa aceitar ele para permitir a troca
	if item_destino != null and not slot_origem.pode_receber_item(item_destino):
		return

	# Faz a troca ou movimentação
	slot_origem.item_atual = item_destino
	item_atual = item_origem

	# Atualiza os dois slots
	slot_origem.atualizar_visual()
	atualizar_visual()


func _notification(what: int) -> void:
	# Quando o drag termina, limpa qualquer destaque que tenha sobrado
	if what == NOTIFICATION_DRAG_END:
		limpar_hover_global()
