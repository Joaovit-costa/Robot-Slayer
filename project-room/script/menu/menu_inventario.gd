extends Control

# Lista de itens
const ListaItensScript = preload("res://script/menu/lista_itens.gd")
var itens = ListaItensScript.new()

# Arrays para guardar referências dos slots
var slots_extensores: Array = []
var slots_inventario: Array = []
var slots_equipamento: Array = []

# Estrutura de dados do inventário
var inventario = {
	"inventario": [],
	"equipado": [],
	"extensor": []
}


func _ready() -> void:
	pegar_slots()
	configurar_slots()
	conectar_sinais_slots()

	# Coloca os primeiros itens nos slots visuais do inventário
	for i in range(min(slots_inventario.size(), itens.itens.size())):
		var item = itens.itens[i]
		adicionar_item_inventario(item)

	# Garante sincronização final
	sincronizar_inventario_com_slots()


func adicionar_item_inventario(item: Dictionary) -> void:
	# Usa a quantidade de itens já existentes no inventário
	# para descobrir o próximo slot livre
	var indice = inventario["inventario"].size()

	if indice < slots_inventario.size():
		var colocou = slots_inventario[indice].definir_item(item)

		if colocou:
			sincronizar_inventario_com_slots()


func pegar_slots() -> void:
	# Pega os slots extensores
	for slot in $PainelPrincipal/Conteudo/PainelEsquerdo/SlotsExtensores.get_children():
		slots_extensores.append(slot)

	# Pega os slots normais do inventário
	for slot in $PainelPrincipal/Conteudo/PainelDireito/GradeInventario.get_children():
		slots_inventario.append(slot)

	# Pega os slots de equipamento
	for slot in $PainelPrincipal/Conteudo/PainelDireito/SlotsEquipamento.get_children():
		slots_equipamento.append(slot)

	print("Extensores:", slots_extensores.size())
	print("Inventário:", slots_inventario.size())
	print("Equipamento:", slots_equipamento.size())


func configurar_slots() -> void:
	# Configura os slots extensores
	for slot in slots_extensores:
		slot.tipo_slot = "extensor"
		slot.definir_bloqueio(false)

	# Configura os slots do inventário
	for slot in slots_inventario:
		slot.tipo_slot = "inventario"
		slot.definir_bloqueio(false)

	# Configura os slots de equipamento
	for slot in slots_equipamento:
		slot.tipo_slot = "equipamento"

	# Dois primeiros slots equipados começam desbloqueados
	if slots_equipamento.size() > 0:
		slots_equipamento[0].definir_bloqueio(false)

	if slots_equipamento.size() > 1:
		slots_equipamento[1].definir_bloqueio(false)

	# Restante começa bloqueado
	for i in range(2, slots_equipamento.size()):
		slots_equipamento[i].definir_bloqueio(true)


func conectar_sinais_slots() -> void:
	# Conecta slots do inventário
	for slot in slots_inventario:
		slot.item_movido.connect(_on_item_movido)

	# Conecta slots de equipamento
	for slot in slots_equipamento:
		slot.item_movido.connect(_on_item_movido)

	# Conecta slots extensores
	for slot in slots_extensores:
		slot.item_movido.connect(_on_item_movido)


func sincronizar_inventario_com_slots() -> void:
	# Limpa os dados atuais
	inventario["inventario"].clear()
	inventario["equipado"].clear()
	inventario["extensor"].clear()

	# Atualiza os dados dos slots normais
	for i in range(slots_inventario.size()):
		var item = slots_inventario[i].item_atual

		if item != null:
			item["id_slot"] = i
			inventario["inventario"].append(item)

	# Atualiza os dados dos slots equipados
	for i in range(slots_equipamento.size()):
		var item = slots_equipamento[i].item_atual

		if item != null:
			item["id_slot"] = i
			inventario["equipado"].append(item)

	# Atualiza os dados dos slots extensores
	for i in range(slots_extensores.size()):
		var item = slots_extensores[i].item_atual

		if item != null:
			item["id_slot"] = i
			inventario["extensor"].append(item)

	print("Inventário sincronizado:")
	print(inventario)


func _on_item_movido() -> void:
	# Sempre que um item for movido, sincroniza os dados
	sincronizar_inventario_com_slots()


func _on_botao_fechar_pressed() -> void:
	# Esconde o menu de inventário
	hide()
